---
layout: post
title: "Digging into Rails: Start"
tags: rails mychain
author: Robin Roestenburg
published_at: "2012-02-23"
---
It has been around 11 months since I wrote my first Rails (and Ruby)
application, the `sample_app` application that I wrote following the Rails 3
Tutorial by Michael Hartl. Check it out on
[Github](https://github.com/robinroestenburg/sample_app) (and have a good laugh
;)).

Since then, my knowledge of Ruby and the Rails framework have increased.
Especially after I switched from Java to Ruby at work three months ago. I have
learned a lot more in those three months than in the period before when I was
working my way through books and articles and trying things out on hobby
projects.

But now, the time has come to dig deeper and learn about Rails' inner workings.
The knowledge I gain will let me make better judgments when creating
applications using Rails and therefore create better applications with it. Also,
knowing how the framework works will give me more confidence deciding/explaining
when to use the framework and (maybe even more important) when not to use it.

### So, where to start?

I want to start exploring from the bottom-up, but to do that I must know which
components Rails consists of, what they do, and of course which comes first. 

As the Rails [source](https://github.com/rails/rails) is pretty well-structured
this was not very difficult to find out. Rails is made up of the following
modules:

* **ActiveRecord**: connects classes to relational database tables to establish
  a persistence layer for applications
* **ActiveModel**: provides a set of interfaces for usage in model classes
* **ActiveResource (ARes)**: connects business objects and REST web services
* **ActiveSupport**: a collection of utility classes and standard library
  extensions
* **ActionPack**: a framework for handling and responding to web requests,
  providing mechanisms for routing (**ActionDispatch**), defining controllers
  (**ActionController**) and generating responses by rendering views
  (**ActionView**)
* **ActionMailer**: a framework for designing email-service layers
* **Railties**: responsible for gluing all frameworks together
* **ARel**: a SQL AST manager for Ruby (where AST stands for: abstract syntax
  tree) which simplifies the generation of complex SQL queries and adapts to
  various RDBMS systems
* **Journey**: a router, it routes requests.

Some of these descriptions (taken from the README's of the different modules)
are a bit vague-ish, but I hope to be able to give a better/more elaborate
explanation of these modules in a couple of weeks.

[ARel](https://github.com/rails/arel) and
[Journey](https://github.com/rails/journey) are separate projects that Rails
uses. 

### Bottoms up

I consider the bottom of the framework to be the component that interacts with
the information, usually a database. In Rails this is ActiveRecord and I
guess ultimately ARel.  I do not know if ActiveRecord is only delegating
creating SQL to ARel or if ARel is a layer through which
ActiveRecord accesses the database -- I will start with ARel for now,
see how it used by ActiveRecord and continue from there.

That is it for today, a small post to get me started on my chain. 

