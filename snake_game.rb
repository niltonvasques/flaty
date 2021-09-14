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
    self.caption = 'Snake Game'

    @camera = GameWindow.camera
    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @camera.look(0, 0)
    axis_colors = { lines: Gosu::Color::BLACK, text: Gosu::Color::BLACK }
    @camera_debug = CameraDebug.new(@camera, axis_colors)

    # assets
    @font = Gosu::Font.new(25)
    @eat = Gosu::Sample.new('assets/sounds/snake_eat.wav')

    reset_snake
    @updated_at = 0
  end

  def reset_snake
    @snake = [Vector2d[0,0]]
    @snake << Vector2d[1,0]
    @snake << Vector2d[2,0]
    @food = Vector2d[3, 3]
    @loose = false
    @direction = Vector2d[-1, 0]
  end

  def update
    super
    return if paused?
    reset_snake if Gosu.button_down? Gosu::KB_R
    return if @loose

    @direction = Vector2d[0, 1]  if Gosu.button_down? Gosu::KB_UP and @direction.y == 0
    @direction = Vector2d[0, -1] if Gosu.button_down? Gosu::KB_DOWN and @direction.y == 0
    @direction = Vector2d[-1, 0] if Gosu.button_down? Gosu::KB_LEFT and @direction.x == 0
    @direction = Vector2d[1, 0]  if Gosu.button_down? Gosu::KB_RIGHT and @direction.x == 0

    seconds = (Gosu.milliseconds / 250).to_i

    previous = @snake[0].dup
    if seconds - @updated_at > 0
      @updated_at = seconds
      i = 1
      @snake[0] += @direction
      while i < @snake.size
        aux = @snake[i]
        @snake[i] = previous
        previous = aux

        i += 1
      end
    end

    # tail
    @snake.each_with_index do |v, index|
      next if index == 0
      dead if v == @snake[0]
    end

    # walls
    dead if @snake[0].x < @camera.shift_x or @snake[0].y < @camera.shift_y
    dead if @snake[0].x >= (@camera.shift_x + @camera.width)
    dead if @snake[0].y >= (@camera.shift_y + @camera.height)

    if @snake[0] == @food
      @eat.play
      @snake << previous
      x = (rand * @camera.width + @camera.shift_x).to_i
      y = (rand * @camera.height + @camera.shift_y).to_i
      @food = Vector2d[x, y]
    end
  end

  def draw
    @camera_debug.draw

    Gosu.draw_rect(0, 0, GameWindow.width, GameWindow.height, Gosu::Color::GRAY, 0)

    x = @camera.translate_x(@food.x)
    y = @camera.translate_y(@food.y) - @camera.unit_y
    seconds = (Gosu.milliseconds / 100).to_i % 2
    color = seconds == 0 ? Gosu::Color::BLUE : Gosu::Color::GREEN
    Gosu.draw_rect(x, y, @camera.unit_x, @camera.unit_y, color, 0)

    @snake.each_with_index do |v, index|
      x = @camera.translate_x(v.x)
      y = @camera.translate_y(v.y) - @camera.unit_y
      color = index == 0 ? Gosu::Color::RED : Gosu::Color::BLACK
      Gosu.draw_rect(x, y, @camera.unit_x, @camera.unit_y, color, 0)
    end

    @font.draw_text("Score: #{@snake.size}", GameWindow.width - 200, 10, 10, 2.0, 2.0,
                    Gosu::Color::GREEN)
    if @loose
      x = GameWindow.width / 2 - @camera.unit_x
      @font.draw_text("GAME OVER", x, 10, 10, 2.0, 2.0, Gosu::Color::RED)
    end
  end

  private

  def dead
    @loose = true
  end
end

game = SnakeGame.new
game.show
