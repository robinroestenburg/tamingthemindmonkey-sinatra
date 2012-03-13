--- 
layout: post 
title: "ActiveRecord: Inserting a record Pt. 2"
author: Robin Roestenburg 
tags: rails activerecord mychain 
chain: "Digging into Rails"
published_at: "2012-03-13" 
---

In [this post]() we took a first look at the `ActiveRecord::Relation#insert`
method. We saw that it performs the following functions:

1. Prefetching the primary key value if needed. 
2. Create a `Arel::Nodes::InsertStatement` which will be converted to sql when 
   actually inserting the record into the database.
3. Substitute the actual values by bind parameters 
4. Add the substitued values to the `InsertStatement`-object. 
5. Insert the record into the database using the database specific connection. 

We still have to look at points 2, 4 and 5, that conern creating an ARel object
and using it to insert the record into the database. 

### Creating the Arel::Table object (sneak peek)
The following lines from the `ActiveRecord::Relation#insert` method create the
Arel object and fill it with the necessary information to have it produce a SQL
insert statement. 

~~~ ruby
im = arel.create_insert
im.into @table
im.insert substitutes
~~~

The `arel` is a method call to the `ActiveRecord::Relation::QueryMethods#arel`
method, that performs the following:

~~~ ruby
def arel
  @arel ||= with_default_scope.build_arel
end
~~~

Let's skip the `with_default_scope` part for now, we will look at scoping in
another post (probably more than one). What's left is the `build_arel` call,
which is a method in the same module. The method creates an `Arel::Table` object
and adds all relevant, for generating the SQL, object to it. 

It takes a table and adds, for example, the table on which the SQL statement is 
to be performed (in our running example `monkeys`). The method responsible for
retrieving the table is `arel_table`, which is defined in `Core` and looks like 
this:

~~~ ruby
def arel_table
  @arel_table ||= Arel::Table.new(table_name, arel_engine)
end
~~~

The `arel_engine` variable contains the name of the ActiveRecord base class of
this class. In our case this is ActiveRecord::Model.

The method returns an `Arel::Table` object like this:

~~~ text
#<Arel::Table:0x007f93904580f0 @name="monkeys", 
                               @engine=ActiveRecord::Model, 
                               @columns=nil, 
                               @aliases=[], 
                               @table_alias=nil, 
                               @primary_key=nil>
~~~

All information needed to create the statement is pushed onto the `Arel::Table`
object in the build_arel method. I will not go into this right here, but
dedicate a separate post to that - so I can experiment some more with creating
different queries.

In our case, we do not have any extra information added to the `Arel::Table`
object and the object shown above is returned to the `arel.create_insert` call.

### The InsertManager
Let's look at the following code again:

~~~ ruby,showlines
im = arel.create_insert
im.into @table
im.insert substitutes
~~~

The first line will create an `Arel::InsertManager` and returns the following:

~~~ text
#<Arel::InsertManager:0x007fdd7bc7bbf8 
          @engine=ActiveRecord::Model, 
          @ctx=nil, 
          @ast=#<Arel::Nodes::InsertStatement:0x007fdd7bc7bbd0 
                                @relation=nil, 
                                @columns=[], 
                                @values=nil>>
~~~

The `InsertManager` is responsible for inserting the record into the database.
It will contain all information needed to insert a record into the database.
Presently the `InsertManager` contains an `@ast` (abstract syntax tree) object
which will be used to create the sql statement lateron. For now, the `@ast`
contains no values.

The second line will set the `@relation` variable of the abstract syntax tree to
be the table in which the record has to be inserted. The `Arel::Table` object
that we discussed before is added here.

~~~ text
#<Arel::InsertManager:0x007f8a4e477bf8 
          @engine=ActiveRecord::Model, 
          @ctx=nil, 
          @ast=#<Arel::Nodes::InsertStatement:0x007f8a4e477bd0 
                         @relation=#<Arel::Table:0x007f8a4e458a78  
                                             @name="monkeys",  
                                             @engine=ActiveRecord::Model,  
                                             @columns=nil,  
                                             @aliases=[], 
                                             @table_alias=nil,
                                             @primary_key=nil>, 
                         @columns=[], 
                         @values=nil>>
~~~

The last line will add a column and a value for each of the entries in the
`substitutes` array, which I discussed [here]().

~~~ text
#<Arel::InsertManager:0x007fd184d2fc50 
          @engine=ActiveRecord::Model, 
          @ctx=nil, 
          @ast=#<Arel::Nodes::InsertStatement:0x007fd184d2fc28 
                         @relation=#<Arel::Table:0x007fd184d10ad0 ... >,
                         @columns=[#<struct Arel::Attributes::Attribute 
                                                    relation=#<Arel::Table:0x007fd184d10ad0 ... >, 
                                                    name="name">], 
                         @values=#<Arel::Nodes::Values:0x007fd184d2f9a8 
                                           @left=["$1"], 
                                           @right=[#<struct Arel::Attributes::Attribute 
                                                                    relation=#<Arel::Table:0x007fd184d10ad0 ... >, 
                                                                    name="name">]>>>
~~~

(I truncated the duplicate `Arel::Table` objects for brevity)

### Generating the SQL (another sneak peek)
The `InsertManager` now contains all information it needs to generate the sql
and it is handed off to the database connection which will trigger the sql
creation.

~~~ ruby 
conn.insert(
  1                                                                                                                                                 
  im,                                                                                                                                                         
  'SQL',                                                                                                                                                      
  primary_key,                                                                                                                                                
  primary_key_value,                                                                                                                                          
  nil,                                                                                                                                                        
  binds) 
~~~

Again, I will look at inserting the record through the database connection some
other time. I want to check out the generation of the sql statement first.
Generating the sql is done through the `to_sql` method on the `InsertManager`.

For our example it will produce this query:

~~~ sql
INSERT INTO "monkeys" ("name") VALUES ($1)
~~~ 

Of course, a lot of complexity is not shown in this example. I hope to be able
to show you more of the `to_sql` when I check out the different queries that can
be generated through Arel.

One thing that is interesting is that Arel provides an sql statement containing
the bind parameters. These will be replaced by bind values (`binds`) by the
database connection. I will look into that later.

That's it for tonight. I have a lot of stuff that I can look into now. Tomorrow
I hope to do some more concrete things and look at building queries using Arel.
