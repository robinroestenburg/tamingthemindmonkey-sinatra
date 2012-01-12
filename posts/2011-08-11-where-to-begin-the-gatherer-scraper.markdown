---
layout: post
title: Where to begin? The Gatherer scraper!
tags: mtg mychain scraper
---
<div>After setting up my repository and playing around (too long) with the GitHub  for Mac application yesterday, I'm ready to start the actual  development. First though, let's define the main goal of the  program. Currently, I'd define it like this: <em>&nbsp;</em></div>
<div>
<blockquote>Using the program a user  should be able to view and edit his/her collection of Magic: The  Gathering cards</blockquote>
</div>
<div>This should be sufficient for now, I'll probably adjust  it later on.</div>
<p>Where to begin? As I see it now, the program will consist of three parts:</p>
<div><ol>
<li>A web-based front-end allowing the end-user to manage his/her collection.</li>
<li>An administrative back-end for managing users, collections and all the card information in the database.</li>
<li>A scraper which scrapes the information of the MTG cards into the  database of the program. The scraper will use the <a title="Gatherer" href="http://gatherer.wizards.com" target="_blank">Gatherer</a> website as  it's data source. The Gatherer website is maintained by <a title="Wizards of the Coast" href="http://www.wizards.com" target="_blank">Wizards of the  Coast</a>, the manufacturer of the MTG.&nbsp; </li>
</ol></div>
<div>Scraping the information on this site into the  database of the program will be the first part to develop. I could've gone the other way and develop the web-interface  first, but then I'd have to make some assumptions about the data model  which may turn out <em>not to be true</em> or <em>sub-optimal</em>. When starting with the scraper, the data  model containing the cards and sets should be pretty much complete after  this. From previous attempts  at this kind of program I already have a general idea of what the data  model should look like (I will try to look up one of those old data models), but I want to see if my tests will <em>guide to</em> something similar or if they help me produce <em>something better</em>.</div>
<p>What about this Gatherer site then? What does it look like? The Gatherer site basically consists of two different pages containing:</p>
<div><ol>
<li>Cards found by the search functionality (in different formats, the checklist format is shown in the screenshot), and<img class="posterous_plugin_object posterous_plugin_object_image" src="http://getfile8.posterous.com/getfile/files.posterous.com/temp-2011-08-11/FurvHFlDeesavGdgypziDtDHshtceHeptGqgshotrowfDgtAypitpcihodsj/Screen_Shot_2011-08-11_at_10.37.00_PM.png.thumb100.png?content_part=ajmcstblCFwDdIqpmqzy" alt="" width="100" height="100" /></li>
<li>Details of a particular card (the famous Black Lotus card is shown). <img class="posterous_plugin_object posterous_plugin_object_image" src="http://getfile1.posterous.com/getfile/files.posterous.com/temp-2011-08-11/GndskogctvdkwJgmfmAEddslhBDADlElDzrbwtjBFaihlCvzjxBvdncfwDig/Screen_Shot_2011-08-11_at_10.36.26_PM.png.thumb100.png?content_part=iuHwGnBvjdeEfAluEAue" alt="" width="100" height="100" />This page actually consists of 4 separate pages, '<em>Details</em>', '<em>Sets &amp; Legality</em>', '<em>Rules</em>' and '<em>Discussion</em>'. The last one won't be scraped.</li>
</ol></div>
<div>The HTML structure of the pages is ok'ish, I should be able to parse it with not much difficulty. When I get to the actual scraping of these pages, I'll elaborate more on the structure and content of these pages.</div>
<p>I've already set up a Rails project (oh yea, this will be my first time, developing a program in Ruby/Rails - yikes!). For testing the scraper (in combination with the different Gatherer pages) I will be using the VCR gem in my unit tests, which is pretty amazing. I've played with it a bit already and set up a couple of unit tests using it. Tomorrow's post will be about that.</p>
<blockquote>
<div>Day #3</div>
</blockquote>
