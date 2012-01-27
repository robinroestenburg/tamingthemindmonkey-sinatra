---
layout: post
title: "ActiveRecord: default_scope not applied when used in has_many :through associations"
tags: activerecord mychain rails
author: Robin Roestenburg
published_at: "2011-08-25"
---
Currently I have defined the following many-to-many relationship in my model:
    #!ruby
    class Card &lt; ActiveRecord::Base
      has_many :card_mana, :order =&gt; "mana_order ASC"
      has_many :mana, :through =&gt; :card_mana, :order =&gt; "card_manas.mana_order ASC"
    end

    class CardMana &lt; ActiveRecord::Base
      belongs_to :card
      belongs_to :mana
    end

    class Mana &lt; ActiveRecord::Base
    end

I wanted to DRY up the model by defining the ordering in the only logical place, the **CardMana** class. Defining a `default_scope` on the **CardMana** class and define the ordering in there should do the trick.
However, the tests failed (on Rails 3.0.9) when I changed the model to this:
    #!ruby
    class Card &lt; ActiveRecord::Base
      has_many :card_mana
      has_many :mana, :through =&gt; :card_mana
    end

    class CardMana &lt; ActiveRecord::Base
      default_scope :order =&gt; 'mana_order ASC'

      belongs_to :card
      belongs_to :mana
    end

    class Mana &lt; ActiveRecord::Base
    end

The ordering was not applied when the `default_scope` was added to the join model. I Google'd around a bit and found the following two sites where people were basically having the same problem:

- [has_many :through associations may not respect default_scope :conditions](https://rails.lighthouseapp.com/projects/8994/tickets/3610-has_many-through-associations-may-not-respect-default_scope-conditions)
- [Default_scope on a join table](http://stackoverflow.com/questions/5463385/default-scope-on-a-join-table)

The first site is an issue in the previous issue tracker for Rails (I'm guessing from before they moved to Github). The issue was then rejected as being invalid: the `default_scope` in the join model is not considered when accessing the `has_many :through` association.

So, when specifying `card.first.mana` the `default_scope` defined in the **CardMana** join model is not part of the "default" scope for this statement or something? Feels like a bug to me.

I'll try out Rails edge this weekend and see if it has not already been fixed. If it has not been fixed, I'll try and fix it and send in the patch. It'll be good experience for me to get more familiar with the Rails code.

**Day #17**
