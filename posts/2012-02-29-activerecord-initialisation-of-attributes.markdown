--- 
layout: post 
title: "ActiveRecord: Initialisation of attributes on class"
author: Robin Roestenburg 
tags: rails activerecord mychain 
chain: "Digging into Rails"
published_at: "2012-02-29" 
---
I have been figuring out what Rails, and specifically Active Record, is doing
behind-the-scenes with the following (simple) example:

~~~ ruby
monkey = Monkey.new
monkey.name = 'George'
monkey
~~~

I have [looked]() at how Active Record knows in what database table to store the
data, but I have yet to look at how the database column `name` is mapped to an
attribute of the `Monkey` class. The `Monkey` class code does not contain it: 

~~~ ruby
class Monkey
  include ActiveRecord::Model
end
~~~

Active Record must somehow add the `name` attribute when creating an instance of
the class.

### Back to initialize (again)
This is going to be a difficult piece to write. I'll try my best, but I don't
expect everyone to reach the end ;-) Let's take another look at the `initialize`
method in the `ActiveRecord::Core` module.

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

#### Retrieving column information
First, it assigns the attributes that are present on this class to the
`@attributes` instance variable. The `ActiveRecord::ModelSchema.column_defaults`
method will get a list of columns, and default values for those columns, from
the database. It retrieves them using the `columns`-method on the
connection-specific adapter class. In our case this is the
`ActiveRecord::ConnectionAdapters::PostgreSQLAdapter`. 

This method will retrieve the column definitions for the mapped table
containing a list of the table's column names, data-types, and default values.
It returns an array of `PostgreSQLColumn` objects. These are Column objects
containing all information about a column in the database plus some Postgres
specific extensions/implementations. The column definitions are retrieved using
a database specific query from the database metadata.

Back to `column_defaults`. It only takes the name and default value from the
array of column definitions and returns this back to the
`ActiveRecord::Core.initialize` method. In our case it returns:
  
~~~ ruby
{"name" => nil}
~~~

#### Assigning the attributes?
Once back in the `initialize` method the column names and default values are
used as input for the `init_attributes` method. My first guess was that this
method would created accessor method for each column, but this was not the case.
The `init_attributes` method initializes the (by default optimistic) locking
columns, and does some special things for attributes that are to be serialized.
I will not look at that right now. 

After this, where the hash returned from the `column_defaults` is passed on and
stored into the `@attributes` on the `Monkey`-class. This does not mean that an
accessor method for the `name` attribute has been created.

Let's take a look at the rest of the `initialize`-method and see if the accessor
methods are created there:

* The @columns_hash is set with a hash containing the name of the column and the
  previously mentioned `PostgreSQLColumn` object.
* Method `init_internals` initializes some of the instance variables.
* Method `ensure_proper_type` sets the attribute used for single table
  inheritance when necessary.
* Method `populate_with_current_scope_attributes` sets values of scoped
  attributes on this class' attributes.
* Method `assign_attributes` assigns the attributes that are passed to the
  constructor.

#### Method missing magic
I am missing something here. Where are the accessor methods for the columns
created? Maybe it is somewhere in a callback method?

After searching around some more, I found out that the accessor methods are 
created on the fly by using some `method_missing` action - good times ;-)

I will look into this tomorrow. 
