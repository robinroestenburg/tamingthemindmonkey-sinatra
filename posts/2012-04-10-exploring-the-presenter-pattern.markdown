--- 
layout: post 
title: "Exploring the Presenter pattern"
author: Robin Roestenburg 
tags: ruby presenter
published_at: "2012-04-10" 
---

This weekend I have been getting familiar with the presenter pattern, a concept
introduced by Jay Fields. I practiced implementing a presenter on the codebase
of my blog application, this post will describe this process.

### Models containing view related code
This blog has a model `Post` that represent a post, like the one you are reading
now. For displaying the posts grouped by year and month (see main page) I
introduced a method on the `Post` model called `grouped_by_year_and_month`
(which does exactly what the method name implies). I use it as follows:

~~~ ruby
# models/post.rb
def grouped_by_year_and_month
  Hash[
    all_posts.
      group_by { |post| post.published_at.year }.
      collect do |year, posts_by_year|
        [ year, posts_by_year.group_by { |post| post.published_at.month } ]
      end]
end

# routes/main.rb
get '/' do
  @posts = Post.grouped_by_year_and_month
  haml :index
end

# views/index.haml
.post-list
  - if @posts.any?

    - @posts.each do |year, posts_by_year|
      %h2= year

      - posts_by_year.each do |month, posts|
        %h3= Date.new(year, month).strftime('%B')

          - posts.each do |post|
            = partial :post_list_row, :locals => { :post => post }
~~~

The method `Post.grouped_by_year_and_month` (a class method) is used by the
Sinatra route to retrieve a list of posts which is then rendered into a list of
posts grouped by years and month in the view. 

The only reason the `grouped_by_year_and_month` method exists on the `Post`
model is because it was the easiest place to put it at the time. It does not add
anything to the domain of a post and that's why I want to pull it out of the
model and store its logic into a presenter which will decorate the `Post` model
with grouping behavior.

### Moving to a presenter

A presenter is a class representation of the state of the view. It takes model
and user entered data and adds behavior to it, which can be tested very easily.
In the example, the model data is `Post.all_posts` and
`grouped_by_year_and_month` is the behavior that will be added to it.

Look at the snippet from `routes/main.rb` above, I would like to replace the
call to the `Post` model with a call to a presenter like this: 

~~~ ruby
# routes/main.rb
get '/' do
  @posts = PostsPresenter.new(Post.all_posts).grouped_by_year_and_month
  haml :index
end
~~~ 

I chose the name `PostsPresenter` because it presents a collection of posts in
this case. Not sure if it is the best name, it will have to do for now :-)

Creating the implementation is fairly straightforward. I wrote the following 
(simple) specs (no specs were present for this method on the model - shame on me!):

~~~ ruby
describe PostsPresenter do

  describe '#grouped_by_month_and_year' do

    let(:collection) do
      [OpenStruct.new(published_at: Time.new(2011, 1, 1)),
       OpenStruct.new(published_at: Time.new(2011, 1, 1)),
       OpenStruct.new(published_at: Time.new(2011, 6, 1)),
       OpenStruct.new(published_at: Time.new(2012, 8, 1))]
    end

    subject { PostsPresenter.new(collection).grouped_by_year_and_month }

    it 'groups items by year and month' do
      subject[2011][1].count.should == 2
      subject[2011][6].count.should == 1
      subject[2012][8].count.should == 1
    end

  end
end
~~~

The tests use a simple struct as an item of the collection. This is good enough,
because we only need the `published_at` attribute. I kind of like the idea of
using structs instead of stubs where possible. I will explore this idea in
another post.

The actual implementation is a copy of the method as it existed on the model,
where I have replaced the call to `all_posts` by the instance variable
`@collection`: 

~~~ ruby
class PostsPresenter

  def initialize(collection) 
    @collection = collection
  end

  def grouped_by_year_and_month
    Hash[
      @collection.
        group_by { |post| post.published_at.year }.
        collect do |year, posts_by_year|
          [ year, posts_by_year.group_by { |post| post.published_at.month } ]
        end]
  end
end
~~~~

You could reduce the coupling between the presenter and the kind of object
it presents by letting the `published_at` attribute be passed as a parameter or
something.

### Expanding the presenter

What other things could be presented by this `PostsPresenter`? Well, basically
every method that acts on the `Post` model for the view. Examples:

* We could add a method `latest` which would return the latest posts. This is
  also a view related method, because how much posts should be displayed is a
  view related matter. 
* Grouping posts by tags or title. This is basically the same idea as grouping
  by year/month. 

Tomorrow I want to look at using the Strategy pattern to provide different
grouping behavior to our `PostsPresenter`. In [this
post](http://blog.steveklabnik.com/posts/2011-09-06-the-secret-to-rails-oo-design),
Steve Klabnik, gives an example of a `Dictionary` presenter using policys
(strategies) which I want to try out.

### Further reading

Jay Fields wrote a set of blog posts about the presenter concept in 2006 and
2007 which are good reads:

* [Rails Model View Controller + Presenter?](http://blog.jayfields.com/2006/09/rails-model-view-controller-presenter.html) 
* [Another Rails presenter example](http://blog.jayfields.com/2007/01/another-rails-presenter-example.html)
* [Rails: Presenters - An additional layer alternative](http://blog.jayfields.com/2007/02/rails-presenters-additional-layer.html)
* [Rails: Presenter Pattern](http://blog.jayfields.com/2007/03/rails-presenter-pattern.html)
* [Rails: Rise and Fall and Potential Rebirth of the Presenter Pattern](http://blog.jayfields.com/2007/10/rails-rise-fall-and-potential-rebirth.html)

Also, Steve Klabnik wrote two excellent posts on this subject: 

* [The Secret to Rails OO Design](http://blog.steveklabnik.com/posts/2011-09-06-the-secret-to-rails-oo-design)
* [Better Ruby Presenters](http://blog.steveklabnik.com/posts/2011-09-09-better-ruby-presenters) 

