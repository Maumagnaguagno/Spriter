# Spriter [![Build Status](https://travis-ci.org/Maumagnaguagno/Spriter.svg)](https://travis-ci.org/Maumagnaguagno/Spriter)
<a href="https://rawgithub.com/Maumagnaguagno/Spriter/master/sprites/svgc/sprite_65.svg" target="_blank">
<img src="https://rawgithub.com/Maumagnaguagno/Spriter/master/sprites/svgc/sprite_65.svg" align="right" width="96px" title="Puma" border="0"/>
</a>

<a href="https://rawgithub.com/Maumagnaguagno/Spriter/master/sprites/svgc/sprite_64.svg" target="_blank">
<img src="https://rawgithub.com/Maumagnaguagno/Spriter/master/sprites/svgc/sprite_64.svg" align="right" width="96px" title="Old man" border="0"/>
</a>

Sprite generator based on [Spritegen](http://tools.putpixel.com/spritegen.html)

I wanted cool sprites, but the creativity block is always haunting me...
Soon I found the site of putpixel generating several small sprites and thought: **Cool, but it is not Ruby...** :broken_heart:  
Inspecting the element I found the source with the [WTFPL](http://www.wtfpl.net/), and got started.

It was December 2013, created my own version with most of the algorithm intact to test my Image class.
Then the integer probability and seed control made easier to handle the beast.
Some time after that I moved most of the Image class to C to achieve enough speed for in-game effects and let the old pure Ruby class waiting.
Therefore the project contains an Image class split in two files, ```Image.rb``` with the pixel information visible and ```ImageX.rb``` extending the Image class with complex instructions.
A Spriter class in ```Spriter.rb``` make use of the Image class.

The goal is not to have a Sprite generator alone, but a consistent example of an Image class being used to save and load files.
It is a shame that image and sound are not first class citizens of modern languages, requiring a lot of work to build a library or to understand one to reach this level of fun.

## How Image works
Before you have sprites, you need images. 
And since BMP files are my favorite image format (much simpler), the images use BGRA32 internally to hold the channels in a packed String, e.g. an image with 3 pixels is stored as ```BGRABGRABGRA```.
Each 8 bits channel holds a color: Red, Green, Blue and Alpha.
Alpha is used for transparency effects, usually used in PNGs.
We can easily pack an Array ```color = [B,G,R,A]``` to a BGRA32 String using ```color.pack('C4')```, where B, G, R and A are Fixnums between 0 and 255.

```Ruby
require 'zlib' # PNG compression
require './Image'
require './ImageX'

width = height = 32
img = Image.new(width, height)
red_bgr = [255,0,0].reverse
# add alpha channel, RGB => BGRA32
red_bgra = (red_bgr << 255).pack('C4')
# Fill image with red in a single call
data = red_bgra * (width * height)
img.write(0, 0, data, data.size)
img.save_bmp('red.bmp') # BMPs are uncompressed, eat HD (3.05KB)
img.save_png('red.png') # PNGs are compressed, eat CPU (100 Bytes)
img.save_svg('red.svg') # SVGs are vector, eat both HD and CPU (63.4 KB)
img.save_svg_compressed('red2.svg', red_bgr) # SVGs compressed (149 bytes)
```

You can also load BMPs and PNGs, but PNGs already exploded for me with ZLib doing the decompression under Ruby 1.8.7.
I need more tests to see if this behavior maintains.
You should note that I only support one type of BMP file with 24 bits per pixel, therefore palette based ones are up to you to implement.
I tried to support two modes for PNGs: RGB and RGBA, but no reason to enter in details before I actually test this.

If you do not understand at first sight part of my implementation you should read this [guide to the binary format of BMPs](https://practicingruby.com/articles/binary-file-formats).
I just optimized further for my specific need/love of BMPs with 24 bits.
Another interesting post is [ChunkyPNG pack/unpack tricks](http://chunkypng.com/2010/01/17/ode-to-array-pack-and-string-unpack.html) related to images stored as an Array of Fixnums.

SVGs are very recent to me, never explored them earlier.
The default method to save SVGs is extremely simple and creates a big file, while the compressed method creates a single rect for the background and cluster remaining equal pixels in lines.
This line compression may help to decrease the final size, but makes more tests during the transformation.
This is not a sign that all images will be compressed, images with several colors will not take advantage of this, only taking longer to be saved.
The positive side is to exchange CPU time with HD space/time, as a smaller file will take less HD and less cycles to be written now, and read out in the future.

## How Spriter works
Ok, so now we (You and I!) can play with images.
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
Spriter is grid-based (zeroes and ones) and can print without problems to the terminal.

```Ruby
require 'zlib' # PNG compression
require './Image'
require './ImageX'

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
  # Save it to a file, sprites/bmp/ must already exist
  # You can also give foreground and background colors default is green on black
  spt.save("sprites/bmp/sprite_#{inspiration}", 'bmp', [0,255,0,255], [0,0,0,255])
}
```

## ToDo's
- API documentation
- More tests (Spriter, BMP and PNG with different image proportions)
- Optional color based on neighbor count (may take a lot of CPU)
