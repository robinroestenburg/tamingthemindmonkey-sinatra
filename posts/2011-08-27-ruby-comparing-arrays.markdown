---
layout: post
title: "Ruby: Comparing arrays"
tags: ruby mychain
author: Robin Roestenburg
published_at: "2011-08-27"
---
One small follow-up post on my [previous post](http://www.tamingthemindmonkey.com/scraping-mana-symbols) on scraping the mana symbols. I actually forgot something before building the mana symbol scraping code. I had not changed the `assert_card_equal` to also compare the mana symbols that are present on an card. Not really TDD'ish :-) So, after I finished the code all my tests were still passing even though I had not added the **Card** to **Mana* mappings to the fixtures.

The list of mana symbols of the card fixture had to be compared to the list of mana symbols (and their ordering) to the scraped card. This proved to be a bit of a challenge. I came up with the following solution:

~~~ ruby
assert_block(full_message) do
  a = card.card_mana.map { |cm| [cm.mana_order, cm.mana.code] }
  b = other_card.card_mana.map { |cm| [cm.mana_order, cm.mana.code] }

  ((a | b) - (a &amp; b)).empty?
end
~~~

This may need some explaining :)

I thought I could just take the *exclusive or* of the two arrays: if the size is 0 then the two arrays are equal (there are no elements that are in one array but not in another). The `((a | b ) - (a &amp; b)).empty?` should do just this (see [Ruby-Forum](http://www.ruby-forum.com/topic/168040)). This didn't work, because an unsaved **CardMana** object is never equal to another object (I learned that the [hard way](http://www.tamingthemindmonkey.com/do-not-override-the-method-of-activerecordbas) :)).

I worked around it by creating two arrays (`a` and `b`) for comparison. The `map` enumerator creates a new array for each card (`c` and `o`) which contains objects that contain the mana_order and the code of the mana symbol. These new arrays are comparable - and work great to compare if the list of mana symbols of one card are equal to the other card's mana symbols.

### Alternative implementation
The `((a | b) - (a &amp; b))` syntax is a bit difficult to understand. One David A. Black also posted another solution:

~~~ ruby
module EnumExOr
  def ^(other)
    reject {|e| other.include?(e) }.
    concat(other.reject {|e| include?(e) })
  end
end

array = [1,2,3,4,5].extend(EnumExOr)

p array ^ [3,4,5,6,7]   # [1,2,6,7]
~~~

Though I'm not going to use this yet in my code, I have tested this solution and it works. It is a much easier to understand `(a ^ b).empty?`.
