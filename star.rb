require 'gosu'

class Star < GameObject
  attr_accessor :x, :y

  def initialize(animation)
    super({ speed: 0 })

    @animation = animation
    self.x = rand * GameWindow::SCREEN_WIDTH
    self.y = rand * GameWindow::SCREEN_HEIGHT
  end

  def update(speed)
    delta = Gosu.milliseconds - self.updated_at
    self.updated_at = Gosu.milliseconds

    @x -= speed * (delta / 1000.0)
  end

  def draw
    img = @animation[Gosu.milliseconds / 100 % @animation.size]
    img.draw(self.x - img.width / 2.0, self.y - img.height / 2.0,
        ZLayers::STARS, 1, 1, Gosu::Color::YELLOW, :add)
  end
end
