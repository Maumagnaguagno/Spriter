#!/usr/bin/env ruby
#-----------------------------------------------
# Spriter
#-----------------------------------------------
# Mau Magnaguagno
#-----------------------------------------------
# Use Spriter.rb
#-----------------------------------------------
# - Sprite Generator
# - Based on http://tools.putpixel.com/spritegen.html
#-----------------------------------------------
# Dec 2013
# - Created
# - Integer probability
# - Added seed
# Feb 2015
# - Optimized
# Mar 2015
# - Fall off x outside inner loop
# - Correct xy mirroring
#-----------------------------------------------
# TODOs
# - Optional clean step
# - Support odd proportions
# - Color based on neighbor count
#-----------------------------------------------

require './Image'

#-----------------------------------------------
# Spriter
#-----------------------------------------------

class Spriter

  AROUND = [
    [-1,-1],[0,-1],[1,-1],
    [-1, 0],       [1, 0],
    [-1, 1],[0, 1],[1, 1]]

  #-----------------------------------------------
  # Initialize
  #-----------------------------------------------

  def initialize(width, height)
    # Image proportion
    @width = width
    @height = height
    @grid = Array.new(width * height, 0)
  end

  #-----------------------------------------------
  # Constant
  #-----------------------------------------------

  def constant(range, pos)
    1
  end

  #-----------------------------------------------
  # Linear
  #-----------------------------------------------

  def linear(range, pos)
    i = 1 - (range - pos + 0.5).abs / range
    i < 0 ? 0 : i < 1 ? i : 1
  end

  #-----------------------------------------------
  # Cosine
  #-----------------------------------------------

  def cosine(range, pos)
    x = (1 - (range - pos + 0.5).abs / range)
    (1 - Math.cos(x * Math::PI)) * 0.5
  end

  #-----------------------------------------------
  # Spherical
  #-----------------------------------------------

  def spherical(range, pos)
    x = (1 - (range - pos + 0.5).abs / range).abs
    Math.sqrt((2 - x) * x)
  end

  #-----------------------------------------------
  # Generate
  #-----------------------------------------------

  def generate(mx = 0, my = 0, falloff = :cosine, probmin = 10, probmax = 75, modifier = :remove, clean = 88, modify = 90)
    probmax -= probmin
    mirror_x = rand(101) <= mx
    mirror_y = rand(101) <= my
    range_x = @width >> 1
    range_y = @height >> 1
    limit_x = mirror_x ? range_x : @width
    limit_y = mirror_y ? range_y : @height
    # Draw
    index_y = 0
    falloff_x = Array.new(limit_x) {|x| send(falloff, range_x, x)}
    limit_y.times {|y|
      falloff_y = probmax * send(falloff, range_y, y)
      limit_x.times {|x| @grid[x + index_y] = 1 if rand(101) <= probmin + falloff_y * falloff_x[x]}
      index_y += @width
    }
    # Clean
    index_y = 0
    limit_y.times {|y|
      limit_x.times {|x|
        count = 0
        AROUND.each {|i,j| count += 1 if @grid[x + i + (y + j) * @width] == 1}
        if count == 1 and rand(101) <= clean
          @grid[x + index_y] = 0
        elsif count.zero?
          if rand(101) <= modify
            case modifier
            when :remove
              @grid[x + index_y] = 0
            when :extend
              @grid[x + rand(3).pred + (y + rand(3).pred) * @width] = 1
            end
          end
        end
      }
      index_y += @width
    }
    # Mirror
=begin
    index_y = 0
    limit_y.times {|y|
      limit_x.times {|x|
        if mirror_x
          color = @grid[x + index_y]
          @grid[@width.pred - x + index_y] = color
          if mirror_y
            @grid[x + (@height.pred - y) * @width] = color
            @grid[@width.pred - x + (@height.pred - y) * @width] = color
          end
        elsif mirror_y
          @grid[x + (@height.pred - y) * @width] = @grid[x + index_y]
        end
      }
      index_y += @width
    }
=end
    index_y = 0
    if mirror_y
      if mirror_x
        mirror_xy = (@width * @height).pred
        mirror_x = @width.pred
        mirror_y = mirror_xy - mirror_x
        limit_y.times {
          limit_x.times {|x| @grid[mirror_x - x] = @grid[mirror_y + x] = @grid[mirror_xy - x] = @grid[x + index_y]}
          index_y += @width
          mirror_x += @width
          mirror_y -= @width
          mirror_xy -= @width
        }
      else
        mirror_y = @height.pred * @width
        limit_y.times {
          limit_x.times {|x| @grid[mirror_y + x] = @grid[x + index_y]}
          mirror_y -= @width
          index_y += @width
        }
      end
    elsif mirror_x
      mirror_x = @width.pred
      limit_y.times {
        limit_x.times {|x| @grid[mirror_x - x] = @grid[x + index_y]}
        mirror_x += @width
        index_y += @width
      }
    end
  end

  #-----------------------------------------------
  # to String
  #-----------------------------------------------

  def to_s
    str = ''
    index = 0
    @height.times {
      @width.times {
        str << @grid[index]
        index += 1
      }
      str << "\n"
    }
    str
  end

  #-----------------------------------------------
  # Save
  #-----------------------------------------------

  def save(filename, ext = 'bmp', front = [0,255,0,255], back = [0,0,0,255])
    # [R,G,B,A] to BGRA32
    front = (front[0,3].reverse! << front.last).pack('C4')
    back = (back[0,3].reverse! << back.last).pack('C4')
    pixels = ''
    @grid.each {|i| pixels << (i.zero? ? back : front)}
    img = Image.new(@width, @height).write(0, 0, pixels, pixels.size)
    case ext
    when 'bmp'
      img.save_bmp("#{filename}.bmp")
    when 'png'
      img.save_png("#{filename}.png", Image::RGB)
    when 'svg'
      img.save_svg("#{filename}.svg")
    when 'svgx'
      img.save_svg_compressed("#{filename}.svg", back.unpack('C3'))
    else
      raise "Unknown extension #{ext}"
    end
  end
end

#-----------------------------------------------
# Main
#-----------------------------------------------
if $0 == __FILE__
  begin
    t = Time.now.to_f
    div = '-' * 32
    ext = 'svgx'
    100.times {|seed|
      srand(seed)
      spt = Spriter.new(32, 32)
      spt.generate(87, 13)
      #puts spt.to_s, div
      spt.save("spriter/#{ext}/sprite_#{seed}", ext)
    }
    p Time.now.to_f - t
  rescue Interrupt
    puts 'Interrupted'
  rescue
    puts $!, $@
    STDIN.gets
  end
end
