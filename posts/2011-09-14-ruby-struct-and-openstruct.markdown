---
layout: post
title: "Ruby: Struct and OpenStruct"
tags: mychain ruby
---

As I wrote [yesterday](http://www.tamingthemindmonkey.com/decoupling-the-gatherer-library), I want to remove all reference to the model classes of the application from the scraper code. I'll first replace all references to the model classes by structs.

### Struct?
Ruby's documentation say the following about the **Struct** class: 'A Struct is a convenient way to bundle a number of attributes together, using accessor methods, without having to write an explicit class.' I think of it as some kind of data container.

I came across a good article about structs [here](http://blog.rubybestpractices.com/posts/rklemme/017-Struct.html). The author also lists when to use a struct:

- *you need a data container and fields are fixed and known beforehand (i.e. at time of writing of the code),*
- *you need a structured Hash key,*
- *you want to quickly define a class with a few fields,*
- *you need to detect errors caused by misspelled field names.*

I don't need point 2 and good unit tests make point 4 obsolete. I just need some structure that holds the data so a client (me) can process it into its own data model. I could've gone with a Hash or with an OpenStruct (also see mentioned article). I like the Struct better because you have to explicitly specify the attributes when creating it.

### Creating a Struct
There are two ways to create a new Struct. You can create a explicitly named struct class like so:

{% highlight ruby %}
# Create a structure with a name in Struct
Struct.new("Mana", :identifier, :name)    #=> Struct::Mana
Struct::Mana.new("R", "Red")              #=> #<struct Struct::Mana identifier="R", name="Red">
{% endhighlight %}

Defining a name for the struct (like 'Mana' above) will create a constant for that name inside class **Struct**. This is probably not a good idea, because it can lead to potential conflicts.

You can also create an anonymous struct class:

{% highlight ruby %}
# Create a structure named by its constant
Mana = Struct.new(:identifier, :name)     #=> Mana
Mana.new("R", "Red")                      #=> #<struct Mana identifier="R", name="Red">
{% endhighlight %}

This leads to some naming issues as well though. It would be confusing to have ActiveRecord Card classes available and also Card structs. Hmm, I do not even know if that will even work.
{% highlight text %}
irb :001 > card = Card.new
=> #<Card id: nil, ... >

irb :002 > Card = Struct.new("Card", :name)
(irb):2: warning: already initialized constant Card
=> Struct::Card

irb :003 > struct = Card.new
=> #<struct Struct::Card name=nil>
{% endhighlight %}

Guess not ;) Ruby gives a warning that you are overwriting the Card constant.

I'll name the struct classes like a normal variable for now (e.g. lowercase 'mana'). The alternative would be to name them like 'ManaStruct' or something.

### Changes to the code (1)
Changing the references to the model class turned out to be very easy :) For example, check out the the following code:

{% highlight ruby %}
def create_card_mana(code, index)
  card_mana = CardMana.new
  card_mana.mana_order = index
  card_mana.mana = Mana.find_or_create_by_code(code: code)

  card_mana
end
{% endhighlight %}

After changing the model class references to structs, the code looks like this:
{% highlight ruby %}
def create_card_mana(code, index)
  card_mana = Struct.new(:order, :mana)
  card_mana.new(index, code)
end
{% endhighlight %}

Having my doubts about the performance penalty for defining a new struct every time. If I define the structs as constants of my class it should be alright.
{% highlight ruby %}
CardManaStruct = Struct.new(:order, :mana)

def create_card_mana(code, index)
  CardManaStruct.new(index, code)
end
{% endhighlight %}
Also, I went with the alternative naming of the struct class to show it is a constant.

### Changes to the code (2)
Another example:
{% highlight ruby %}
def get_card_details
  card            = Card.new
  card.identifier = @identifier
  card.name       = name_on_page
  ...
end
{% endhighlight %}

This code got changed into:
{% highlight ruby %}
def get_card_details
  card_struct     = Struct.new(:identifier,
                               :name,
                               :cost,
                               :strenght,
                               :toughness,
                                :category,
                               :artist,
                               :number,
                               :rarity,
                               :description,
                               :flavor,
                               :card_mana)
   card            = card_struct.new
   card.identifier = @identifier
   card.name       = name_on_page
   ...
end
{% endhighlight %}

Hmm, this is a bit ugly. Moving the creation of the struct to a class constant will make this somewhat better ():
{% highlight ruby %}
CardStruct = Struct.new(:name,
                        ...

def get_card_details
  card = CardStruct.new
  card.identifier = @identifier
  card.name       = name_on_page
  ...
end
{% endhighlight %}

### OpenStruct
In the end I could've just defined a separate class for the **CardStruct** instead of the struct class constants I ended up with now). I'm going to go with the **OpenStruct** instead.

Using **OpenStruct** I do not need to explicitly define the attributes that are present on the struct class. This makes the code less readable, but I guess it is still ok.

The above two examples turn out like this when using the **OpenStruct**:
{% highlight ruby %}
def get_card_details
  card = OpenStruct.new
  card.identifier = @identifier
  card.name       = name_on_page
  ...
end

def create_card_mana(code, index)
  OpenStruct.new({ :order =&gt; index,
                   :identifier =&gt; code})
end
{% endhighlight %}

These two methods show the two ways to define an OpenStruct. When you provide a hash it will automatically generate attributes and values.

That's it for today!
