require 'gosu'
require 'ostruct'

class Bird
  FRAME_DURATION = 1000 / 60
  FG_SPEED = 30.0 / FRAME_DURATION
  SCALE = 3

  def initialize
    @birds = Gosu::Image.load_tiles('assets/seagull_tiles.png', 32, 40)

    @bird = @birds[0]
    @current = 0

    @elapsed = 0
  end

  def update
    @elapsed += FRAME_DURATION

    @current = (@elapsed / 200) % 4
    puts @current
  end

  def draw
    x = 0
    y = GameWindow::SCREEN_HEIGHT / 2
    @birds[@current].draw(0, y, 0, scale_x = SCALE, scale_y = SCALE)
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
