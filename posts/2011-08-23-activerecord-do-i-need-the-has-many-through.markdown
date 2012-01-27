---
layout: post
title: "ActiveRecord: Do I need the has_many :through?"
tags: activerecord mychain rails
author: Robin Roestenburg
published_at: "2011-08-23"
---
Yesterday I've implemented a many-to-many relationship in Rails using the has_many :through association.

I was thinking about that implementation some more today and one thing that bugged me a little is the fact that I have added two associations on my **Card** model class and I'm only using one of them. The **Card** model class looks like this:

    #!ruby
    class Card &lt; ActiveRecord::Base

      has_many :card_mana, :order =&gt; 'mana_order ASC'
      has_many :mana, :through =&gt; :card_mana

    end

Do I really need the **:mana** association there? I'm not using it right now. I'm only using the **:card_mana** has_many association to add the mana symbols to the card. I have to add the mana symbols through the **:card_mana** association, because that is the only way I can specify the ordering of the symbols. After deleting **:mana** has_many association, the tests are still passing. So, technically I don't need it...

The only way it could be of use is when the **:mana** association also contained an ordered list of mana symbols. I could then use it to display the mana symbols that are present on a card directly instead of going through the **card_mana** association.

In order to check the behavior, I've added another test:
    #!ruby
    test "should have a ordered list of mana symbols" do
      card = cards(:accorder_paladin)
      card.card_mana.create(:mana_order =&gt; 2,
                            :mana =&gt; manas(:white))
      card.card_mana.create(:mana_order =&gt; 1,
                            :mana =&gt; manas(:one))

      assert_equal Mana.find_by_code('1'), card.mana[0]
      assert_equal Mana.find_by_code('W'), card.mana[1]
    end

This test checks if the list of mana symbols (using the **:mana** association) is ordered correctly. The test fails with the following error message:

    Loaded suite test/unit/card_test
    Started
    F
    Finished in 0.128392 seconds.

    1) Failure:
    test_should_have_a_ordered_list_of_mana_elements(CardTest) [test/unit/card_test.rb:55]:
    &lt;#&lt;Mana id: 980190962, code: "1", created_at: "2011-08-23 21:12:37", updated_at: "2011-08-23 21:12:37"&gt;&gt; expected but was
    &lt;#&lt;Mana id: 47173029, code: "W", created_at: "2011-08-23 21:12:37", updated_at: "2011-08-23 21:12:37"&gt;&gt;.

Adding the **:order** option to the **:mana** association which should get this test to pass. I've changed the association to this:
    #!ruby
    has_many :mana, :through =&gt; :card_mana,
                    :order =&gt; 'card_manas.mana_order ASC'

Tests are passing and I now have an ordered array of mana symbols on my Card model class.

Technically I don't really need this extra **:mana** association on my Card model class, but I think it'll be a good shortcut to use later on in development. The convention seems to always specify the two has_many associations together though (have not seen examples that did only specify one) - I'll try to find out if there is a reason (one that I'm missing) for that.

**Day #15**
