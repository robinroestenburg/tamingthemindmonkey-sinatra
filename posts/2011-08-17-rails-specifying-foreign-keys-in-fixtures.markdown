---
layout: post
title: "Rails: Specifying foreign keys in fixtures"
tags: fixtures mychain rails
author: Robin Roestenburg
published_at: "2011-08-17"
---
Today I've added scraping the image of a particular *Magic: The Gathering* card into the database. For this I had to create the **CardImage** model, which was pretty straight forward. The **CardImage** model class looks like this:

~~~ ruby
class CardImage &lt; ActiveRecord::Base
  attr_accessible :data, :size, :content_type
end
~~~

After creating the **CardImage** model I defined the behaviour of the **CardImage** in the application. I defined the following test as a first case:

~~~ ruby
test "should have a writable card_image attribute" do
  card  = Card.new
  card.card_image = card_images(:black_lotus)
  assert_not_nil card.card_image
end
~~~

To get this test to pass I've added a `has_one` relationship called `card_image` to the Card model and a fixture (named `black_lotus`). While adding the fixture I spotted a potential problem: how to store the binary in the YAML file? I'll write a post about this tomorrow.

Next testcase: when I load a card (e.g. Black Lotus), I want the `card_image` attribute returning the image belonging to this card (and not some random other card).

~~~ ruby
test "should have the right cardimage" do
  black_lotus = cards(:black_lotus)
  assert_equal card_images(:black_lotus), black_lotus.card_image
end
~~~

This failed with the following error:

~~~ text
test_should_have_the_right_cardimage(CardTest):
  ActiveRecord::StatementInvalid: SQLite3::SQLException:
    no such column: card_images.card_id:
    SELECT "card_images".* FROM "card_images" WHERE ("card_images".card_id = 1053489865) LIMIT 1
~~~

I forgot to add the `card_id` attribute to the **CardImage** model. After adding this the test was still failing; this time because of incorrect data in the `cards` and `card_images` fixtures. In the `card_images` fixture I had to reference to which card the image belonged to. For this to work I had to specify the id for each card in the cards fixture (they were being auto generated). The fixtures now looked like this:

~~~ yaml
# cards.yml
black_lotus:
  id: 5
  name: Black Lotus
  ...

# card_images.yml
black_lotus:
  size: 1
  data: foo
  content_type: png
  card_id: 5
~~~

As you can see specifying foreign keys in fixtures this way is pretty fragile and difficult to understand. ActiveRecord to the rescue! It finds all the `belongs_to` associations in the fixture's model class (**CardImage**) and lets you specify a target label for the association (e.g. `card: black_lotus`) instead of a target id for the foreign key (e.g. `card_id: 5`). The above fixture can now be rewritten into:

~~~ yaml
# cards.yml
black_lotus:
  name: Black Lotus
  ...

# card_images.yml
black_lotus:
  size: 1
  data: foo
  content_type: png
  card: black_lotus
~~~

Much better! I had to add the `belongs_to` assocation to the **CardImage** model class before, but then it was working and the test passing.
