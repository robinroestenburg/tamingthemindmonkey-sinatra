---
layout: post
title: "Ruby: Stubbing with Mocha"
tags: mocha mychain rails
---
The scraper module has some classes that interact with each other. When testing a particular class I want to stub out all other classes, so that I'm able to test the class in isolation. This way, a failing test is almost always caused by the class under test and not some other class. Also, using stubs I'm able to generated some edge cases that are difficult to reproduce otherwise.

Today I've read up on stubs and mocks in Ruby. I've used Mocha to do some initial implementation, liking it a lot. The mocking tools (e.g. Jmockit, Easymock, Mockito) that I've used for Java development provide the same functionality (in one way or the other), but do not even begin to come close when it comes to being easy to use. Also they usually pollute the tests a lot, making them difficult to read.

### Stub or mock?
Whilst writing this post I was wondering about the difference between a stub and a mock. I could not explain the difference clearly, so I decided to look it up. Wikipedia has a pretty decent explanation about mocks and how they compare to stubs, found [here](http://en.wikipedia.org/wiki/Mock_object#Mocks.2C_fakes_and_stubs). I found an even clearer explanation in the [Eloquent Ruby](http://www.amazon.com/Eloquent-Ruby-Addison-Wesley-Professional/dp/0321584104) book by Russ Olsen:

*A stub is an object that implements the same interface as one of the supporting cast members, but returns canned answers when its methods are called. [...] A mock is a stub with an attitude. Along with knowing what canned responses to return, a mock also knows which methods should be called and with what arguments. Critically, a disappointed mock will fail the test. Thus, while a stub is there purely to get the test to work, a mock is an active participant in the test, watching how it is treated and failing the test if it doesn't like what it sees.*

### Mocha
To start with I've used the [Mocha](http://mocha.rubyforge.org/) gem, which I could fit in easily into my existing Test::Unit test cases. When (not if) I cross over to RSpec I'll compare Mocha against the stubbing and mocking capabilities provided by RSpec and see if I'll keep on using it.

Mocha is easy to set up (as always I guess), add the following line to the *Gemfile* of your project:
{% highlight ruby %}
gem 'mocha', '~&gt; 0.9.12'
{% endhighlight %}

Run `bundle install` and you're set.

### Refactoring
The code below was untested, I wrote it in order to get the `delayed_job` gem to work.
{% highlight ruby %}
class Scraper &lt; Struct.new(:set_name)

  def perform
    cards = []

    checklist = CheckListPage.new(set_name)
    identifiers = checklist.get_card_identifiers

    identifiers.each do |identifier|
      details = DetailsPage.new(identifier)
      card = details.get_card_details
      card.color = checklist.get_card_color(identifier)
      cards &lt;&lt; card
    end

    cards
  end
end
{% endhighlight %}

I knew to be able to test this code efficiently I had to fake the **CheckListPage** and **DetailsPage** classes. I did not know how to do that then, so I skipped the tests - am going to write them now :) The current code could use some refactoring before I continue though, the creation of the **CheckListPage** and the retrieval of the identifiers should be done in a separate method:
{% highlight ruby %}
class Scraper &lt; Struct.new(:set_name)

  def perform
    cards = []

    identifiers = card_identifiers_for_set(set_name)

    identifiers.each do |identifier|
      details = DetailsPage.new(identifier)
      card = details.get_card_details
      card.color = @checklist.get_card_color(identifier)
      cards &lt;&lt; card
    end

    cards
  end

  def card_identifiers_for_set(set_name)
    @checklist = CheckListPage.new(set_name)
    @checklist.get_card_identifiers
  end
end
{% endhighlight %}

Same should be done with the code inside the `each`-block:
{% highlight ruby %}
class Scraper &lt; Struct.new(:set_name)

  def perform
    cards = []

    identifiers = card_identifiers_for_set(set_name)

    identifiers.each do |identifier|
      card = get_card(identifier)
      cards &lt;&lt; card
    end

    cards
  end

  def card_identifiers_for_set(set_name)
    @checklist = CheckListPage.new(set_name)
    @checklist.get_card_identifiers
  end

  def get_card(identifier)
    details = DetailsPage.new(identifier)

    card       = details.get_card_details
    card.color = get_card_color(identifier)
    card
  end

  def get_card_color(identifier)
    @checklist.get_card_color(identifier)
  end
end
{% endhighlight %}

Much better. The refactoring also shows me what parts of the class I need to fake to get a test to work. The interaction with the **CheckListPage** and **DetailsPage** classes is contained in the methods `card_identifiers_for_set` and `get_card`.

### Writing the test
I want to test the following: *The scraper should return the details for every card present in a checklist.* I wrote the following initial test:
{% highlight ruby %}
test "should return details for every card present in checklist" do
  scraper = Gatherer::Scraper.new('Mirrodin Besieged')
  scraped_cards = scraper.perform

  assert_not_nil scraped_cards
  assert_equal 155, scraped_cards.size
end
{% endhighlight %}

This fails because I am using Fakeweb and this gem disables all HTTP connections while running your tests:
{% highlight text %}
FakeWeb::NetConnectNotAllowedError:
  Real HTTP connections are disabled.
  Unregistered request:
    GET http://gatherer.wizards.com/Pages/Search/Default.aspx?output=checklist&amp;set=[%22Foo%22].
  You can use VCR to automatically record this request and replay it later.
{% endhighlight %}

I don't want to record this test in VCR, the generated YAML file would be huge. I decided to stub out the two methods mentioned above:
{% highlight ruby %}
test "should return details for every card present in checklist" do
  scraper = Gatherer::Scraper.new('Foo')
  scraper.stubs(:card_identifiers_for_set).returns([1,2,3,4,5])
  scraper.stubs(:get_card).returns(Factory.build(:card))

  scraped_cards = scraper.perform

  assert_not_nil scraped_cards
  assert_equal 5, scraped_cards.size
end
{% endhighlight %}

As you can see, there are 5 identifiers returned by the stubbed method. And for each identifier a card is returned from the factory. The test asserts that the returned number of cards by the **Scraper** class is not nil and contains 5 cards. I do not care for the details of the cards, I am testing that elsewhere.

There some things I could improve in the above code and tests. The stub is not exactly on the class boundary - I think I need to improve that.

Additionally, I could verify that the `get_card` method is called exactly 5 times (as expected) by adding the following line to the test (before the `perform`-method call):
{% highlight ruby %}
Scraper.expects(:get_card).times(5).returns(build(:card))
{% endhighlight %}

**Day #1 (Back to day one, I broke the chain yesterday after 25 days.)**
