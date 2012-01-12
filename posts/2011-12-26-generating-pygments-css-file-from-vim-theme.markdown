---
layout: post
published: false
---

Inspired by @iain_nl's mvim contraption (really cool, check it out over here: ) I wanted to have my
code blocks in my blog use the ir_black theme as well.

I was confident that there already was a publicly available css file for Pygments available that
I could use. However after some searching, I was not able to find one.

So - how about generating one myself?
The documentation of Pygments explains how to
http://pygments.org/docs/styles/#builtin-styles
create your own styles. This could work, I'd only have to convert the styles used in the vim theme
to the format that Pygments wanted to have it.

After more searching, I found this django-richtemplates project on BitBucket. It already had
a Pygments style (no css file yet) generated from the ir_black vim theme (by using VIM Colorscheme
 Converter).

https://bitbucket.org/lukaszb/django-richtemplates/src/8ba421e7812e/richtemplates/pygstyles/irblack.py

The Vim Colorscheme Converter works like this:

https://github.com/honza/vim2pygments
python vim2pygments.py molokai.vim > molokai.py


Now to generate a css file from this Pygments style.

Luckily, someone had already documented it:
http://honza.ca/2011/02/how-to-convert-vim-colorschemes-to-pygments-themes

Add the ir_blakc.py to the styles directory of pygments. In OS X this is located:
/Library/Python/2.7/site-packages/Pygments-1.4-py2.7.egg/pygments/styles

(of course, versions could be different on your machine)

Generating the css file could not be easier:
./pygmentize -S ir_black -f html -a .highlight > ir_black.css
