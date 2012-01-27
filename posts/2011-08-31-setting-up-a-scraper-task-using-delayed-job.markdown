---
layout: post
title: "Setting up scraper task using Delayed Job"
tags: delayed_job mychain rails
author: Robin Roestenburg
published_at: "2011-08-31"
---
Scraping a set of Magic: The Gathering cards will take a couple of minutes. I want to run this through a background task. Heroku (where I probably will host the application, once finished) supports running background processes through [delayed_job](https://github.com/collectiveidea/delayed_job) (DJ).

### Setting up delayed_job
Configuring the application to use DJ should be very easy. Most (all) 'Getting started'-documentation I found online have not been update for Rails 3 though. These are the 4 steps that I needed to get DJ set up:

##### 1. Install the gem
Install the gem first. Add the following line to your `Gemfile`:
    #!ruby
    gem 'delayed_job', '~&gt; 2.1.4'
Run the `bundle install` command to install the new gem.
##### 2. Generate the table
Now you are able to generate the DJ script and migration. The README file on [collectiveidea/delayed_job](https://github.com/collectiveidea/delayed_job) Github page says you can generate these with:
    script/rails generate delayed_job
This does not work in Rails 3 and you should use (if you are running Rails 3) the following command:
    rails generate delayed_job
It generates the following files:
    create  script/delayed_job
     chmod  script/delayed_job
    create  db/migrate/20110830183509_create_delayed_jobs.rb
Run the migration using `rake db:migrate` and you're good to go.
##### 3. Configuration options!
Ok, this part is *very* important and cost me a lot of time to figure out. Create a file called `delayed_job_config.rb` in the `script/initializers` directory. This file contains the options for DJ. I've put the following options in mine:
    #!ruby
    Delayed::Worker.destroy_failed_jobs = false
    Delayed::Worker.sleep_delay = 60
    Delayed::Worker.max_attempts = 3
    Delayed::Worker.max_run_time = 5.minutes
The most important one is the `destroy_failed_jobs` option, if set to *true* you'll not know if and why a particular job failed. DJ will log the failure message into the database if the option is set to *false*. For example, I had a problem that the location of my custom job (`lib`) was not available in the Rails `autoload_paths` - I did not find out until I saw what DJ logged into the failed job.
##### 4. Starting the worker
This is pretty easy (there is another way - check the documentation):
    rake jobs:work

### Custom scraper job
There are a couple of ways to run a piece of code in a background process using DJ:

- Calling `.delay.method(params)` on any object.
- Marking a method with `handle_asynchronously`.
- Creating a custom job class.

Take a look at the documentation on Github for more information.

I've chosen to create a custom job. With the first two options it is not directly clear that a particular method is being redirected to a background task. The custom job option uses a pretty verbose command to start the custom job (as you'll see later on). It is then immediately clear that a background task is being created.

The scraper job looks like this:
    #!ruby
    class ScraperJob &lt; Struct.new(:set_name)

      def perform
        checklist = CheckListPage.new(set_name)
        identifiers = checklist.get_card_identifiers

        identifiers.each do |identifier|
          details = DetailsPage.new(identifier)
          card = details.get_card_details
          card.color = checklist.get_card_color(identifier)
        end
      end
    end

For DJ to be able to run the task the job needs a `perform`-method - this method runs the actual task. The name of the set to scrape is provided to the job via a struct from which the job extends - this is (supposedly) convention for these kind of jobs.

This particular implementation is scraping the Gatherer-pages (yay!), but it is not actually storing anything yet. I'm not sure yet how and where to write the code that stores the information into the database.

Running the job can be done as follows:
    Delayed::Job.enqueue Gatherer::Scraper.new('Mirrodin Besieged')

### Troubleshooting: autoload_path
Arghh.. that's all I have to say about this part ;) I've spent some (too much) time on getting this to work and in the end it was pretty simple (as it always is).

Eventually, this was the problem I was facing: the `ScraperJob` was running correctly when executing the method from rails console. When enqueueing it and running it with DJ the following error occurred:
    ruby-1.9.2-p290 :001 &gt; Delayed::Job.enqueue Gatherer::Scraper.new('Mirrodin Besieged')
    NameError: uninitialized constant Gatherer

(I did not see this error at first though, because I was require'ing Gatherer - doH! I then only found out after checking the failure message in the job table.)

This was caused by the fact that the `lib`-directory (where the the Gatherer module is stored) was not in the `autoload_path` of Rails. I added the following line to application.rb:
    #!ruby
    config.autoload_paths += %W(#{config.root}/lib)

### Success!
After this the job was processed by DJ in the background and it scraped the complete 'Mirrodin Besieged' set - very cool :)

**Day #22 &amp; #23**
