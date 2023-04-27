# Spriter [![Actions Status](https://github.com/Maumagnaguagno/Spriter/workflows/build/badge.svg)](https://github.com/Maumagnaguagno/Spriter/actions)
**Sprite generator based on monochrome [Spritegen](https://web.archive.org/web/20160305123432/http://tools.putpixel.com/spritegen.html)**
<a href="/sprites/svg/sprite_65.svg" target="_blank">
<img src="/sprites/svg/sprite_65.svg" align="right" width="96" title="Puma"/>
</a>
<a href="/sprites/svg/sprite_64.svg" target="_blank">
<img src="/sprites/svg/sprite_64.svg" align="right" width="96" title="Old man"/>
</a>

I wanted cool sprites, but creative blocks are always haunting me...
Soon I found an online tool generating several small sprites and thought: **Cool, but it is not Ruby...** :broken_heart:  
Inspecting the element I found the source with the [WTFPL](http://www.wtfpl.net/), and got started.  
A [new colored version of Spritegen is available here](https://img.uninhabitant.com/spritegen.html).

It was December 2013, created my own version with most of the algorithm intact to test my Image class.
With integer probability and seed control it was easy to handle the beast.
Some time after that I moved most of the Image class to C to achieve enough speed for in-game effects and left the old pure Ruby class waiting.
Therefore, the project contains an Image class split in two files, [Image.rb](Image.rb) with basic methods and [ImageX.rb](ImageX.rb) extending the Image class with complex methods.
The Spriter class defined in [Spriter.rb](Spriter.rb) make use of the Image class.

The goal is not to have a Sprite generator alone, but a consistent example of an Image class being used to save and load files.
It is a shame that image and sound are not first class citizens of modern languages, requiring a lot of work to build a library or to understand one to reach this level of fun.

## Image class
Before you have sprites, you need images.
And since BMP is my favorite image format (much simpler), pixels are stored as BGRA32 internally to hold the channels in a packed String, e.g. an image with 3 pixels is stored as ``BGRABGRABGRA``.
Each 8 bit channel holds a color: Red, Green, Blue and Alpha.
Alpha is used for transparency effects, usually used in PNGs.
We can easily pack an Array ``color = [B,G,R,A]`` to a BGRA32 String using ``color.pack('C4')``, where B, G, R and A are Integers between 0 and 255.

```Ruby
require_relative 'Image'
require_relative 'ImageX'

width = height = 32
data = [0, 0, 255, 255].pack('C4') * (width * height)
img = Image.new(width, height)
img.write(0, 0, data, data.size) # Fill image with red BGRA32
img.save_bmp('red.bmp') # BMPs are uncompressed, eat HD (3.05 KB)
img.save_png('red.png') # PNGs are compressed, eat CPU (96 bytes)
# SVGs are vector based, CPU and HD usage varies
img.save_svg('red1.svg') # Without background (470 bytes)
img.save_svg('red2.svg', 255, 0, 0) # With red background (96 bytes)
```

You can also load BMPs and PNGs, note that only BMPs with 24 bits per pixel (8 bits per channel) are supported, therefore palette based ones are up to you to implement.
It supports two modes for PNG: RGB and RGBA.

If any part of my implementation is not understandable at first sight, you should read this [guide to the binary format of BMPs](https://practicingruby.com/articles/binary-file-formats).
I just optimized further for my specific need of BMPs.
Another interesting post is [ChunkyPNG pack/unpack tricks](https://web.archive.org/web/20200202031423/https://chunkypng.com/2010/01/17/ode-to-array-pack-and-string-unpack.html) related to images stored as an Array of Integers.

The naive conversion to SVG resulted in big files describing each pixel as a rectangle.
The new method sets a background color and cluster consecutive equal pixels.
Such optimization may help decrease the file size while saving time, as writing a big file to disk is much slower.
Note that only images with limited palette can exploit such optimization.

## Spriter class
Ok, so now we can play with images.
But none of us know how to draw, even less without an interface.
We are not alone, the computer also does not know.
Now the three of us make the non-artist club.
We know that sometimes we draw OK, but it is one in ten and it takes a long time to draw.
The computer can draw much faster those ten times.
Humm...
What if we asked the computer for a lot of images with different random seeds and pixel distribution probabilities.
It works, the computer drew something that resembles a Puma!
Creativity is just brute-force with insight now!
We can look at the generated images and complete the missing pixels.

It is important to note that you can reproduce your results by giving the same ~~seed~~ inspiration to the computer.
The Image class is only used to save and load files, no need to require it otherwise.
Spriter works on a binary grid, which can be printed to a terminal.

```Ruby
require_relative 'Spriter'

100.times {|inspiration|
  srand(inspiration)
  # 32x32 is my style, bigger images are harder to generate cool effects
  spt = Spriter.new(32, 32)
  # Generate a sprite with:
  # 87% chance of replicating the left on the right
  # 13% chance of replicating the top on the bottom
  # You can also control the distribution function, probabilities and cleaning/adding loose pixels
  spt.generate(87, 13)
  # If you want to see it in the Terminal, print it
  # just make sure the character "\0" is invisible and "\1" is visible
  puts spt.to_s, '-' * 32
  # Save it to a file, destination folder sprites/bmp/ must already exist
  # You can also give foreground and background colors, default is green on black
  spt.save("sprites/bmp/sprite_#{inspiration}.bmp", 0,255,0,255, 0,0,0,255)
}
```

## ToDo's
- API documentation
- More tests (Spriter, BMP and PNG with different image proportions)
- Optional color based on neighbor count (may take a lot of CPU)