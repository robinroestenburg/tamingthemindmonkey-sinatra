---
layout: post
title: "Ruby: Testing for values inside objects of a collection"
tags: ruby mychain
author: Robin Roestenburg
published_at: "2011-08-20"
---
Yesterday I showed the first two of my Nokogiri *learning tests*. I wrote another test which gave me some problems. Let me show you the initial test first:

~~~ ruby
test "matching multiple elements" do
  html = '<table><tr><td class="foo">bar</td><td class="foo">baz</td></tr></table>'
  doc = Nokogiri::HTML(html)
  cells = doc.css('td.foo')

  assert_equal 2, cells.size
  flunk("How do I check if the content of the retrieved cells is correct?")
end
~~~

This failed on the `flunk` of course. I want to compare a value inside an element of an array against an expected value. Being the Java programmer that I am, I was already thinking about for-loops going over the collection etc. I came up with this working test at first:

~~~ ruby
test "matching multiple elements" do
  html = '<table><tr><td class="foo">bar</td><td class="foo">baz</td></tr></table>'
  doc = Nokogiri::HTML(html)
  cells = doc.css('td.foo')

  assert_equal 2, cells.size
  assert cell_content_present?(cells, 'bar')
  assert cell_content_present?(cells, 'baz')
end

def cell_content_present?(cells, expected_content)
  content_present = false
  cells.each do |cell|
    content_present = true if (cell.content == expected_content)
  end
  content_present
end
~~~

The method `cell_content_present?` loops over all elements (in this case cells of the table) found by Nokogiri, and checks if the expected content is present in one of them. I could improve it by having the method return `true` from inside the loop when a match was found and `false` otherwise.

Having read a couple of books on Ruby and being a follower of a couple of blogs about Ruby, I knew this wasn't exactly *the Ruby way* to do this ;) It is probably possible to write a better solution using Ruby.

So, what could I do to improve the code? I decided to remove the `cell_content_present?` function and rewrite the assertions in a way that would communicate my intent for this test in a better way.

~~~ ruby
test "matching multiple elements" do
  html = '<table><tr><td class="foo">bar</td><td class="foo">baz</td></tr></table>'
  doc = Nokogiri::HTML(html)
  cells = doc.css('td.foo')

  assert_equal 2, cells.size
  assert content_of_cells.include? 'bar'
  assert content_of_cells.include? 'baz'
end
~~~

The `include?`-method works on an array and returns true if the value after the method statement is present in the array. The `content_of_cells` needs to be an array then. I knew about the `map`-iterator and I figured I could use it in this case. Using `map` (which is an iterator that interacts with the code block you specify following it) on the `cells`-array I could create a new array containing the contents of the cells. Creating this array of contents using `map` looks like this (1 line, and still readable):

~~~ ruby
content_of_cells = cells.map { |td| td.content }
~~~

After this, I could finish this test. The final tests looks like this:

~~~ ruby
test "matching multiple elements" do
  html = '<table><tr><td class="foo">bar</td><td class="foo">baz</td><td>quux</td></tr></table>'
  doc = Nokogiri::HTML(html)
  cells = doc.css('td.foo')
  assert_equal 2, cells.size

  content_of_cells = cells.map { |td| td.content }
  assert content_of_cells.include? 'bar'
  assert content_of_cells.include? 'baz'
  assert !content_of_cells.include?('quux')
end
~~~

I'm pretty pleased with this solution, looks clean and simple. I'm not sure if there is a better way to do this (as I am a Ruby beginner) - let me know if there is (and what it is of course ;))!
