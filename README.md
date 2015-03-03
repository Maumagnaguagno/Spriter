
# Spriter
<a href="https://rawgithub.com/Maumagnaguagno/Spriter/master/images/sprite_65.svg" target="_blank">
<img src="https://rawgithub.com/Maumagnaguagno/Spriter/master/images/sprite_65.svg" align="right" width="96px" title="Puma" border="0"/>
</a>

<a href="https://rawgithub.com/Maumagnaguagno/Spriter/master/images/sprite_64.svg" target="_blank">
<img src="https://rawgithub.com/Maumagnaguagno/Spriter/master/images/sprite_64.svg" align="right" width="96px" title="Old man" border="0"/>
</a>

  Sprite generator
  Based on http://tools.putpixel.com/spritegen.html

I wanted cool sprites without the creativity block that always happens...  
Soon I found the site of putpixel generating several small sprites and thought:  
  **Cool, but it is not Ruby...**  
Inspecting the element I found the source with the WTFPL (http://www.wtfpl.net/), and got started.

It was December 2013, created my own version with most of the algorithm intact to test my Image class.
Then the integer probability and seed control made easier to handle the beast. Some time after that I moved most of the Image class to C to achieve speed enough for effects during game execution and let the old pure Ruby class waiting.
Found this project the other day lost in my HD, optimized a little bit, made C and Ruby talk again and here we are.
This version lacks some common Image methods as I have to downgrade/upgrade them from my C implementation. Why not a gem project? I really do not like to recompile/install a gem for every Ruby/Plataform I am developing, so I have this C version only for my machine right now.

The goal is not to have a Sprite generator alone, but a consistent example of an Image class being used to render, save and load files. It is a shame that image and sound are not first class citizens of modern languages, requiring a lot of work to build a library or to understand one to reach this level of fun.

# How the Image class works
Before you have sprites, you need images. You can create your images from scratch, actually, you can only create from scratch until I add more methods to Ruby. And since BMP files are my favorite, the images use BGRA32 internally to hold the channels in a packed String.
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

If you do not understand at first sight some of my tricks you should read this explanation as a guide to the binary format of BMPs: https://practicingruby.com/articles/binary-file-formats  
I just optimized further for my specific need/love of BMPs with 24 bits.

# How Spriter works
Ok, so now we (You and I!) can play with images. Yeah! But none of us know how to draw, even less without interface. But we are not alone, the computer also does not know. Now the three of us make the non-artist club. We know that sometimes we draw OK, but it is one in ten. The computer can draw much faster those ten... Humm... OK, what if we asked for a lot of images with different random seeds and pixel distribution probabilities. It works! Creativity is just brute-force with insight now! We can look at the images generated and complete the blanks of our computer friend.

It is important to note that you can reproduce your results giving the same ~~seed~~inspiration to the computer. If you do not need to save the images to files there is no need to require the Image class. Spriter is grid-based (zeroes and ones) and can print without problems to the terminal.

```Ruby
require './Image'

# What extension do you want
ext = 'bmp'
# 100 must be enough inspiration
100.times {|seed|
  # 32x32 is my style, bigger images are harder to create with cool effects
  spt = Spriter.new(32, 32, seed)
  # I am only giving the mirroring probabilities here
  # 87% of replicating the left on the right
  # 13% of replicating the top on the bottom
  # You can also control the distribution with function symbol and a range
  # falloff = :cosine
  # probmin = 10
  # probmax = 75
  # Further modifications on the previous result through the cleaning stage
  # to remove or extend lonely pixels
  # modifier = :remove
  # clean = 88
  # modify = 90
  spt.generate(87, 13)
  # If you want to see in the Terminal, print it
  # just make sure the character "\0" is invisible and "\1" is visible
  puts spt.to_s, '-' * 32
  # Save it to a folder that already exists (You need spriter/bmp/ for this example to work)
  # You can also give foreground and background colors default is green on black
  # save(filename, ext = 'bmp', front = [0,255,0,255], back = [0,0,0,255])
  spt.save("spriter/#{ext}/sprite_#{seed}",ext)
}
```

# ToDo's
- Optional clean step
- Color based on neighbor count (may take a lot of CPU)
- Better PNG support, I believe there is a problem with this version for some image proportions
- Compress SVG, define a background rect and only the foreground pixels, cluster them into rects.
  - It will work, but how complex is to find the minimal set of rects in a grid?
