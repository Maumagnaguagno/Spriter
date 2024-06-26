#!/usr/bin/env ruby
#-----------------------------------------------
# Spriter
#-----------------------------------------------
# Mau Magnaguagno
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
# - Fall off X outside inner loop
# - Correct XY mirroring
# Jan 2016
# - Optional clean step
# Mar 2016
# - Removed array colors
# Apr 2016
# - Add match pixel
#-----------------------------------------------
# TODOs
# - Support odd proportions
# - Color based on neighbor count
#-----------------------------------------------

require_relative 'Image'
require_relative 'ImageX'

class Spriter

  #-----------------------------------------------
  # Initialize
  #-----------------------------------------------

  def initialize(width, height)
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
    x = 1 - (range - pos + 0.5).abs / range
    x < 0 ? 0 : x < 1 ? x : 1
  end

  #-----------------------------------------------
  # Cosine
  #-----------------------------------------------

  def cosine(range, pos)
    x = 1 - (range - pos + 0.5).abs / range
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

  def generate(mx = 0, my = 0, falloff = :cosine, probmin = 10, probmax = 75, clean = 88, modify = 90, remove = true)
    probmax -= probmin
    mirror_x = rand(101) <= mx
    mirror_y = rand(101) <= my
    range_x = @width >> 1
    range_y = @height >> 1
    limit_x = mirror_x ? @width - range_x : @width
    limit_y = mirror_y ? @height - range_y : @height
    # Draw
    index_y = 0
    falloff_x = Array.new(limit_x) {|x| send(falloff, range_x, x)}
    limit_y.times {|y|
      falloff_y = probmax * send(falloff, range_y, y)
      limit_x.times {|x| @grid[x + index_y] = 1 if rand(101) <= probmin + falloff_y * falloff_x[x]}
      index_y += @width
    }
    # Clean
    if clean and modify
      index_y = 0
      j = -@width
      limit_y.times {|y|
        limit_x.times {|x|
          count = 0
          i = x + j
          count += 1 if @grid[i.pred] == 1
          count += 1 if @grid[i] == 1
          count += 1 if @grid[i.succ] == 1
          i += @width
          count += 1 if @grid[i.pred] == 1
          count += 1 if @grid[i.succ] == 1
          i += @width
          count += 1 if @grid[i.pred] == 1
          count += 1 if @grid[i] == 1
          count += 1 if @grid[i.succ] == 1
          case count
          when 1
            @grid[x + index_y] = 0 if rand(101) <= clean
          when 0
            if rand(101) <= modify
              if remove
                @grid[x + index_y] = 0
              else
                @grid[x + rand(3).pred + (y + rand(3).pred) * @width] = 1
              end
            end
          end
        }
        j = index_y
        index_y += @width
      }
    end
    # Mirror
    if mirror_y
      index_y = 0
      mirror_y = -@width
      if mirror_x
        limit_y.times {
          @grid[index_y + limit_x, range_x] = @grid[index_y, range_x].reverse!
          @grid[mirror_y - index_y, @width] = @grid[index_y, @width]
          index_y += @width
        }
      else
        range_y.times {
          @grid[mirror_y - index_y, @width] = @grid[index_y, @width]
          index_y += @width
        }
      end
    elsif mirror_x
      mirror_x = limit_x
      limit_y.times {
        @grid[limit_x, range_x] = @grid[limit_x - mirror_x, range_x].reverse!
        limit_x += @width
      }
    end
  end

  #-----------------------------------------------
  # to String
  #-----------------------------------------------

  def to_s
    str = @grid.pack("C#{@width}x" * @height)
    index = -1
    @height.times {str.setbyte(index += @width.succ, 10)}
    str
  end

  #-----------------------------------------------
  # to Image
  #-----------------------------------------------

  def to_image(r1 = 0, g1 = 255, b1 = 0, a1 = 255, r2 = 0, g2 = 0, b2 = 0, a2 = 255)
    front = [b1, g1, r1, a1].pack('C4')
    back = [b2, g2, r2, a2].pack('C4')
    i = 0
    pixels = back * (@width * @height)
    @grid.each {|p| pixels[i,4] = front if p != 0; i += 4}
    Image.new(@width, @height).write(0, 0, pixels, i)
  end

  #-----------------------------------------------
  # Save
  #-----------------------------------------------

  def save(filename, r1 = 0, g1 = 255, b1 = 0, a1 = 255, r2 = 0, g2 = 0, b2 = 0, a2 = 255)
    case File.extname(filename)
    when '.bmp' then to_image(r1, g1, b1, a1, r2, g2, b2, a2).save_bmp(filename)
    when '.png' then to_image(r1, g1, b1, a1, r2, g2, b2, a2).save_png(filename)
    when '.svg' then to_image(r1, g1, b1, a1, r2, g2, b2, a2).save_svg(filename, r2, g2, b2)
    else raise "Unknown extension #{File.extname(filename)}"
    end
  end
end

#-----------------------------------------------
# Main
#-----------------------------------------------
if $0 == __FILE__
  begin
    t = Time.now.to_f
    div = '--------------------------------'
    ext = ARGV[0] || 'bmp'
    unless File.directory?("sprites/#{ext}")
      Dir.mkdir('sprites') unless File.directory?('sprites')
      Dir.mkdir("sprites/#{ext}")
    end
    100.times {|seed|
      srand(seed)
      spt = Spriter.new(32, 32)
      spt.generate(87, 13)
      #puts spt.to_s, div
      spt.save("sprites/#{ext}/sprite_#{seed}.#{ext}")
    }
    p Time.now.to_f - t
  rescue Interrupt
    puts 'Interrupted'
    exit(130)
  rescue
    puts $!, $@
    exit(2)
  end
end