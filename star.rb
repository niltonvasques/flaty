require 'gosu'

class Star < GameObject
  def initialize(animation, opts = {})
    super(opts.merge({ speed: 0 }))

    @animation = animation
    self.current = 0
  end

  def update(speed)
    self.x -= speed * GameWindow.delta
    self.current = Gosu.milliseconds / 100 % @animation.size
  end

  def draw
    img = @animation[self.current]
    img.draw(self.x, self.y, ZLayers::STARS, 1, 1, Gosu::Color::YELLOW, :add)
  end
end
