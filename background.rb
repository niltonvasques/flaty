require 'gosu'
require 'ostruct'

class Background
  FRAME_DURATION = 1000 / 60
  FG_SPEED = 100.0 / FRAME_DURATION

  def initialize
    @background_image = Gosu::Image.new('assets/mountain/bg.png', tileable: true)
    fg_img = Gosu::Image.new('assets/mountain/foreground-trees.png', tileable: true)
    trees_img = Gosu::Image.new('assets/mountain/distant-trees.png', tileable: true)
    mountains_img = Gosu::Image.new('assets/mountain/mountains.png', tileable: true)
    @bg_scale_x = GameWindow::SCREEN_WIDTH / @background_image.width.to_f
    @bg_scale_y = GameWindow::SCREEN_HEIGHT / @background_image.height.to_f

    @fg        = image_position(fg_img, FG_SPEED)
    @trees     = image_position(trees_img, FG_SPEED / 3)
    @mountains = image_position(mountains_img, FG_SPEED / 6)

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

    @mountains.x1, @mountains.x2 = parallax(@mountains.x1, @mountains.x2, @mountains.scaled_width, @mountains.speed)
    @trees.x1, @trees.x2 = parallax(@trees.x1, @trees.x2, @trees.scaled_width, @trees.speed)
    @fg.x1, @fg.x2       = parallax(@fg.x1, @fg.x2, @fg.scaled_width, @fg.speed)
  end

  def draw
    @background_image.draw(0, 0, 0, scale_x = @bg_scale_x, scale_y = @bg_scale_y)

    @mountains.image.draw(@mountains.x1, @mountains.y, 0, scale_x = @bg_scale_x, scale_y = @bg_scale_y)
    @mountains.image.draw(@mountains.x2, @mountains.y, 0, scale_x = @bg_scale_x, scale_y = @bg_scale_y)

    @trees.image.draw(@trees.x1, @trees.y, 0, scale_x = @bg_scale_x, scale_y = @bg_scale_y)
    @trees.image.draw(@trees.x2, @trees.y, 0, scale_x = @bg_scale_x, scale_y = @bg_scale_y)

    @fg.image.draw(@fg.x1, @fg.y, 0, scale_x = @bg_scale_x, scale_y = @bg_scale_y)
    @fg.image.draw(@fg.x2, @fg.y, 0, scale_x = @bg_scale_x, scale_y = @bg_scale_y)
  end

  private

  def parallax(x1, x2, width, speed)
    if x1 + width > 0 and (x2 > x1 or x2 + width < 0)
      x1 -= speed
      x2 = x1 + width
      #puts "1: (#{@elapsed / 1000}) #{x1}...#{x2}"
    else
      x2 -= speed
      x1 = x2 + width
      #puts "2: (#{@elapsed / 1000}) #{x1}...#{x2}"
    end
    [x1, x2]
  end

  def image_position(image, speed)
    OpenStruct.new(
      image: image,
      scaled_width: image.width * @bg_scale_x,
      x1: 0,
      x2: (image.width * @bg_scale_x),
      y: GameWindow::SCREEN_HEIGHT - (image.height * @bg_scale_y),
      speed: speed
    )
  end
end
