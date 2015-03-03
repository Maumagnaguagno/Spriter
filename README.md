# Spriter
Sprite generator  
Based on http://tools.putpixel.com/spritegen.html

My favorites are the old man and the puma:
![Old man](https://rawgithub.com/Maumagnaguagno/Spriter/master/images/sprite_64.svg)
![Puma](https://rawgithub.com/Maumagnaguagno/Spriter/master/images/sprite_65.svg)

I wanted cool sprites without the creativity block that always happens...  
Soon I found the site of putpixel generating several small sprites and thought: **cool, but it is not Ruby...**
Inspecting the element I found the source with **DO WTF YOU WANT TO PUBLIC LICENSE**, and I started.

It was December 2013, created my own version with most of the algorithm intact to test my Image class.
Then the integer probability and seed control made easier to handle the beast. Some time after that I moved most of the Image class to C to achieve speed enough for effects during game execution and let the old pure Ruby class waiting.
Found this project the other day lost in my HD, optimized a little bit, made C and Ruby talk again and here we are.
This version lacks some common Image methods as I have to downgrade/upgrade them from my C implementation.

The goal is not to have a Sprite generator alone, but a consistent example of a image class being used to render, save and load files. It is a shame that image and sound are not first class citizens of modern languages, requiring a lot of work to build a library or to understand one to reach this level of fun.

# How the Image class works
You can create your images from scratch, actually, you can only create from scratch until I add more methods to Ruby. And since BMP files are my favorite, the images use BGRA32 internally to hold the channels in a packed String.
```Ruby
require './Image'

# Let us create a small image
width = height = 32
img = Image.new(width, height)
# I want to fill it with red now
red_rgb = [255,0,0]
# But we need to convert before anything (add alpha channel)
red_bgra = (red_rgb.reverse << 255).pack('C4')
# We could write several times, but I want to write at once all the pixels
data = red_bgra * (width * height)
# Our data size is 4 times larger, (BGRA) * 4, but a shift is faster with integers
img.write(0, 0, data, data.size)
# Which extension we need? Save them all
img.save_bmp('red.bmp') # BMPs are uncompressed, eat HD (3.05KB)
img.save_png('red.png') # PNGs are compressed, eat CPU (100 Bytes)
img.save_svg('red.svg') # SVGs are vector, eat both at the current level (66.4 KB)
```
You can also load BMPs and PNGs, but PNGs already exploded for me with ZLib doing the descompression under Ruby 1.8.7. I need more tests to see if this behavior maintains. But BMPs work just fine and can be loaded with ```img = Image.load_bmp2(filename)```, noticed a ```2```? This happens because I have a C version as the default one, some large bitmaps take a long time to load and fill the alpha channel to each pixel, therefore I maintained the old version under a different name. You should note that I only support one type of BMP file with 24 bits per pixels, therefore palette based ones are up to you to implement. I tried to support two modes for PNGs: RGB and RGBA, but no reason to enter in details before I actually test this.

# How Spriter works
ToDo write this section

# ToDo's
- Optional clean step
- Support odd proportions
- Color based on neighbor count
- Better PNG support, I believe there is a problem with this version for some image proportions
