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

    new_x = World.camera.translate_x(self.x)
    new_y = World.camera.translate_y(self.y)

    self.tiles[self.current].draw(new_x, new_y, ZLayers::STARS, 1, 1, Gosu::Color::YELLOW, :add)
  end
end
