# encoding: ascii-8bit
require 'zlib'

class Image

  RGB = 2
  RGBA = 6

  #-----------------------------------------------
  # Header BMP
  #-----------------------------------------------

  def self.header_bmp(width, height)
    # BMP header
    [19778, (((24 * width + 31) >> 5) * height << 2) + 54, 54,
    # DIB header
    40, width, height, 1, 24].pack('slx4l4s2x24')
  end

  #-----------------------------------------------
  # Load BMP
  #-----------------------------------------------

  def self.load_bmp(filename)
    width, height, data = IO.binread(filename).unpack('x18l2x28a*')
    image = new(width, height)
    padding = width & 3
    w3 = width << 3
    index = -3
    index_image = (width * height.pred).pred << 2
    height.times {
      width.times {image.write(index_image += 4, 0, data[index += 3,3] << 255, 4)}
      index_image -= w3
      index += padding
    }
    image
  end

  #-----------------------------------------------
  # Save BMP
  #-----------------------------------------------

  def save_bmp(filename)
    open(filename,'wb') {|file|
      file << Image.header_bmp(width, height)
      size = width * height << 2
      data = ' ' * size
      read(0, 0, data, size)
      padding = ' ' * (width & 3)
      index = size - (width.succ << 2)
      w = width << 3
      height.times {
        width.times {file << data[index += 4, 3]}
        file << padding
        index -= w
      }
    }
  end

  #-----------------------------------------------
  # Load PNG
  #-----------------------------------------------

  def self.load_png(filename)
    image = nil
    width = height = color_type = 0
    open(filename,'rb') {|file|
      # Signature
      file.pos = 8
      loop {
        size, type = file.read(8).unpack('NA4')
        case type
        when 'IHDR'
          width, height, color_type = file.read(size).unpack('N2xC')
        when 'IDAT' # Support only single IDAT chunk
          image = new(width, height)
          data = Zlib::Inflate.inflate(file.read(size)).reverse!
          index_image = -4
          index = data.size
          if color_type == RGB
            height.times {
              index -= 1
              width.times {image.write(index_image += 4, 0, data[index -= 3, 3] << 255, 4)}
            }
          else
            height.times {
              index -= 1
              width.times {image.write(index_image += 4, 0, data[index -= 3, 3] << data[index -= 1], 4)}
            }
          end
        when 'IEND'
          break
        else file.pos += size
        end
        # CRC
        file.pos += 4
      }
    }
    image
  end

  #-----------------------------------------------
  # Save PNG
  #-----------------------------------------------

  def save_png(filename, color_type = RGB)
    size = width * height << 2
    data = ' ' * size
    read(0, 0, data, size)
    data.reverse!
    img_data = ''
    index = size.succ
    if color_type == RGB
      height.times {
        img_data << 0
        width.times {img_data << data[index -= 4, 3]}
      }
    else
      height.times {
        img_data << 0
        width.times {img_data << data[index -= 4, 3] << data[index.pred]}
      }
    end
    Image.save_png_data(filename, img_data, width, height, color_type)
  end

  #-----------------------------------------------
  # Save PNG data
  #-----------------------------------------------

  def self.save_png_data(filename, data, width, height, color_type)
    IO.binwrite(filename, "\x89PNG\r\n\x1a\n" <<
      chunk('IHDR', [width, height, 8, color_type].pack('N2C2x3')) <<
      chunk('IDAT', Zlib::Deflate.deflate(data, 9)) <<
      "\0\0\0\0IEND\xAEB`\x82")
  end

  #-----------------------------------------------
  # Chunk
  #-----------------------------------------------

  def self.chunk(type, data)
    [data.size, type, data, Zlib.crc32(type << data)].pack('NA4A*N')
  end

  #-----------------------------------------------
  # Save SVG
  #-----------------------------------------------

  def save_svg(filename, r = nil, g = nil, b = nil)
    size = width * height << 2
    data = ' ' * size
    read(0, 0, data, size)
    data = data.reverse!.unpack('C*')
    open(filename,'w') {|file|
      file << "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"#{width}\" height=\"#{height}\""
      file.printf(" style=\"background:#%02x%02x%02x\"", r, g, b) if r and g and b
      file << '>'
      index = size - 3
      background = [r, g, b]
      height.times {|y|
        w = 0
        color = data[index, 3]
        width.times {|x|
          if color == data[index, 3]
            w += 1
          else
            file.printf('<path d="M%d %dh%dv1H%dz" fill="#%02x%02x%02x"/>', x - w, y, w, x - w, *color) if color != background
            w = 1
            color = data[index, 3]
          end
          index -= 4
        }
        file.printf('<path d="M%d %dh%dv1H%dz" fill="#%02x%02x%02x"/>', width - w, y, w, width - w, *color) if color != background
      }
      file << '</svg>'
    }
  end
end