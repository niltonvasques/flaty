#unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__) + '/..'))
#  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/..'))
#end

require "flaty/flaty"

class SnakeGame < GameWindow
  SCREEN_WIDTH        = 1500
  SCREEN_HEIGHT       = 1500
  CAMERA_WIDTH_UNITS  = 10.0
  CAMERA_HEIGHT_UNITS = 10.0
  SCALE               = SCREEN_WIDTH / CAMERA_WIDTH_UNITS
  DEFAULT_SPEED       = 4 # 8 units per second

  @food           = Vec2i.new(1, 1)
  @snake          = Deque(Vec2i).new()
  @last_direction = Vec2i.new(-1,0)
  @direction      = Vec2i.new(-1,0)

  def initialize
    #super(SCREEN_WIDTH, SCREEN_HEIGHT, fullscreen: false)
    super(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS, SCALE, "Snake Game")

    #@camera = GameWindow.camera
    #@camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    #@camera.look(0, 0)
    #axis_colors = { lines: Gosu::Color::BLACK, text: Gosu::Color::BLACK }
    #@camera_debug = CameraDebug.new(@camera, axis_colors)
    #
    ## assets
    #@font = Gosu::Font.new(25)
    #@eat  = Gosu::Sample.new('assets/sounds/snake_eat.wav')

    @updated_at = 0
    @speed      = DEFAULT_SPEED
    restart
  end

  def restart
    @updated_at = 0
    @food = Vec2i.new(0, 1)
    @snake.clear
    @snake.push Vec2i.new(5,0)
    @snake.push Vec2i.new(6,0)
    @snake.push Vec2i.new(7,0)
    @loose = false
    @last_direction = @direction = Vec2i.new(-1,0)
  end

  def update(delta)
    super
    #return if paused?

    #restart if Gosu.button_down? Gosu::KB_R
    return if @loose

    #update_snake_direction

    previous = update_snake_position

    detect_collisions(previous)
  end

  def draw(target, states)
    #@camera_debug.draw

    #Gosu.draw_rect(0, 0, GameWindow.width, GameWindow.height, Gosu::Color::GRAY, 0)
    @window.clear Flaty::Colors::GRAY

    draw_food

    draw_snake

    #draw_hud
  end

  def button_down(code)
    # last direction avoids walking backward and bite in the opposite direction
    case code
    when .r?
      restart
    when .left?
      @direction = Vec2i.new(-1, 0) if @last_direction.x == 0
    when .up?
      @direction = Vec2i.new(0, 1)  if @last_direction.y == 0
    when .right?
      @direction = Vec2i.new(1, 0)  if @last_direction.x == 0
    when .down?
      @direction = Vec2i.new(0, -1) if @last_direction.y == 0
    end
  end

  def update_snake_direction
  end

  def update_snake_position
    seconds = (elapsed_seconds * @speed).to_i

    previous = @snake[0]
    puts seconds
    puts @direction
    if seconds - @updated_at > 0
      @updated_at = seconds
      @snake[0] += @direction
      @last_direction = @direction
      @snake.each_index do |index|
        next if index == 0
        aux = @snake[index]
        @snake[index] = previous
        previous = aux
      end
    end
    previous
  end

  def detect_collisions(previous)
    # tail
    @snake.each_with_index do |v, index|
      next if index == 0
      dead if v == @snake[0]
    end

    # walls
    dead if @snake[0].x < 0 || @snake[0].y < 0
    dead if @snake[0].x >= (CAMERA_WIDTH_UNITS)
    dead if @snake[0].y >= (CAMERA_HEIGHT_UNITS)

    if @snake[0] == @food
    #  @eat.play
      @snake.push previous
      generate_food
    end
  end

  def generate_food
    x = (rand * CAMERA_WIDTH_UNITS).to_i
    y = (rand * CAMERA_HEIGHT_UNITS).to_i
    @food.x = x
    @food.y = y
  end

  FOOD_ANIMATION_SPEED = 100 # 10 blinks per second
  def draw_food
    seconds = (elapsed_time / FOOD_ANIMATION_SPEED).to_i % 2
    color = seconds == 0 ? Flaty::Colors::BLUE : Flaty::Colors::GREEN
    Flaty.draw_rect(@food.x, @food.y, 1, 1, color)
  end

  def draw_snake
    @snake.each_with_index do |v, index|
      color = index == 0 ? Flaty::Colors::RED : Flaty::Colors::BLACK
      Flaty.draw_rect(v.x, v.y, 1, 1, color)
    end
  end

  def draw_hud
    #@font.draw_text("Score: #{@snake.size}", GameWindow.width - 200, 10, 10, 2.0, 2.0,
    #                Gosu::Color::GREEN)
    #if @loose
    #  x = GameWindow.width / 2 - @camera.unit_x
    #  @font.draw_text("GAME OVER", x, 10, 10, 2.0, 2.0, Gosu::Color::RED)
    #end
  end

  def dead
    @loose = true
  end
end

game = SnakeGame.new
game.loop
