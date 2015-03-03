require 'zlib'

#-----------------------------------------------
# Image
#-----------------------------------------------

class Image

  attr_reader :width, :height

  def initialize(width, height)
    @width = width
    @height = height
    @pixels = '\0' * (width * height << 2)
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

  BMP_HEADER = 'a2ls2l4s2l6'
  RGB = 2
  RGBA = 6

  #--------------------------------------------------------------
  # Header BMP
  #--------------------------------------------------------------

  def self.header_bmp(w, h)
    # BMP header
    ['BM', (((24 * w + 31) >> 5) * h << 2) + 54, 0, 0, 54,
    # DIB header
    40, w, h, 1, 24, 0, 0, 0, 0, 0, 0].pack(BMP_HEADER)
  end

  #--------------------------------------------------------------
  # Load BMP
  #--------------------------------------------------------------

  def self.load_bmp2(filename)
    image = nil
    open(filename,'rb') {|file|
      header = file.read(54)
      header_unpack = header.unpack(BMP_HEADER)
      w = header_unpack[6]
      h = header_unpack[7]
      image = new(w, h)
      padding = w & 3
      w3 = w << 3
      index_image = (w - 1) * h << 2
      h.times {
        w.times {
          image.write(index_image, 0, file.read(3) << "\xFF", 4)
          index_image += 4
        }
        index_image -= w3
        file.pos += padding
      }
    }
    image
  end

  #--------------------------------------------------------------
  # Save BMP
  #--------------------------------------------------------------

  def save_bmp(filename)
    open(filename,'wb') {|file|
      # Header
      file << Image.header_bmp(width, height)
      # Data
      size = width * height << 2
      data = ' ' * size
      read(0, 0, data, size)
      padding = ' ' * (width & 3)
      index = size - (width << 2)
      w = width << 3
      height.times {
        width.times {
          file << data[index, 3]
          index += 4
        }
        index -= w
        file << padding
      }
    }
  end

  #--------------------------------------------------------------
  # Load PNG
  #--------------------------------------------------------------

  def self.load_png(filename)
    image = nil
    w = h = 0
    color_type = 0
    open(filename,'rb') {|file|
      # Signature
      file.pos += 8
      loop {
        size, type = file.read(8).unpack('NA4')
        data = file.read(size).unpack('A*').first
        # CRC
        file.pos += 4
        case type
        when 'IHDR'
          data = data.unpack('N2C5')
          w = data.first
          h = data[1]
          color_type = data[3]
          image = new(w, h)
        when 'IDAT'
          data = Zlib::Inflate.inflate(data)
          index = 0
          index_image = 0
          if color_type == RGB
            h.times {
              index += 1
              w.times {
                image.write(index_image, 0, data[index,3].reverse << "\xFF", 4)
                index += 3
                index_image += 4
              }
            }
          else
            h.times {
              index += 1
              w.times {
                image.write(index_image, 0, data[index,3].reverse << data[index+3], 4)
                index += 4
                index_image += 4
              }
            }
          end
        when 'IEND'
          break
        end
      }
    }
    image
  end

  #--------------------------------------------------------------
  # Save PNG
  #--------------------------------------------------------------

  def save_png(filename, color_type = RGBA)
    size = width * height << 2
    data = ' ' * size
    read(0, 0, data, size)
    img_data = ''
    index = 0
    alpha = color_type == RGBA
    height.times {
      img_data << "\0"
      width.times {
        img_data << data[index, 3].reverse
        img_data << data[index+3] if alpha
        index += 4
      }
    }
    Image.save_png_data(filename, img_data, width, height, color_type)
  end

  #--------------------------------------------------------------
  # Save PNG data
  #--------------------------------------------------------------

  def self.save_png_data(filename, data, w, h, color_type)
    open(filename,'wb') {|file|
      file << "\x89PNG\r\n\x1a\n"
      file << chunk('IHDR', [w, h, 8, color_type, 0, 0, 0].pack('N2C5'))
      file << chunk('IDAT', Zlib::Deflate.deflate(data, 9))
      file << "\0\0\0\0IEND\xAEB`\x82"
    }
  end

  #--------------------------------------------------------------
  # Chunk
  #--------------------------------------------------------------

  def self.chunk(type, data)
    [data.size, type, data, Zlib.crc32(type << data)].pack('NA4A*N')
  end
  
  #--------------------------------------------------------------
  # Save SVG
  #--------------------------------------------------------------

  def save_svg(filename)
    size = width * height << 2
    data = ' ' * size
    read(0, 0, data, size)
    data = data.unpack('C*')
    open(filename,'w') {|file|
      file << "<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" width=\"#{width}\" height=\"#{height}\">\n"
      index = 0
      height.times {|y|
        width.times {|x|
          file << "<rect x=\"#{x}\" y=\"#{y}\" width=\"1\" height=\"1\" fill=\"rgb(#{data[index+2]},#{data[index+1]},#{data[index]})\"/>\n"
          index += 4
        }
      }
      file << '</svg>'
    }
  end

  #--------------------------------------------------------------
  # Save SVG compressed
  #--------------------------------------------------------------

  def save_svg_compressed(filename, back)
    size = width * height << 2
    data = ' ' * size
    read(0, 0, data, size)
    data = data.unpack('C*')
    open(filename,'w') {|file|
      file << "<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" width=\"#{width}\" height=\"#{height}\">\n"
      file << "<rect x=\"0\" y=\"0\" width=\"#{width}\" height=\"#{height}\" fill=\"rgb(#{back[2]},#{back[1]},#{back[0]})\"/>\n"
      index = 0
      height.times {|y|
        width.times {|x|
          file << "<rect x=\"#{x}\" y=\"#{y}\" width=\"1\" height=\"1\" fill=\"rgb(#{data[index+2]},#{data[index+1]},#{data[index]})\"/>\n" if back != data[index, 3]
          index += 4
        }
      }
      file << '</svg>'
    }
  end
end
