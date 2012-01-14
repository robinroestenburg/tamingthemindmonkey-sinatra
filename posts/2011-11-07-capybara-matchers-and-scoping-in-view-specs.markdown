---
layout: post
title: "Capybara matchers and scoping in view specs"
tags: capybara mychain
---

Last week I ran into a problem with Capybara when using it in view specs. I wanted to write a view spec which tests if a form and its elements are available. Using Webrat this could be written like this:

~~~ ruby
require 'spec_helper'

describe "posts/new.html.erb" do

  let(:post) { mock_model("Post").as_null_object.as_new_record }

  before do
    assign(:post, post)
  end

  it "renders the form to create a post" do
    rendered.should have_selector("form", :method =&> "post", :action =&> messages_path ) do |form|
      form.should have_selector("input", :type =&> "submit")
    end
  end
end
~~~

As I am using Capybara to drive my Cucumber features I wanted to write the same test using Capybara. This proved a bit more difficult though.

Capybara's `have_selector` matcher does not allow the passing of a block. After searching around a bit, I found the [following issue](https://github.com/jnicklas/capybara/issues/384) on Capybara's project page on Github.

In one of the comments, the following solution is proposed:

~~~ ruby
rendered.find('form').tap do |form|
  form.should have_selector("input[type=submit][value='Save']")
end
~~~


This does not work in a view or helper spec, because Capybara's matchers and finders are not available there. Running the spec results in the following error:

~~~ text
NoMethodError:
   undefined method `find' for #&lt;String:0x007fb82e6b0c90&>
~~~


### Enhancing rendered
When working with a view spec you render the view using the `render` method. This method renders the view and stores the output in `@rendered`, which can be retrieved using the `rendered` method and contains the html output of the view.

There is a way to enhance the string with the Capybara matchers and finders using the `Capybara.string()`-method. This will wrap the string in a `Capybara::Simple::New` class which will have access to all matchers and finders.

Rewriting the code as follows will make it work:

~~~ ruby
it "renders the form to create a post" do
  render
  Capybara.string(rendered).find('form').tap do |form|
    form.should have_selector("input[type=submit][value='Save']")
  end
end
~~~


It works, but it's a bit ugly to call Capybara.string in every spec.

### David Chelimsky to the rescue!
Googling my way around for a better way I found a [recent thread](http://old.nabble.com/Rails-view-spec-expectations-matchers-to32630767.html#a32631449) from the rspec-users mailing list. In it, David Chelimsky (creator of RSpec) presents a nice solution to my problem.

He suggests creating a helper method for the view specs which overwrites the 'rendered' method. The rendered method will replace the existing rendered method with the following:

~~~ ruby
def rendered
  # Using @rendered variable, which is set by the render-method.
  Capybara.string(@rendered)
end
~~~

This method is to be added to a new module which is loaded in the **spec_helper.rb** for the view specs. Now we can get rid of the `Capybara.string` stuff and just use `rendered` in our view specs.

~~~ ruby
it "renders the form to create a post" do
  render
  rendered.find('form').tap do |form|
    form.should have_selector("input[type=submit][value='Save']")
  end
end
~~~

Very nice :)

### There's more!
In the same thread he also describes a way of using Capybara's `within`-method, which is also not available in view and helper specs. The method makes it possible to scope certains matchers/finders to within a specific area of the page, for example a form.

Adding the following method to the same module as we've added the new `rendered`-method will allow you to use the `within`-method in you view specs:

~~~ ruby
def within(selector)
  yield rendered.find(selector)
end
~~~

It will perform a search for the selector passed and yields the result to a block. Now I'm able to write the following code:

~~~ ruby
require 'spec_helper'

  describe "posts/new.html.erb" do

    let(:post) { mock_model("Post").as_null_object.as_new_record }

    before do
      assign(:post, post)
    end

    it "renders the form to create a post" do
      render
      within 'form' do |form|
        rendered.should have_button("Save")
      end
    end
  end
~~~
