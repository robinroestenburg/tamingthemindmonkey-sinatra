---
layout: post
title: "ActiveRecord: Persisting arrays using serialized attributes"
tags: activerecord mychain rails
---
Magic: The Gathering cards have rules and/or flavor text printed on them. While storing these lines into the model I came across a nice feature of Rails' ActiveRecord.

At first I was going to store every line into a new record in the database and make the lines available through a `has_many` relationship on the *Card* model. This would've looked something like this (*hoping my [yUML](http://yuml.me) is strong yes*):

![Initial model](http://yuml.me/diagram/scruffy/class/%5BCard%5D+1-ruleLines%20%3E*%5BRuleLine%5D,%20%5BCard%5D+1-flavorLines%3E*%5BFlavorLine%5D "Initial model")

After thinking about it some more I figured I'd not be cross-referencing the flavor or rule lines and I could do without the *FlavorLine* and *RuleLine* extension to my model. I'd have to be able to store and retrieve the lines from a single attribute on the *Card* model to make this work.

I could do this the easy way: take all lines, put `br`'s between them and be done with it. This would leave me in the situation that I would only be able to view this data correctly in HTML. Any other format and I'd have to do something about those breaks.

Enter ActiveRecord's serialized attributes. By annotating a model's attribute with the _serialize_ keyword, you can store any Ruby type into your model. This means we are also able to store arrays into a single attribute.

In the *Card* model I've created two serialized attributes: *flavor* and *description*.
    #!ruby
    class Card &lt; ActiveRecord::Base
      serialize :description
      serialize :flavor
    end

You can write to them as you would to the 'normal' attributes. See for example the code for scraping the flavor text of a card:
    #!ruby
    def flavor_text_on_page(page)
      lines = []

      page.css("#{ROW_IDENTIFIER}flavorRow div.cardtextbox").each { |row|
        lines &lt;&lt; row.inner_html
      }

      lines if lines.size &gt; 0
    end

    card.flavor = flavor_text_on_page(page)

For each `div`-element containing a line of flavor text a line is added to the `lines`-array. This array is then written to the `flavor` attribute on the Card model.

Persisting the card to the database will store the array into YAML format. In Rails 3.1 it will also be possible to write your own serializer using `load` and `dump` methods which will be used in retrieving and loading serialized data from and to the database. See a more detailed post about this [here](http://edgerails.info/articles/what-s-new-in-edge-rails/2011/03/09/custom-activerecord-attribute-serialization/index.html "Custom ActiveRecord attribute serialization").
