---
layout: post
title: "Decoupling the Gatherer library"
tags: mychain
---
Tonight I've be working on (or rather thinking about) decoupling the scraper code from the model classes. In various parts in the scraper I use model classes directly. For example, the following code creates a record in the join-model **CardMana**:
{% highlight ruby %}
def create_card_mana(code, index)
  card_mana = CardMana.new
  card_mana.mana_order = index
  card_mana.mana = Mana.find_or_create_by_code(code: code)

  card_mana
end
{% endhighlight %}

[SRP](http://www.objectmentor.com/resources/articles/srp.pdf) states that a class should have only one reason to change. The scraper code violates this principle now, because changes to the model will result in changes to the scraper. Therefore all usages of the model classes should be removed. The **one** reason to change the scraper is when the Gatherer site changes.

Also, I want to release the scraper as a gem (first and foremost to walk through the whole process of releasing a gem), I can't have the gem depending on these model classes.

### Where to start?
I'm not quite sure how to start. I have been looking for more information most of this night - was not able to find anything good though. I've come up with the following three steps to decouple the code from my application.

- First, I'll start with replacing every model class by a `Struct` in the Gatherer library.
- Then the `jsonify` gem will convert the scrapers result (the `Structs`) to a json response which can be decoded by a client.
- Last, I'll have to write the code that decodes the json response to the model classes.

Tomorrow I'll write a post about these steps. Hopefully it will turn out as planned ;)
