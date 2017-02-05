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

  def generate_puma(filename = nil)
    srand(65)
    spt = Spriter.new(32, 32)
    spt.generate(87, 13)
    if filename
      File.delete(filename) if File.exist?(filename)
      assert_nothing_raised {spt.save(filename)}
      assert_equal(true, File.exist?(filename))
    end
    spt
  end

  def save_load_compare_puma(ext)
    filename = "test.#{ext}"
    spt = generate_puma(filename)
    # Compare both images
    img1 = spt.to_image
    img2 = ext == 'bmp' ? Image.load_bmp(filename) : Image.load_png(filename)
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
    File.delete(filename) if File.exist?(filename)
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
    filename = 'test.svg'
    spt = generate_puma(filename)
    # Compare both images
    data = '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32"><rect width="32" height="32" fill="#000000"/>'
    x = y = w = 0
    color = nil
    PUMA.each_byte {|b|
      if b != 10
        color = b unless color
        if color == b
          w += 1
        else
          data << "<rect x=\"#{x - w}\" y=\"#{y}\" width=\"#{w}\" height=\"1\" fill=\"#00ff00\"/>" unless color.zero?
          w = 1
          color = b
        end
        x += 1
      else
        data << "<rect x=\"#{32 - w}\" y=\"#{y}\" width=\"#{w}\" height=\"1\" fill=\"#00ff00\"/>" unless color.zero?
        x = w = 0
        y += 1
        color = nil
      end
    }
    assert_equal(data << '</svg>', IO.read(filename))
  ensure
    File.delete(filename) if File.exist?(filename)
  end
end
