--- 
layout: post 
title: "Digging into Rails: Naming of table mappings" 
author: Robin Roestenburg 
tags: rails activerecord mychain 
published_at: "2012-02-27" 
---
Yesterday I managed to get the connection to the database
[working](/2012/02/26/digging-into-rails-connecting-to-the-database). I now have
to add the `monkeys` table to the database containing a column `name` to get my
example to work. I will repeat the example for clarity: 

~~~ ruby
monkey = Monkey.new
monkey.name = 'George'
monkey.save
~~~

After adding the table to my database and running the example I now have the
following content in my `monkeys` table:

~~~ text
monkey_business=# select * from monkeys;

  name  
  --------
   George
   (1 row)
~~~

Cool, it works :-)

How did this work? I never specified any table name nor the columns of the
table. How did it generate the insert statement? To answer these question I will
go back to where I ended with [this
post](/2012/02/25/digging-into-rails-closer-look-at-activerecord-initialize);
the initialization of a Active Record class. I got sidetracked in the last post
to get the database connection running, but I will continue with the following
line from the `columns` method on the `ActiveRecord::ModelSchema` module: 

~~~ ruby
connection.schema_cache.columns[table_name]
~~~

It returns an array of column objects for the mapped table of the class it
is called on, here `Monkey`. The `ModelSchema#table_name` method returns the
name of the table in the database to which the class is mapped. The method
`ModelSchema#compute_table_name` does all the *heavy* lifting though:

~~~ ruby
# Computes and returns a table name according to default conventions.
def compute_table_name
  base = base_class
  if self == base
    # Nested classes are prefixed with singular parent table name.
    if parent < ActiveRecord::Model && !parent.abstract_class?
      contained = parent.table_name
      contained = contained.singularize if parent.pluralize_table_names
      contained += '_'
    end
    "#{full_table_name_prefix}#{contained}#{undecorated_table_name(name)}#{table_name_suffix}"
  else
    # STI subclasses always use their superclass' table.
    base.table_name
  end
end
~~~

### Naming of table mappings
As you can see, there are some different cases possible in the determining the
name of the database table to which a class is mapped.

* Pluralize 
* Adding a prefix
* Adding a suffix
* Nested classes
* Single Table Inheritance
* Defining a custom names

Let's go through them one by one.

#### Pluralize (or, in this case, singularize)
When using Rails, by default, a class maps to a table with the plural version of
the class name. This is something that can be turned off if you do not like such
a naming scheme:

~~~ ruby
ActiveRecord::Model.pluralize_table_names = false

class Monkey
  include ActiveRecord::Model
end
~~~

In our example, Active Record will now look for a table named `monkey`.

#### Adding a prefix 
It is possible to prepend a prefix to every table name. Configuring this for all
classes including `ActiveRecord::Model` is done as follows: 

~~~ ruby
ActiveRecord::Model.table_name_prefix = 'weird_'
~~~ 

The table to which the `Monkey`-class is mapped has now been changed to
`weird_monkeys`.

#### Adding a suffix 
Instead of a prefix you can also append a suffix: 

~~~ ruby
ActiveRecord::Model.table_name_suffix = '_on_my_mind'
~~~

Now, Active Record will look for the table `monkeys_on_my_mind`.

#### Nested classes
Take a look at the following example of a nested class:

~~~ ruby
class Monkey
  include ActiveRecord::Model

  class Mind
    include ActiveRecord::Model
  end
end

monkey_mind = Monkey::Mind.new
~~~

Active Record will now look for the table `monkey_minds` when you initialize
the `Mind` class. The main class is singularized (if pluralization is on) and
prepended to the nested class.

#### Single Table Inheritance
When using STI, the name of the table is the same as the name of base class
(kind of obvious). The following example shows this case:

~~~ ruby
class Monkey 
  include ActiveRecord::Model

  class EmperorTamarin < Monkey
  end
end

emperor_tamarin = Monkey::EmperorTamarin.new
~~~

Check out the 'Emperor Tamarin' monkey on Google ;-)

#### Defining custom name
If you do not like the default Rails naming scheme, including the already
mentioned options, it is possible to just define you own name: 

~~~ ruby
class Monkey
  include ActiveRecord::Model
  self.table_name = 'primates'
end

primate = Monkey.new
~~~

The `Monkey` class is now mapped to the `primates` table. This kind of
overriding would be useful if you are working with some kind of legacy database. 


That's about it for tables names and for this post, see you tomorrow. 

**I've posted the code examples for this blog post on Github, check it out
[here](https://github.com/robinroestenburg/digging-into-rails/tree/master/004-naming-of-mapped-tables).**

