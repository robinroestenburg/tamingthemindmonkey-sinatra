--- 
layout: post 
title: "ActiveRecord: Basic finders Pt. 3"
author: Robin Roestenburg 
tags: activerecord rails
chain: "Digging into Rails"
published_at: "2012-03-23" 
---

Today I will be examining the last part of the basic finders series: executing
the select statement against the database and filling the object(s) with the
returned result. 

The `Relation#exec_queries` method will call the `Querying#find_by_sql` method
in case no associations have to be loaded. I will look at association in later
posts, so I will no discuss the other path here. 

The `find_by_sql` takes two parameters: 

* the sql to be executed (as determined by Arel)
* the (optional) bind values

~~~ ruby,showlines
def find_by_sql(sql, binds = [])
  logging_query_plan do
    result_set = connection.select_all(sanitize_sql(sql), "#{name} Load", binds)
    column_types = {}

    if result_set.respond_to? :column_types
      column_types = result_set.column_types
    else
      ActiveSupport::Deprecation.warn "the object returned from `select_all` must respond to `column_types`"
    end

    result_set.map { |record| instantiate(record, column_types) }
  end
end
~~~

### Sanitizing the generated SQL
Before passing the sql to the database connection the sql is sanitized by the 
`sanitize_sql` method, this will replace the ? by the values provided.

~~~ ruby
name = 'Red Pine'
Tree.find_by_sql ["SELECT name FROM trees WHERE name = ?", name]
~~~

The `sanitize_sql` is an alias for the `sanitize_sql_for_conditions` method that
performs this interpolation together with the `sanitize_sql_array`. There are
some other sql sanitizing methods, they are all located in the `Sanitization`
module.




