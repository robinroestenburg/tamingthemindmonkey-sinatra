---
layout: post
title: "Rails: Readable tests by using fixtures"
tags: fixtures mychain rails ruby
---
I spent some time working on the scraper for the pages containing the card details. After implementing most of the functionality I ended up with the following test:
    #!ruby

    test "should return detailed information of the Accorder Paladin card" do
      scraper = Gatherer::Details.new
      card = scraper.get_card_details(Nokogiri::HTML(@accorder_paladin_printed_html))

      assert_equal "Accorder Paladin",        card.name
      assert_equal 2,                         card.cost
      assert_equal 3,                         card.strength
      assert_equal 1,                         card.toughness
      assert_equal "Creature &mdash; Human Knight", card.category
      assert_equal 1,                         card.number
      assert_equal "Kekai Kotaki",            card.artist
      assert_equal "Uncommon",                card.rarity
      assert_equal [...removed text...],      card.description
      assert_equal 1,                         card.description.size
      assert_equal [...removed text...],      card.flavor
      assert_equal 1,                         card.flavor.size
    end
I don't like my tests having more than one assertion, because this limits the readability of a test in my opinion. I wanted to refactor it to a test which would have an assertion that looked something like
    #!ruby
    assert_equal accorder_paladin_object, card
### Fixtures
Luckily Rails gives you *fixtures*, a way to specify sample data which is loaded into the test database before running your tests. These fixtures can be specified in YAML or CSV, YAML is the preferred format.

The YAML-format is very easy to read. For example, specifying the *Biorhythm* card looks like this:
    #!yaml
    biorhythm:
      name: Biorhythm
      cost: 8
      category: Sorcery
      number: 247
      artist: Ron Spears
      rarity: Rare
      description:
        ["Each player's life total becomes the number of creatures he or she controls."]
      flavor:
        ["&lt;i&gt;\"I have seen life's purpose, and now it is my own.\"&lt;/i&gt;",
         "‐Kamahl, druid acolyte"]

Rails automatically loads all fixtures from the `test/fixtures` folder into your tests. Loading is done in three steps:

*    Remove existing data from the table corresponding to the fixture
*    Load the fixture data into the table
*    Dump the fixture data into a variable in case you want to access it directly.

The variable name for the Biorhythm card would become `:biorhythm` and the Card object can be retrieve by using `cards(:biorhythm)`.

### Refactoring
I thought I could just rewrite all assertions in the above testcase into one line (and basically moving all card specifics into the YAML file) like this:
    #!ruby
    assert_equal cards(:accorder_paladin), card
Compare the fixture against the Card object returned by the scraper, should be easy ;)

However the test failed and I spent the next half hour trying to get it to work. First I thought the fixture was the problem, but the testing the fixture using the following test (based on original test) did not fail:
    #!ruby
    assert_equal "Accorder Paladin", cards(:accorder_paladin).name
    assert_equal 2,                  cards(:accorder_paladin).cost
    assert_equal 3,                  cards(:accorder_paladin).strength
    ...
Second, I tried comparing the individual fields of the fixture against the card returned by the scraper - this was also working.

After this I figured there was something wrong with the test for equality in the `assert_equals` method when comparing two Card objects. This turned out to be correct. Defining a custom method for the `==`-operator in the Card class solved the problem.
    #!ruby
    def ==(o)
      name        == o.name &amp;&amp;
      cost        == o.cost &amp;&amp;
      strength    == o.strength &amp;&amp;
      toughness   == o.toughness &amp;&amp;
      category    == o.category &amp;&amp;
      number      == o.number &amp;&amp;
      artist      == o.artist &amp;&amp;
      description == o.description &amp;&amp;
      flavor      == o.flavor
    rescue
      false
    end
The custom method checks all fields of Card and returns true when they are all equal. I'd would have preferred the `&amp;&amp;`'s in front of each line, but Ruby doesn't like that (don't know how to fix it yet -- maybe later).

As for my tests: I've now added fixtures for 5 cards and set up a test for each card. This allows me to test the scraper for a different cards very quickly while still keeping them readable (2 lines per test).

*Day #7*
