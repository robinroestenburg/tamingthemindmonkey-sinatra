--- 
layout: post 
title: "ActiveRecord: Inserting a record Pt. 1"
author: Robin Roestenburg 
tags: rails activerecord mychain 
chain: "Digging into Rails"
published_at: "2012-03-02" 
---
So far, I have looked at the the first two lines of my running example:

~~~ ruby,showlines
monkey = Monkey.new
monkey.name = 'George'
monkey.save
~~~

The third line will save the new record to the database. I want to know how this
works, especially the following parts:

* Creation of the insert query which will save the record into the database.
* Collecting the result and returning it as an instance of the `Monkey` class.

This is the most basic of functionality, once I know how this works things like 
validations, database constraints should be easy.

### Create or update?
I guess the first place to look for this is the `save` method which should be
somewhere on the `ActiveRecord::Model` that is included into the `Monkey` class.
Within the `ActiveRecord` namespace there are a couple of save methods present,
the one that is used is `ActiveRecord::Persistence#save`: 

~~~ ruby,showlinenos
def save(*)
  begin
    create_or_update
  rescue ActiveRecord::RecordInvalid
    false
  end
end
~~~

> **Note**: I did not know what the naked `*` parameter meant. Turns out it is
> the same as using `*args`, only you cannot reference the arguments by name
> from within the method.  Normally, `*args` would be used - but because none of
> the arguments are used in this method they problably chose to use a naked `*`.
> I'm guessing the arguments *are* used in some callback - will look at that
> later. 

If it is a new record it will create a new record in the database, otherwise it
will update the existing record. A new instance of a Active Record class is
always considered to be a new record and the instance variable `@new_record` is
initialized to `true` in the `ActiveRecord::Core#init_internals` method that is
called when initializing the instance.

### Creating a new record
The `ActiveRecord::Persistence#create` method (the one without any parameters)
is used to save the the record into the database. It looks like this: 

~~~ ruby,showlinenos
# Creates a record with values matching those of the instance attributes
# and returns its id.
def create
  attributes_values = arel_attributes_values(!id.nil?)

  new_id = self.class.unscoped.insert attributes_values

  self.id ||= new_id if self.class.primary_key

  IdentityMap.add(self) if IdentityMap.enabled?
  @new_record = false
  id
end
~~~

At line 4 it creates a hash containing a database value for each of the
attributes on the class.  For our example, the hash that is returned contains: 

~~~ text
{#<struct Arel::Attributes::Attribute 
     relation=#<Arel::Table:0x007fda2cc1bc00
                  @name="monkeys", 
                  @engine=ActiveRecord::Model, 
                  @columns=nil, 
                  @aliases=[],
                  @table_alias=nil, 
                  @primary_key=nil>, 
     name="name"> => "George"}
~~~

It uses some of Arels code here, but I will not go into those details right now. 

Next, at line 6, it will insert the record into that database. The
`insert`-method is defined in the module `ActiveRecord::Relation`, and (how
surprising) does a lot of stuff. Short version of it: creates an Arel
*insert-object* and calls the database specific `insert` method on the
`ConnectionAdapter` module with the Arel object and the attribute values as
parameters. 

### Going further...
I skipped through the `create`-method pretty fast. This was intentionally
because the `create`-method, and the methods it invokes, have too much
complexity to be able to explain in a single post. Having looked at most of the
code, I think I am going to go through it like this: 

* look at how the Arel attributes are created and what information it contains,
* look at the creation of the Arel *insert-object*,
* look at all the things happening in the `ActiveRecord::Relation#insert`
  method,
* look at `ActiveRecord::ConnectionAdapter`s `insert`-method that invokes the
  transformation of an Arel object into a SQL string.

Another thing that is bugging me, is that I see some callbacks being called when
I did not expect any (when calling `create_or_update` and when calling
`create`). Might be good to spent some time with the callbacks as well.
