---
layout: post
title: "ActiveRecord: Implementing a many-to-many relationship"
tags: activerecord mychain rails
author: Robin Roestenburg
published_at: "2011-08-22"
---
*Magic: The Gathering* spell cards cost mana to play - the cost is shown on the top right of the card's image. Each mana symbol on the card represents one mana of that color that must be paid when playing the card as a spell. A number in a gray circle next to the mana symbols represents how much additional generic mana must be paid; this additional mana can be of any color or colorless. For example, the *Accorder Paladin* card shown below costs two mana in total - one white and one other.

![Mana Symbols](http://farm7.static.flickr.com/6204/6070456565_c456728ec6.jpg)

Thankfully (for me building the scraper ;-)) the page containing card details on Gatherer also shows the mana cost in the table with card information.

### has_many :through or has_many_and_belongs_to?
How to store this information? First I have to be change the model so that mana symbols can be stored on the card. A card can have zero or more mana symbols, and every mana symbol can be used by many cards. A many-to-many relationship.

There are two ways to model the many-to-many relationship in Rails. You can use:

-    the `has_many :through` association and
-    the (older) `has_many_and_belongs_to` (also called `habtm`) association.

The Rails documentation states that: *The simplest rule of thumb is that you should set up a `has_many :through` relationship if you need to work with the relationship model as an independent entity. If you don&rsquo;t need to do anything with the relationship model, it may be simpler to set up a `has_and_belongs_to_many` relationship.*

The many-to-many relationship between a card and mana symbols is simple enough for using `habtm`. However, I want to explicitly specify the ordering of the mana symbols as they appear on the card. As I see it now I can only do this using the `has_many :through` association and add an attribute to the join model containing the ordering of the mana symbols for the card. If anyone knows a better way, let me know!

### Generating the model and defining the associations
Generating the model for two models, **Mana** &amp; the join model (**CardMana**) is pretty straightforward:

    rails generate model Mana identifier:string
    rails generate model CardMana card_id:integer mana_id:integer mana_order:integer

The **Mana** model has (for now) only one attribute, the identifier of the mana symbol. The **CardMana** model is a little more complex as you have to specify the foreign keys to either side of the relationship. Also, it contains the attribute `mana_order` which specifies the ordering.  **Note: Do not name the attribute you want to use for ordering your association 'order'. It will not generate SQL like ORDER BY order.. this not worky :P**

After defining the associations the model classes look like this (omitted all other details):

    #!ruby
    class Card &lt; ActiveRecord::Base

      has_many :card_mana
      has_many :mana, :through =&gt; :card_mana

    end

    class CardMana &lt; ActiveRecord::Base

      belongs_to :card
      belongs_to :mana

    end

    class Mana &lt; ActiveRecord::Base

    end

I have not set up the inverse relationship in the **Mana** class, as I don't need it (yet).

### Working the relationship
Ok, so now to check if it all works like expected. First I want to check if I can add new mana symbols to the card:

    #!ruby
    test "should have a list of mana elements" do
      card = cards(:accorder_paladin)
      card.mana &lt;&lt; manas(:one)
      card.mana &lt;&lt; manas(:white)

      assert_equal 2, card.card_mana.size
    end

Added two mana symbols, R and B, results in the join model being automatically updated to contain 2 elements. Note that the ordering of the mana symbols on the card is not stored. In order to also store the ordering into the join model I have to add the mana symbols using the join-model. The test I wrote for testing the ordering shows how:

    #!ruby
    test "should have an ordered list of mana elements" do
      card = cards(:accorder_paladin)
      card.card_mana.create(:mana_order =&gt; 1,
                            :mana =&gt; manas(:one))
      card.card_mana.create(:mana_order =&gt; 2,
                            :mana =&gt; manas(:white))

      assert_equal Mana.find_by_code('1'), card.card_mana[0].mana
      assert_equal Mana.find_by_code('W'), card.card_mana[1].mana
    end

The tests adds two ordered mana symbols to the *Accorder Paladin* card, 1 and white, and checks that they are retrieved in the correct order into the `card_mana` array.

### Adding :order
The above test passed, but it failed when I changed the ordered list test to add the mana symbols in a different order:
    #!ruby
    card.card_mana.create(:mana_order =&gt; 2,
                          :mana =&gt; manas(:white))
    card.card_mana.create(:mana_order =&gt; 1,
                          :mana =&gt; manas(:one))

Turns out I forgot to specify the order of the associated objects of the CardMana model class. It is probably ordered by time of insertion of the rows into the join model.

Specifying the order in which the associated `card_mana` objects are returned is again straightforward, I've changed the Card model class like this:

    #!ruby
    class Card &lt; ActiveRecord::Base

      has_many :card_mana, :order =&gt; 'mana_order ASC'
      has_many :mana, :through =&gt; :card_mana

    end

Tests are passing again ;)

**Day #14 (two weeks!)**

