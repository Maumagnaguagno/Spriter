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
  # Dup
  #-----------------------------------------------

  def dup
    self.class.new(@width, @height).write(0, 0, @pixels, @pixels.size)
  end

  #-----------------------------------------------
  # Get pixel
  #-----------------------------------------------

  def get_pixel(x, y)
    pixel = @pixels[x + y * @width << 2, 4].unpack('C4')
    b = pixel[0]
    pixel[0] = pixel[2]
    pixel[2] = b
    pixel
  end

  #-----------------------------------------------
  # Set pixel
  #-----------------------------------------------

  def set_pixel(x, y, r, g, b, a)
    @pixels[x + y * @width << 2, 4] = [b,g,r,a].pack('C4')
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
