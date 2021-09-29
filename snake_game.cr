#unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__) + '/..'))
#  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/..'))
#end

require "crsfml"
require "flaty/flaty"

class SnakeGame < Flaty::GameWindow
  SCREEN_WIDTH        = 1500
  SCREEN_HEIGHT       = 1500
  CAMERA_WIDTH_UNITS  = 20.0
  CAMERA_HEIGHT_UNITS = 20.0
  SCALE               = SCREEN_WIDTH / CAMERA_WIDTH_UNITS
  DEFAULT_SPEED       = 6 # 6 units per second

  @food           = Vec2i.new(1, 1)
  @snake          = Deque(Vec2i).new()
  @last_direction = Vec2i.new(-1,0)
  @direction      = Vec2i.new(-1,0)

  def initialize
    super(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS, SCALE, "Snake Game")

    puts Rect.xywh(1,1,2,4).x
    puts Rect.xywh(1,1,2,4).y
    puts Rect.xywh(1,1,2,4).width
    puts Rect.xywh(1,1,2,4).height
    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @camera.look(CAMERA_WIDTH_UNITS / 2, CAMERA_HEIGHT_UNITS / 2)
    update_camera
    axis_colors = { lines: Flaty::Colors::BLACK, text: Flaty::Colors::BLACK }
    @camera_debug = CameraDebug.new(@camera, axis_colors)

    ## assets
    @font      = SF::Font.from_file("assets/Cantarell-Regular.otf")
    eat_buffer = SF::SoundBuffer.from_file("assets/sounds/snake_eat.wav")
    @eat       = SF::Sound.new(eat_buffer)

    @fps_list = [] of Float64
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
    return if paused?

    return if @loose

    previous = update_snake_position

    detect_collisions(previous)
  end

  def draw(target, states)
    Flaty.paint(Flaty::Colors::GRAY)

    draw_food

    draw_snake

    draw_hud

    @camera_debug.draw if debug?
  end

  def button_down(code)
    # last direction avoids walking backward and bite in the opposite direction
    case code
    when .r? then restart
    when .left? then @direction = Vec2i.new(-1, 0) if @last_direction.x == 0
    when .up? then @direction = Vec2i.new(0, 1)  if @last_direction.y == 0
    when .right? then @direction = Vec2i.new(1, 0)  if @last_direction.x == 0
    when .down? then @direction = Vec2i.new(0, -1) if @last_direction.y == 0
    when .o?
      @camera.zoom(1)
      update_camera
    when .i?
      @camera.zoom(-1)
      update_camera
    end
  end

  def update_snake_direction
  end

  def update_snake_position
    seconds = (elapsed_seconds * @speed).to_i

    previous = @snake[0]
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
      @eat.play
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
    Flaty.draw_text_in_pixels(@font, "Score: #{@snake.size}", 9, 9)
    @fps_list << (1.0/@delta.as_seconds).round(2)
    @fps_list = @fps_list[2..@fps_list.size] if @fps_list.size > 1000

    fps = "FPS: #{@fps_list.sum / @fps_list.size}"
    Flaty.draw_text_in_pixels(@font, fps, SCREEN_WIDTH-100, 9,
                              20, Flaty::Colors::GREEN)
    if @loose
      msg = "GAME OVER"
      font_size = 50
      x = ((SCREEN_WIDTH / 2.0) - (msg.size/2.0) * font_size).to_i
      y = 9
      Flaty.draw_text_in_pixels(@font, "GAME OVER", x, y, font_size, Flaty::Colors::RED)
    end
  end

  def dead
    @loose = true
  end
end

game = SnakeGame.new
game.loop
