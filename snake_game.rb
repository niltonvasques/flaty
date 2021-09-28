#unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__) + '/..'))
#  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/..'))
#end

require "flaty/flaty"

struct SF::Rect
  def center
    SF::Vector2.new(left + width/2, top + height/2)
  end
end

class SF::Transformable
  def center!
    self.origin = local_bounds.center
    self
  end
end

class SnakeGame < GameWindow
  SCREEN_WIDTH        = 1500
  SCREEN_HEIGHT       = 1500
  CAMERA_WIDTH_UNITS  = 10
  CAMERA_HEIGHT_UNITS = 10
  SCALE               = SCREEN_WIDTH / CAMERA_WIDTH_UNITS
  DEFAULT_SPEED       = 8 # 8 units per second

  @food : SF::Vector2(Int32)

  def initialize
    #super(SCREEN_WIDTH, SCREEN_HEIGHT, fullscreen: false)
    super(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS, SCALE, "Snake Game")

    #@camera = GameWindow.camera
    #@camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    #@camera.look(0, 0)
    #axis_colors = { lines: Gosu::Color::BLACK, text: Gosu::Color::BLACK }
    #@camera_debug = CameraDebug.new(@camera, axis_colors)
    #
    @food = SF::Vector2.new(1, 1)
    ## assets
    #@font = Gosu::Font.new(25)
    #@eat  = Gosu::Sample.new('assets/sounds/snake_eat.wav')

    #@updated_at = 0
    @speed      = DEFAULT_SPEED
    #restart
  end

  def restart
    #@snake = [Vector2d[0,0]]
    #@snake << Vector2d[1,0]
    #@snake << Vector2d[2,0]
    #@loose = false
    #@last_direction = @direction = Vector2d[-1, 0]
  end

  def update
    super
    #return if paused?

    #restart if Gosu.button_down? Gosu::KB_R
    #return if @loose

    #update_snake_direction

    #previous = update_snake_position

    #detect_collisions(previous)
  end

  def draw(target, states)
    #@camera_debug.draw

    #Gosu.draw_rect(0, 0, GameWindow.width, GameWindow.height, Gosu::Color::GRAY, 0)

    draw_food(target, states)

    #draw_snake

    #draw_hud
  end

  def update_snake_direction
    # last direction avoids walking backward and bite in the opposite direction
    #@direction = Vector2d[0, 1]  if Gosu.button_down? Gosu::KB_UP and @last_direction.y == 0
    #@direction = Vector2d[0, -1] if Gosu.button_down? Gosu::KB_DOWN and @last_direction.y == 0
    #@direction = Vector2d[-1, 0] if Gosu.button_down? Gosu::KB_LEFT and @last_direction.x == 0
    #@direction = Vector2d[1, 0]  if Gosu.button_down? Gosu::KB_RIGHT and @last_direction.x == 0
  end

  def update_snake_position
    #seconds = (Gosu.milliseconds / (Second.in_millis / @speed)).to_i

    #previous = @snake[0].dup
    #if seconds - @updated_at > 0
    #  @updated_at = seconds
    #  @snake[0] += @direction
    #  @last_direction = @direction
    #  @snake.each_index do |index|
    #    next if index == 0
    #    aux = @snake[index]
    #    @snake[index] = previous
    #    previous = aux
    #  end
    #end
    #previous
  end

  def detect_collisions(previous)
    # tail
    #@snake.each_with_index do |v, index|
    #  next if index == 0
    #  dead if v == @snake[0]
    #end

    ## walls
    #dead if @snake[0].x < @camera.shift_x or @snake[0].y < @camera.shift_y
    #dead if @snake[0].x >= (@camera.shift_x + @camera.width)
    #dead if @snake[0].y >= (@camera.shift_y + @camera.height)

    #if @snake[0] == @food
    #  @eat.play
    #  @snake << previous
    #  generate_food
    #end
  end

  def generate_food
    #x = (rand * @camera.width + @camera.shift_x).to_i
    #y = (rand * @camera.height + @camera.shift_y).to_i
    #@food = Vector2d[x, y]
  end

  FOOD_ANIMATION_SPEED = 100 # 10 blinks per second
  def draw_food(window, states)
    seconds = (@clock.elapsed_time.as_milliseconds / FOOD_ANIMATION_SPEED).to_i % 2
    color = seconds == 0 ? Flaty::Colors::BLUE : Flaty::Colors::GREEN
    Flaty.draw_rect(@food.x, @food.y, 1, 1, color)
  end

  def draw_snake
    #@snake.each_with_index do |v, index|
    #  color = index == 0 ? Gosu::Color::RED : Gosu::Color::BLACK
    #  Flaty.draw_rect(v.x, v.y, 1, 1, color, 0)
    #end
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
