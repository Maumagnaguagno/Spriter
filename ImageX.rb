require 'zlib'

class Image

  BMP_HEADER = 'sls2l4s2l6'
  RGB = 2
  RGBA = 6

  #-----------------------------------------------
  # Header BMP
  #-----------------------------------------------

  def self.header_bmp(width, height)
    # BMP header
    [19778, (((24 * width + 31) >> 5) * height << 2) + 54, 0, 0, 54,
    # DIB header
    40, width, height, 1, 24, 0, 0, 0, 0, 0, 0].pack(BMP_HEADER)
  end

  #-----------------------------------------------
  # Load BMP
  #-----------------------------------------------

  def self.load_bmp2(filename)
    image = nil
    open(filename,'rb') {|file|
      header_unpack = file.read(54).unpack(BMP_HEADER)
      width = header_unpack[6]
      height = header_unpack[7]
      image = new(width, height)
      padding = width & 3
      w3 = width << 3
      index_image = width.pred * height << 2
      heigt.times {
        width.times {
          image.write(index_image, 0, file.read(3) << 255, 4)
          index_image += 4
        }
        index_image -= w3
        file.pos += padding
      }
    }
    image
  end

  #-----------------------------------------------
  # Save BMP
  #-----------------------------------------------

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

  #-----------------------------------------------
  # Load PNG
  #-----------------------------------------------

  def self.load_png(filename)
    image = nil
    width = height = color_type = 0
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
          width = data.first
          height = data[1]
          color_type = data[3]
          image = new(width, height)
        when 'IDAT'
          data = Zlib::Inflate.inflate(data)
          index = index_image = 0
          if color_type == RGB
            height.times {
              index += 1
              width.times {
                image.write(index_image, 0, data[index,3].reverse! << 255, 4)
                index += 3
                index_image += 4
              }
            }
          else
            height.times {
              index += 1
              width.times {
                image.write(index_image, 0, data[index,3].reverse! << data[index+3], 4)
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

  #-----------------------------------------------
  # Save PNG
  #-----------------------------------------------

  def save_png(filename, color_type = RGBA)
    size = width * height << 2
    data = ' ' * size
    read(0, 0, data, size)
    img_data = ''
    if color_type == RGBA
      index = 0
      height.times {
        img_data << 0
        width.times {
          img_data << data[index, 3].reverse! << data[index+3]
          index += 4
        }
      }
    else
      index = -4
      height.times {
        img_data << 0
        width.times {img_data << data[index += 4, 3].reverse!}
      }
    end
    Image.save_png_data(filename, img_data, width, height, color_type)
  end

  #-----------------------------------------------
  # Save PNG data
  #-----------------------------------------------

  def self.save_png_data(filename, data, width, height, color_type)
    open(filename,'wb') {|file|
      file << "\x89PNG\r\n\x1a\n" <<
              chunk('IHDR', [width, height, 8, color_type, 0, 0, 0].pack('N2C5')) <<
              chunk('IDAT', Zlib::Deflate.deflate(data, 9)) <<
              "\0\0\0\0IEND\xAEB`\x82"
    }
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

  #-----------------------------------------------
  # Save SVG compressed
  #-----------------------------------------------

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
        w = 0
        color = data[index, 3]
        width.times {|x|
          if color == data[index, 3]
            w += 1
          else
            file << "<rect x=\"#{x - w}\" y=\"#{y}\" width=\"#{w}\" height=\"1\" fill=\"rgb(#{color[2]},#{color[1]},#{color[0]})\"/>\n" if color != back
            w = 1
            color = data[index, 3]
          end
          index += 4
        }
        file << "<rect x=\"#{width - w}\" y=\"#{y}\" width=\"#{w}\" height=\"1\" fill=\"rgb(#{color[2]},#{color[1]},#{color[0]})\"/>\n" if color != back
      }
      file << '</svg>'
    }
  end
end
