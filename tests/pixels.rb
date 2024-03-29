require 'test/unit'
require './Image'

class Pixels < Test::Unit::TestCase

  def test_dimensions
    img = Image.new(2,3)
    assert_equal(2, img.width)
    assert_equal(3, img.height)
  end

  def test_copy
    img = Image.new(1,1)
    dup = img.set_pixel(0,0, 100,150,200,255).dup
    assert_equal([100,150,200,255], img.get_pixel(0,0))
    assert_equal([100,150,200,255], dup.get_pixel(0,0))
    assert_true(img.match_pixel?(0,0, 100,150,200,255))
    assert_true(dup.match_pixel?(0,0, 100,150,200,255))
    img.set_pixel(0,0, 1,1,1,1)
    assert_equal([1,1,1,1], img.get_pixel(0,0))
    assert_equal([100,150,200,255], dup.get_pixel(0,0))
    assert_true(img.match_pixel?(0,0, 1,1,1,1))
    assert_true(dup.match_pixel?(0,0, 100,150,200,255))
  end

  def test_get_set_match_pixels
    img = Image.new(1,1)
    assert_equal([0,0,0,0], img.get_pixel(0,0))
    assert_true(img.match_pixel?(0,0, 0,0,0,0))
    assert_same(img, img.set_pixel(0,0, 100,150,200,255))
    assert_equal([100,150,200,255], img.get_pixel(0,0))
    assert_true(img.match_pixel?(0,0, 100,150,200,255))
  end

  def test_read_write
    img = Image.new(1,1)
    data_r = '    '
    assert_same(img, img.read(0, 0, data_r, 4))
    assert_equal("\0\0\0\0", data_r)
    data_w = "\100\150\200\255"
    assert_same(img, img.write(0, 0, data_w, 4))
    assert_same(img, img.read(0, 0, data_r, 4))
    assert_equal(data_w, data_r)
    assert_not_same(data_w, data_r)
    assert_same(img, img.write(3, 0, "\10", 1))
    assert_same(img, img.read(0, 0, data_r, 4))
    assert_equal("\100\150\200\10", data_r)
    assert_same(img, img.read(3, 1, data_r, 1))
    assert_equal("\100\10\200\10", data_r)
  end

  def test_multibyte_chars
    img = Image.new(2,2)
    img.set_pixel(0,0, 0, 0x97, 0xC3, 0)
    img.set_pixel(1,0, 1, 2, 3, 255)
    data_r = "\0\0\0\0\0\0\0\0"
    img.read(0,0, data_r, 8)
    assert_equal(8, data_r.size)
    assert_equal(8, data_r.bytesize)
    data_w = "\xC3\x97\0\0\3\2\1\xFF".b
    data_r2 = "\0\0\0\0\0\0\0\0"
    img.write(0,0, data_w, 8)
    img.read(0,0, data_r2, 8)
    assert_equal(data_r, data_r2)
  end
end