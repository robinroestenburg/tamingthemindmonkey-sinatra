--- 
layout: post 
title: "ActiveRecord: Basic finders"
author: Robin Roestenburg 
tags: rails activerecord mychain 
chain: "Digging into Rails"
published_at: "2012-03-16" 
---
Yesterday I set up my example which I will be using during this set of posts
about selecting/finding records using ActiveRecord. Today I will be discussing
the basic finders that exist. 

There are 3 different ways to call the basic find methods:

* a call to the class' `first`, `all` and  `last` methods,
* using an id or a list of ids, and
* one of the above combined with a hash containing options.

They are all shortcuts to a more general find method. E.g. `Tree.find(1)` will
call `Tree.find(:id, 1)`, `Tree.first` will call `Tree.find(:first, *args)`,
etc.

There are a lot of options you specify in the options hash:

* `:conditions`: SQL fragment containing the where-clause.
* `:order`: SQL fragment containing the order-clause.
* `:group`: SQL fragment containing the group by-clause.
* `:having`: SQL fragment containning the having-clause.
* `:limit`: Number of rows to select. 
* `:offset`: Number of rows to skip in the result.
* `:joins`: Tables to join.
* `:include`: List of associations that should be loaded alongside the select.
* `:select`: Columns to select.
* `:from`: Table from which to select.
* `:readonly`: Returns the result as *read-only* records.
* `:lock`: SQL fragment to specify locking mechanism (e.g. 'FOR UPDATE').

Let's only look at the general find method and skip the 4 convenience methods
because the implemenation will be similar.

The basic find method looks like this: 

~~~ ruby,showlines
def find(*args)                                                                                                                                                                                                  
  return to_a.find { |*block_args| yield(*block_args) } if block_given?                                                                                                                                          
 
  options = args.extract_options!                                                                                                                                                                                
  
  if options.present?                                                                                                                                                                                            
    apply_finder_options(options).find(*args)                                                                                                                                                                    
  else                                                                                                                                                                                                           
    case args.first                                                                                                                                                                                              
    when :first, :last, :all                                                                                                                                                                                     
      send(args.first)                                                                                                                                                                                           
    else                                                                                                                                                                                                         
      find_with_ids(*args)
    end                                                                                                                                                                                                          
  end
end
~~~ 

The options from the options hash are applied to the class using the
`apply_finder_options` method (**line #7**) on
`ActiveRecord::Relation.SpawnMethods`.

For each of the options the apply method will call a particular scoping method
on the `Relation` object. Let me give you an example.

~~~ ruby
Tree.find(condition: ["type = ?", 'Red Pine'])
~~~

This would trigger the `where`-method on `ActiveRecord::Relation::QueryMethods`
module. 

~~~ ruby,showlines
def where(opts, *rest)                                                                                                                                                                                           
  return self if opts.blank?                                                                                                                                                                                     

  relation = clone                                                                                                                                                                                               
  relation = relation.references(PredicateBuilder.references(opts)) if Hash === opts                                                                                                                             
  relation.where_values += build_where(opts, rest)                                                                                                                                                               
  relation                                                                                                                                                                                                       
end
~~~ 

This module contains the different methods that are called from the
`apply_finder_options` method. For example, others are `having` and `group`.
Each of these methods creates a new `Relation` (or scope) (**line #4**)  and
adds the options on to it (**line #6**). The options are made available through
instances variables on this module as well, e.g. `@where_values`,
`@having_values`, etc. These variables are used when building the Arel object,
which I mentioned in an [earlier post]().

After the find options are applied, another call to the same `find` method is
performed (second part of **line #7** in first code listing). This is a
recursive call to the same method. The options have been stripped from the
methods' arguments from the first call (**line #4** in first code listing). In
our case the second time the `find`-method is called without any arguments
(because the `conditions` option was the only argument). 

This second call will perform a find using the `find_with_ids`-method (**line
#13** in first code listing) within the current scope (which has been set by the
`where`-method) and return the result.

I will discuss the `find_with_ids` method in the next post and see how and where
the select query will be built. I want to take a closer look at the
`QueryMethods` module as well, the lines with the `PredicateBuilder` and the
`build_where` call are probably worth looking into.

