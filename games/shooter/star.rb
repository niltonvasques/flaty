require 'gosu'

class Star < GameObject
  def initialize(animation, opts = {})
    @scale = GameWindow.camera.scale(animation[0].width, 1)
    super(opts.merge({ tiles: animation, scale_x: @scale, scale_y: @scale }))
  end

  def update
    self.current = Gosu.milliseconds / 100 % self.tiles.size
  end

  def draw_obj(x, y, z)
    current_image.draw(x, y, ZLayers::STARS, @scale, @scale, Gosu::Color::YELLOW, :add)
  end
end
