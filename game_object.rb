require 'gosu'
require 'ostruct'

class GameObject < OpenStruct
  #attr_accessor :image, :width, :height, :x, :y, :z, :speed

  def update
  end

  def draw
    image.draw(x, y, z, scale_x = self.scale_x, scale_y = self.scale_y)
  end
end
