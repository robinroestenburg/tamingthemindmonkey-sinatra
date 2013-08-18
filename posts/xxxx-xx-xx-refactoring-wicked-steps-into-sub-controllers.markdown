---
layout: post
title: Refactoring Wicked steps into sub controllers
author: Robin Roestenburg
published_at: "2012-10-04"_
--

Wicked is a gem which allows you to create a multi-step wizard in a short amount
of time. Check out the Railscasts about it if you are not familair with the gem.

It is a great gem when used for wizards with few steps and/or are operating on a
single object. Problems arise in the maintainability/clean code area when your
wizard has more steps and is using/updating multiple objects in those steps. 

The problem is probably best shown by giving an example:

``` ruby
# app/controllers/some_wizard_controller.rb
class SomeWizardController < ApplicationController
  include Wicked::Wizard

  steps :introduction,
        :information,
        :some_more_information,
        :store_the_final_result,
        :etcetera

  def show                                                                       
    case step                                                                    
    when :introduction                                                           
      @foo = initialize_foo
    when :information                                                   
      @bar = retrieve_information
    when :some_more_information                                                              
      @baz = create_a_baz
    when :store_the_final_result                                                                
      @quux = update_a_quux
    when :etcetera
      ...
    end                                                                          

    render_wizard                                                                
  end                              

  ...
end
```

As you can see, for a wizard with a couple of steps this alreay becomes a bit of
a nightmare. Take into account that the `update` method of this controller looks
relatively the same.

## Goal of refactoring

It would be much nicer if you could use a controller for each step of the
wizard. The above example would turn into something like this:

``` ruby
## app/controllers/some_wizard_controller.rb
class SomeWizardController < ApplicationController
  include Wicked::Wizard

  steps :introduction,
        :information,
        :some_more_information,
        :store_the_final_result,
        :etcetera
  
  ...

end

## app/controllers/some_wizard_introduction_controller.rb
class SomeWizardIntroductionController < SomeWizardController

  def show
    @foo = initialize_foo
    render_wizard
  end

end

## app/controllers/some_wizard_information_controller.rb
...
```

You get the idea ;-)

Some conditions this refactoring must adhere to:

- You should be able to use the 'normal' mode as well (that is: not using
  sub-controllers).
- Preferrably, you should not have to configure or do anything else. I think
  this will be hard to accomplish because new routes probably need to be
  defined.

## Here we go!

Ok first thing to do, is find out how Wicked works. There are a couple of things
I need to know:

1. To navigate back and forth through the wizard, Wicked provides helper methods
   `next_wizard_path` and `previous_wizard_path`. The path of the current step
   can be obtained through `wizard_path`. How do these methods work? Is this the
   way to change it or should I use something else when handling the incoming
   request to the controller?

I tweaked the wizard_path method as follows:
- Created a string from the wizard controller concatenated with the step to go
  to (if any) and 'controller'. I check if the constant is defined, two options
  - constant is defined, a subcontroller exists - redirect to that controller
  - constant is not defined use regular wizard controller for handling request.

But when passing the sub-controller to the url_for_ method, the link changes to
/my_steps_introduction/introduction. This is not what I want. I want to be able
to use /my_steps/introduction_ and still redirect to another controller.

The options of url_for_ are not helping:

``` text
Options
:anchor - Specifies the anchor name to be appended to the path.
:only_path_ - If true, returns the relative URL (omitting the protocol, host name, and port) (true by default unless :host is specified).
:trailing_slash_ - If true, adds a trailing slash, as in "/archive/2005/". Note that this is currently not recommended since it breaks caching.
:host - Overrides the default (current) host if provided.
:protocol - Overrides the default (current) protocol if provided.
:user - Inline HTTP authentication (only plucked out if :password is also present).
:password - Inline HTTP authentication (only plucked out if :user is also present).
```

There are some options (like controller, action, etc.) that are passed directly
to the Router. I will have to look into that.


2. Write a spec which tests the new / expected functionality.

3. Write an integration test to test the implementation in an actual web app.

4. Set up a sample project to spike little things.

