--- 
layout: post 
title: "ActiveRecord: Last pieces of the initialization puzzle"
author: Robin Roestenburg 
tags: rails activerecord mychain 
chain: "Digging into Rails"
published_at: "2012-03-01" 
---
Yesterday I tried to find out how the attributes are added to a Active Record
class based on the columns that are present in the database table to which the
class is mapped. I spent the whole post figuring out the initialization of a
Active Record (thinking that would be the place where the attributes are added
to the class). I found out that the attributes were not added there. After
unraveling the stack I found the method responsible for adding the attribute
methods on a Active Record class hidden in the
`ActiveRecord::AttributeMethods` module:

~~~ ruby,showlinenos
~~~

### How is it called?
It is very obscure how this method is called, let me walk you through it:

* When creating a new instance the `ActiveRecord::Core.initialize` method is
  called (see yesterday's post for more information).
* At the end of this method the callback chain for the `:initialize` callback is
  executed by the `ActiveSupport::Callbacks` module, specifically the
  `__run__callbacks` method. I won't go into the details, but take it from me -
  this method calls the `respond_to?`-method on the Active Record class. 
* The `ActiveRecord::AttributeMethods#respond_to?` method calls the
  `define_attribute_methods` class methods (present in same module) which
  defined the attribute methods as shown below.

~~~ ruby,showlinenos
# Generates all the attribute related methods for columns in the database
# accessors, mutators and query methods.
def define_attribute_methods
  # Use a mutex; we don't want two thread simaltaneously trying to define
  # attribute methods.
  @attribute_methods_mutex.synchronize do
    return if attribute_methods_generated?
    superclass.define_attribute_methods unless self == base_class
    super(column_names)
    @attribute_methods_generated = true
  end
end
~~~

**Notes:** 

* There is also a `method_missing` method on the
  `ActiveRecord::AttributeMethods` module, which create attribute methods when
  they are missing. This is actually not used for initialization, probably for
  performance reasons - but it would have made more sense to just leave it to
  that method.
* In my opinion, it would have been a whole lot easier to just add the call to
  the `define_attribute_methods` method from the
  `ActiveRecord::AttributeMethods#respond_to?` method to the
  `ActiveRecord::Core#initialize` method. 

### How is it called? - Pt. 2 
Now I know how the code that defines the attribute methods is called, I want to
find out how it works. The method itself is not that difficult, on line number 8
(in the above code block) the method `define_attribute_methods` is
called on the super class containing the column names of the database table to
which the class is mapped.

What is the super class of my `Monkey` class? Object? I decided to search for
the method `define_attribute_methods` within the ActiveRecord namespace, no
results.  Searching through Rails did give me a hit in
`ActiveModel::AttributeMethods`. How/why did it get there?

Turns out, the `ActiveRecord::AttributeMethods` includes this module, which
makes the `define_attribute_methods` method available in this module.  This kind
of makes sense, because adding attribute methods is behavior that is also
present on a Active Model (where you explicitly call this method).

#### Super into included modules
The `super` call on line 8 (in the code example) goes through the included
modules for the `define_attribute_methods` method taking 1 parameter. I did not
understand this at first, but after I created a small example it became more
clear:

~~~ ruby,showlinenos
module B
  def bar(baz)
    baz
  end
end

module A
  include B

  def bar
    super("Quux")
  end
end

class Foo
  include A
end

foo = Foo.new
foo.bar #=> "Quux"
~~~

### How is it called? - Pt. 3
In the `ActiveModel::AttributeMethods#define_attribute_methods` method attribute
methods are created for each of the column names. 

For each column name a call to
`define_method_attribute` and `define_method_attribute=` on resp.
`ActiveRecord::AttributeMethods::Read` and
`ActiveRecord::AttributeMethods::Write` is made. Below the code from the `Read`
module: 

~~~ ruby,showlinenos
def define_method_attribute(attr_name)
  cast_code = attribute_cast_code(attr_name)

  generated_attribute_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
    def __temp__
      #{internal_attribute_access_code(attr_name, cast_code)}
    end
    alias_method '#{attr_name}', :__temp__
    undef_method :__temp__
  STR

  generated_external_attribute_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
    def __temp__(v, attributes, attributes_cache, attr_name)
      #{external_attribute_access_code(attr_name, cast_code)}
    end
    alias_method '#{attr_name}', :__temp__
    undef_method :__temp__
  STR
end
~~~

And with that wonderful piece of code I am done with my search for the
initialization of the attribute methods. 

See you tomorrow, err, today! :)



