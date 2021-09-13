unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
end

require 'pry-byebug'
require 'method_source'
require 'gosu'
require 'engine/game_window'
require 'engine/camera_debug'
require 'engine/benchmark'
require 'engine/benchmark'
require 'math/poly'

class SnakeGame < GameWindow
  SCREEN_WIDTH   = 1500
  SCREEN_HEIGHT  = 1500
  CAMERA_WIDTH_UNITS  = 10
  CAMERA_HEIGHT_UNITS = 10

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, fullscreen: false)
    self.caption = 'Math Axis'

    @camera = GameWindow.camera
    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @camera.look(0, 0)
    axis_colors = { lines: Gosu::Color::BLACK, text: Gosu::Color::BLACK }
    @camera_debug = CameraDebug.new(@camera, axis_colors)

    @snake = [Vector2d[0,0]]
    @snake << Vector2d[1,0]
    @snake << Vector2d[2,0]

    @food = Vector2d[3, 3]

    # assets
    @font = Gosu::Font.new(25)

    @updated_at = 0
  end

  def update
    super
    return if paused?

    direction = Vector2d[0, 0]
    direction = Vector2d[0, 1]  if Gosu.button_down? Gosu::KB_UP
    direction = Vector2d[0, -1] if Gosu.button_down? Gosu::KB_DOWN
    direction = Vector2d[-1, 0] if Gosu.button_down? Gosu::KB_LEFT
    direction = Vector2d[1, 0]  if Gosu.button_down? Gosu::KB_RIGHT
    return if direction == Vector2d[0, 0]

    seconds = (Gosu.milliseconds / 250).to_i

    previous = @snake[0].dup
    if seconds - @updated_at > 0
      @updated_at = seconds
      i = 1
      @snake[0] += direction
      while i < @snake.size
        aux = @snake[i]
        @snake[i] = previous
        previous = aux

        i += 1
      end
    end

    if @snake[0] == @food
      @snake << previous
      @food = Vector2d[(rand * 10 - 5).to_i, (rand * 10 - 5).to_i]
    end
  end

  def draw
    @camera_debug.draw

    Gosu.draw_rect(0, 0, GameWindow.width, GameWindow.height, Gosu::Color::GRAY, 0)

    x = @camera.translate_x(@food.x)
    y = @camera.translate_y(@food.y) - @camera.unit_y
    Gosu.draw_rect(x, y, @camera.unit_x, @camera.unit_y, Gosu::Color::YELLOW, 0)

    @snake.each_with_index do |v, index|
      x = @camera.translate_x(v.x)
      y = @camera.translate_y(v.y) - @camera.unit_y
      color = index == 0 ? Gosu::Color::RED : Gosu::Color::BLACK
      Gosu.draw_rect(x, y, @camera.unit_x, @camera.unit_y, color, 0)
    end
  end
end

game = SnakeGame.new
game.show
