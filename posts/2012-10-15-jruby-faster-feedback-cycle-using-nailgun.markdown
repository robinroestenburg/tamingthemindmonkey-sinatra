---
layout: post
title: "JRuby: Faster feedback cycle using Nailgun"
tags: jruby nailgun jvm
author: Robin Roestenburg
published_at: "2012-10-15"
---

I have been working on a JRuby application these last couple of weeks and all
together I have probably spent a good couple of hours waiting on the JVM to
start up when running my specs.

TL;DR; I could have saved a lot of time had I used Nailgun from the get-go.

### TDD workflow

Let me first explain my development workflow real quick. I work from terminal
Vim and have the key combination `,r` mapped to saving my current file and
running the spec/test file that belongs to the current file (or if the current
file is a spec/test file then it will just run that). Hitting this combo is
second nature and it leads to a normal TDD workflow as follows:

1. Write test.
2. `,r`
3. Test fails.
4. Write production code to fix failure.
5. Multiple iterations of steps 2, 3 and 4.
6. `,r`
7. Test passes.

Writing a couple of lines of production code does not usually take very long, so
I tend to run the test a couple of times per minute.

Now, doing this on MRI is painless. Tests for isolated code (not talking about
code which uses Rails here!) run in tens of milliseconds. The **feedback cycle**
from making a change in your production code and having the change evaluated by
your tests is really quick.

Ok, but what about JRuby?

### Performance: JRuby vs. MRI
Running a Ruby command from JRuby takes a lot longer then running the same
command from MRI. There is about a 2 second difference on my machine:

``` text
# JRuby 1.7.0.RC2
~/time jruby -e "puts 'Foo'"
Foo

real  1.66s
user  2.08s
sys   0.15s

# MRI 1.9.3-p194
~/time ruby -e "puts 'Foo'"
Foo

real  0.05s
user  0.02s
sys   0.02s
```

This delay is very noticeable in my development workflow. If on the other hand
you are using MacVim or an IDE like RubyMine I can imagine this will not bother
you that much. You probably switch between windows or use the mouse anyway when
running your tests - thus losing precious time.

What to do? A colleague of mine working on a Scala project was experiencing the
same JVM startup problems when compiling and came across a utility called
[Zinc](https://github.com/typesafehub/zinc) which uses Nailgun underneath. I had
heard of [Nailgun](http://www.martiansoftware.com/nailgun/) before, but I never
tried it out (scumbag me). I had some time now, so I figured lets try it out. 

### Nailgun

What is Nailgun and why does it speed up JRuby or Scala commands? The gist of it
is stated on the [project
website](http://www.martiansoftware.com/nailgun/background.html): *Run all your
Java apps in the same JVM, the Nailgun server, which only needs to start once.*
There is probably a lot more to it than that, but for now this is all I need to
know.

##### Installing Nailgun

Installing Nailgun is not even necessary, it comes with JRuby since version
1.3.0, see Headius'
[blogpost](http://blog.headius.com/2009/05/jruby-nailgun-support-in-130.html)
announcing JRuby 1.3.0. It is also available as a package on Homebrew in case
you prefer that - in this blogpost I describe the situation where you use the
JRuby bundled Nailgun.

Getting JRuby to work under the latest version of RVM proved to be a bit more
problematic. 

Installing JRuby using the latest (1.16.13) version of RVM did not work on my
machine. It failed with the following error message:

``` text
Error running 'jruby_install_build_nailgun', please read /Users/robin/.rvm/log/jruby-1.6.8/nailgun.log
```

I filed an issue on the RVM project
[here](https://github.com/wayneeseguin/rvm/issues/1229) hoping they can fix
this.

In the meantime, reverting RVM back to 1.15.9 as suggested
[here](https://gist.github.com/3662673) worked.

##### Running JRuby commands using Nailgun

The previously mentioned blogpost by Headius explains how to start your JRuby
commands using Nailgun, it is pretty simple:

1. Startup a Nailgun server:  
   `jruby --ng-server &`  
   This will start Nailgun server in the background which will start a JVM. This
   started JVM will run the different Ruby command you throw at it, saving you
   the time of starting up a JVM each time you run a command.

2. Running a Ruby command against the Nailgun server:  
   `jruby --ng COMMAND`

As I said, simple.

### Automatically starting Nailgun server

On his blogpost Headius talks about further improvements: *Future improvements
will include having --ng start up the server for you if you haven't started it*.

I figured this would work by now (JRuby 1.3.0 is from 2009). I tried it out and
it does not work:

``` text
connect to Nailgun server: Connection refused
```

That is kind of annoying, but you could automate starting the Nailgun server 
pretty easily I guess.

I will spin up the Nailgun server by hand for now. As long as you do not 
reinstall JRuby you won't have to restart the server, so I can just leave it
running all day. I did add an alias to my zsh settings:

``` bash
alias jruby=jruby --ng
```

This makes sure every JRuby command runs against the Nailgun server.

### Performance: Nailgun-powered JRuby vs. MRI

The question that remains is, does it make a difference?

The first time you run a command using the `--ng` switch the JVM is loaded but
after that the speed increase is pretty dramatic:

``` text
# Run 1
~/time jruby --ng -e "puts 'Foo'"
Foo

real  2.67s
user  0.01s
sys   0.01s

# Run 2
~/time jruby --ng -e "puts 'Foo'"
Foo

real  0.49s
user  0.01s
sys   0.01s

# Run 3
~/time jruby --ng -e "puts 'Foo'"
Foo

real  0.38s
user  0.01s
sys   0.01s
```

Because of the HotSpot compiler it evens goes down to the 0.28s after a couple
of runs, which is almost 10 times as fast.

### Conclusion

JRuby combined with Nailgun is still slower than MRI (yes it is noticeable) but
it is a lot less annoying right now. Cool stuff.. now wishing I had looked at 
it earlier ;-(
