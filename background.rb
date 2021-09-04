require 'gosu'
require 'ostruct'

class Background
  FRAME_DURATION = 1000 / 60
  FG_SPEED = 30.0 / FRAME_DURATION

  def initialize
    @background_image = Gosu::Image.new('assets/mountain/bg.png', tileable: true)
    fg_img = Gosu::Image.new('assets/mountain/foreground-trees.png', tileable: true)
    trees_img = Gosu::Image.new('assets/mountain/distant-trees.png', tileable: true)
    mountains_img = Gosu::Image.new('assets/mountain/mountains.png', tileable: true)
    big_mountain_img = Gosu::Image.new('assets/mountain/big-mountain.png', tileable: true)
    @bg_scale_x = GameWindow::SCREEN_WIDTH / @background_image.width.to_f
    @bg_scale_y = GameWindow::SCREEN_HEIGHT / @background_image.height.to_f

    @fg        = build_layer(fg_img, FG_SPEED)
    @trees     = build_layer(trees_img, FG_SPEED / 3)
    @mountains = build_layer(mountains_img, FG_SPEED / 6)
    @big_mountain = build_layer(big_mountain_img, FG_SPEED / 10)

    @reverse = false
    @reverse_at = 0
    @elapsed = 0
    @forward = true
  end

  def update
    @elapsed += FRAME_DURATION

    if Gosu.button_down? Gosu::KB_R
      @reverse = !@reverse if (@elapsed - @reverse_at) > 1000
      @reverse_at = @elapsed
    end

    #return if @reverse

    parallax(@big_mountain)
    parallax(@mountains)
    parallax(@trees)
    parallax(@fg)
  end

  def draw
    @background_image.draw(0, 0, 0, scale_x = @bg_scale_x, scale_y = @bg_scale_y)

    @big_mountain.image.draw(@big_mountain.x1, @big_mountain.y, 0, scale_x = @bg_scale_x, scale_y = @bg_scale_y)
    @big_mountain.image.draw(@big_mountain.x2, @big_mountain.y, 0, scale_x = @bg_scale_x, scale_y = @bg_scale_y)

    @mountains.image.draw(@mountains.x1, @mountains.y, 0, scale_x = @bg_scale_x, scale_y = @bg_scale_y)
    @mountains.image.draw(@mountains.x2, @mountains.y, 0, scale_x = @bg_scale_x, scale_y = @bg_scale_y)

    @trees.image.draw(@trees.x1, @trees.y, 0, scale_x = @bg_scale_x, scale_y = @bg_scale_y)
    @trees.image.draw(@trees.x2, @trees.y, 0, scale_x = @bg_scale_x, scale_y = @bg_scale_y)

    @fg.image.draw(@fg.x1, @fg.y, 0, scale_x = @bg_scale_x, scale_y = @bg_scale_y)
    @fg.image.draw(@fg.x2, @fg.y, 0, scale_x = @bg_scale_x, scale_y = @bg_scale_y)
  end

  private

  def parallax(obj)
    if !@reverse
      if obj.x1 + obj.scaled_width > 0 and (obj.x2 > obj.x1 or obj.x2 + obj.scaled_width < 0)
        obj.x1 -= obj.speed
        obj.x2 = obj.x1 + obj.scaled_width
      else
        obj.x2 -= obj.speed
        obj.x1 = obj.x2 + obj.scaled_width
      end
    else
      if obj.x1 < GameWindow::SCREEN_WIDTH and (obj.x2 < obj.x1 or obj.x2 > GameWindow::SCREEN_WIDTH)
        obj.x1 += obj.speed
        obj.x2 = obj.x1 - obj.scaled_width
      else
        obj.x2 += obj.speed
        obj.x1 = obj.x2 - obj.scaled_width
      end
    end
  end

  def build_layer(image, speed)
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
