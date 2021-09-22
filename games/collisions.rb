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

    restart
  end

  def restart
    @bodies = []
    @left_wall = GameObject.new(position: Vector2d[-5,0], speed: Vector2d[0, 0], width: 1, height: 10,
                                mass: 1000000000, color: Gosu::Color::BLACK)
    @right_wall = GameObject.new(position: Vector2d[4,0], speed: Vector2d[0, 0], width: 1,
                                 height: 10, mass: 1000000000, color: Gosu::Color::BLACK)
    @floor = GameObject.new(position: Vector2d[-5,-1.01], speed: Vector2d[0, 0], width: 10,
                            height: 1, mass: 1000000000, color: Gosu::Color::BLACK)
    @body1 = GameObject.new(position: Vector2d[0,0], speed: Vector2d[-4, 0], width: 2, height: 2,
                            color: Gosu::Color::RED, mass: 40.0, rigidbody: true)
    @body2 = GameObject.new(position: Vector2d[-4,0], speed: Vector2d[1, 0], width: 1, height: 1,
                            color: Gosu::Color::BLUE, mass: 10.0, rigidbody: true)
    #@body3 = GameObject.new(position: Vector2d[0,6], speed: Vector2d[0, -2], width: 1, height: 1,
    #                        color: Gosu::Color::YELLOW, mass: 10.0, rigidbody: true)
    @bodies << @floor
    @bodies << @left_wall
    @bodies << @right_wall
    @bodies << @body1
    @bodies << @body2
    #@bodies << @body3
  end

  def update
    super
    return if paused?
    restart if Gosu.button_down? Gosu::KB_R
    @body1.mass += 1  if Gosu.button_down? Gosu::KB_UP
    @body1.mass -= 1 if Gosu.button_down? Gosu::KB_DOWN

    # collision after gravity are locking bodies X axis
    # @bodies.select(&:rigidbody).each { |body| body.acceleration = GRAVITY.dup }
    @bodies.each(&:update)

    Physics.elastic_collisions(@bodies)
  end

  def draw
    #@camera_debug.draw

    Flaty.paint(Gosu::Color::GRAY)

    draw_bodies
  end

  def draw_bodies
    @bodies.each do |body|
      Flaty.draw_rect(body.x, body.y, body.width, body.height, body.color, 0)
      x = body.x + (body.width / 2.0)
      y = body.y + (body.height / 2.0)
      mass = "#{body.mass.to_i.to_s} kg"
      Flaty.draw_text(@font, mass, x, y) if body.rigidbody
    end
  end
end

game = Collisions.new
game.show
