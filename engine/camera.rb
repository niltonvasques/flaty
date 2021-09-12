require 'gosu'
require 'engine/math/vector_2d'
require 'engine/math/rect'

class Camera
  NOT_BOUNDED = -1
  attr_accessor :width, :height, :position, :bounds

  attr_reader :unit_x, :unit_y

  def initialize(width, height)
    self.bounds = Rect[NOT_BOUNDED, NOT_BOUNDED, NOT_BOUNDED, NOT_BOUNDED]
    size(width, height)
    look(width / 2, height / 2)
  end

  def look(x, y)
    y = self.bounds.y if self.bounds.y != NOT_BOUNDED and y > self.bounds.y
    x = self.bounds.x if self.bounds.x != NOT_BOUNDED and x < self.bounds.x
    x = self.bounds.width if self.bounds.width != NOT_BOUNDED and x > self.bounds.width
    self.position = Vector2d[x.to_f, y.to_f]
  end

  def size(width, height)
    self.width = width
    self.height = height
    @unit_x = GameWindow.width / width.to_f
    @unit_y = GameWindow.height / height.to_f
  end

  def visible?(obj)
    return false if obj.x > (self.position.x + self.width / 2.0)
    return false if obj.x + obj.width < (self.position.x - self.width / 2.0)
    true
  end

  def width_pixels
    self.width * self.unit_x
  end

  def height_pixels
    self.height * self.unit_y
  end

  def shift_x
    self.position.x - (self.width / 2)
  end

  def shift_y
    self.position.y - (self.height / 2)
  end

  def pixel_to_unit_x(w)
    w / self.unit_x.to_f
  end

  def pixel_to_unit_y(h)
    h / self.unit_y.to_f
  end

  def translate_x(x)
    (x - shift_x) * self.unit_x
  end

  def translate_y(y)
    GameWindow.height - ((y - shift_y) * self.unit_y)
  end
end
