require 'gosu'
require 'ostruct'

class GameObject < OpenStruct
  #attr_accessor :image, :width, :height, :x, :y, :z, :speed

  def initialize(opts = {})
    super({ speed: 0, scale_x: 1, scale_y: 1, current: 0 }.merge(opts))
  end

  def update
  end

  def draw
    return if outside_window?

    current_image.draw(x, y, z, scale_x = self.scale_x, scale_y = self.scale_y)
  end

  def outside_window?
    self.x > GameWindow::SCREEN_WIDTH or (self.x + current_image.width * self.scale_x) < 0
  end

  def current_image
    return image if image
    tiles[current]
  end
end
