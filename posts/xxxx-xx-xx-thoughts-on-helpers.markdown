Today I want to share my thoughts on helper modules/methods in Rails. 

I have been programming in Rails for about half a year and I remember quite
clearly how amazed I was when I saw a helper method being used for the
first time.  

It did make sense to extract the logic from the view, but storing it in a helper
did not seem like the best solution. However, to my understanding it was a Rails
practice and I've seen them being used in the projects I've worked on so far.
Also, I could not think (or did not have the knowledge) of anything better at
that time.  

Even more strange was the `helper_method` method by which you can make a
controller method available to the view. This did not make sense at all, seemed
a bit lazy to use them. You cou But again, to my understanding it was good
practice.


Today, my thoughts on helpers can be summarized as follows: DO NOT USE THEM.
Well, at least that was my first thought - read on and see how my mind has
changed a bit.



### Move business logic to models

Sometimes helper methods are actually a representation of some sort of business
logic on the model. There should be no discussion about this, it should be moved
to the model. 

Example:



### Replace all other logic with presenters

Most things that end up helpers are:

* extracted logic, like conditionals
* complex 

These are the things for which a presenter should be used. 

Reasons to use a presenter:

* You give the method a place to live, now it just sits in a module. Which means
  it is just a plain namespaced method. 
* Testing is easy (easier then testing helper methods).
* You are explicitly binding the behavior to the view in the controller. There
  are no surprises in the view. 

The presenters should be instantiated in the controller, not from the view. You
want a clean separation between the things that happen in the controller and the
view.

There is a catch-22 here though, if you want to remove all conditionals to a
presenter then it is better to use a helper method for some of it.



### Create helper methods for conditional views

if record.flag?
  "html stuff"
else
  "...."
end

I do not really like moving the generation of these pieces of html to a Ruby
class like a presenter or a helper method. 

But, I do like to use a view presenter which 'presents' a piece of the view. So
then we could replace the previous example with:

htmstuff(record)

This would render a template containing the html. Now, note that I would not use
this right away - but only when I need to reuse a piece of the view more than
once and the conditional is not trivial.



### Exceptions to the rule

Like any good rule, there are exceptions of course: 

As Avdi has stated in his Objects on Rails book, helper method can be useful as
a way to make instance variables available to the view without using the
variable (which makes for brittle design). 

Another is the I18n h() and l() methods that are made available to the view via
helper methods. I consider these to be utility methods, that are not specific to
a single controller. More like these are: `form_for`, `url_for` etc. One, could
argue that the view presenter is a utility method as well, but I think the
behavior is slightly different, because its job is no to generate html. 

These are the only things I can come up with right now. 


### 

So that's it, these are my thoughts on helpers. It has helped me clear my head
on when to use them and when not. I hope you agree, maybe you don't - I'd love
to get some feedback on it!
