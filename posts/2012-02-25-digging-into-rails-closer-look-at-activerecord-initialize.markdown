--- 
layout: post 
title: "Digging into Rails: Closer look at Active Record initialization" 
author: Robin Roestenburg 
tags: rails activerecord mychain 
published_at: "2012-02-25" 
---

Yesterday I
[wrote](/2012/02/24/digging-into-rails-setting-up-activerecord-class) about
setting up a Active Record class. The post ended with Active Record throwing a
`ActiveRecord::ConnectionNotEstablished` error when I tried to create a new
instance of my `Monkey`-class (which inherited from `ActiveRecord::Base`). 

I would like to find out what I need to do to fix this error, so let's take a
look what happens when initializing the class. 

### Including instead of inheriting 

The backtrace produced by the error showed that it originated from
`ActiveRecord::Core.initialize()`. As the `Monkey`-class is inheriting from
`ActiveRecord::Base` I want to check out where `ActiveRecord::Core` gets
involved. `ActiveRecord::Base` is an empty class which only includes the module
`ActiveRecord::Model`. After opening the `Model` module, I came across an
interesting comment at the top of the module: 

~~~ ruby 
# ActiveRecord::Model can be included into a class to add Active Record
# persistence. This is an alternative to inheriting from ActiveRecord::Base.
~~~

This means I can change my `Monkey` class as follows: 

~~~ ruby 
require 'active_record'
class Monkey 
  include ActiveRecord::Model 
end
~~~

There is no need to inherit from `ActiveRecord::Base` anymore, which makes a
lot more sense - persistence is behavior and should be mixed into the class.
Also explains the empty Base class :) 

**Note:** this has only recently been committed (by Jon Leighton) in Rails, and
is only available when using Edge Rails.

Running the example still produces the same error, so that is good (for now
anyway).  

### Initializing, step 1 of ?
There is **a lot** of stuff that gets included into the `Model` module, the
`Core` module (containing the `initialize`-method) is one of them. After
browsing around in the `Core` module for a bit and getting a feel of everything
that is in there, I took a closer look at the `initialize`-method:

~~~ ruby
def initialize(attributes = nil, options = {})
  @attributes = self.class.initialize_attributes(self.class.column_defaults.dup)
  @columns_hash = self.class.column_types.dup

  init_internals

  ensure_proper_type

  populate_with_current_scope_attributes

  assign_attributes(attributes, options) if attributes

  yield self if block_given?
  run_callbacks :initialize
end
~~~

A lot of things going on in this method, let's go through it line for line. 

#### Retrieving attributes
First, the attributes of the class are retrieved from the underlying database
table and stored in the instance variable `@attributes`. Class methods
`initialize_attributes` and `column_defaults` are used to retrieve the
attributes. 

As the `column_defaults`-method is input for the `initialize_attributes`-method,
and it is the next method in the backtrace of the error, I will look at that
method next. 

It is defined in the `ModelSchema` module which is
included in `Model`. It will return a Hash of (key,value)-pairs
where the keys are the column names and the values are the default values for
the table. This hash will be used to initialize `@attributes` with default
values using the already mentioned `initialize_attributes`-method. 

How does `column_defaults` know which columns are present in the database table
(and which table it should look at) and what the default values are? It takes a
connection to the database and retrieves the columns of the table from the
schema. A small snippet from the `columns` class method on the `ModelSchema`
module shows this: 

~~~ ruby
connection.schema_cache.columns[table_name]
~~~

The `connection`-method is defined in the `ConnectionHandling` module which is
also included into `Model`. Tomorrow I will take a look at this connection
handling code and probably be able to create a connection to my database. 

Ugh, that was a big blob of words. I am getting closer to where I want to be
though. 

**I've posted the code example for this blog post on Github, check it out
[here](https://github.com/robinroestenburg/digging-into-rails/tree/master/002-closer-look-at-activerecord-initialization).**
