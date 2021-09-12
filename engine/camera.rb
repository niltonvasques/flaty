require 'gosu'
require 'engine/math/vector_2d'
require 'engine/math/rect'

class Camera
  NOT_BOUNDED = -1
  attr_accessor :width, :height, :position, :bounds

  def initialize(width, height)
    self.width = width
    self.height = height
    self.bounds = Rect[(width / 2), (height / 2), NOT_BOUNDED, NOT_BOUNDED]
    look(width / 2, height / 2)
  end

  def look(x, y)
    y = self.bounds.y if self.bounds.y != NOT_BOUNDED and y > self.bounds.y
    x = self.bounds.x if self.bounds.x != NOT_BOUNDED and x < self.bounds.x
    x = self.bounds.width if self.bounds.width != NOT_BOUNDED and x > self.bounds.width
    self.position = Vector2d[x.to_f, y.to_f]
  end

  def visible?(obj)
    return false if obj.x > (self.position.x + self.width / 2.0)
    return false if obj.x + obj.width < (self.position.x - self.width / 2.0)
    true
  end

  def width_pixels
    self.width * World::UNIT_X
  end

  def height_pixels
    self.height * World::UNIT_Y
  end

  def shift_x
    self.position.x - (self.width / 2)
  end

  def shift_y
    self.position.y - (self.height / 2)
  end

  def pixel_to_unit_x(w)
    w / World::UNIT_X.to_f
  end

  def pixel_to_unit_y(h)
    h / World::UNIT_Y.to_f
  end

  def translate_x(x)
    (x - shift_x) * World::UNIT_X
  end

  def translate_y(y)
    (y - shift_y) * World::UNIT_X
  end
end
