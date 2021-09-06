require 'gosu'

class Star < GameObject
  def initialize(animation, opts = {})
    super(opts.merge({ speed: 0 }))

    @animation = animation
    self.current = 0
  end

  def update(speed)
    delta_seconds = (Gosu.milliseconds - self.updated_at) / 1000.0
    self.updated_at = Gosu.milliseconds

    x_shift = ((speed * delta_seconds) / Tile::SIZE.to_f) * (Tile::WIDTH)
    self.x -= x_shift
    self.current = Gosu.milliseconds / 100 % @animation.size
  end

  def print
    puts "self.x = #{self.x}"
  end

  def draw
    img = @animation[self.current]
    img.draw(self.x, self.y, ZLayers::STARS, 1, 1, Gosu::Color::YELLOW, :add)
  end
end
