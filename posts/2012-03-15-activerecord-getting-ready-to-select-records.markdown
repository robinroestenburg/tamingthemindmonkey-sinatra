--- 
layout: post 
title: "ActiveRecord: Getting ready to select records"
author: Robin Roestenburg 
tags: rails activerecord mychain 
chain: "Digging into Rails"
published_at: "2012-03-15" 
---

Let's start with a little bit more complicated example than the one I used in
the previous set of posts. I wanted an association in the models used, so I
could check out some of the non-standard select queries. Here is what I came up
with: 

* Forest, contains of many trees
* Tree, belongs to forest and a specific type (e.g. 'Red Pine')

This is a pretty simple model, but still allows us to create some more advanced
queries than the basic selection. Two examples from the top of my head:

* grouping the trees in a forest by type and only returning the type of trees
  of which there are more than X present in the forest, and
* selecting the name of the forest as well as the types of trees that are
  present in that forest.

### Setting up the tables
First, I have created the database tables which will store forest and trees:

~~~ sql
CREATE TABLE forests (id serial, name varchar, PRIMARY KEY(id));
CREATE TABLE trees (id serial, type varchar, forest_id integer, PRIMARY KEY(id));
~~~

While creating the tables I was looking for the syntax for creating a
auto-increment-like primary key column and I came across Postgres' serial data
type. 

##### PostgreSQL serial types
The following text is taken from Postgres' documentation, found
[here](http://www.postgresql.org/docs/9.1/static/datatype-numeric.html#DATATYPE-SERIAL):

> The data types serial and bigserial are not true types, but merely a
> notational convenience for setting up unique identifier columns (similar to
> the `AUTO_INCREMENT` property supported by some other databases). In the
> current implementation, specifying: 
> 
> ~~~ sql
> CREATE TABLE tablename (colname SERIAL);
> ~~~
> 
> is equivalent to specifying:
> 
> ~~~ sql
> CREATE SEQUENCE tablename_colname_seq;   
> CREATE TABLE tablename (colname integer DEFAULT nextval('tablename_colname_seq') NOT NULL);
> ~~~
> 
> Thus, we have created an integer column and arranged for its default values to
> be assigned from a sequence generator. A NOT NULL constraint is applied to
> ensure that a null value cannot be explicitly inserted, either. 

### Creating the model classes
Second I created a first version of the models that we will be using in the
examples: 

~~~ ruby
# forest.rb
class Forest                                                                                                                                                                                                         
  include ActiveRecord::Model                                                                                                                                                                                        
  has_many :trees                                                                                                                                                                                                    
end

# tree.rb
class Tree                                                                                                                                                                                                           
  include ActiveRecord::Model                                                                                                                                                                                        
  attr_accessible :type
  belongs_to :forest                                                                                                                                                                                                 
end
~~~

Simple enough :) One small note: being on Edge Rails I now have to add the
`attr_accessible` call for the `type` attribute to be able to mass-assign it
when constructing a `Tree` object using `new`.

### The example
In the following series I will be working with the following example: 

~~~ ruby
# Create a forest, check: http://en.wikipedia.org/wiki/Rothrock_State_Forest                                                                                                                                         
forest = Forest.new(name: 'Rothrock')                                                                                                                                                                                

# Create a couple of trees, for more types check: http://www.tree-pictures.com/tree_types.html                                                                                                                       
forest.trees << Tree.new(type: 'Cucumbertree')                                                                                                                                                                                
forest.trees << Tree.new(type: 'Red Pine')                                                                                                                                                                                    
forest.trees << Tree.new(type: 'Black-Toothed Willow')                                                                                                                                                                        

forest.save

# Examples of selecting records follow here:
...
~~~

That is what I will work with for the following few posts, check out the code on
Github
[here](https://github.com/robinroestenburg/digging-into-rails/tree/master/006-selecting-records).

See you tomorrow, I will start with examining the `ActiveRecord::Relation.find`
method. 
