---
layout: post
title: "Roman numeral kata using TPP"
tags: kata tpp ruby
author: Robin Roestenburg
published_at: "2013-01-07"
---

Corey Haines recently posted an excellent screencast of him performing the Roman
numeral kata. If you haven't seen it, go [watch
it](http://programmingtour.blogspot.nl/2012/12/roman-numerals-kata-with-commentary.html)
before reading this post.  
Not familiar with the Roman numeral kata exercise?
Check the [explanation](http://codingdojo.org/cgi-bin/wiki.pl?KataRomanNumerals)
on the CodingDojo website. It has a lot of other kata exercises as well, check
them out!

### Why? TPP!

Why this blog post, right? Corey's kata was great, there are already a bunch of
other blog posts on this kata and the kata isn't even that difficult.

The reason I wanted to write this post is because of the Transformation Priority
Premise (TPP) by Uncle Bob Martin. According to the TPP there is a prioritized
list of transformations that can be applied to add behaviour to code (and also
to pose new tests). Read about it
[here](http://cleancoder.posterous.com/the-transformation-priority-premise) and
his follow-up post
[here](http://thecleancoder.blogspot.nl/2011/02/fib-t-p-premise.html). Corey's
mentions the TPP in his commentary, and that was my first introduction to the
TPP (thanks Corey!).

After playing around with the kata for a bit, I decided to perform the kata
using the TPP as my guide. After performing the kata a couple of times in this
way, I noticed that my steps towards the final algorithm were different and also
tended to be smaller. This was probably due to the fact I was following the TPP
pretty closely.

### My version of the kata

Let me show you how I performed the kata. For brevity's sake, I will skip the
initial setup and I won't show my tests. They are similar to the ones in Corey's
kata.

##### The 0-case

The implementation to pass the 0-case is straightforward.

``` ruby
def convert(arabic_number)
  ''
end
```

I arrived at this code by transforming the code from no code at all, to code
that employs nil, to code that uses a constant. Let's move on.

##### The 1-case

In order to pass the 1-case I split the execution path, transforming the code
from being unconditional to containing an if-statement:

``` ruby
def convert(arabic_number)
  if arabic_number == 0
    ''
  else
    'I'
  end
end
```

I intentionally did not refactor the if-else structure to a guard clause for the
0-case. I will show you why in a second.

##### Moving forward, 5 or 2?

Next up, is a slightly more complex constant - Corey choose the 5 for this. In
my opinion, the 5 is not *more* complex, it is basically the same as 1. I will
use something that I think is more complex, 2.

I can not add an if-else statement to the existing one, as adding a case to an
existing switch or if is all the way down on the TPP list. This is the reason
why I did not convert the 0-case to a guard clause.

You would then probably not notice you are adding an extra case to the
if-statement and end up with something this:

``` ruby
def convert(arabic_number)
  return '' if arabic_number == 0

  return 'V' if arabic_number == 5

  'I'
end
```

Which is similar to Corey's kata (where he had the 5 case as guard clause, and
returned the 1-case). This is ok, it will not lead to a different algorithm but
it

* needs another test case to transform the code to either recursion or being
  able to look up roman numerals for arabic numbers,
* will make the transformation done in the next step a lot bigger and seem like
  a bit more magic. This is something that I noticed in Corey's kata, the step
  where he removed the two guard clauses and added the find-block was a big one.

##### The 2-case: recursion!

Here is my version after adding the 2-case:

``` ruby
def convert(arabic_number)
  if arabic_number == 0
    ''
  else
    'I' + convert(arabic_number - 1)
  end
end
```

You can see I've transformed the code from a return statement to a recursive
call. This fixes the 2-case (as well the 3-case). I should improve this
according to the TPP, which says I should have used tail recursion instead:

``` ruby
def convert(arabic_number, roman_numeral = '')
  if arabic_number == 0
    roman_numeral
  else
    convert(arabic_number - 1, roman_numeral + 'I')
  end
end
```

**Note**: I did not add the tail recursion for the performance benefits that it
could have, because:

* Roman numerals don't go beyond the 3,000-range (M can only be repeated 3
  times).
* Ruby does not perform tail call optimization by default and it is not even
  available on all Ruby implementations. Magnus Holms does an excellent job
  explaining this in his blogpost [Tailin'
  Ruby](http://timelessrepo.com/tailin-ruby).

I **did** add it because I think it provides a clear step to the next
transformation.

##### 4-case: finishing up..

At this point, the next test case is a 4. I could also do 5 or 10 for that
matter. I just need an extra Arabic to Roman conversion factor.

First, I will refactor the existing code to extract the arabic to roman factors
into a separate variable. The presence of the tail recursion makes this
refactoring an obvious one.

``` ruby
def convert(arabic_number, roman_numeral = '')
  if arabic_number == 0
    roman_numeral
  else
    arabic_factor, roman_factor = [1, 'I']
    convert(arabic_number - arabic_factor, roman_numeral + roman_factor)
  end
end
```

After that, I transform the `[1, 'I']` variable to an array by adding the 4 to
'IV' conversion. Transforming this expression to a *find* function to look up
the conversion factor using the arabic number to be transformed as an argument.

``` ruby
...
arabic_factor, roman_factor = [[1, 'I'], [4, 'IV']].find { |arabic, _| arabic == arabic_number }
...
```

(Of course, this should be refactored into a separate method and a constant -
just like Corey showed in his kata.)

Adding the minimal amount of code to satisfy the test is tricky in this case,
because I know the final solution and am tempted to implement it right away.
Let's see what happens...

##### Failing 2-case

This code will make the 2-case fail, because it is not part of the array of
conversion factors. I have to change the condition in the `find` block to return
conversion factors whose arabic factor is smaller or equal to the current arabic
number that we are converting:

``` ruby
...
arabic_factor, roman_factor = [[1, 'I'], [4, 'IV']].find { |arabic, _| arabic <= arabic_number }
...
```

##### Failing 4-case, again!

This will fix the 2-case, but make the 4 case fail again. It is now returning
`'IIII'` instead of `'IV'`. This has to do with the ordering of the array, and
is easily fixed. The final code looks like this:

``` ruby
...
arabic_factor, roman_factor = [[4, 'IV'], [1, 'I']].find { |arabic, _| arabic <= arabic_number }
...
```

That's it! Adding the conversions to the array will allow us to convert Arabic
numbers to Roman numerals.

### Conclusion

The Transformation Priority Premise is very interesting, it helped me think
about the code (both test and production) I write in a whole different way.

Imo, by thinking about the different transformations at each step of solving the
kata I was able to end up with *a clearer path* to the algorithm.

Let me know what you think!
