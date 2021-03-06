---
layout: post
title: "Ruby: Grouping to two-dimensional Hash"
tags: ruby howto
author: Robin Roestenburg
published_at: "2012-02-19"
---
On the fontpage of this blog I wanted to show a list of posts grouped by year and month, similar to
the post list for a year (see [here](/2011)). I would have reused the code that was used there,
except it only selects the posts for a particular year and groups them by month.

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
>> grouped_posts = posts.group_by { |post| [post.year, post.month] }
=> {[2011, 1]=>[#<struct Post year=2011, month=1, content="Foo">,
                #<struct Post year=2011, month=1, content="Quux">],
    [2011, 2]=>[#<struct Post year=2011, month=2, content="Bar">],
    [2012, 2]=>[#<struct Post year=2012, month=2, content="Baz">]}
~~~

This was not exactly the result I wanted, as I could not do something like `grouped_posts[2011][1]` and
retrieve the posts for January 2011. In fact, the only way to retrieve the posts for January 2011 is
`grouped_posts[[2011,1]]`, not really straightforward.

### Group combined with collect
I realized that I first had to group by year and then do *something* with the posts for each year.
A `collect` on each result of the `group_by` should work. From the Ruby documentation: *[Collect]
invokes the block once for each element of self, replacing the element with the value returned by
block.*

Here's my first try:

~~~ text
>> posts.group_by { |post| post.year }.collect { |grouped_posts| grouped_posts[1].group_by { |post| post.month } }
=> [{1=>[#<struct Post year=2011, month=1, content="Foo">,
         #<struct Post year=2011, month=1, content="Quux">],
     2=>[#<struct Post year=2011, month=2, content="Bar">]},
    {2=>[#<struct Post year=2012, month=2, content="Baz">]}]
~~~

Almost there... It loses the keys to retrieve the years again a hash. There is no way to tell (other
than examining the posts) to which year the hashes belong. Also, the outer element (containing the
grouped hash of posts) is an array, which is not what I want. Luckily, both of these things can be
fixed.

#### Adding the years
Something I did not know about Ruby's Enumerable is that when you enumerate a 2D-array, you can
reference each element of the *inner* array by name by using it as a parameter in the block. For
example:

~~~ text
>> [[1, 'Foo'], [2, 'Bar']].each { |index, content| puts "#{index}: #{content}" }
1: Foo
2: Bar
~~~

In the above example I only referenced the array as a whole (by `grouped_posts`). In order to
preserve the year of the posts I can have the `collect` method return a array containing the year and
the list of posts for that year grouped by month:

~~~ text
>> grouped_posts = posts.group_by(&:year).collect { |year, posts_by_year| [year, posts_by_year.group_by(&:month)] }
=> [[2011,
     {1=>
       [#<struct Post year=2011, month=1, filename="Foo">,
        #<struct Post year=2011, month=1, filename="Bar">],
      2=>[#<struct Post year=2011, month=2, filename="Baz">]}],
    [2012, {1=>[#<struct Post year=2012, month=1, filename="Quux">]}]]
~~~

For readability, I replaced the verbose `group_by` calls using a block by the more condensed
variant in above example.

I can now access the posts of January 2011 as follows: `grouped_posts[0][1][1]`. Does not look that
good yet :)

**Note:** I could have returned a hash instead of an array here and it would have allowed me to
retrieve the posts as follows `grouped_posts[0][2011][1]`. I did try this at first, but I ran into
problems converting the array to hash, see the next section for more information.

#### Converting Array to Hash
This turned out to be really easy, as there is a `[]`-method on Ruby's `Hash` class which takes an
array of key-value pairs or an object convertible to a hash, and returns a hash.

The example in the documentation shows the solution for my problem:

~~~ ruby
Hash[ [ ["a", 100], ["b", 200] ] ]   #=> {"a"=>100, "b"=>200}
~~~

As you can see the `[]`-method strips out the surrounding array(s) which I need to get rid of the
remaining outer array. As bonus it automatically converts the `[year, posts]`-arrays inside it to
a Hash.

**Note about the note above:** When used on the hash variant this method would not detect
a key-value pair and return an empty hash as a result.

~~~ text
>> grouped_posts = Hash[posts.group_by(&:year).collect { |year, posts_by_year| [year, posts_by_year.group_by(&:month)] }]
=> {2011=>
    {1=>
      [#<struct Post year=2011, month=1, filename="Foo">,
       #<struct Post year=2011, month=1, filename="Bar">],
     2=>[#<struct Post year=2011, month=2, filename="Baz">]}},
   {2012=>{1=>[#<struct Post year=2012, month=1, filename="Quux">]}}
~~~

That's about it, `grouped_posts[2011][1]` now returns the posts of January 2011.

Check out the end result on the [frontpage](/).


