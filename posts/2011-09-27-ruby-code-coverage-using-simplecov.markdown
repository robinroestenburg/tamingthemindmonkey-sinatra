---
layout: post
title: "Ruby: Code coverage using SimpleCov"
tags: simplecov mychain
---

Tonight, I'll be adding test coverage metrics to my application. First, I had to look up which library 'does test coverage' in Ruby land.

I only knew about the [RCov](https://github.com/relevance/rcov) gem, but it turned out this gem will not work for Ruby 1.9.x. The [project page](https://github.com/relevance/rcov) referred to the [SimpleCov](https://github.com/colszowka/simplecov) gem which does work on Ruby 1.9.

The SimpleCov gem uses the (experimental) [Coverage](http://www.ruby-doc.org/ruby-1.9/classes/Coverage.html) module that is present in Ruby 1.9. Experimental because the Ruby documentation states that *'**Coverage** provides coverage measurement feature for Ruby. This feature is experimental, so these APIs may be changed in future.'*. For now, SimpleCov does work and it produces nice results.

### Getting started with SimpleCov
Configuring your Rails app to use SimpleCov for measuring the code coverage of your test suite is (as always) very simple. The project's ['README'](https://github.com/colszowka/simplecov/blob/master/README.md) documentation contains three steps to get you started.

After running your tests, SimpleCov produces a good looking page containing the coverage metrics of your application's tests. For my (rather small) application it looks like this:

![Coverage statistics for MTG](http://farm7.static.flickr.com/6169/6186366988_8e9b86b07f.jpg)

Not really great statistics there :-( To see where you are lacking coverage in your tests you can open the detailed coverage by selecting the filename:

![Detailed coverage statistics](http://farm7.static.flickr.com/6170/6186378742_7d191da856.jpg)

This shows I'm not testing the `get_card_details` method. This is correct because I was still looking at the stubbing capabilities of RSpec and have yet to rewrite this test from my previous Test::Unit tests.

Gonna do this tomorrow and make sure I get the coverage to where it is supposed to be :-)

### Merging coverage data from multiple frameworks
If you want to merge the coverage statistics of multiple test suites, like RSPec and Cucumber, then you can put the configuration into a file called `.simplecov`. Otherwise, you'd have to duplicate the configuration into the different test suite helpers.

The following line is all that remains of the SimpleCov configuration in the test setup helper of RSpec:

~~~ ruby
# spec/spec_helper.rb
require 'simplecov'
~~~

### Filters
It is possible to filter files, directories. Filters can be as simple as filtering all files in the `/test/` directory:

~~~ ruby
# .simplecov
SimpleCov.start do
  add_filter "/test/"
end
~~~

Or, you could write your own filter class and get creative :-) For an example of a  filter class, see the next code sample.

### Groups
You can specify custom groups to be shown as a tab on the page containing coverage results.

For example, you want your models to show up in a separate tab. You would have to add these lines to the SimpleCov configuration:

~~~ ruby
# .simplecov
SimpleCov.start do
  add_group "Models", "app/models"
end
~~~

The SimpleCov gem comes with a default setting for Rails applications. You can use this by passing `'rails'` as an argument to the `SimpleCov.start` command in your test framework's helper file (as I've done in the code sample below). This will create groups for your models, controllers, libraries, etc. You can see the result in one of the screenshots above.

Also, it is possible to define groups based on specific filters. Take a look at the following example:

~~~ ruby
# .simplecov
class LineFilter < SimpleCov::Filter
  def passes?(source_file)
    source_file.lines.count > filter_argument
  end
end

SimpleCov.start 'rails' do
  add_group "Short files", LineFilter.new(5)
end
~~~

For my application this generates the following 'Short files' tab containing only the files which have 5 lines or less:

![Short files](http://farm7.static.flickr.com/6170/6185961537_ff1618d27d.jpg)

### Bug?
One odd thing about this is that a file is added to the group when the filter does not pass. In the above case, files longer then 5 lines are not added to the group, but they pass the filter.

The documentation states that: *'Group definition works similar to Filters (and indeed also accepts custom filter classes), but source files end up in a group when the filter passes (returns true), as opposed to filtering results, which exclude files from results when the filter results in a true value.'*. The code does not work this way right now. In fact, the example given in the documentation does not work because of this as well.

The method `grouped()` from [simplecov.rb](https://github.com/colszowka/simplecov/blob/master/lib/simplecov.rb) contains the code responsible for this odd behavior:

~~~ ruby
grouped[name] =
  SimpleCov::FileList.new(
    files.select {|source_file| !filter.passes?(source_file)})
~~~

The negation should be left out, will add a issue for this tomorrow.

### More...
There are some more configuration options, like adapters and formatters. Checkout the project's README for more information about these options.

*#031*
