--- 
layout: post 
title: "Refactoring: Retrieving the Arel attributes and values for create/update"
author: Robin Roestenburg 
tags: rails activerecord refactoring
published_at: "2012-03-06" 
---
I showed this refactoring in the original post from yesterday, but I wanted to
explain the process of how I got to the result in a separate post. Let's look at
the original code again:

~~~ ruby,showlinenos
def arel_attributes_values(include_primary_key = true, include_readonly_attributes = true, attribute_names = @attributes.keys)
  attrs      = {}
  klass      = self.class
  arel_table = klass.arel_table

  attribute_names.each do |name|
    if (column = column_for_attribute(name)) && (include_primary_key || !column.primary)
    
      if include_readonly_attributes || !self.class.readonly_attributes.include?(name)
    
        value = if klass.serialized_attributes.include?(name)
                  @attributes[name].serialized_value
                else
                  read_attribute(name)
                end
    
        attrs[arel_table[name]] = value
      end
    end
  end
  attrs
end
~~~

As you can see it is overly complex; some of the things I do not like:

* the double nested if-structure which is checking for primary keys and read
  only attributes,
* the if-else case inside the assignment of the value variable,
* the flag parameters (include_primary_key and include_readyonly_attributes)

### Step 1: Removing the nested ifs
First, I removed the if conditions and replaced them by conditional `next`
statements. I did not change the original if-condition and just replaced the if
by unless: 

~~~ ruby,showlinenos
  ...
  attribute_names.each do |name|
    next unless (column = column_for_attribute(name)) && (include_primary_key || !column.primary)
    next unless (include_readonly_attributes || !self.class.readonly_attributes.include?(name))
    ...
  end
  ...
~~~

Already a lot better, tests are still passing.

Then I extracted the column assignment from the first if, because it would make
the checks for primary key  and read-only attributes almost the same.

~~~ ruby,showlinenos
  ...
  attribute_names.each do |name|
    next unless (column = column_for_attribute(name))
    next unless (include_primary_key || !column.primary)
    next unless (include_readonly_attributes || !self.class.readonly_attributes.include?(name))
    ...
  end
  ...
~~~

After this, I created two seperate method to contain the checks for primary key
and read-only attributes, which I could call from a single `unless`-condition in
the loop:

~~~ ruby,showlinenos
def arel_attributes_values(include_primary_key = true, include_readonly_attributes = true, attribute_names = @attributes.keys)
  ...
  attribute_names.each do |name|
    next unless (column = column_for_attribute(name))
    next unless attribute_allowed?(include_primary_key, include_readonly_attributes, name)
    ...
  end
  attrs
end

private

def attribute_allowed?(include_primary_key, include_readonly_attributes, name)
  (include_primary_key || !pk_attribute?(name)) && 
    (include_readonly_attributes || !readonly_attribute?(name))
end

def readonly_attribute?(name)
  self.class.readonly_attributes.include?(name)
end

def pk_attribute?(name)
  column_for_attribute(name).primary
end
~~~

I am now calling `column_for_attribute` two times now, which is not great. Also 
I would like to have a single `if` statement in the each loop, so I added the 
check for the column assignment to the attribute_allowed method and replaced the
`next unless` by an `if`-statement around the body of the each-iterator.


~~~ ruby,showlinenos
def arel_attributes_values(include_primary_key = true, include_readonly_attributes = true, attribute_names = @attributes.keys)
  ...
  attribute_names.each do |name|
    if attribute_allowed?(include_primary_key, include_readonly_attributes, name)
    ...
    end
  end
  attrs
end

private

def attribute_allowed?(include_primary_key, include_readonly_attributes, name)
  return unless (column = column_for_attribute(name))

  (include_primary_key || !pk_attribute?(column)) && 
    (include_readonly_attributes || !readonly_attribute?(name))
end

def pk_attribute?(column)
  column.primary
end
...
~~~

I do not like the `return` in the `attribute_allowed?`-method, but it was the
best place considering the other option was placing it in the main loop.

### Step 2: Removing the if-else case inside the assignment
This was easy. Extract the statement to a method, `typecasted_attribute_value`
and inline the call.

~~~ ruby,showlinenos
def arel_attributes_values(include_primary_key = true, include_readonly_attributes = true, attribute_names = @attributes.keys)
  ...
  attribute_names.each do |name|
    if attribute_allowed?(include_primary_key, include_readonly_attributes, name)
      attrs[arel_table[name]] = typecasted_attribute_value(name)
    end
  end
  attrs
end

private
...
def typecasted_attribute_value(name)
  if self.class.serialized_attributes.include?(name)
    @attributes[name].serialized_value
  else
    # FIXME: we need @attributes to be used consistently.
    # If the values stored in @attributes were already typecasted, this code 
    # could be simplified
    read_attribute(name)
  end
end
~~~

I kept the FIXME in there, as I did not want to shave that yak just yet ;) 

### Step 3: Cleaning up
I did some renaming of attributes and methods and the result looks like this:

~~~ ruby
def arel_attributes_values(pk_attr_allowed = true, readonly_attr_allowed = true, attribute_names = @attributes.keys)
  attrs      = {}
  arel_table = self.class.arel_table

  attribute_names.each do |name|
    if attribute_allowed?(pk_attr_allowed, readonly_attr_allowed, name) 
      attrs[arel_table[name]] = typecasted_attribute_value(name)
    end
  end

  attrs
end

private

def attribute_allowed?(pk_attribute_allowed, readonly_attribute_allowed, name)
  return unless column = column_for_attribute(name)

  (pk_attribute_allowed || !pk_attribute?(column)) && 
    (readonly_attribute_allowed || !readonly_attribute?(name))
end

def readonly_attribute?(name)
  self.class.readonly_attributes.include?(name)
end

def pk_attribute?(column)
  column.primary
end

def typecasted_attribute_value(name)
  if self.class.serialized_attributes.include?(name)
    @attributes[name].serialized_value
  else
    # FIXME: we need @attributes to be used consistently.
    # If the values stored in @attributes were already typecasted, this code 
    # could be simplified
    read_attribute(name)
  end
end
~~~

I did not touch the parameters of the method because I do not know how much
effort it would take right now (don't want to shave that yak either!). I would
like to refactor this next.

The main goal of this refactoring was to get rid of the nested ifs and the ugly
if-statement inside the assignment of value. I think I succeeded, I hope
[they](https://github.com/rails/rails/pull/5294) like it :)

