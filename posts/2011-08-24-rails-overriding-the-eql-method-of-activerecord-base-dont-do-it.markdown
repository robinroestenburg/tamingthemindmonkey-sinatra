---
layout: post
title: "Rails: Overriding the == method of ActiveRecord::Base (Don't do it!)"
tags: activerecord mychain rails
---
I ran into some trouble the other day when comparing a **Card** fixture against a **Card** object returned by the scraper code. Asserting that the cards present in the fixtures were the same as the cards that the scraper returned failed. TextMate returned the following error:

![RakeMate error message](http://farm7.static.flickr.com/6076/6076847931_486ca0632e_z.jpg)

This error did not make sense to me for two reasons:

1. Before having the single assertion between two **Card** objects, my test contained an `assert_equal` for every attribute present on the card. The test was passing and I figured rewriting it into a single assertion would [be more readable](http://www.tamingthemindmonkey.com/readable-tests-by-using-fixtures).
2. On closer examination, the error messages produced by TextMate did not show any difference between the expectations and the assertions. In above screenshot this is best seen for test #3.

At that time it was pretty unclear for me what was going wrong - some value(s) of the objects were not equal , but the error message did not tell me which. I then made an incorrect assumption that the cause of the problem was the use of serialized attributes in the **Card** model. *Why did I make that assumption?* Don't know, probably because the error message showed text from the flavor and description attributes and no text/data from the other attributes. Based on an wrong assumption I went ahead and implemented my own `==`-method in the **Card** class (which extends from ActiveRecord::Base).
### youredoingitwrong
The overridden `==`-method just didn't feel right though. I didn't know what was wrong, and didn't think I was going to find out on myself anytime soon. So I explained a colleague of mine (with a lot of Ruby/Rails experience) the problem:
Me: *...explaining the problem...*
Him: *"Why did you override the `==`-method of the ActiveRecord::Base class? You shouldn't do that ;)"*
Me: *"Why not?"*
Him: *"An ActiveRecord object is only equal when the id in the database is the same."*
Me: *"Id? Hmm, I'm not even saving to the database yet - so there are no id's."*
Him: *"Then they are not equal according to the `==`-method and you should test it in a different way."*

I was doing it wrong, doh! At home I looked up what the `==`-method of the ActiveRecord::Base class actually did (check out [base.rb](https://github.com/rails/rails/blob/master/activerecord/lib/active_record/base.rb)):

&gt;Returns true if `comparison_object` is the same exact object, or
&gt;`comparison_object` is of the same type and `self` has an ID and
&gt;it is equal to `comparison_object.id`.

&gt;Note that new records are different from any other record by
&gt;definition, unless the other record is the receiver itself.
&gt;Besides, if you fetch existing records with `select` and leave
&gt;the ID out, you&rsquo;re on your own, this predicate will return
&gt;false.

&gt;Note also that destroying a record preserves its ID in the model
&gt;instance, so deleted models are still comparable."

### Fixing it
As I said the scraper is not saving the cards to the database (I'll let a controller class handle that later). This means that the following code will never pass the assertion:
    #!ruby
    card = scraper.get_card_by_identifier(42)
    assert_equals cards(:answer_to_everything), card

The `card` object is an unsaved ActiveRecord object, which by definition is not equal to anything else.

I could fix it by going back to my unit tests with multiple assertions - one per attributes. As I do not want to go back to the situation of having multiple assertions per testcase I'll probably write a custom assertion that will assert if the values of the scraped card are equal to the expected data (which is in the fixture). I'll write about that in a follow-up post.

### TextMate fail
How about that incorrect assumption though? I figured something was going wrong with the serialized `flavor` and `description` because of the error message that was given by the TextMate test output. However after finding that the problem was in the `id` of the object and not the serialized attributes I decided to check the output of the test when running from command line. The output is totally different though - a diff of the hashes of the objects that are compared is output:
    2) Failure:
    test_should_return_detailed_information_of_the_the_Biorhythm_card(GathererDetailsTest) [/Users/robin/Workspace/rails_projects/mtg/test/unit/gatherer_details_test.rb:39]:
    --- /var/folders/65/60g_29x56kgd0xc468p2ghsm0000gn/T/expect20110824-60481-tdenxs  2011-08-24 14:56:35.000000000 +0200
    +++ /var/folders/65/60g_29x56kgd0xc468p2ghsm0000gn/T/butwas20110824-60481-b06643  2011-08-24 14:56:35.000000000 +0200
    @@ -1 +1 @@
    -&lt;#&lt;Card id: 310802822, name: "Biorhythm", created_at: "2011-08-24 12:56:35", updated_at: "2011-08-24 12:56:35", cost: 8, strength: nil, toughness: nil, category: "Sorcery", number: 247, artist: "Ron Spears", rarity: "Rare", description: ["Each player's life total becomes the number of creatures he or she controls."], flavor: ["&lt;i&gt;\"I have seen life's purpose, and now it is my own.\"&lt;/i&gt;", "&mdash;Kamahl, druid acolyte"], identifier: 39913&gt;&gt;
    +&lt;#&lt;Card id: nil, name: "Biorhythm", created_at: nil, updated_at: nil, cost: 8, strength: nil, toughness: nil, category: "Sorcery", number: 247, artist: "Ron Spears", rarity: "Rare", description: ["Each player's life total becomes the number of creatures he or she controls."], flavor: ["&lt;i&gt;\"I have seen life's purpose, and now it is my own.\"&lt;/i&gt;", "&mdash;Kamahl, druid acolyte"], identifier: 39913&gt;&gt;

If TextMate would have given me this output, then I would have seen that the id was not present in one of the two objects. I probably wouldn't have come up with the "let's override the `==`-method"-solution :)

From now on I'll only be running my tests from command line (using autotest) - as I probably should have done from the beginning.

**Day #16**
