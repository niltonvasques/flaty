require "flaty"
require "flaty/fps"
require "flaty/game_object"

class Collisions < Flaty::GameWindow
  SCREEN_WIDTH        = 1500
  SCREEN_HEIGHT       = 1500
  CAMERA_WIDTH_UNITS  = 20.0
  CAMERA_HEIGHT_UNITS = 20.0
  SCALE               = SCREEN_WIDTH / CAMERA_WIDTH_UNITS
  HALF_WIDTH          = CAMERA_WIDTH_UNITS / 2.0
  HALF_HEIGHT         = CAMERA_HEIGHT_UNITS / 2.0
  GRAVITY             = Vec2d.new(0, -1) # -1 m/s

  def initialize
    super(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS, SCALE, "Collisions Simulator")

  #  @circle_img = Gosu::Image.new('assets/metal_ball.png')

    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @camera.look(0, HALF_HEIGHT)
    update_camera

    axis_colors = { lines: Flaty::Colors::BLACK, text: Flaty::Colors::BLACK }
    @camera_debug = Flaty::CameraDebug.new(@camera, axis_colors)

    @obj = Flaty::GameObject.new()

  #  # assets
  #  @font = Gosu::Font.new(25)
  #  @@font = @font

    @bodies = [] of Flaty::GameObject
  #  @world = Physics::World.new
  #  @world.collision_type = :elastic

    restart
  end

  #BIGNUM = (2**30).freeze
  def restart
  #  @frames = 0
  #  @sum_frames = BIGNUM
  #  @draws = 0
  #  @sum_draws = BIGNUM
  #  @world.bodies.clear
    create_walls

  #  #@world.bodies << create_circle([-3.5001, 1.5001], [0,   0], Gosu::Color::CYAN, 'CYAN')
  #  @world.bodies << create_rect(Vector2d[0,  1.001], Vector2d[-4, 0], 1, 10, Gosu::Color::RED)
  #  @world.bodies << create_rect(Vector2d[-6, 1.001], Vector2d[1,  0], 2, 100, Gosu::Color::BLUE)
  #  @world.bodies << create_circle([-3, 6], [5,   5])
  #  @world.bodies << create_circle([-3, 2], [2,  -4])
  #  @world.bodies << create_circle([-1, 4], [3,  -3])
  #  @world.bodies << create_circle([0,  3], [0,   5])
  #  @world.bodies << create_circle([1,  4], [-4, -1])
  #  @world.bodies << create_circle([2,  4], [-4, -1])
  #  @world.bodies << create_circle([3,  4], [-1, -1])
  #  @world.bodies << create_circle([3,  5], [2,  -1])
  #  @world.bodies << create_circle([3,  6], [4,  -1])
  end

  #def create_circle(xy, speed, tag = :circle)
  #  xy = Vector2d.elements(xy) / 1.0
  #  speed = Vector2d.elements(speed) / 1.0
  #  c = Flaty.random_color
  #  opts = { position: xy, speed: speed, radius: 0.5, color: c, mass: 10.0, elasticity: 0.99,
  #           rigidbody: true, tag: tag, image: @circle_img }
  #  CircleGameObject.new(opts)
  #end

  #def create_rect(xy, speed, size, mass,  c)
  #  opts = { position: xy, speed: speed, width: size, height: size, color: c, mass: mass, rigidbody: true, elasticity: 0.6, damp: 1 }
  #  RectGameObject.new(opts)
  #end

  def create_walls
    m = 1000000000.0
    base = {
      :speed => Vec2d.new(0, 0),
      :mass => m,
      :color => Flaty::Colors::BLACK
    }
    p = base.merge({
      :position => Vec2d.new(-HALF_WIDTH, 0), :width => 1.0,
      :height => HALF_HEIGHT.to_f, :tag => :left_wall
    })

    # left
    @bodies << Flaty::RectGameObject.new(p)
    @bodies << Flaty::RectGameObject.new(p.merge({ :position => Vec2d.new(-HALF_WIDTH, HALF_HEIGHT) }))

    # right
    p = p.merge({ :position => Vec2d.new(HALF_WIDTH-1, HALF_HEIGHT), :tag => :right_wall })
    @bodies << Flaty::RectGameObject.new(p)
    @bodies << Flaty::RectGameObject.new(p.merge({ :position => Vec2d.new(HALF_WIDTH-1, 0) }))

    # floor
    p = p.merge({
      :position => Vec2d.new(0, 0), :width => HALF_WIDTH.to_f, :height => 1.0, :tag => :floor
    })
    @bodies << Flaty::RectGameObject.new(p)
    @bodies << Flaty::RectGameObject.new(p.merge({ :position => Vec2d.new(-HALF_WIDTH, 0) }))

    # ceil
    p = p.merge({ :position => Vec2d.new(-HALF_WIDTH, CAMERA_HEIGHT_UNITS-1), :tag => :ceil })
    @bodies << Flaty::RectGameObject.new(p)
    @bodies << Flaty::RectGameObject.new(p.merge({ :position => Vec2d.new(0, CAMERA_HEIGHT_UNITS-1) }))
  end

  #def update
  #  super
  #  return if paused?
  #  restart if Gosu.button_down? Gosu::KB_R
  #  t = Benchmark.elapsed do
  #    @camera.zoom(-1) if Gosu.button_down? Gosu::KB_NUMPAD_PLUS
  #    @camera.zoom(1)  if Gosu.button_down? Gosu::KB_NUMPAD_MINUS
  #    @world.gravity.y += 0.1 if Gosu.button_down? Gosu::KB_DOWN
  #    @world.gravity.y += -0.1 if Gosu.button_down? Gosu::KB_UP
  #    generate_circle

  #    @world.update
  #  end
  #  @frames += 1
  #  @sum_frames += t
  #end

  #def print_bench
  #  @sum_frames -= BIGNUM
  #  @sum_draws -= BIGNUM
  #  puts "#{Benchmark::NANO/(@sum_frames/@frames)} UPS"
  #  puts "#{Benchmark::NANO/(@sum_draws/@draws)} DPS"
  #  puts "#{(@sum_frames/@frames)} AVG UPDATE TIME"
  #  puts "#{(@sum_draws/@draws)} AVG DRAW TIME"
  #  puts "#{@sum_frames} UPDATE TIME"
  #  puts "#{@sum_draws} DRAW TIME"
  #end

  def draw(window, states)
    Flaty.paint(Flaty::Colors::GRAY)
  #  t = Benchmark.elapsed do
  #    @camera_debug.draw if GameWindow.debug
  #    @world.draw_quad

  #    Flaty.paint(Gosu::Color::GRAY)

    draw_bodies

  #    msg = "FPS: #{Gosu.fps} #{@world.gravity.round} gravity"
  #    @font.draw_text(msg, 10, 10, 100, 1.0, 1.0, Gosu::Color::GREEN)
  #  end
  #  @draws += 1
  #  @sum_draws += t
    @camera_debug.draw
  end

  def draw_bodies
    @bodies.each do |body|
  #    next if body.is_a? CircleGameObject

      puts "#{body.x} x #{body.y} #{body.width} w #{body.height}"
      Flaty.draw_rect(body.x, body.y, body.width, body.height, body.color)
  #    x = body.x + (body.width / 2.0)
  #    y = body.y + (body.height / 2.0)
  #    mass = "#{body.mass.to_i.to_s} kg"
  #    Flaty.draw_text(@font, mass, x, y) if body.rigidbody
    end

  #  @world.bodies.select { |b| b.is_a? CircleGameObject }.each(&:draw)
  end

  def button_down(code)
    @camera.key_pressed(self, code)
  end

  #def generate_circle
  #  if Gosu.button_down? Gosu::KB_C and @circle_up == 0
  #    @circle_up = Gosu.milliseconds
  #    cx = (rand * (CAMERA_WIDTH_UNITS - 3))-((CAMERA_WIDTH_UNITS - 3)/2.0)
  #    cy = CAMERA_HEIGHT_UNITS - 2
  #    @world.bodies << create_circle([cx, cy], [-1, -1])
  #  elsif Gosu.milliseconds - @circle_up > 250
  #    @circle_up = 0
  #  end
  #end
end

game = Collisions.new
game.loop
