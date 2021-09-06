require 'gosu'

class Star < GameObject
  def initialize(animation, opts = {})
    super(opts.merge({ tiles: animation }))
  end

  def update(speed)
    self.x -= speed * GameWindow.delta
    self.current = Gosu.milliseconds / 100 % self.tiles.size
  end

  def draw
    return if outside_window?

    self.tiles[self.current].draw(self.x, self.y, ZLayers::STARS, 1, 1, Gosu::Color::YELLOW, :add)
  end
end
