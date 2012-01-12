---

layout: post
published: false
tags: rspec rails

---

Today I ran into a little problem at a project. I have a view that is loaded into a popup using
a Ajax call. Because it is an Ajax call the response type should be javascript (why is that?).

I wrote the following spec:

~~~ ruby
it "should render the js template when :format => js" do
  get :index, :format => 'js'
  response.should render_template 'index.js'
end
~~~

This was my initial guess, which did not work. Leaving off the '.js' in the render_template test
would work, but this would work without the :format in the get request as well.

Searching Google did not result in a quick answer on how to test this, so we left it at that and
went on implementing the layout and stuff.

Tonight I intend to find a way to test this case correctly.

RSpecs render_template method delegates to the ActiveSupport::TestCase::Assertion's assert_template
method:

~~~ ruby
# @api private
def matches?(*)
  match_unless_raises ActiveSupport::TestCase::Assertion do
    @scope.assert_template expected, @message
  end
end
~~~

This method is implemented as follows:

~~~ ruby
def assert_template(options = {}, message = nil)
  ...

  case options
  when NilClass, String, Symbol
    options = options.to_s if Symbol === options
    rendered = @templates
    msg = build_message(message,
            "expecting <?> but rendering with <?>",
            options, rendered.keys.join(', '))
    assert_block(msg) do
      if options
        rendered.any? { |t,num| t.match(options) }
      else
        @templates.blank?
      end
    end
  ...
end
~~~

The magic is in the rendered.any? line. It matches each of the options against the rendered.
If we put :format => 'js' in the options of our render_template call, it is checked against the
rendered in assert_template, small test to check the assumption.

response.headers['Content-Type'].should == "text/html"

https://gist.github.com/917903

There is a guideline in TDD that you should test your code and not
other people's code. The behaviour you're interested in testing is
that of ActionController::Base, not of your code.

format = mock("format")
format.should_receive(:json).and_return("this text")
controller.should_receive(:respond_to).and_yield(format)
get 'path/to/file', :format => 'json'

http://nubyonbritishrails.blogspot.com/2010/05/rspec-controller-and-respondto-with-js.html
