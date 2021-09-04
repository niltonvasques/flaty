require 'gosu'
require 'ostruct'

class Bird
  FRAME_DURATION = 1000 / 60
  FG_SPEED = 30.0 / FRAME_DURATION
  SCALE = 3

  def initialize
    @birds = Gosu::Image.load_tiles('assets/seagull_tiles.png', 32, 40)

    @bird = @birds[0]

    @scaled_width = @bird.width * SCALE
    @scaled_height = @bird.width * SCALE

    @move_x = 0
    @move_y = GameWindow::SCREEN_HEIGHT / 2
    @current = 0

    @elapsed = 0
  end

  def update
    @elapsed += FRAME_DURATION

    @current = (@elapsed / 200) % 4

    @move_x -= 5 if Gosu.button_down? Gosu::KB_LEFT
    @move_x += 5 if Gosu.button_down? Gosu::KB_RIGHT
    @move_y -= 5 if Gosu.button_down? Gosu::KB_UP
    @move_y += 5 if Gosu.button_down? Gosu::KB_DOWN
    @move_x = 0 if @move_x < 0
    @move_x = GameWindow::SCREEN_WIDTH - @scaled_width if @move_x + @scaled_width > GameWindow::SCREEN_WIDTH
    @move_y = 0 if @move_y < 0
    @move_y = GameWindow::SCREEN_HEIGHT - @scaled_height if @move_y + @scaled_height > GameWindow::SCREEN_HEIGHT
  end

  def draw
    @birds[@current].draw(@move_x, @move_y, 0, scale_x = SCALE, scale_y = SCALE)
  end

  private

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
