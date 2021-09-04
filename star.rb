require 'gosu'

class Star
  attr_accessor :x, :y

  def initialize(animation)
    @animation = animation
    @color = Gosu::Color::BLACK.dup
    @color.red = rand(256 - 40) + 40
    @color.green = rand(256 - 40) + 40
    @color.blue = rand(256 - 40) + 40
    @x = rand * GameWindow::SCREEN_WIDTH
    @y = rand * GameWindow::SCREEN_HEIGHT
  end

  def update(speed)
    @x -= speed
  end

  def draw
    img = @animation[Gosu.milliseconds / 100 % @animation.size]
    img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
        ZLayers::STARS, 1, 1, Gosu::Color::YELLOW, :add)
  end
end
