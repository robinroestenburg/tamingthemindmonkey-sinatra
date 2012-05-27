---
layout: post
title: "Setting up a Rails plugin with RSpec and Cucumber"
author: "Robin Roestenburg"
tags: rails how-to
published_at: "2012-05-27"
---

Since Rails 3.1 it is possible in Rails to generate gemified plugins using the
`rails plugin` command. Using it, you can easily create an extension for Rails
that you can use on other projects or that you can share with other people. 

I won't be going into details on Rails plugins in this post. However, there is
an excellent Rails guide on creating a plugin. Check it out
[here](http://guides.rubyonrails.org/plugins.html). 

Also, check out the book 'Crafting Rails Applications' by Jose Valim.
Throughout the book he uses the `enginex` gem, which got merged into Rails and
formed the basis for the current plugin functionality.

What I want to talk about today is how to set up a Rails plugin using the RSpec
and Cucumber frameworks instead of the Test::Unit default. There are some
guides online, but I have found them lacking a bit - so I decided to try to
write one myself.

### Creating a Rails plugin

You can generate a plugin for Rails using the `rails plugin new` command. It
will generate a skeleton for developing any kind of Rails plugin. Creating a
plugin called `foo` would generate the following files:

``` text
~/ rails plugin new foo                                                                                                               
      create  
      create  README.rdoc
      create  Rakefile
      create  foo.gemspec
      create  MIT-LICENSE
      create  .gitignore
      create  Gemfile
      create  lib/foo.rb
      create  lib/tasks/foo_tasks.rake
      create  lib/foo/version.rb
      create  test/test_helper.rb
      create  test/foo_test.rb
      append  Rakefile
  vendor_app  test/dummy
         run  bundle install
```

A dummy Rails application is created under `test/dummy` which includes the
code of the Rails plugin you are developing (located under `/lib`). This dummy application is the Rails
environment that is used to run your tests against.

As you can see, a dummy unit test has been generated using the Test::Unit
framework and the `test_helper.rb` file contains the following line:

``` ruby
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
```

This line will make sure the tests are run against the dummy applications'
environment.

As I don't like Test::Unit, I want to switch it out for RSpec combined with
Cucumber. Let's start with RSpec.

### Add RSpec support

Adding RSpec is can be done in the following three steps:

* Removing Test::Unit as default test framework.
* Moving the dummy Rails environment within the RSpec test directory.
* Installing RSpec as the default test framework.

#### Remove Test::Unit

This probably the easiest step :-). Generate the plugin using the command
`rails plugin new foo --skip-test-unit`.  It will not generate any Test::Unit
files, but generate the following files:

``` text
~/rails plugin new foo --skip-test-unit
      create  
      create  README.rdoc
      create  Rakefile
      create  foo.gemspec
      create  MIT-LICENSE
      create  .gitignore
      create  Gemfile
      create  lib/foo.rb
      create  lib/tasks/foo_tasks.rake
      create  lib/foo/version.rb
         run  bundle install
```

No more Test::Unit files are generated, but no dummy Rails environment was
generated as well. Let's fix that.  

#### Move the dummy Rails environment 

Another easy one, generate the plugin using the command `rails plugin new foo
--skip-test-unit --dummy-path=spec/dummy`. It will generate the following
files:

``` text
~/rails plugin new foo --skip-test-unit --dummy-path=spec/dummy
      create  
      create  README.rdoc
      create  Rakefile
      create  foo.gemspec
      create  MIT-LICENSE
      create  .gitignore
      create  Gemfile
      create  lib/foo.rb
      create  lib/tasks/foo_tasks.rake
      create  lib/foo/version.rb
  vendor_app  spec/dummy
         run  bundle install
```

The dummy Rails environment is generated again, and we can move on to the next
step: installing RSpec as the default test framework.

#### Install RSpec 

