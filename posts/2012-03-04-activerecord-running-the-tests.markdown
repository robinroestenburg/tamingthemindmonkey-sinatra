--- 
layout: post 
title: "ActiveRecord: Running the tests"
author: Robin Roestenburg 
tags: rails activerecord mychain 
chain: "Digging into Rails"
published_at: "2012-03-04" 
---
Because of limited time I will write a short post today about running the unit
tests for ActiveRecord. All other tests in the Rails test suites are trivial to
run, but to run the ActiveRecord test you have to put a little more effort into
it.

### Setting up the test databases
First, we need a database to run our tests against. Default Rails will use a
sqlite database, but I want to run it on Postgres. I will have to create a test
database first. 

Rails comes with a Rake task to construct Postgres databases for testing
purposes: `postgresql:build_databases`. This tasks creates two databases:

* `activerecord_unittest`, and
* `activerecord_unittest2`

It will create these databases with default settings for the Postgres database.
If you need another port or host, for instance, you have to copy the
`test/config.example.xml` to `test/config.xml` and edit it
accordingly (from within the `activerecord` project directory).

### Running the tests
Next up, running the tests. There are a couple of ways you can do this:

* Run `rake test`, this will test ActiveRecord against the `mysql`, `mysql2`,
  `sqlite3` and `postgresql` adapters. 
* Run the tests for a specific adapter i.e., using `rake test_postgresql`. Run
  `rake -T` within the `activerecord` project directory to get a list of other
  adapters that have a rake task to run the tests.
* Run a specific test file using `ruby -Itest test/cases/base_test.rb`.
  If you want to use a different database then your default database from your
  `config.xml` then set the `ARCONN` variable: `ARCONN=postgresql ruby -Itest
  test/cases/base_test.rb` 
* Run a specific test using `ruby -Itest test/cases/base_test.rb -n
  test_if_something_works`.

### Error...
I tried running the tests for the Postgres adapter, it resulted in the following
error:

~~~ text
/Users/robin/.rvm/rubies/ruby-1.9.3-preview1/lib/ruby/1.9.1/minitest/spec.rb:131:
  in `register_spec_type': wrong number of arguments (1 for 2) (ArgumentError)
~~~

Rails 4 will run on Ruby 1.9.3, and it turns out that I was using a preview 
version of Ruby 1.9.3 which did not contain the new `register_spec_type` method 
just yet. I should be ready to run the tests after:

* upgrading RVM (`rvm get latest`), 
* reloading RVM (`rvm reload`),
* installing Ruby 1.9.3-p0 (`rvm install 1.9.3-p0`), 
* recreating the gemset for Rails (`rvm --create --rvmrc 1.9.3@rails`)
* installing Bundler (`gem install bundler`), and
* installing all of Rails' dependencies (`bundle install`).

### Running the tests - Pt. 2
Take two, running `rake test_postgresql`:

~~~ text
Finished tests in 57.112900s, 60.1615 tests/s, 184.4242 assertions/s.

3436 tests, 10533 assertions, 0 failures, 0 errors, 31 skips
~~~

Cool, that is it for today. Tomorrow I will continue the posts on saving a
record to the database (see [this
post](http://localhost:4567/2012/03/02/activerecord-saving-a-record)). 
