require 'gosu'
require 'ostruct'

class GameObject < OpenStruct
  #attr_accessor :image, :width, :height, :x, :y, :z, :speed

  def initialize(opts = {})
    super(opts.merge(updated_at: Gosu.milliseconds))
  end

  def update
  end

  def draw
    return image.draw(x, y, z, scale_x = self.scale_x, scale_y = self.scale_y) if image

    tiles[current].draw(x, y, 0, scale_x = self.scale_x, scale_y = self.scale_y) if tiles
  end

  def adjusted_speed(delta)
    self.speed * (delta / 1000.0)
  end
end
