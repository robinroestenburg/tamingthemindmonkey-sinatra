---
layout: post
title: "Changing attributes on Card model to many-to-one associations"
tags: mychain rails
---
Today I normalized the **Card** data model a bit. I converted two attributes into associations:

- **rarity**: contains the rarity of a card. Possible values: *Common*, *Uncommon*, *Rare*, *Mythic Rare*.
- **color**: added [yesterday](http://www.tamingthemindmonkey.com/color-attribute-not-present-on-details-page-h) and contains the color of a card. Possible values: *Green*, *White*, *Red*,  *Black*, *Blue*, *Multicolor*, *nil* (actually not a value ;)).

### Changing the tests
The tests did not need much changing. Only the `assert_card_equals` needed changing so as to compare the (non-existing) **Rarity** and **Color** objects instead of the attributes. As this change broke my tests I had to generate the models and declare the association first.

### Declaring the belongs_to association
First I created the two new models I needed to store the data of the attributes in:
    rails generate model Rarity identifier:string name:string
    rails generate model Color identifier:string name:string

Now I needed a many-to-one relationship from **Card** to the new models. This can be done by specifying `belongs_to` associations in the **Card** model to these new models. The name of this association is a bit confusing, I mean, a **Card** does not *belong to* a **Color** or a **Rarity**. I suppose the rarity of the color should be seen as some kind of category in this case.

When declaring a `belongs_to` association you need to add a foreign key to the table of the model which contains the declaration of the `belongs_to` association. In this case I needed to add two foreign keys to the **Card** model:
    rails generate migration add_color_id_and_rarity_id_to_card color_id:integer rarity_id:integer

Loving Rails' ability to automatically generate the correct migration from the above command :)
    #!ruby
    # Generated migration.
    class AddColorIdAndRarityIdToCard &lt; ActiveRecord::Migration
      def self.up
        add_column :cards, :color_id, :integer
        add_column :cards, :rarity_id, :integer
      end

      def self.down
        remove_column :cards, :rarity_id
        remove_column :cards, :color_id
      end
    end

Ah, almost forgot to remove the old attributes:
    rails generate migration remove_color_and_rarity_from_card

### Changing the tests (again)
After adding the model and declaring the association, the method for comparing two cards was working. The tests were failing, because my scraper code was still writing to the non-existing color and rarity attributes (which I had just removed). The scraper code returned errors like this:
    ActiveRecord::AssociationTypeMismatch: Rarity(#2198861860) expected, got String(#2151928260)

I rewrote the scraper code to make the tests pass again. The method to scrape the rarity of a card from the details page now looks like this:
    #!ruby
    def rarity_on_page
      rarity = @page.at_css("#{ROW_IDENTIFIER}rarityRow div.value span")
      if rarity
        rarity = rarity.content.strip
        Rarity.find_by_name(rarity) || Rarity.create!(identifier: rarity.first, name: rarity)
      end
    end

When a rarity is specified on the details page, the rarity is returned from the database or created and then returned.

I'm not to happy with the code. Aside from it being a bit verbose, I wanted to keep the scraper ignorant about database-stuff like creating/retrieving etc. I'm now thinking I should let the scraper return something like `xml` or `json` that would have to be parsed into an object model. This would make the scraper be completely decoupled from the application and would make testing it easier (no custom equals-method).

I'll be exploring this tomorrow night.

### Even more changes to the tests
Back to the tests, which are still failing. Now because I have yet to adjust the fixtures. Once these are correctly in place the tests are passing :-)

**Day #21 - Three weeks ;)**
