---
layout: post
title: "Migrating Rails application to Postgres: Migration"
tags: mychain postgres rails
author: "Robin Roestenburg"
published_at: "2011-09-21"
---

Yesterday, I wrote a post about installing Postgres on your Mac. This post will explain how to migrate your Rails application to Postgres.

### Configuring Rails
In a basic Rails application there are only two files that need to be changed before you can use Postgres as a database server. First, you have to change the adapter and location of the databases used in the different environments to point to the new Postgres database. This information is stored in the file **config/database.yml**. After making the changes the file **database.yml** could look like this:

~~~ yaml
development:
  adapter: postgres
  database: mtg_development
  username: robin
  password: ""

test: &test
  adapter: postgres
  database: mtg_test
  username: robin
  password: ""

cucumber:
  <<: *test
~~~

Next we have to remove the default **sqlite** gem from the **Gemfile** and replace it with the **pg** gem. Of course, run the **bundle install** command to activate the changes in the **Gemfile**.

### Loading the schema
The application is now able to talk to a Postgres database. Running your tests will probably fail miserably, because the database schema of your application if not yet loaded into the new Postgres database.

Assuming you have no data to migrate, you can easily load the schema with the following command:

~~~ text
rake db:schema:load
~~~

This command loads the schema into your development database, in my case **mtg_development**. In the Postgres console, I can check if the schema has really been loaded by running the **\d** command (shows all tables/sequences):

~~~ text
mtg_development=# \d
                List of relations
 Schema |        Name         |   Type   | Owner
--------+---------------------+----------+-------
 public | card_images         | table    | robin
 public | card_images_id_seq  | sequence | robin
 public | card_manas          | table    | robin
 public | card_manas_id_seq   | sequence | robin
 public | cards               | table    | robin
 public | cards_id_seq        | sequence | robin
 public | colors              | table    | robin
 public | colors_id_seq       | sequence | robin
 public | delayed_jobs        | table    | robin
 public | delayed_jobs_id_seq | sequence | robin
 public | manas               | table    | robin
 public | manas_id_seq        | sequence | robin
 public | rarities            | table    | robin
 public | rarities_id_seq     | sequence | robin
 public | schema_migrations   | table    | robin
(15 rows)
~~~

Looks about right :-)

### Wrapping it up
There are two more steps that should be performed to complete the migration to Postgres:

- migrating the data and
- running the tests to verify if everything is still working.

When you encounter any problems with migrating to Postgres it will probably be in these two steps. For my simple application which is still running in development, this was not the case and therefore I'll probably not be of any help to you in the following two sections :-)

**Data migration**
I have not performed any migration of my data - I started over with an empty database.

Most of the time this is not an option, and you have to migrate your data to the new application. This should be pretty straightforward, as the structure of the database stays the same, but I can't speak from experience.

One tip from the [PostgreSQL screencast](https://peepcode.com/products/postgresql) by [Peepcode](https://peepcode.com/): when migrating form MySQL take a look at [this gem](https://github.com/maxlapshin/mysql2postgres) for automatically migrating your data. .

**Running the tests**
Next up, check if all tests are still passing after the migration to Postgres has been completed. Don't forget to run:

~~~ text
rake db:test:prepare
~~~

This will load the schema into the test database as well. Personally I had no problems, but I can imagine you have to fix some or more tests depending on how much custom sql you are using.
