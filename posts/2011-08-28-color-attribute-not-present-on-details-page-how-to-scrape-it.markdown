---
layout: post
title: "Color attribute not present on details page, how to scrape it?"
tags: mychain
---
I went over the list of fields that I needed to scrape from the Gatherer site and saw that I was missing one: the color of the card.

### Colors of Magic: The Gathering
For a good overview of all colors in Magic, see this [Wikipedia article](http://en.wikipedia.org/wiki/Magic:_The_Gathering#Colors_of_Magic). Summarizing, Magic: The Gathering cards can have one of the following colors: white, blue, black, red, green, multicolored or colorless.

### Color is in the details, or not?
First, I added the color to the test fixtures and updated the `assert_card_equals` method, which is responsible for comparing all attributes of two cards. The tests are failing now, good. This is because we are not scraping the color attribute yet. When checking out where the color attribute was located I ran into the following problem.

So far, all attributes could be scraped from the details page of a card. The color of a card is only shown on the checklist page though.
![Color of card only present on checklist](http://farm7.static.flickr.com/6080/6090373088_91309326bd.jpg)
This is a bit of a problem, because the scraper only uses the checklist page to retrieve an array of card identifiers to use when scraping the actual **Card**-object + details from the details page.

### Implementation issues
I have a Gatherer module which exists of two classes:

- **CheckListPage**: responsible for retrieving a checklist page using a given name of a set of cards. It returns the identifiers present on the page.
- **DetailsPage**: responsible for retrieving a card details page using a given card identifier. It returns a **Card**-object with all scraped attributes.

I could make the **CheckListPage** return identifiers and colors (like `[40197, White]`) and use the identifier and color as input of the **DetailsPage**. This feels wrong, I would be calling **DetailsPage** like this:
    #!ruby
    # The identifier and color of the Doom Cannon card are determined
    # by the CheckListPage, using constants below for readability.
    details = DetailsPage.new(DOOM_CANNON_IDENTIFIER, DOOM_CANNON_COLOR)
    card = details.get_card_details

The color actually has nothing to do with the construction of the **DetailsPage** class, so why add it to the class? It would be better to write something like this:
    #!ruby
    details = DetailsPage.new(DOOM_CANNON_IDENTIFIER)
    card = details.get_card_details
    card.color = DOOM_CANNON_COLOR

This could work. But it still doesn't look right when looking at the complete algorithm for scraping the cards:

    #!ruby
    cards = []
    checklist = CheckListPage.new('Foo')
    ids_colors = checklist.get_card_identifiers_and_colors

    ids_color.each do |identifier, color|
      details = DetailsPage.new(identifier)
      card = details.get_card_details
      card.color = color
      cards &lt;&lt; card
    end

Having the checklist page return identifiers and colors in one call doesn't seem right: a method should do one thing. So I rewrote it into this:

    #!ruby
    cards = []
    checklist = CheckListPage.new('Foo')
    identifiers = checklist.get__card_identifiers

    identifiers.each do |identifier|
      details = DetailsPage.new(identifier)
      card = details.get_card_details
      card.color = checklist.get_card_color(identifier)
      cards &lt;&lt; card
    end

The **CheckListPage** is still responsible for returning the color for a particular card (by a given identifier), but it does so using a separate method call (`get_card_color`). This might perform worse (minimally when I cache the checklist page in the first call) but this code is not going to be run very often so I take that for granted.

**Day #20**
