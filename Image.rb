# encoding: ascii-8bit
class Image

  attr_reader :width, :height

  #-----------------------------------------------
  # Initialize
  #-----------------------------------------------

  def initialize(width, height)
    @width = width
    @height = height
    @pixels = "\0" * (width * height << 2)
  end

  #-----------------------------------------------
  # Initialize copy
  #-----------------------------------------------

  def initialize_copy(other)
    super
    @pixels = @pixels.dup
  end

  #-----------------------------------------------
  # Get pixel
  #-----------------------------------------------

  def get_pixel(x, y)
    index = x + y * @width << 2
    [@pixels.getbyte(index + 2), @pixels.getbyte(index + 1), @pixels.getbyte(index), @pixels.getbyte(index + 3)]
  end

  #-----------------------------------------------
  # Set pixel
  #-----------------------------------------------

  def set_pixel(x, y, r, g, b, a)
    index = x + y * @width << 2
    @pixels.setbyte(index, b)
    @pixels.setbyte(index + 1, g)
    @pixels.setbyte(index + 2, r)
    @pixels.setbyte(index + 3, a)
    self
  end

  #-----------------------------------------------
  # Match pixel
  #-----------------------------------------------

  def match_pixel?(x, y, r, g, b, a)
    index = x + y * @width << 2
    @pixels.getbyte(index) == b and @pixels.getbyte(index + 1) == g and @pixels.getbyte(index + 2) == r and @pixels.getbyte(index + 3) == a
  end

  #-----------------------------------------------
  # Read
  #-----------------------------------------------

  def read(pixel_index, data_index, data, n_elem)
    data[data_index, n_elem] = @pixels[pixel_index, n_elem]
    self
  end

  #-----------------------------------------------
  # Write
  #-----------------------------------------------

  def write(pixel_index, data_index, data, n_elem)
    @pixels[pixel_index, n_elem] = data[data_index, n_elem]
    self
  end
end