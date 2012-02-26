--- 
layout: post 
title: "Digging into Rails: Connecting to the database"
author: Robin Roestenburg 
tags: rails activerecord mychain 
published_at: "2012-02-26" 
---

In the [previous
post](/2012/02/25/digging-into-rails-closer-look-at-activerecord-initialize),
I went through a couple of different modules/methods that are involved in the
initialization of a Active Record. As I was figuring out how the attributes of a
table were loaded I ended up in the `ConnectionHandling` module, specifically in
the `connection` class method. 

This method retrieves a connection to the database through the connection
handler which is a (singleton) attribute on the `Core` module. The
connection handler (an instance of `ConnectionAdapters::ConnectionHandler`
class) contains a collection of ConnectionPool objects (one for each database in
which the data of your Active Record models are stored, usually only one).

The `ConnectionHandler#retrieve_connection` retrieves a connection pool object
for the nearest super class (in our case the `Monkey` class):

~~~ ruby
def retrieve_connection(klass) #:nodoc:
  pool = retrieve_connection_pool(klass)
  (pool && pool.connection) or raise ConnectionNotEstablished
end
~~~

Initially, the hash containing the connection pools is empty. No connection
pool can be retrieved for the class and
`ConnectionHandler#retrieve_connection_pool`
will return nil which generates our error as you can see in the last line.

### Establishing a connection
So, now the question is - how do we initialize the connection handler in such a
way that there is at least one connection pool present? 

The connection pool for a particular class is retrieved by looking up the class
in a hash containing names of the classes and connection pools as (key,
value)-pairs. I decided to check which methods added to this hash. There were a
couple, but only one I had not seen yet,
`ConnectionHandler#establish_connection`. 

This method on its own was not helping me find an answer, but when I checked the
methods that called it I did. It is called by the
`ConnectionHandling.establish_connection` class method (subtle difference). This 
method contains a big comment, describing how to initialize Active Record by
providing it with information to connect to a database as follows:

~~~ ruby
ActiveRecord::Base.establish_connection(
  :adapter  => "postgres",
  :host     => "localhost",
  :username => "root",
  :password => "",
  :database => "monkey_business"
)
~~~

Calling this before creating an instance of the `Monkey`-class should fix the
error. Normally Rails will take care of setting up your connections, now I have
to do it manually. 

### Missing non-existent gem
After running the example I am confronted with a new error. It seems I am
missing the postgres adapter gem: 

~~~ text
/Users/robin/Playground/rails/activesupport/lib/active_support/dependencies.rb:251:in `require': 
  Please install the postgres adapter: `gem install activerecord-postgres-adapter` 
  (cannot load such file -- active_record/connection_adapters/postgres_adapter) (LoadError)
~~~

Turns out that there is no such gem, and it is standard error that is generated
when an adapter could not be found. If I set the to `foo` I would have gotten
suggestion to install the `activerecord-foo-adapter` gem. We have this brilliant
piece of code to thank for that:

~~~ ruby
begin
  require "active_record/connection_adapters/#{spec[:adapter]}_adapter"
rescue LoadError => e
  raise LoadError, "Please install the #{spec[:adapter]} adapter: `gem install activerecord-#{spec[:adapter]}-adapter` (#{e.message})", e.backtrace
end
~~~ 

After adding the `pg` gem for
[postgres](/2011/09/21/migrating-rails-application-to-postgres-migration)
support to my Gemfile, I was not too happy to see the same error as before!

### Base does not belong to me
I will not go into details why this did not work, maybe some other post. 
TL;DR: I now included `ActiveRecord::Model` and did not inherit from
`ActiveRecord::Base` anymore. When I switched to inheritance again, it worked 
and I unlocked a new error - yay! 

As I do not want to inherit from `ActiveRecord::Base`, I called the
`establish_connection` method on the `ActiveRecord::Model` module to see if that
works. This also works (as in: it produces the same new error), I will stick 
with this - as it will automatically provide a database connection for all
classes including `ActiveRecord::Model`.  

### Missing table
The new error was an obvious one:

~~~ text
/Users/robin/Playground/rails/activerecord/lib/active_record/connection_adapters/postgresql_adapter.rb:1242:in `async_exec': 
  PG::Error: ERROR:  relation "monkeys" does not exist (ActiveRecord::StatementInvalid)
~~~

No table `monkeys` is currently present in my database, so this error makes
sense. 

Tomorrow I will continue with the example and see if I can get Active Record to
determine the attributes on my table. 

