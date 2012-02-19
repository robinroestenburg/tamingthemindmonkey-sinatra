---
layout: post
title: "Ruby: Grouping to two-dimensional Hash"
tags: ruby tips
author: Robin Roestenburg
published_at: "2012-02-18"
---
On the fontpage of this blog I wanted to show a list of posts grouped by year and month, similar to
the post list for a year (see [here](/2011)). I would have reused the code that was used there,
except it selects all posts for a particular year and groups them by month.

I could have taken the easy way out and do something like this:

~~~ ruby
posts = []
[2012, 2011].each do |year|
  posts[year] = Post.find_by_year(year)
end
~~~

But I wanted to investigate how it could be done in a more Ruby-esque way and started messing around
in IRB with the following datastructure:

~~~ text
>> Post = Struct.new(:year, :month, :filename)
=> Post

>> posts = [Post.new(2011,1,'Foo'), Post.new(2011,1, 'Bar'), Post.new(2011,2,'Baz'), Post.new(2012,1,'Quux')]
=> [#<struct Post year=2011, month=1, filename="Foo">,
    #<struct Post year=2011, month=1, filename="Bar">,
    #<struct Post year=2011, month=2, filename="Baz">,
    #<struct Post year=2012, month=1, filename="Quux">]

~~~

### Grouping on two attributes
So the first thing I tried was a `group_by` on two attributes at once:

~~~ text
>> posts.group_by { |post| [post.year, post.month] }
=> {[2011, 1]=>[#<struct Post year=2011, month=1, content="Foo">,
                #<struct Post year=2011, month=1, content="Quux">],
    [2011, 2]=>[#<struct Post year=2011, month=2, content="Bar">],
    [2012, 2]=>[#<struct Post year=2012, month=2, content="Baz">]}
~~~

This was not exactly the result I wanted, as I could not do something like `posts[2011][1]` and
retrieve the posts for January 2011.

### Group combined with collect
I realized that I first had to group by year and then do *something* with the posts for each year.
A `collect` on the each result of the `group_by` should work. From Ruby's documentation: *Invokes
the block once for each element of self, replacing the element with the value returned by block.*

~~~ text
>> posts.group_by { |post| post.year }.collect { |grouped| grouped[1].group_by { |post| post.month } }
=> [{1=>[#<struct Post year=2011, month=1, content="Foo">,
         #<struct Post year=2011, month=1, content="Quux">],
     2=>[#<struct Post year=2011, month=2, content="Bar">]},
    {2=>[#<struct Post year=2012, month=2, content="Baz">]}]
~~~

Almost there... It loses the keys to retrieve the years again a hash. There is no way to tell (other
than examining the posts) to which year the hashes belong. Also, the outer element (containing the
grouped hash of posts) is an array, which is not what I want.

#### Adding the years

~~~ text
>> [[1,'Foo'],[2, 'Bar']].each { |index, content| puts "#{index}---#{content}" }
1---Foo
2---Bar
~~~

#### Converting Array to Hash
Hash[posts.group_by(&:year).map { |year, posts| [year, posts.group_by(&:month)] }]
=> {2011=>{1=>[#<struct Post year=2011, month=1, content="Foo">, #<struct Post year=2011, month=1, content="Bar">], 2=>[#<struct Post year=2011, month=2, content="Baz">]}, 2012=>{1=>[#<struct Post year=2012, month=1, content="Quux">]}}


That's about it, check out the result on the [frontpage](/).


