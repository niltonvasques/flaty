unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__) + '/..'))
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/..'))
end

require 'pry-byebug'
require 'method_source'
require 'gosu'
require 'flaty/flaty'
require 'math/poly'

class Collisions < GameWindow
  SCREEN_WIDTH        = 1500
  SCREEN_HEIGHT       = 1500
  CAMERA_WIDTH_UNITS  = 10
  CAMERA_HEIGHT_UNITS = 10
  GRAVITY             = Vector2d[0, -1].freeze # -1 m/s

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, fullscreen: false)
    self.caption = 'Collisions Simulator'

    @camera = GameWindow.camera
    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @camera.look(0, 5)
    axis_colors = { lines: Gosu::Color::BLACK, text: Gosu::Color::BLACK }
    @camera_debug = CameraDebug.new(@camera, axis_colors)

    # assets
    @font = Gosu::Font.new(25)
    @@font = @font

    @world = Physics::World.new

    restart
  end

  def self.font
    @@font
  end

  def restart
    @frames = 0
    @sum_frames = 0
    @world.bodies.clear
    create_walls

    #@world.bodies << create_rect(Vector2d[0,  1], Vector2d[-4, 0], 1, 10, Gosu::Color::RED)
    #@world.bodies << create_rect(Vector2d[-4, 1], Vector2d[1,  0], 2, 100, Gosu::Color::BLUE)
    @world.bodies << create_circle([-3, 6], [5,   5], Gosu::Color::CYAN)
    @world.bodies << create_circle([-3, 2], [2,  -4], Gosu::Color::BLUE)
    @world.bodies << create_circle([-1, 4], [3,  -3], Gosu::Color::RED)
    @world.bodies << create_circle([0,  2], [0,   5], Gosu::Color::WHITE)
    @world.bodies << create_circle([0,  4], [0,   5], Gosu::Color::FUCHSIA)
    @world.bodies << create_circle([1,  4], [-4, -1], Gosu::Color::GREEN)
    @world.bodies << create_circle([2,  4], [-4, -1], Gosu::Color::AQUA)
    @world.bodies << create_circle([3,  4], [-1, -1], Gosu::Color::BLACK)
    @world.bodies << create_circle([3,  5], [2,  -1], Gosu::Color::RED)
    @world.bodies << create_circle([3,  6], [4,  -1], Gosu::Color::YELLOW)
  end

  def create_circle(xy, speed, c)
    xy = Vector2d.elements(xy) / 1.0
    speed = Vector2d.elements(speed) / 1.0
    opts = { position: xy, speed: speed, radius: 0.5, color: c, mass: 10.0, elasticity: 0.9,
             rigidbody: true }
    CircleGameObject.new(opts)
  end

  def create_rect(xy, speed, size, mass,  c)
    opts = { position: xy, speed: speed, width: size, height: size, color: c, mass: mass, rigidbody: true, elasticity: 0.6, damp: 1 }
    RectGameObject.new(opts)
  end

  def create_walls
    m = 1000000000
    base = { speed: Vector2d[0, 0], mass: m, color: Gosu::Color::BLACK }
    @world.bodies << RectGameObject.new(base.merge({ position: Vector2d[-5, 0],   width: 1, height: 10, tag: :left_wall }))
    @world.bodies << RectGameObject.new(base.merge({ position: Vector2d[4, 0],    width: 1, height: 10, tag: :right_wall }))
    @world.bodies << RectGameObject.new(base.merge({ position: Vector2d[-5, -0.001], width: 10, height: 1, tag: :floor }))
    @world.bodies << RectGameObject.new(base.merge({ position: Vector2d[-5, 9],   width: 10, height: 1, tag: :ceil }))
  end

  def update
    super
    return if paused?
    restart if Gosu.button_down? Gosu::KB_R
    t = Benchmark.elapsed do
      @camera.zoom(-1) if Gosu.button_down? Gosu::KB_NUMPAD_PLUS
      @camera.zoom(1)  if Gosu.button_down? Gosu::KB_NUMPAD_MINUS
      @world.gravity.y += 0.1 if Gosu.button_down? Gosu::KB_DOWN
      @world.gravity.y += -0.1 if Gosu.button_down? Gosu::KB_UP

      @world.update
    end
    @frames += 1
    @sum_frames += t
  end

  def print_bench
    puts "#{Benchmark::NANO/(@sum_frames/@frames)} UPS"
  end

  def draw
    @camera_debug.draw if GameWindow.debug

    Flaty.paint(Gosu::Color::GRAY)

    draw_bodies

    msg = "FPS: #{Gosu.fps} #{@world.gravity.round} gravity"
    @font.draw_text(msg, 10, 10, 100, 1.0, 1.0, Gosu::Color::GREEN)
  end

  def draw_bodies
    @world.bodies.each do |body|
      next if body.is_a? CircleGameObject

      Flaty.draw_rect(body.x, body.y, body.width, body.height, body.color, 0)
      x = body.x + (body.width / 2.0)
      y = body.y + (body.height / 2.0)
      mass = "#{body.mass.to_i.to_s} kg"
      Flaty.draw_text(@font, mass, x, y) if body.rigidbody
    end

    @world.bodies.select { |b| b.is_a? CircleGameObject }.each(&:draw)
  end
end

game = Collisions.new
game.show
game.print_bench
