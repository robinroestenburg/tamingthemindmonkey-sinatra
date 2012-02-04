---
layout: post
title: "Ruby: Module with multiple classes"
tags: mychain ruby
author: Robin Roestenburg
published_at: "2011-09-08"
---
I'm still learning RSpec, so tonight a smaller post about how to create a module that is spread out over multiple files in Ruby.

Currently I have one module, called **Gatherer**. It contains all the functionality that is needed to work with the [Gatherer API](http://gatherer.wizards.com) at wizards.com. I'm using the module as a namespace, accessing the methods/classes inside the module should be done through the `Gatherer::` prefix.

It consists of three classes:

- **Scraper**: Scrapes a particular set of cards, uses the *CheckListPage* and the *DetailsPage*.
- **CheckListPage**: Gives a list of cards belonging to a set or (not implemented yet) query.
- **DetailsPage**: Provides detailed information about a card.

I've bundled these three classes into one file which contains the module:

~~~ ruby
module Gatherer

  class Scraper
    # Implementation omitted for brevity.
  end

  class CheckListPage
    # ...
  end

  class DetailsPage
    # ...
  end
end
~~~

The Gatherer module now contains 200+ lines, which is too much for my taste :-)

### Extracting classes into separate files
I want to extract the classes from the module into separate files and reference them in such a way that they still belong to the module.

First, I tried to include the classes into the module and figured that would work:

~~~ ruby
require 'scraper'
require 'check_list_page'
require 'details_page'

module Gatherer
  include Scraper
  include CheckListPage
  include DetailsPage
end
~~~

This does not work, because (for example) only the instance methods of the actual **Scraper** class are mixed in to the **Gatherer** module in this case.

Then I figured I could encapsulate the three classes in specific modules. This way when I mix in the modules the class gets added to the **Gatherer** module:

~~~ ruby
# gatherer.rb
require 'scraper'
require 'check_list_page'
require 'details_page'

module Gatherer
  include ScraperModule
  include CheckListPageModule
  include DetailsPageModule
end

# scraper.rb
module ScraperModule
  class Scraper
  end
end

# ...
~~~

This works, but it looks a bit dodgy.

### Third time is the charm
It was a bit hard to find the correct way for doing this, so it could either be very basic or something that is not done too often. After Googling around a bit, I found a good looking (and rather obvious) implementation:

~~~ ruby
# gatherer.rb
require 'scraper'
require 'check_list_page'
require 'details_page'

# scraper.rb
module Gatherer
  class Scraper
  end
end

# details_page.rb
module Gatherer
  class DetailsPage
  end
end

# ...
~~~

Every **Gatherer** module extends on it by adding a class to the module. When I `require 'gatherer'` all classes are available through the **Gatherer** namespace.
This also has the advantage that when I `require 'scraper.rb'`, you still have to access it through the namespace.

### Another one (do not use this ;))
Ok, so I found another implementation [on this forum post](http://www.ruby-forum.com/topic/148303):

~~~ ruby
module Gatherer
  eval File.open('scraper.rb').read
  eval File.open('details_page.rb').read
  eval File.open('check_list_page.rb').read
end
~~~

Ugly, but working :) Does not have the advantage that the namespace is enforced when requiring the `scraper.rb` file stand alone though.

That's it for today!
