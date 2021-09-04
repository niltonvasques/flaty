require 'gosu'

class Background
  FRAME_DURATION = 1000 / 60
  FG_SPEED = 300.0 / FRAME_DURATION

  def initialize
    @background_image = Gosu::Image.new('assets/mountain/bg.png', tileable: true)
    @foreground_image = Gosu::Image.new('assets/mountain/foreground-trees.png', tileable: true)
    @bg_scale_x = GameWindow::SCREEN_WIDTH / @background_image.width.to_f
    @bg_scale_y = GameWindow::SCREEN_HEIGHT / @background_image.height.to_f

    @fg_scaled_width = (@foreground_image.width * 4.5)

    @fg_y = GameWindow::SCREEN_HEIGHT - (@foreground_image.height * 4.5)
    @fg_x1 = 0
    @fg_x2 = @fg_x1 + (@foreground_image.width * 4.5)

    @paused = false
    @paused_at = 0
    @elapsed = 0
  end

  def update
    @elapsed += FRAME_DURATION

    if Gosu.button_down? Gosu::KB_LEFT
      @paused = !@paused if (@elapsed - @paused_at) > 1000
      @paused_at = @elapsed
    end

    return if @paused

    if @fg_x1 + @fg_scaled_width > 0 and (@fg_x2 > @fg_x1 or @fg_x2 + @fg_scaled_width < 0)
      @fg_x1 -= FG_SPEED
      @fg_x2 = @fg_x1 + @fg_scaled_width
      puts "1: (#{@elapsed / 1000}) #{@fg_x1}...#{@fg_x2}"
    else
      @fg_x2 -= FG_SPEED
      @fg_x1 = @fg_x2 + @fg_scaled_width
      puts "2: (#{@elapsed / 1000}) #{@fg_x1}...#{@fg_x2}"
    end
  end

  def draw
    @background_image.draw(0, 0, 0, scale_x = @bg_scale_x, scale_y = @bg_scale_y)

    @foreground_image.draw(@fg_x1, @fg_y, 0, scale_x = 4.5, scale_y = 4.5)

    @foreground_image.draw(@fg_x2, @fg_y, 0, scale_x = 4.5, scale_y = 4.5)
  end
end
