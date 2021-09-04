require 'gosu'
require './game_object'

class Parallax < GameObject
  #attr_accessor :image, :width, :height, :x1, :x2, :y, :z, :speed

  def update(backward)
    if !backward
      if self.x1 + self.scaled_width > 0 and (self.x2 > self.x1 or self.x2 + self.scaled_width < 0)
        self.x1 -= self.speed
        self.x2 = self.x1 + self.scaled_width
      else
        self.x2 -= self.speed
        self.x1 = self.x2 + self.scaled_width
      end
      return
    end

    if self.x1 < GameWindow::SCREEN_WIDTH and (self.x2 < self.x1 or self.x2 > GameWindow::SCREEN_WIDTH)
      self.x1 += self.speed
      self.x2 = self.x1 - self.scaled_width
    else
      self.x2 += self.speed
      self.x1 = self.x2 - self.scaled_width
    end
  end

  def draw
    image.draw(x1, y, z, scale_x = self.scale_x, scale_y = self.scale_y)
    image.draw(x2, y, z, scale_x = self.scale_x, scale_y = self.scale_y)
  end
end