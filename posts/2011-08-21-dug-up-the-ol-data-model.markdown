---
layout: post
title: "Dug up the ol' data model"
tags: mychain
---
<p>In an <a href="http://www.tamingthemindmonkey.com/65090142">earlier post</a> I mentioned that I've started coding the Magic cards manager program a couple of times. For me, it is a good project to get some hands-on experience with a new language or a new technique. This time I'm using it to get more experience with the Ruby programming language and the Rails framework as well as the ecosystem that surrounds them. Apart from the experience, I do want to finish the program this time. I want to get feedback on the application/code and the only way to get feedback is to put <em>'stuff out there'</em> (which is one of the reasons for starting this blog as well).</p>
<p>Back to the previous attempts. On my last attempt (summer of 2010) I've used Groovy and the Grails framework to code the program in. Before starting I spent a good amount of time creating the data model. The model that I came up with back then looked like this (<em>finally an excuse to play around with OmniGraffle!</em>):</p>
<p><img class="posterous_plugin_object posterous_plugin_object_image" src="http://getfile5.posterous.com/getfile/files.posterous.com/temp-2011-08-21/AfukfyiqluIxaaejxFuhFithqIjvsqgFhlDCAtdGkBpAHwwtsApwizsaGmiD/original_data_model.png.thumb100.png?content_part=tAGiFImCGsxjmuinIBBl" alt="" width="100" height="100" /></p>
<p>Some quick comments on the model to explain it:</p>
<ul>
<li><em>Magic: The Gathering</em> cards are released in sets. Because <strong>Set</strong> was a restricted keyword in Groovy I went with the name <strong>Series</strong>.</li>
<li>Every set of cards has an edition (<strong>SeriesEdition</strong>) for every language it is released in: English, French, Chinese, etc. This also means that the information (text and image) for every card is different for every edition (<strong>SeriesEditionCard</strong>).</li>
<li>All attributes that are the same for every edition (like colour, rarity, artist, etc.) are stored in the <strong>Card </strong>class.</li>
</ul>
<p>There is another part of the model which deals with users and their collections (for example: how many of a particular card are present in the collection is stored there). I will probably get to that part in a later post.</p>
<p>When working with it last time, as well as drawing it out today, the model feels a bit bloated. Using a <a href="http://www.agiledata.org/essays/tdd.html">TDD</a> approach, I'm hoping the tests will guide me toward something better. So far, the current model looks like this:</p>
<p><img class="posterous_plugin_object posterous_plugin_object_image" src="http://getfile3.posterous.com/getfile/files.posterous.com/temp-2011-08-21/yfdCxceEjFldviEpuuinCdshkxreesihgkmxkoznhFlbCjxyJbCtrzkadolh/current_datamodel.png.thumb100.png?content_part=osisuHEvkisnpmqHvBqu" alt="" width="100" height="100" />I've already got rid of the separate classes for storing the flavor and card text (see <a title="ActiveRecord: Persisting arrays using serialized attributes" href="http://www.tamingthemindmonkey.com/persisting-arrays-using-activerecords-seriali">this post</a>). I'm curious to see what I'll end up!</p>
<p>Coming week, I want to have added the missing data for a card (list of mana-elements and the card colour) and the set class (for storing sets of cards).</p>
<p><strong>Day #13</strong></p>
