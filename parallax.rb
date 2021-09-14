require 'gosu'
require 'engine/flaty'

class Parallax < GameObject
  #attr_accessor :image, :width, :height, :x1, :x2, :y, :z, :speed

  # connecting two images one after the other in the horizontal path
  # with this strategy, when the ending of one image appears, the next one is already on the screen
  def update(backward)
    local_speed = self.speed * GameWindow.delta

    if !backward
      if self.x1 + self.scaled_width > 0 and (self.x2 > self.x1 or self.x2 + self.scaled_width < 0)
        self.x1 -= local_speed
        self.x2 = self.x1 + self.scaled_width
      else
        self.x2 -= local_speed
        self.x1 = self.x2 + self.scaled_width
      end
      return
    end

    if self.x1 < GameWindow.width and (self.x2 < self.x1 or self.x2 > GameWindow.width)
      self.x1 += local_speed
      self.x2 = self.x1 - self.scaled_width
    else
      self.x2 += local_speed
      self.x1 = self.x2 - self.scaled_width
    end
  end

  def draw
    image.draw(x1, y, z, scale_x = self.scale_x, scale_y = self.scale_y)
    image.draw(x2, y, z, scale_x = self.scale_x, scale_y = self.scale_y)
  end
end
