---
layout: post
title: "Migrating Rails application to Postgres: Installation"
tags: mychain postgres
---
I've moved my Rails application from the default SQLite to a Postgres database.

I watched the Peepcode screencast on [PostgreSQL](https://peepcode.com/products/postgresql) the other day and it walked through the process of migrating your Rails application to a Postgres database. I had not worked with Postgres for more than 5 years and I was pleasantly surprised by the progress that has been made on it.

Furthermore, all Heroku applications use a Postgres database and since I'm planning on running the application over there it is probably best to have my local development and test environment match this.

### Installation
The installation of the PostreSQL database server on a Mac is a breeze, thanks to [Homebrew](http://mxcl.github.com/homebrew/). After installing Homebrew (see [here](https://github.com/mxcl/homebrew/wiki/installation) for instructions), run the following command:
{% highlight text %}
    brew install postgresql
{% endhighlight %}

This installs PostgreSQL onto your system. After this, you have to set up the directory where the data will be stored. Run the following command to specify this place:
{% highlight text %}
    initdb /usr/local/var/pg_data
{% endhighlight %}

You can then start the database server by running either one of the following commands:
{% highlight text %}
    pg_ctl -D /usr/local/var/pg_data -l /tmp/logfile start

    postgres -D /usr/local/var/pg_data/
{% endhighlight %}

The first will start the server as a system service, the second one will start the server in your current terminal window.

### Troubleshooting
I had an issue with PostgreSQL on OS X Lion. Lion comes with a preinstalled version of Postgres. Executing the above commands result in an error like:
{% highlight text %}
    psql: could not connect to server: Permission denied
        Is the server running locally and accepting
        connections on Unix domain socket "/var/pgsql_socket/.s.PGSQL.5432"?
{% endhighlight %}

Thankfully, the problem has already been solved and documented in [this post](http://nextmarvel.net/blog/2011/09/brew-install-postgresql-on-os-x-lion/).

### Check 1.. 2.. 3..
Once the server is running you can check if everything works as you expected by creating a database named `mtg` with the following command:
{% highlight text %}
    createdb mtg
{% endhighlight %}

Open the postgres console for this database:
{% highlight text %}
    psql mtg
{% endhighlight %}

Now you are able to run some SQL statements on the database (commented lines are the result as returned by Postgres):
{% highlight sql %}
    CREATE TABLE card (id integer, name varchar, PRIMARY KEY(id));
    -- CREATE TABLE
    INSERT INTO card VALUES (0, 'Black Lotus');
    -- INSERT 0 1
    INSERT INTO card VALUES (1, 'Akroma, Angel of Wrath');
    -- INSERT 0 1
    SELECT * FROM card;
    --  id |          name
    -- ----+------------------------
    --   0 | Black Lotus
    --   1 | Akroma, Angel of Wrath
    -- (2 rows)
{% endhighlight %}

That's it, easy enough to get started!

*Day #1*