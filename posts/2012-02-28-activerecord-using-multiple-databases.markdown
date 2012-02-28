--- 
layout: post 
title: "ActiveRecord: Using multiple databases"
author: Robin Roestenburg 
tags: rails activerecord mychain 
chain: "Digging into Rails"
published_at: "2012-02-27" 
---
In a [previous post](/2012/02/26/digging-into-rails-connecting-to-the-database)
I came across ActiveRecords ability to use a different databases for specific
model classes. From the top of my mind I can think of some scenarios where this
would be useful e.g.,

* Migration of data from one database to another.
* Using a specialized database to hold a portion of your data (like geographical
  data or something).

Normally you would establish a connection for all ActiveRecord::Model classes:

~~~ ruby
ActiveRecord::Model.establish_connection(
  :adapter  => "postgres",
  :host     => "localhost",
  :username => "root",
  :password => "",
  :database => "monkey_business"
)
~~~

If you would like a specific class to make use of another database then just
call `establish_connection` on this class. This will not affect the other
databases.

### Migrating from hexadecimal monkeys!
Let me show you how this work with an example. Say we have an old database
containing monkeys. The database is called `encoded_ape`, the table containing
the monkeys is called `_6d6f6e6b657973`. I guess someone thought it was a good
idea to have the table names be encoded into a hexadecimal format. Even worse,
the attribute names and the data are also encoded in a hexadecimal format, good
times ;-) 

The database we are migrating to is that of our running example,
`monkey_business`. It has a table `monkeys` which will contain all migrated
monkey data.

#### Creating the Active Record classes
First, I will create Active Record classes to represent each of these tables:

~~~ ruby
class Monkey 
  include ActiveRecord::Model
end

class OldMonkey
  include ActiveRecord::Model
end
~~~

The `OldMonkey` will represent the monkey data from the `encoded_ape` database.  

#### Configuring the database connections
I will store the database configuration in `config/database.rb`. I will leave
the `ActiveRecord::Model.establish_connection` configuration as it is and create
a specific one for the encoded database:

~~~ ruby
OldMonkey.establish_connection(
  :adapter  => "postgres",
  :host     => "localhost",
  :username => "root",
  :password => "",
  :database => "encoded_ape"
)
~~~

#### Testing the database connections
Next, I will make sure I can retrieve the data from the old database using the
`OldMonkey` model. I set a custom table name (for more on table names, click
[here](/2012/02/28/activerecord-using-multiple-databases)) to be able to access
the `_6d6f6e6b657973` table and then I should be able to retrieve the data from
that database.

~~~ ruby
class OldMonkey
  include ActiveRecord::Model
  self.table_name = '_6d6f6e6b657973'
end

p OldMonkey.all
#=> [#<OldMonkey _6e616d65: "42616279205079676d79204d61726d6f73657473">, 
#    #<OldMonkey _6e616d65: "537175697272656c204d6f6e6b6579">, 
#    #<OldMonkey _6e616d65: "537069646572204d6f6e6b6579">]
~~~

This works. I checked if accessing the `Monkey` class works and it does. 

#### Migration
To finish this example I have created a `MigratesMonkeys` class that migrates
the data from the encoded table to the non-encoded `monkeys` table. Nothing
fancy, it looks like this:

~~~ ruby
class MigratesMonkeys

  def migrate
    OldMonkey.all.each do |old_monkey| 
      monkey = Monkey.new
      monkey.name = decode(old_monkey.name)
      monkey.save
    end
  end

  def decode(name)
    [name].pack('H*')
  end

end
~~~

A couple of notes:

* I've added the name method which wraps around the `_6e616d65` attribute on the
  `OldMonkey` class for clarity of the example. 
* Decoding the hexadecimal string is done using Ruby's `pack`- method, check it
  out [here](http://ruby-doc.org/core-1.9.3/Array.html#method-i-pack).

Let's take a look at the contents of the `monkeys` table before and after
running the example: 

~~~ ruby
p Monkey.all
#=> []

MigratesMonkeys.new.migrate

p Monkey.all
#=> [#<Monkey name: "Baby Pygmy Marmosets">, 
#    #<Monkey name: "Squirrel Monkey">,
#    #<Monkey name: "Spider Monkey">]
    
~~~

It works! 

That was a quick example of creating a small Ruby application using Active
Record that migrates data between two databases. It's small and easy to set up,
I like it. 

That's all for today. 

**I've posted the code examples for this blog post on Github, check it out
[here](https://github.com/robinroestenburg/digging-into-rails/tree/master/005-using-multiple-databases).**



