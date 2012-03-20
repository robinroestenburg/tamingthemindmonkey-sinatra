---
layout: post
title: "ActiveRecord: Basic finders Pt. 2"
author: Robin Roestenburg
tags: rails activerecord
chain: "Digging into Rails"
published_at: "2012-03-20"
---

In the [last post](/2012/03/16/activerecord-basic-finders) I made a start at
looking at how the basic finder methods work in Active Record. I stopped at the
`find_with_ids method`, which is called after the options have been applied to
the current scope.

The `Relation::FinderMethods#find_with_ids` method looks like this (only showing
the important lines):

~~~ ruby,showlines
def find_with_ids(*ids)
  ...
  ids = ids.flatten.compact.uniq

  case ids.size
  when 0
    raise RecordNotFound, "Couldn't find #{@klass.name} without an ID"
  when 1
    result = find_one(ids.first)
    expects_array ? [ result ] : result
  else
    find_some(ids)
  end
end
~~~

This method will call `Relation::FinderMethods#find_some` in case the arguments
contain more than one id. It will call `Relation::FinderMethods#find_one` there
is only one id, and raise an error when no ids are present.

Some other things to note about this method (and the general `find` method that
calls this method):

* Duplicate ids and nil values are filtered from the list of ids (by
  respectively using the `uniq` and `compact` method - see line **#3** in above
  code listing).
* Normally, when you search for a particular id, the matching record is returned
  as an object. When you search for a particular id and supply that id as an
  element in an array, the result you get will also be an array (also see line
  **#10** in above code listing).
  For example:   
  * Using `Tree.find([1])` will result in `[#<Tree id: 1, type: nil, forest_id: 1>]`,
  and
  * using `Tree.find(1)` will result in `#<Tree id: 1, type: nil, forest_id: 1>`.

Let's look at the `find_one` method (the `find_some` method executes the select
in a similar way).

~~~ ruby,showlines
def find_one(id)
  id = id.id if ActiveRecord::Base === id

  column = columns_hash[primary_key]
  substitute = connection.substitute_at(column, @bind_values.length)
  relation = where(table[primary_key].eq(substitute))
  relation.bind_values += [[column, id]]
  record = relation.first

  unless record
    conditions = arel.where_sql
    conditions = " [#{conditions}]" if conditions
    raise RecordNotFound, "Couldn't find #{@klass.name} with #{primary_key}=#{id}#{conditions}"
  end

  record
end
~~~

By looking at line **#2** I found out that the supplied id does not have to be
an integer, but can also by an object inheriting from (or including) the
`ActiveRecord::Base` class. Not really useful if you ask me, you probably 
should use `reload` for this.

The rest of the method (lines **#4** until **#7** perform the substitution of
the values by bind parameters, which I already looked at when discussing
inserting a record into the database (check for more information
[here](/2012/03/08/activerecord-inserting-a-record-pt-3) and the two posts
following it).

### Converting to array retrieves the records...
The record gets retrieved from the database by the `relation.first` call (which
is the convenience method for calling `find(:first, *args)`). This method has
similar logic to apply the finder options as is present in the general find
method, but that gets skipped because all our options have been applied already.
Instead the method calls `Relation::FinderMethods#find_first`.

~~~ ruby
def find_first
  if loaded?
    @records.first
  else
    @first ||= limit(1).to_a[0]
  end
end
~~~

Pretty simple (yay!). The record is returned by `@records` if it has already
been loaded, otherwise the current scope is transformed to an array and the
first element is returned.

Where is the database stuff? It is hidden in the `to_a` method, which module
`Relation` overwrites from the Ruby core.  This method only calls the
`Relation#exec_queries` method which calls `Querying#find_by_sql`. This method
performs the actual select statement on the database.

Both the `exec_queries` as the `find_by_sql` methods are interesting enough to
take a deeper look at. I will write a post on each of them. 

### Problem with the example
Returning to my example from before, the forest and trees have been inserted and
now I want to select a particuler type of tree, the Red Pine. First I tried the
following select:

~~~ ruby
Tree.find(:all, :conditions => ['type = ?', 'Red Pine'])
~~~

I discovered that I cannot use the `type` column, because Rails uses this for
Single Table Inheritance. So I switched the example (and the previous post) to
use a `species` column and it worked:

~~~ ruby
Tree.find(:all, :conditions => ['species = ?', 'Red Pine'])
# => [#<Tree id: 2, species: "Red Pine", forest_id: 1>]
~~~

Excellent. Now, let's get rid of the ugly `:conditions` option and use the
scoping methods on `Relation` (which get implicitly called) instead:

~~~ ruby
Tree.where(['species = ?', 'Red Pine'])
# => [#<Tree id: 2, species: "Red Pine", forest_id: 1>]
~~~

That looks a lot better. NB. I have been using the options variant in this blog
post because that would make it easier to understand the methods in the
`finder_methods` module.
