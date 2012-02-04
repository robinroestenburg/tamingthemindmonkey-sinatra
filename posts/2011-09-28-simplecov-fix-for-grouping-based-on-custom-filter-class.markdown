---
layout: post
title: "SimpleCov: Fix for grouping based on custom filter class"
tags: simplecov
author: "Robin Roestenburg"
published_at: "2011-09-28"
---

Tonight I'll be making my first pull request on Github, yay! I've fixed the bug in the SimpleCov gem that I mentioned in [this post](http://www.tamingthemindmonkey.com/ruby-code-coverage-using-simplecov).

### Filters and groups
SimpleCov allows you to define groups of files which are then shown on a separate tab. It also allows you to filter specific files. An example of this could be filtering all files that have 100% coverage, so only the files that still need work are shown.

It is possible to define a custom filter class that can be used to filter specific files. This could look like this:

~~~ ruby
class LineFilter < SimpleCov::Filter
  def passes?(source_file)
    source_file.lines.count < filter_argument
  end
end
~~~

The **LineFilter** class will filter out all files that have less then a specific number of lines.

This class can also be used to group files. When a file has less lines then the specified threshold SimpleCov will add the file to the group.

At least, that is what it should do :)

### The bug
The above **LineFilter** example is mentioned in the documentation of SimpleCov. I tried this out and configured SimpleCov as follows:

~~~ ruby
class LineFilter < SimpleCov::Filter
  def passes?(source_file)
    source_file.lines.count < filter_argument
  end
end

SimpleCov.start 'rails' do
  add_group "Short files", LineFilter.new(5)
end
~~~

Instead of showing me the files that have less then 5 lines, the tab 'Short files' contains all files that are greater than or equal to 5 lines.

### Fixing the bug - Pt. 1
I identified the problem by looking at the code of the SimpleCov gem. The  method **grouped** in **lib/simplecov.rb** has an obvious error:

~~~ ruby
#
# Applies the configured groups to the given array of SimpleCov::SourceFile items
#
def grouped(files)
  grouped = {}
  grouped_files = []
  groups.each do |name, filter|
    grouped[name] = SimpleCov::FileList.new(files.select {|source_file| !filter.passes?(source_file)})
    grouped_files += grouped[name]
  end
  if groups.length > 0 and (other_files = files.reject {|source_file| grouped_files.include?(source_file)}).length > 0
    grouped["Ungrouped"] = SimpleCov::FileList.new(other_files)
  end
  grouped
end
~~~

It negates the result from **filter.passes?** which leads to the behavior mentioned above.

### Writing a feature
Before fixing this, I searched for the feature for testing the custom filter classes. Argh..there are no tests for testing the filter class, I've got to write my own.

This was actually good fun, as the SimpleCov project has a non-standard way of testing. The project runs the features on a fake project and the features contain the configuration for the project which is injected into the test helper file before running the coverage statistics on the fake project.

After writing a failing feature (good), I changed the code and the feature passed. Great!

Running the complete set of features showed that some other features were affected by my change.

### Filtering or passing?
The failing features showed me that the groups defined by blocks and strings were not working correctly now.

Digging deeper into the code revealed the cause of this problem. In file **lib/simplecov/filter.rb** two classes are defined, **StringFilter** and **BlockFilter**. The first is used when you define a group (or filter) like this:

~~~ ruby
add_group "Controllers", "app/controllers"
~~~

The second is used when you define it like this:

~~~ ruby
add_group "Long files" do |src_file|
  src_file.lines.count > 100
end
~~~

The StringFilter class looks like this:

~~~ ruby
class StringFilter < SimpleCov::Filter
  # Returns true when the given source file's filename matches the
  # string configured when initializing this Filter with StringFilter.new('somestring)
  def passes?(source_file)
    !(source_file.filename =~ /#{filter_argument}/)
  end
end
~~~

What's going on with negation? The comment does not match the code: *"Returns true when the given source file's filename matches the string...."* That's not what this does, it does exactly the opposite.

When the filename matches the string then **passes?** returns *false*, probably meaning something like *the file did not pass the filter, because it matched the filtering condition*. Confusing.

The **BlockFilter** class has the same negation - and the same problem.

### Fixing the bug - Pt. 2
Renaming the **passes?** method to **matches?** will make the intent of the code more clear: *When a file matches a filter then it is filtered from the result*. I can get rid of the negation now as well. This leaves the following **StringFilter** class:

~~~ ruby
class StringFilter < SimpleCov::Filter
  # Returns true when the given source file's filename matches the
  # string configured when initializing this Filter with StringFilter.new('somestring)
  def matches?(source_file)
    (source_file.filename =~ /#{filter_argument}/)
  end
end
~~~

Ah, better. The comment even matches the code now :) There are still some features failing though (as well as some minor unit tests that are easily fixed).

### Fixing the bug - Pt. 3
Rewriting the **StringFilter** and **BlockFilter** classes fixes the problem when defining a group. However, it breaks all features defining a filter. The negation that was removed should be added somewhere.

Right next to the previously changed method `grouped` in **lib/simplecov.rb** sits the method `filtered`. It looks like this:

~~~ ruby
#
# Applies the configured filters to the given array of SimpleCov::SourceFile items
#
def filtered(files)
  result = files.clone
  filters.each do |filter|
    result = result.select {|source_file| filter.passes?(source_file) }
  end
  SimpleCov::FileList.new result
end
~~~

Changing the **select** into a **reject** (and changing the **passes?** into **matches?**) will remove (or reject) all files match the filter. Again, much better.

All tests and features are passing, time to commit.

### Finishing up
Committing these changes to the forked project and creating a pull request is so easy, I'm not even going to write anything about it (time's up as well ;-))
