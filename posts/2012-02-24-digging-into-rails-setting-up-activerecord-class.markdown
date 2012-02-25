---
layout: post
title: "Digging into Rails: Setting up a ActiveRecord class"
tags: rails mychain activerecord
author: Robin Roestenburg
published_at: "2012-02-24"
---
Last night I [decided]() to start my adventure through Rails by looking at the
bottom of its stack.  I was going to look at ARel, but after looking at the 
source some more that seemed a bit too low-level. I think examining how 
ActiveRecord uses ARel will be a better place to start. 

### Monkey business
The best way to get familiar with a particular library is to write some
learning tests or write a quick example program to test a particular feature.
Normally I would write tests exercising the behavior of the library and see how
it works. For brevity's sake I will not do that in these blog posts. 

Sticking with the monkey theme of this blog I want to get the following example
to work:

~~~ ruby
monkey = Monkey.new
monkey.name = 'George'
monkey.save
~~~

This should save a row to the database containing a monkey. I've created a
project and put this code in the root of the project in a file called
`monkey_business.rb`.

### How to create a ActiveRecord class?
First up, is a way to create a ActiveRecord class. The README of the 
ActiveRecord module states the following: 

> The library provides a **base class** that, when subclassed, sets up a mapping
> between the new class and an existing table in the database.

This base class is `ActiveRecord::Base` and when I subclass it, I should be 
ready to go. In the file `lib/monkey.rb` I've defined the following class: 

~~~ ruby
class Monkey < ActiveRecord::Base
end
~~~

When I run the `monkey_business.rb` file, I get an error because it does not
know the `Monkey` class. Requiring it will give the following error: 

~~~ text
/Users/robin/Playground/activerecord-spike/lib/monkey.rb:1:in `<top (required)>': uninitialized constant ActiveRecord (NameError)
  from monkey_business.rb:1:in `require_relative'
  from monkey_business.rb:1:in `<main>'
~~~
    
Requiring the `active_record` module in the `lib/monkey.rb` file will fix this. 

Before I can do this, I will need to add a Gemfile to the project so I can 
load the ActiveRecord module. I've cloned the Rails project to a local directory 
so I could work with the source more easily. The Gemfile of the project looks 
like this:

~~~ ruby
source :rubygems
gem 'rails', :path => '/path/to/local/rails-repo'
~~~

I would have expected this to work, but I get an error that it cannot load
`rails/active_record`. I do not know why this fails, will have to look into
it. Turns out ActiveRecord is a gem on its own and I can load it in my Gemfile 
(it does need ActiveSupport and ActiveModel though), and finally my Gemfile
looks like this: 

~~~ ruby
source :rubygems
gem 'activesupport', :path => '~/Playground/rails/rails/activesupport'
gem 'activemodel',   :path => '~/Playground/rails/rails/activemodel'
gem 'activerecord',  :path => '~/Playground/rails/rails/activerecord'
~~~

This works, I now get a different error - yay! 

### Database trouble
I now get the following error:

~~~ text
/Users/robin/Playground/rails/rails/activerecord/lib/active_record/connection_adapters/abstract/connection_pool.rb:378:in `retrieve_connection': ActiveRecord::ConnectionNotEstablished (ActiveRecord::ConnectionNotEstablished)
  from /Users/robin/Playground/rails/rails/activerecord/lib/active_record/connection_handling.rb:81:in `retrieve_connection'
  from /Users/robin/Playground/rails/rails/activerecord/lib/active_record/connection_handling.rb:55:in `connection'
  from /Users/robin/Playground/rails/rails/activerecord/lib/active_record/model_schema.rb:197:in `columns'
  from /Users/robin/Playground/rails/rails/activerecord/lib/active_record/model_schema.rb:232:in `column_defaults'
  from /Users/robin/Playground/rails/rails/activerecord/lib/active_record/core.rb:167:in `initialize'
  from monkey_business.rb:3:in `new'
  from monkey_business.rb:3:in `<main>'
~~~
    
I now have a valid `ActiveRecord` class. When calling `Monkey.new` it is
doing all kinds of things - it is looking for a database connection, 
which I have not set up yet. 

Tomorrow I will try to figure out what it is doing on `new`.

**I've posted the code example for this blog post on Github, check it out
[here](https://github.com/robinroestenburg/digging-into-rails/tree/master/001-setting-up-activerecord-class).**

