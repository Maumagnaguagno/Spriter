# Spriter [![Build Status](https://travis-ci.org/Maumagnaguagno/Spriter.svg)](https://travis-ci.org/Maumagnaguagno/Spriter)
**Sprite generator based on monochrome [Spritegen](https://web.archive.org/web/20160305123432/http://tools.putpixel.com/spritegen.html)**
<a href="https://rawgit.com/Maumagnaguagno/Spriter/master/sprites/svg/sprite_65.svg" target="_blank">
<img src="https://rawgit.com/Maumagnaguagno/Spriter/master/sprites/svg/sprite_65.svg" align="right" width="96px" title="Puma" border="0"/>
</a>
<a href="https://rawgit.com/Maumagnaguagno/Spriter/master/sprites/svg/sprite_64.svg" target="_blank">
<img src="https://rawgit.com/Maumagnaguagno/Spriter/master/sprites/svg/sprite_64.svg" align="right" width="96px" title="Old man" border="0"/>
</a>

I wanted cool sprites, but creative blocks are always haunting me...
Soon I found an online tool generating several small sprites and thought: **Cool, but it is not Ruby...** :broken_heart:  
Inspecting the element I found the source with the [WTFPL](http://www.wtfpl.net/), and got started.
A [new colored version of Spritgen is available here](http://img.uninhabitant.com/spritegen.html?controls=true&autorandomize=false&pal=arne&colours=2&bg=0&size=12&spacing=8&tiles=16&zoom=1&scaler0=eagle2x&scaler1=none&advanced=false&advanced=true&seed=1363177051286&autoreseed=false&autoreseed=true&falloff=linear&probmin=0.1&probmax=0.9&bias=0.8&gain=0.8&mirrorh=0.9&mirrorv=0.1&despeckle=1&despur=1).

It was December 2013, created my own version with most of the algorithm intact to test my Image class.
With integer probability and seed control it was easy to handle the beast.
Some time after that I moved most of the Image class to C to achieve enough speed for in-game effects and left the old pure Ruby class waiting.
Therefore the project contains an Image class split in two files, ``Image.rb`` with the pixel information visible and ``ImageX.rb`` extending the Image class with complex methods.
A Spriter class in ``Spriter.rb`` make use of the Image class.

The goal is not to have a Sprite generator alone, but a consistent example of an Image class being used to save and load files.
It is a shame that image and sound are not first class citizens of modern languages, requiring a lot of work to build a library or to understand one to reach this level of fun.

## How Image works
Before you have sprites, you need images.
And since BMP files are my favorite image format (much simpler), the images use BGRA32 internally to hold the channels in a packed String, e.g. an image with 3 pixels is stored as ``BGRABGRABGRA``.
Each 8 bits channel holds a color: Red, Green, Blue and Alpha.
Alpha is used for transparency effects, usually used in PNGs.
We can easily pack an Array ``color = [B,G,R,A]`` to a BGRA32 String using ``color.pack('C4')``, where B, G, R and A are Integers between 0 and 255.

```Ruby
require './Image'
require './ImageX'

width = height = 32
data = [0, 0, 255, 255].pack('C4') * (width * height)
img = Image.new(width, height)
img.write(0, 0, data, data.size) # Fill image with red BGRA32
img.save_bmp('red.bmp') # BMPs are uncompressed, eat HD (3.05 KB)
img.save_png('red.png') # PNGs are compressed, eat CPU (100 bytes)
# SVGs are vector based, CPU and HD usage varies
img.save_svg('red1.svg') # Without background (1.87 KB)
img.save_svg('red2.svg', 255, 0, 0) # With red background (114 bytes)
```

You can also load BMPs and PNGs, note that only BMPs with 24 bits per pixel (8 bits per channel) are supported, therefore palette based ones are up to you to implement.
It supports two modes for PNG: RGB and RGBA.

If any part of my implementation is not understandable at first sight you should read this [guide to the binary format of BMPs](http://practicingruby.com/articles/binary-file-formats).
I just optimized further for my specific need/love of BMPs with 24 bits.
Another interesting post is [ChunkyPNG pack/unpack tricks](http://chunkypng.com/2010/01/17/ode-to-array-pack-and-string-unpack.html) related to images stored as an Array of Integers.

SVGs are very recent to me, never explored them earlier.
The old method to save SVGs was very simple and created big files, while the new method creates a single rect for the background and cluster consecutive equal pixels.
Such optimization may help decrease the file size while saving time, writing to disk a big file is much slower.
Note that few images can take advantage of such optimization, as real pictures have several colors.

## How Spriter works
Ok, so now we can play with images.
Yeah!
But none of us know how to draw, even less without interface.
We are not alone, the computer also does not know.
Now the three of us make the non-artist club.
We know that sometimes we draw OK, but it is one in ten and take a long time.
The computer can draw much faster those ten times.
Humm...
What if we asked the computer for a lot of images with different random seeds and pixel distribution probabilities.
It works, the computer drew something that resembles a Puma!
Creativity is just brute-force with insight now!
We can look at the generated images and complete the missing pixels.

It is important to note that you can reproduce your results giving the same ~~seed~~ inspiration to the computer.
The Image class is only used to save and load files, no need to require it otherwise.
Spriter is works on a binary grid and can print without problems to the terminal.

```Ruby
require './Spriter'

100.times {|inspiration|
  srand(inspiration)
  # 32x32 is my style, bigger images are harder to generate cool effects
  spt = Spriter.new(32, 32)
  # Generate a sprite with:
  # 87% of replicating the left on the right
  # 13% of replicating the top on the bottom
  # You can also control the distribution function, probabilities and cleaning/adding loose pixels
  spt.generate(87, 13)
  # If you want to see it in the Terminal, print it
  # just make sure the character "\0" is invisible and "\1" is visible
  puts spt.to_s, '-' * 32
  # Save it to a file, destination folder sprites/bmp/ must already exist
  # You can also give foreground and background colors default is green on black
  spt.save("sprites/bmp/sprite_#{inspiration}.bmp", 0,255,0,255, 0,0,0,255)
}
```

## ToDo's
- API documentation
- More tests (Spriter, BMP and PNG with different image proportions)
- Optional color based on neighbor count (may take a lot of CPU)
- Maybe support svgz: gzipped compressed svg