require 'gosu'

class Background
  def initialize
    @background_image = Gosu::Image.new('assets/mountain/bg.png', tileable: true)
    @foreground_image = Gosu::Image.new('assets/mountain/foreground-trees.png', tileable: true)
    @bg_scale_x = GameWindow::SCREEN_WIDTH / @background_image.width.to_f
    @bg_scale_y = GameWindow::SCREEN_HEIGHT / @background_image.height.to_f
  end

  def update
  end

  def draw
    x = 0
    y = 0
    z = 0

    @background_image.draw(x, y, z, scale_x = @bg_scale_x, scale_y = @bg_scale_y)

    y = GameWindow::SCREEN_HEIGHT - (@foreground_image.height * 4.5)
    @foreground_image.draw(x, y, z, scale_x = 4.5, scale_y = 4.5)
  end
end
