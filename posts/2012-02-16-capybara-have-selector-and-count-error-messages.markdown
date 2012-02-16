---
layout: post
title: "Capybara: have_selector and :count error messages"
tags: capybara cucumber rails
author: Robin Roestenburg
published_at: "2012-02-16"
---
I am a big fan of [Capybara](https://github.com/jnicklas/capybara), but it has some minor bugs and shortcomings that
have been annoying me for a couple of weeks now. For example, failure messages could be more informative, and when
using a scope, I would like to have warnings when accessing elements outside of that scope.

But no more! :-) Tonight I've fixed one of the annoyances.

### Failure messages fail
Using Capybara you can check if a particular piece of html contains a selector (could be xpath or css).
For example, consider the following piece of html:

~~~ html
<html>
  <body>
    <div class='monkey'></div>
    <div class='monkey'></div>
    <div class='monkey'></div>
    <div class='monkey'></div>
  </body>
</html>
~~~

In my Cucumber step definitions I could check for the presence of the `monkey` css-class, as follows:

~~~ ruby
page.should have_selector('.monkey')
~~~

The `have_selector` method will return *true* if the selector specified returns at least one element.
You can check if an element is contained a specific number of times by adding the `:count` option,
like this:

~~~ ruby
page.should have_selector('.monkey', :count => 4)
~~~

This is all pretty obvious. Now let's look at the failure messages that are generated! Say, we don't
want to select the monkey css class but feel like we need a great ape.

~~~ ruby
page.should have_selector('.great-ape')
~~~

Cucumber's output (for my made-up scenario) looks like this (I pruned the output a bit for better
readability):

~~~ cucumber
Feature: See monkeys

  Scenario: See the monkeys
    Given I have some tamed monkeys
    When I visit the homepage
    Then I should see a list of tamed monkeys
      expected css ".gorilla" to return something (RSpec::Expectations::ExpectationNotMetError)
~~~

This is what I expected, an error saying the selector could not be found on the page. Let's see
what happens when we go back to selecting monkeys but add a `:count` to the mix:

~~~ ruby
page.should have_selector('.monkey', :count => 5)
~~~

~~~ cucumber
Feature: See monkeys

  Scenario: See the monkeys
    Given I have some tamed monkeys
    When I visit the homepage
    Then I should see a list of tamed monkeys
      expected css ".monkey" to return something (RSpec::Expectations::ExpectationNotMetError)
~~~

The same error! This has led me in the wrong direction when searching for the cause of the
failure a couple of times now - time to do something about it.

### Fixing the failing failure message
I forked the Capybara project, cloned it and ran the tests (pretty cool to watch the Selenium tests
fly by btw):

~~~ text
  1413/1413:   100% |==========================================| Time: 00:01:56
~~~

We're good to go.

I'm familiar with Capybara so I know there is a `has_selector?` method that belongs to the
`Capybara::Node::Matchers` module. I'm guessing the `have_selector` method will be implemented using
the `has_selector?` method, so this method will be my starting point:

~~~ ruby
def has_selector?(*args)
  options = if args.last.is_a?(Hash) then args.last else {} end
  synchronize do
    results = all(*args)
    query(*args).matches_count?(results) or raise Capybara::ExpectationNotMet
    results
  end
rescue Capybara::ExpectationNotMet
  return false
end
~~~

That did not help me much :-) Let's look at the tests:

~~~ ruby
it "fails if has_css? returns false" do
  expect do
    "<h1>Text</h1>".should have_css('h2')
  end.to raise_error(/expected css "h2" to return something/)
end

it "passes if matched node count equals expected count" do
  "<h1>Text</h1>".should have_css('h1', :count => 1)
end

it "fails if matched node count does not equal expected count" do
  expect do
    "<h1>Text</h1>".should have_css('h1', :count => 2)
  end.to raise_error(/expected css "h1" to be returned 2 times/)
end
~~~

The tests are checking the behavior that I see failing in the previous example.
Why do I get different results? If the problem is not in the `has_selector` method,
it must be in the `have_selector` method and my assumption that these methods would
be related turns out to be false.

The `have_selector` method is implemented using a RSpec matcher class, originally
named `HaveSelector`. All other `have`-like methods are implemented using another
matcher class, `HaveMatcher`.

When the matcher fails (e.g. the selector does not match the page), it uses the
`failure_message_for_should` method to generate an failure message. Can you spot
the difference between the `HaveSelector` and `HaveMatcher` implementation?

~~~ ruby
class HaveSelector
  def failure_message_for_should
    results = @actual.resolve(query)
    query.error(results)
  end
end

class HaveMatcher
  def failure_message_for_should
    if failure_message
      failure_message.call(actual, self)
    elsif(@options[:count])
      "expected #{selector_name} to be returned #{@options[:count]} times"
    else
      "expected #{selector_name} to return something"
    end
  end
end
~~~

The implementation in the `HaveMatcher` looks good, this means that I can use a
`:count` on the `have_css` method and get a proper error message (as it is
implemented using the `HaveMatcher` class.

The problem in `HaveSelector`'s implemtation seems to be in the `query.error()` method.

~~~ ruby
class Query
  def failure_message_for_should
    if failure_message
     failure_message.call(actual, self)
    else
     "expected #{selector_name} to return something"
    end
  end
end
~~~

This is exactly the same method as the `HaveMatcher` class, though missing the `elsif` on the
`@options[:count]`. I've resisted the urge to refactor the duplication in generating failure
messages and added the missing condition (and this duplicating some more). I've also added
some tests for it and made a pull request.

Y u no refactor? I want to do the refactoring next, but I don't know how long it will take
and if it will be succesful. That's why I've only implemented a small fix for now.
