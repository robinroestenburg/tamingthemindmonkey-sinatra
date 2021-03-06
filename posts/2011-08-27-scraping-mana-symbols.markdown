---
layout: post
title: "Scraping mana symbols"
tags: mychain tdd
author: Robin Roestenburg
published_at: "2011-08-27"
---
I kinda lost my actual goal for this chain out of sight for the last couple of days. I've not written a lot of code for the program and got a bit sidetracked by Ruby/Rails details. It kinda turned into me exploring the Ruby world ;) But as I am working on a chain, I have made a commitment to produce something that will get me closer to my goal every day.

Let me repeat the goal again: *Write a web application that can be use to manage a collection of Magic: The Gathering (MTG) cards.*
Ok, so let's go and be productive ;)

### Rewriting tests
A couple of days ago I've written a post about the ==-method that I added to the Card model. I removed it today and rewrote my tests using custom assertion methods in Test::Unit:

~~~ ruby
test "should return detailed information of the the Black Lotus card" do
  VCR.use_cassette('detail_pages') do
    scraper = Gatherer::DetailsPage.new(BLACK_LOTUS_IDENTIFIER)
    card = scraper.get_card_details
    assert_card_equal cards(:black_lotus), card
  end
end

def assert_card_equal(c, o, msg = nil)
  full_message = build_message(msg, "? is not equal to ?.", c, o)
  assert_block(full_message) do
    c.name        == o.name &&
    c.cost        == o.cost &&
    c.strength    == o.strength &&
    c.toughness   == o.toughness &&
    c.category    == o.category &&
    c.number      == o.number &&
    c.artist      == o.artist &&
    c.rarity      == o.rarity &&
    c.description == o.description &&
    c.flavor      == o.flavor &&
    c.identifier  == o.identifier
end
~~~

Using this new assertion I can check whether the attributes of a card are all being scraped correctly without saving to the database or anything like that.

### Scraping mana symbols
I've worked on the data model for storing the mana symbols of a card this week. Now for scraping the mana symbols on the details page. The symbols are displayed as a images, for the *Accorder Paladin* card the HTML looks like this:

~~~ html
<div id="ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_manaRow" class="row">
  <div class="label" style="line-height: 25px;">Mana Cost:</div>
  <div class="value">
    <img src="/Handlers/Image.ashx?size=medium&name=1&type=symbol" alt="1" align="absbottom">
    <img src="/Handlers/Image.ashx?size=medium&name=W&type=symbol" alt="White" align="absbottom">
  </div>
</div>
~~~

The Mana model has a `code` attribute, which I use to store the code of a mana symbol. The above two mana symbols would have the following codes: '1' and 'W'.
Using the following CSS selector I grab each image present in the mana row:

~~~ text
#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_manaRow div.value img
~~~

For each image a new **CardMana** object is created. The following attributes of this object are:

- *mana_order*: using a `each_with_index` enumerator I can easily use the `index` variable to fill the `mana_order` attribute
- *mana*: first a search on the **Mana** table for a mana symbol with the code that is equal to the leftmost character of alt-text of the image is performed. If there is no result, then a new mana symbol is added to the database.

The actual scraping code for the mana symbols looks like this:

~~~ ruby
def card_mana_on_page
  card_manas = []
  @page.css(mana_images).each_with_index do |img, index|
    card_mana = create_card_mana(img, index)
    card_manas << card_mana
  end
  card_manas
end

def mana_images
  "#{row_identifier}manaRow div.value img"
end

def create_card_mana(img, index)
  card_mana = CardMana.new
  card_mana.mana_order = index
  card_mana.mana = Mana.find_by_code(img[:alt][0]) || Mana.create!(code: img[:alt][0])
  card_mana
end
~~~
