require 'gosu'
require 'ostruct'
require './parallax'

class Background
  FRAME_DURATION = 1000 / 60
  FG_SPEED = 30.0 / FRAME_DURATION

  def initialize
    bg_img = Gosu::Image.new('assets/mountain/bg.png', tileable: true)
    fg_img = Gosu::Image.new('assets/mountain/foreground-trees.png', tileable: true)
    trees_img = Gosu::Image.new('assets/mountain/distant-trees.png', tileable: true)
    mountains_img = Gosu::Image.new('assets/mountain/mountains.png', tileable: true)
    big_mountain_img = Gosu::Image.new('assets/mountain/big-mountain.png', tileable: true)
    @bg_scale_x = GameWindow::SCREEN_WIDTH / bg_img.width.to_f
    @bg_scale_y = GameWindow::SCREEN_HEIGHT / bg_img.height.to_f

    @bg = GameObject.new(image: bg_img, x: 0, y: 0, z: ZLayers::BG,
                         scale_x: @bg_scale_x, scale_y: @bg_scale_y)

    @fg        = build_layer(fg_img, FG_SPEED)
    @trees     = build_layer(trees_img, FG_SPEED / 3)
    @mountains = build_layer(mountains_img, FG_SPEED / 6)
    @big_mountain = build_layer(big_mountain_img, FG_SPEED / 10)

    @reverse = false
    @reverse_at = 0
    @elapsed = 0
    @forward = true
  end

  def update(speed)
    @elapsed += FRAME_DURATION

    if Gosu.button_down? Gosu::KB_R
      @reverse = !@reverse if (@elapsed - @reverse_at) > 1000
      @reverse_at = @elapsed
    end

    #return if @reverse

    # ensure that the background will remains moving, but in a slow pace when the bird is not
    # accelerating
    speed = FG_SPEED / 6 if speed == 0

    @big_mountain.speed = speed.abs / 10
    @mountains.speed = speed.abs / 6
    @trees.speed = speed.abs / 3
    @fg.speed = speed.abs

    @reverse = speed < 0
    @big_mountain.update(@reverse)
    @mountains.update(@reverse)
    @trees.update(@reverse)
    @fg.update(@reverse)
  end

  def draw
    @bg.draw
    @big_mountain.draw
    @mountains.draw
    @trees.draw
    @fg.draw
  end

  private

  def build_layer(image, speed)
    Parallax.new(
      image: image,
      scaled_width: image.width * @bg_scale_x,
      x1: 0,
      x2: (image.width * @bg_scale_x),
      y: GameWindow::SCREEN_HEIGHT - (image.height * @bg_scale_y),
      z: ZLayers::BG,
      scale_x: @bg_scale_x,
      scale_y: @bg_scale_y,
      speed: speed
    )
  end
end
