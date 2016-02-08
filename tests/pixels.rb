require 'test/unit'
require './Image'

class Pixels < Test::Unit::TestCase

  def test_dimensions
    img = Image.new(2,3)
    assert_equal(2, img.width)
    assert_equal(3, img.height)
  end

  def test_get_set_pixels
    img = Image.new(1,1)
    assert_equal([0,0,0,0], img.get_pixel(0,0))
    assert_equal(img, img.set_pixel(0,0, 100,150,200,255))
    assert_equal([100,150,200,255], img.get_pixel(0,0))
  end

  def test_dup
    img = Image.new(1,1)
    dup = img.set_pixel(0,0, 100,150,200,255).dup
    assert_equal([100,150,200,255], img.get_pixel(0,0))
    assert_equal([100,150,200,255], dup.get_pixel(0,0))
    img.set_pixel(0,0, 1,1,1,1)
    assert_equal([1,1,1,1], img.get_pixel(0,0))
    assert_equal([100,150,200,255], dup.get_pixel(0,0))
  end
end
