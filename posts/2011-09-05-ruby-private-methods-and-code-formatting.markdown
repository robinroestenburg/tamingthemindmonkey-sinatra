---
layout: post
title: "Ruby: Private methods and code formatting"
tags: mychain ruby
---
Ok, tonight a post about private methods in Ruby. First, let me say, that I think defining the visibility of your methods is a good programming style and should be encouraged. However, defining visibility of a method in Ruby is somewhat different then I am used to. In its most basic form though, I think it leads to bad code formatting. Furthermore a private method is not a private as I thought - this is not too big of a problem, but still something that bugs me a bit.

### Vertical distance of methods
I like to order my methods in the order they are called. This way I keep the vertical distance between methods as small as possible and another person doesn't have to go looking for methods while reading my code. Here's an example of this is in Java code (notice the 4 spaces indentation ;-)).
{% highlight java %}
public class Foo {

    public void bar() {
        baz();
        quux();
    }

    private void baz() {
        // ...
    }

    private void quux() {
        // ...
    }
}
{% endhighlight %}

Pretty straightforward. The methods that I don't want available for outside use are marked `private`, others `public`.

If I want to keep the ordering and the method visibility in tact I have to write something like this in Ruby:
{% highlight ruby %}
class Foo

  def bar
    baz
    quux
  end

  private

  def baz
    # ...
  end

  def quux
    # ...
  end

end
{% endhighlight %}

The problem with this is when you add another public method, say `waldo`, I would want to have it below the `quux`-method. This is not possible when using the **private** method like above, all subsequent method definitions have visibility `private`. Thus, I would have to define the `waldo` method after `bar` and the vertical distance between `bar` and `baz` would then not be optimal.

A way to maintain the ordering of the methods and the visibility would be to define the methods visibility after each private (or protected) method. (I know you can mark all your private methods at the end of the class, but I think that leads to code that is hard to maintain.) This would look like this:
{% highlight ruby %}
class Foo

  def bar
    baz
    quux
  end

  def baz
    # ...
  end
  private :baz

  def quux
    # ...
  end
  private :quux

  def waldo
    # ...
  end
end
{% endhighlight %}

For me, defining the visibility of the methods this way (in combination with the vertical ordering) looks best. It is mentioned in the [Ruby Programming Language](http://www.amazon.com/Ruby-Programming-Language-David-Flanagan/dp/0596516177) book, but I have not seen it being used in the Ruby code I've read so far though.

### Not really private
A private method in Ruby is not really private. You can just call it as follows (**Foo** is a class containing private method `bar`):
{% highlight ruby %}
foo = Foo.new
foo.send :bar
foo.instance_eval { bar }
{% endhighlight %}

This is probably bad style to begin with, but it bothers me a bit that it is possible.


### Conclusion
Ok, so that's about it for me on private methods. I think I'll stick with the style in the last example for now, defining the visibility directly after a method. until someone points me in a better direction :-)

**Day #2**
