---
layout: post
title: "Rails: Binary data in fixtures"
tags: fixtures mychain yaml
---
Yesterday I've implemented scraping the image of a card from the Gatherer repository. One of the test cases I've implemented was:
    #!ruby
    test "should have the right cardimage" do
      black_lotus = cards(:black_lotus)
      assert_equal card_images(:black_lotus), black_lotus.card_image
    end

The `card` and `card_image` fixture used in the test looks like this:
    #!yaml
    # cards.yml
    black_lotus:
      name: Black Lotus
      ...

    # card_images.yml
    black_lotus:
      size: 1
      data: foo
      content_type: png
      card: black_lotus

As you can see, I'm not using any binary data in my tests. This was bothering me a bit, so I decided to look into a way to be able to use binary data in a fixture.

YAML supports storing binary data, as is described in the [YAML documentation](http://yaml.org/type/binary.html). An example YAML file from that page looks like this:
    #!yaml
    generic: !binary |
      R0lGODlhDAAMAIQAAP//9/X17unp5WZmZgAAAOfn515eXvPz7Y6OjuDg4J+fn5
      OTk6enp56enmlpaWNjY6Ojo4SEhP/++f/++f/++f/++f/++f/++f/++f/++f/+
      +f/++f/++f/++f/++f/++SH+Dk1hZGUgd2l0aCBHSU1QACwAAAAADAAMAAAFLC
      AgjoEwnuNAFOhpEMTRiggcz4BNJHrv/zCFcLiwMWYNG84BwwEeECcgggoBADs=
    description:
      The binary value above is a tiny arrow encoded as a gif image.

As I don't feel like extracting and converting a Base64 encoded string for a couple of sample images (there will probably be an app for that ;)), I looked for a better way to load the Base64 encoded string into the fixture file.

Solutions were described in [this post](http://techpolesen.blogspot.com/2007/04/rails-fixture-tips.html) and [this one](http://moiristo.wordpress.com/2008/11/01/snippet-binary-to-yaml/). I combined both solutions and added a function to the YAML file (using ERB) that converts the binary data into a Base64 encoded string.
    #!yaml
    # card_images.yml
    &lt;%
      def fixture_data(name)
        render_binary("#{::Rails.root.to_s}/test/fixtures/binaries/#{name}")
      end

      def render_binary(filename, indent_level = 4)
        data = File.open(filename,'rb').read

        indent = ""
        indent_level.times{ indent &lt;&lt; " " }

        "!binary | \n#{indent}#{[data].pack('m').gsub(/\n/,"\n#{indent}")}\n"
      end
    %&gt;

    black_lotus:
      size: 31668
      data: &lt;%= fixture_data("black_lotus.jpg") %&gt;
      content_type: image/jpeg
      card: black_lotus

    accorder_paladin:
      size: 30969
      data: data: &lt;%= fixture_data("accorder_paladin.jpg") %&gt;
      content_type: image/jpeg
      card: accorder_paladin

Now I'm able to load the actual images of the cards into my fixtures. The images are stored in the `test/fixtures/binaries/` folder and are converted using the `fixture_data` and `render_binary` methods.

Oh yeah, the test is passing as well ;-)

**Day #10**
