require 'test/unit'
require './Spriter'

class Puma < Test::Unit::TestCase

  PUMA = "\0\0\0\0\0\0\0\0\0\1\0\1\1\0\0\0\0\0\0\1\1\0\1\0\0\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0
\0\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\0
\0\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\0
\0\0\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\0\0
\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\0\1\1\0\0\1\0\0\0\0\0\0\1\0\0\1\1\0\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\0\1\1\0\1\1\0\1\0\0\1\0\1\1\0\1\1\0\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\0\0\0\0\1\1\1\0\0\0\0\1\1\1\0\0\0\0\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\0\1\0\0\0\0\0\0\1\1\0\0\0\0\0\0\1\0\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\0\1\1\1\0\0\0\1\1\1\1\0\0\0\1\1\1\0\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\1\0\0\1\0\0\1\0\1\1\0\1\0\0\1\0\0\1\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\1\1\0\0\0\1\1\0\1\1\0\1\1\0\0\0\1\1\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\0\0\1\1\0\1\0\0\1\0\1\1\0\0\0\0\0\1\0\0\0\0\0
\0\0\0\0\0\0\1\0\0\0\0\1\0\0\0\1\1\0\0\0\1\0\0\0\0\1\0\0\0\0\0\0
\0\0\0\0\0\0\0\1\0\0\0\1\1\1\0\0\0\0\1\1\1\0\0\0\1\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\0\0\0\1\0\0\1\1\0\0\1\1\0\0\1\0\0\0\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\0\0\0\0\1\0\1\1\1\1\1\1\0\1\0\0\0\0\0\0\0\0\0\0\0
\0\0\0\0\0\0\1\0\0\0\1\0\0\1\1\0\0\1\1\0\0\1\0\0\0\1\0\0\0\0\0\0
\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\1\1\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0
\0\0\0\0\1\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\1\0\0\0\0
\0\0\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\0\0
\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0
\0\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0
"

  def generate_puma(filename_ext = nil, ext = nil)
    srand(65)
    spt = Spriter.new(32, 32)
    spt.generate(87, 13)
    if filename_ext
      File.delete(filename_ext) if File.exist?(filename_ext)
      assert_nothing_raised {spt.save('test', ext)}
      assert_equal(true, File.exist?(filename_ext))
    end
    spt
  end

  def save_load_compare_puma(ext)
    filename_ext = "test.#{ext}"
    spt = generate_puma(filename_ext, ext)
    # Compare both images
    img1 = spt.to_image
    img2 = ext == 'bmp' ? Image.load_bmp(filename_ext) : Image.load_png(filename_ext)
    assert_equal(32, img1.width)
    assert_equal(32, img1.height)
    assert_equal(32, img2.width)
    assert_equal(32, img2.height)
    data1 = ' ' * 4096
    data2 = ' ' * 4096
    img1.read(0, 0, data1, 4096)
    img2.read(0, 0, data2, 4096)
    assert_equal(data1, data2)
    # Compare with PUMA
    puma_data = ''
    front = [0,255,0,255].pack('C4')
    back = [0,0,0,255].pack('C4')
    PUMA.each_byte {|b| puma_data << (b.zero? ? back : front) if b != 10}
    assert_equal(data1, puma_data)
  ensure
    File.delete(filename_ext)
  end

  def test_to_s
    assert_equal(PUMA, generate_puma.to_s)
  end

  def test_bmp
    save_load_compare_puma('bmp')
  end

  def test_png
    save_load_compare_puma('png')
  end

  def test_svg
    filename_ext = 'test.svg'
    spt = generate_puma(filename_ext, 'svg')
    # Compare both images
    data = '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="32" height="32">'
    x = y = 0
    PUMA.each_byte {|b|
      if b != 10
        data << "\n<rect x=\"#{x}\" y=\"#{y}\" width=\"1\" height=\"1\" fill=\"rgb(0,#{b.zero? ? 0 : 255},0)\"/>"
        x += 1
      else
        x = 0
        y += 1
      end
    }
    assert_equal(data << "\n</svg>", IO.read(filename_ext))
  ensure
    File.delete(filename_ext)
  end

  def test_svg_compressed
    filename_ext = 'test.svg'
    spt = generate_puma(filename_ext, 'svgc')
    # Compare both images
    data = "<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" width=\"32\" height=\"32\">\n<rect x=\"0\" y=\"0\" width=\"32\" height=\"32\" fill=\"rgb(0,0,0)\"/>"
    x = y = w = 0
    color = nil
    PUMA.each_byte {|b|
      if b != 10
        color = b unless color
        if color == b
          w += 1
        else
          data << "\n<rect x=\"#{x - w}\" y=\"#{y}\" width=\"#{w}\" height=\"1\" fill=\"rgb(0,255,0)\"/>" unless color.zero?
          w = 1
          color = b
        end
        x += 1
      else
        data << "\n<rect x=\"#{32 - w}\" y=\"#{y}\" width=\"#{w}\" height=\"1\" fill=\"rgb(0,255,0)\"/>" unless color.zero?
        x = w = 0
        y += 1
        color = nil
      end
    }
    assert_equal(data << "\n</svg>", IO.read(filename_ext))
  ensure
    File.delete(filename_ext)
  end
end
