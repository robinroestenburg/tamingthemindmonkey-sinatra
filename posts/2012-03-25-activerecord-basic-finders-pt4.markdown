--- 
layout: post 
title: "ActiveRecord: Basic finders Pt. 4"
author: Robin Roestenburg 
tags: activerecord rails
chain: "Digging into Rails"
published_at: "2012-03-25" 
---

Last post on selecting records using the basic find methods, I promise ;-) 

The only thing left to look at is the instantiation of the records from the
result of the SQL select statement.  In the `QueryingMethod.find_by_sql` the
following line trigger the instantiation and return the result to the caller:

~~~ ruby
result_set.map { |record| instantiate(record, column_types) }
~~~

Because the `map` iterator is used, the result from the `find_by_sql` method
will always be an array (empty when no records are found). 

The `instantiate` method kind of surprised me, it is located inside the
`Inheritance` module. Not exactly the place I was expecting it, as I am not
doing any inheritancy things.

### Inheritance?
The `Inheritance.instantiate` method looks like this:

~~~ ruby,showlines
# Finder methods must instantiate through this method to work with the
# single-table inheritance model that makes it possible to create
# objects of different types from the same table.
def instantiate(record, column_types = {})
  sti_class    = find_sti_class(record[inheritance_column])
  column_types = sti_class.decorate_columns(column_types)
  sti_class.allocate.init_with('attributes' => record, 'column_types' => column_types)
end
~~~

It is not really straightforward to understand what is happening in this
class-method. The comment is helpful and makes things a bit more clear. It comes
down to this: when using STI some extra processing is needed to support instantiating objects
of a different type then the class of the table from which I am selecting (as
can be the case with STI). For example: 

> We use Single Table Inheritance to create different classes for each type of
> `Tree`. If we have the following records in the table `trees`: 
> 
> ~~~ text
>  id  |       species        |      type      | forest_id 
> -----+----------------------+----------------+----------
>    1 | Cucumbertree         | cucumbertree   |        1
>    2 | Red Pine             | red_pine       |        1
> ~~~~
> 
> Selecting all trees from the database returns the following objects
> `[Cucumbertree, RedPine]` instead of `[Tree, Tree]`.



Let's go through the method one line at a time: 

* First line, find the Single-Table-Inheritance class. The column which is used
  for STI (default: `type`) is passed a parameter to the `find_sti_class`
  method. This method returns `self` (`Tree` in our case) if the class does not
  have the inheritance column. Otherwise it will determine the class name based
  on the type column (see the example above).
* Next, the returned class (`Tree`) decorates the columns. Some specific things
  are done for serialized attributes and timezone conversion attributes (?), I
  will skip it for now.
* Last, and most important, an actual instance of the class is instantiated and
  the retrieved attributes are copied onto the object.
  This takes place in the `Core.init_with` method.

### Initializing a ActiveRecord object revisited

The `init_with` method takes a Hash of attributes and adds them to the object
using the class method `initialize_attributes`. I saw this method already when
discussing [the initialization of a ActiveRecord
object](/2012/02/25/digging-into-rails-closer-look-at-activerecord-initialize),
where the Hash of attributes contained the default values for all the columns in
the database.

The `init_with` method will not check if the supplied attributes are present as
columns in the database: 

~~~ ruby
tree = Tree.allocate                                                             
tree.init_with('attributes' => { 'age' => '10' })                     
tree.age #=> '10'   
~~~

I guess this would be useful when selecting grouped columns or calculating
columns inside a select. Furthermore I was having problems saving the record
into the database, it did not show up. I will look into this later on.

After the attributes and the unknown columns are added the select is basically
done. Other values `ActiveRecord` needs are initialized and the callbacks `:find`
and `:initialize` are executed.

Seeing the `:initialize` callback here, explains why the generation of attribute
methods is [so
obscure](/2012/03/01/activerecord-last-pieces-of-the-initialization-puzzle).
Still, the current solution is not the nicest and I will give it a shot to
refactor it.

That is it for today and for the discussion of the basic find methods. Next I
will take a look at the dynamic finders.