Installing into Rails is well-documented on the RSpec documentation site, check
it out
[here](https://www.relishapp.com/rspec/rspec-rails/v/2-10/docs/gettingstarted).
The same steps apply for installing RSpec into the generated Rails plugin:

* Add the `rspec-rails` gem to the Gemfile.
* Install the bundle.
* Bootstrap RSpec using `rails generate rspec:install`.

After these steps you should be ready to go, but you are not! 

What's up? When trying to bootstrap RSpec you will get the following output:

``` text
~/foo rails generate rspec:install
Usage:
  rails new APP_PATH [options]
  ...
```

We are missing the `script/rails` script (which gets generated when creating a
new Rails application). We can copy the one from our dummy Rails environment
and adjust it to look like this:

``` ruby
#!/usr/bin/env ruby

## This command will automatically be run when you run "rails" with Rails 3 
## gems installed from the root of your application.

APP_PATH = File.expand_path('../../spec/dummy/config/application',  __FILE__)
require File.expand_path('../../spec/dummy/config/boot',  __FILE__)

require 'rails/commands'
```

After running the `rails generate rspec:install` again, RSpec gets bootstrapped
into the dummy Rails application. We want RSpec in the main directory of the
plugin so let's move the `spec` and `spec/spec_helper.rb` back to the root of
the plugin.

After this, we also need to adjust the path to the Rails application to use
when running RSpec. This path is configured in the `spec/spec_helper.rb` file:

``` ruby
require File.expand_path("../../spec/dummy/config/environment", __FILE__)  
```

One minor problem, we cannot run `rake spec`. This has to do with the absence of
the RSpec task in the Rakefile, I'll look at this in a later post. In the
meantime, we can run our tests using `rspec` (or `bundle exec rspec`).

Now, let's show that the setup worked by writing an initial first spec.

#### Writing initial spec

Create the file `spec/baz_spec.rb` with the following contents:

``` ruby
require 'spec_helper'

describe Baz do

  it "should return true" do
    subject.qux.should == true
  end
end
```

Run the test and you should get the following error: `uninitialized constant Baz
(NameError)`. This is to be expected, because we have not created the `Baz` class
yet. Let's create this now in `lib/baz.rb`:

``` ruby
class Baz
end
```

Hmm, now we are still getting the same error? The `Foo` class still cannot be
found, this is because the Rails application is require-ing the `foo` module
from our `lib` directory, but is not including anything else. Adding a require
of the `Baz` class to the module will fix the problem. Running the tests again
results in a `NoMethodError: undefined method 'qux' for
\#<Baz:0x007fafcf076bc0>`. 

After we add the method containing the expected implementation the specs should
be green. 

### Adding Cucumber

Installing Cucumber into Rails is also very well-documented on the Cucumber
Github page, check it out [here](https://github.com/cucumber/cucumber-rails).
Again, the same steps as for RSpec apply for installing Cucumber into the
generated Rails plugin:

* Add the `cucumber-rails` and `database_cleaner` gems to the gemspec file.
* Install the bundle.
* Bootstrap Cucumber using `rails generate cucumber:install`.

Again, we need to move all generated files from the dummy Rails environment to
the root directory of our plugin. 

When you run the `cucumber` command you will get the following error:

``` text
~/Playground/foo cucumber
Using the default profile...
cannot load such file -- /Users/.../foo/config/environment (LoadError)
```

Cucumber is trying to load Rails from the root of our plugin directory. We need
to tell it to look for Rails in the `spec/dummy/ directory.  I found the
following [gist](https://gist.github.com/1121879) that fixes this problem. 

Add the following two to the top of the `features/support/env.rb` file:

``` ruby
ENV["RAILS_ENV"] ||= "test"
ENV["RAILS_ROOT"] ||= File.dirname(__FILE__) + "../../../spec/dummy"
```

**Note**: we don't need to require the `environment.rb` as is done in the gist.
You can tell from the error above that Cucumber is trying to load it already.

After this fix, you should be able to run the `cucumber` command and get the
following output:

``` text
~/foo cucumber 
Using the default profile...
0 scenarios
0 steps
0m0.000s
```

As there are no features yet, we cannot be certain that everything is
configured properly. Let's write an initial feature to test the bootstrapped
Cucumber configuration.  

#### Writing initial feature

Create a file called `features/foo.feature` with the following contents:

``` cucumber
Feature: Bazinga                                                                 
                                                                                 
  Scenario: Calling Qux on a Baz                                                 
    Given I have a Baz                                                           
    When I call Qux on a Baz                                                     
    Then it should return true     
```

Also create a file for the steps called
`features/step_definitions/baz_steps.rb`. Add the following contents:

``` ruby
Given /^I have a Baz$/ do
  @baz = Baz.new
end

When /^I call Qux on a Baz$/ do
  @result = @baz.qux
end

Then /^it should return true$/ do
  @result.should == true
end
```

Running the `cucumber` command again will show you that everything is
configured properly:

``` text
~/foo cucumber
Using the default profile...
Feature: Bazinga

  Scenario: Calling Qux on a Baz # features/baz.feature:3
    Given I have a Baz           # features/step_definitions/baz_steps.rb:1
    When I call Qux on a Baz     # features/step_definitions/baz_steps.rb:5
    Then it should return true   # features/step_definitions/baz_steps.rb:9

1 scenario (1 passed)
3 steps (3 passed)
0m0.198s
```

That's it. You now have a Rails plugin using RSpec and Cucumber. Very good.
Next blog post, I will take a look at configuring RSpec and Cucumber for a
special kind of Rails plugin, an engine. This is far simpler than the plugin
configuration we just did, a lot of things work automatically :-)
