---
layout: post
title: "Fixtures be gone"
tags: factory_girl fictures mychain
author: Robin Roestenburg
published_at: "2011-09-02"
---
I didn't have much time to work on the application yesterday, so I only replaced the fixtures by objects that are created inside the test for which they provide the data. Today I want to clean this up a bit by introducing factories to the tests.

### Why replace fixtures anyways?
Ryan Bates did a Railscast about replacing fixtures way-way-way back, see [episode #60](http://railscasts.com/episodes/60-testing-without-fixtures) from 2007. There are a couple of reasons to get rid of the fixtures, but the most important one is that fixtures separate the data we are using in a test from the actual behavior that is being tested. It becomes an external dependency to a test, a dependency being used by multiple other tests. This makes the tests break easily: a change in the fixture to pass one test could make cause a whole bunch of others to fail. Also, the test becomes more difficult to read because you have to look into the fixtures file to understand the test.

For example, I have a couple of test that test my Card model. The following tests if a image if present on the card (I know, not the most brilliant test :)):

~~~ ruby
test "should have a card image" do
  card = cards(:black_lotus)
  assert_not_nil card.card_image
  assert_equal   42, card.card_image.size
end
~~~

I can deduce from this test that the 'Black Lotus' card is supposed to have a card image and that this should be defined in my fixture data. But it is not directly clear, I have to look at the fixture data to check what the data really is (could be nil for all I know).

Now look at this rewritten version of the test (using [factory_girl](https://github.com/thoughtbot/factory_girl)):

~~~ ruby
test "should have a card image" do
  card = Factory.build(:card,
                       :card_image => Factory.build(:card_image,
                                                    :size => 42))
  assert_not_nil card.card_image
  assert_equal   42, card.card_image.size
end
~~~

This test is more verbose, but it's immediately clear what I'm testing. The `factories.rb` file looks something like this by the way:

~~~ ruby
Factory.define :card do |c|
  c.name "Foo"
  c.identifier 42

  c.association :color
  c.association :rarity
end

Factory.define :color do |c|
  c.identifier "B"
  c.name "Black"
end

Factory.define :rarity do |r|
  r.identifier "Rare"
  r.name "Rare"
end

Factory.define :card_image do |ci|
  ci.content_type "image/jpeg"
  ci.size 31668
end
~~~

### Functional tests and fixtures
I've replaced all my fixtures by factories except the fixtures I was using to functionally test the scraper. These tests are depending on data of specific cards that were being scraped in the test. The scraped result was then compared against the fixture.

A factory is not really intended for those kind of tests. An example of a fixture I was using looks like this:

~~~ yaml
black_lotus:
  name: Black Lotus
  cost: 0
  category: Mono Artifact
  artist: Christopher Rush
  rarity: rare
  description:
    ["Adds 3 mana of any single color of your choice to your mana pool, then is discarded. Tapping this artifact can be played as an interrupt."]
  identifier: 600
~~~

This is too much detail for a factory, I would be overwriting all the attributes. So, I've replaced the fixtures with objects scoped to the test in which it is compared. I think I'll end up specifying this data in some kind of higher level test of the scraper using Cucumber or something.

### Get rid of the 'Factory'
There is also an option in `factory_girl` that allows you not to repeat the `Factory.` every time you create/build an object. Specify this in your test class (for Test::Unit):

~~~ ruby
include Factory::Syntax::Methods
~~~

This will allow you to write your test like this:

~~~ ruby
test "should not save card with duplicate identifier" do
  create(:card, :identifier => 1234)

  card = build(:card, :identifier => 1234)
  assert !card.valid?, "Saved card with duplicate identifier"
end
~~~

I'm not really sure if I like this yet. Seeing a `Factory.create` declaration is a trigger for me, like 'Hey, there is something created by factory_girl here'. On the other hand, it might just be something to get used to. The tests look cleaner though.
