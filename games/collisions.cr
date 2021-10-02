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

    # assets
    @font      = SF::Font.from_file("assets/Cantarell-Regular.otf")

  #  @circle_img = Gosu::Image.new('assets/metal_ball.png')

    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @camera.look(0, HALF_HEIGHT)
    update_camera

    axis_colors   = { lines: Flaty::Colors::BLACK, text: Flaty::Colors::BLACK }
    @camera_debug = Flaty::CameraDebug.new(@camera, axis_colors)

    @fps = Flaty::FPS.new(SCREEN_WIDTH, @font)

    @bodies = [] of Flaty::GameObject
    @world = Physics::World.new
    @world.collision_type = :elastic

    create_walls
    restart
  end

  #BIGNUM = (2**30).freeze
  def restart
  #  @world.bodies.clear

  #  #@world.bodies << create_circle([-3.5001, 1.5001], [0,   0], Gosu::Color::CYAN, 'CYAN')
    @world.bodies << create_rect(Vec2d.new(0,  1.001), Vec2d.new(-4, 0), 1.0, 10.0, Flaty::Colors::RED)
    #@world.bodies << create_rect(Vec2d.new(-6,  1.001), Vec2d.new(1, 0), 2.0, 100.0, Flaty::Colors::BLUE)
    @world.bodies << create_circle([-3, 6], [5,   5])
    #@world.bodies << create_circle([-3, 2], [2,  -4])
    #@world.bodies << create_circle([-1, 4], [3,  -3])
    #@world.bodies << create_circle([0,  3], [0,   5])
    #@world.bodies << create_circle([1,  4], [-4, -1])
    #@world.bodies << create_circle([2,  4], [-4, -1])
    #@world.bodies << create_circle([3,  4], [-1, -1])
    #@world.bodies << create_circle([3,  5], [2,  -1])
    #@world.bodies << create_circle([3,  6], [4,  -1])
  end

  def create_circle(xy, speed, tag = :circle)
    xy = Vec2d.new(xy[0].to_f, xy[1].to_f)
    speed = Vec2d.new(speed[0].to_f, speed[1].to_f)
    c = Flaty.random_color
  #  opts = { position: xy, speed: speed, radius: 0.5, color: c, mass: 10.0, elasticity: 0.99,
  #           rigidbody: true, tag: tag, image: @circle_img }
    opts = {
      :position => xy, :speed => speed, :color => c, :tag => tag,
      :mass => 10.0, :rigidbody => true, :elasticity => 0.99
    }
    Flaty::CircleGameObject.new(0.5, opts)
  end

  def create_rect(xy, speed, size, mass,  c)
    opts = {
      :position => xy, :speed => speed, :width => size, :height => size, :color => c,
      :mass => mass, :rigidbody => true, :elasticity => 0.6, :damp => 1.0, :tag => :block
    }
    Flaty::RectGameObject.new(opts)
  end

  def create_walls
    m = 1000000000.0
    base = { :speed => Vec2d.new(0, 0), :mass => m, :color => Flaty::Colors::BLACK }
    p = base.merge({
      :position => Vec2d.new(-HALF_WIDTH, 0), :width => 1.0,
      :height => HALF_HEIGHT.to_f, :tag => :left_wall
    })

    # left
    @world.bodies << Flaty::RectGameObject.new(p)
    @world.bodies << Flaty::RectGameObject.new(p.merge({ :position => Vec2d.new(-HALF_WIDTH, HALF_HEIGHT) }))

    # right
    p = p.merge({ :position => Vec2d.new(HALF_WIDTH-1, HALF_HEIGHT), :tag => :right_wall })
    @world.bodies << Flaty::RectGameObject.new(p)
    @world.bodies << Flaty::RectGameObject.new(p.merge({ :position => Vec2d.new(HALF_WIDTH-1, 0) }))

    # floor
    p = p.merge({
      :position => Vec2d.new(0, 0), :width => HALF_WIDTH.to_f, :height => 1.0, :tag => :floor
    })
    @world.bodies << Flaty::RectGameObject.new(p)
    @world.bodies << Flaty::RectGameObject.new(p.merge({ :position => Vec2d.new(-HALF_WIDTH, 0) }))

    # ceil
    p = p.merge({ :position => Vec2d.new(-HALF_WIDTH, CAMERA_HEIGHT_UNITS-1), :tag => :ceil })
    @world.bodies << Flaty::RectGameObject.new(p)
    @world.bodies << Flaty::RectGameObject.new(p.merge({ :position => Vec2d.new(0, CAMERA_HEIGHT_UNITS-1) }))
  end

  def update(delta)
    @world.bodies.each { |b| b.update(delta) }
    #body1 = @world.bodies[@world.bodies.size - 2]
    #body2 = @world.bodies.last
    #Physics.solve_collision(body1, body2)
    #Physics.solve_collision(body2, body1)
  #  t = Benchmark.elapsed do
  #    @world.gravity.y += 0.1 if Gosu.button_down? Gosu::KB_DOWN
  #    @world.gravity.y += -0.1 if Gosu.button_down? Gosu::KB_UP
  #    generate_circle

    @world.update
  #  end
  end

  def draw(window, states)
    Flaty.paint(Flaty::Colors::GRAY)
    # @world.draw_quad

    draw_bodies

    @camera_debug.draw
    @fps.draw(@delta)
  end

  def draw_bodies
    visible_bodies = @world.bodies.select { |b| @camera.visible?(b) }
    visible_bodies.each do |body|
      next if body.is_a? Flaty::CircleGameObject

      Flaty.draw_rect(body.x, body.y, body.width, body.height, body.color)
      mass = "#{body.mass.to_i.to_s} kg"
      x = body.center.x - 0.2
      Flaty.draw_text_world(@font, mass, x, body.center.y, 20) if body.rigidbody
    end

    visible_bodies.select { |b| b.is_a?(Flaty::CircleGameObject) }.each { |b| b.draw }
  end

  def button_down(code)
    @camera.key_pressed(self, code)
    case code
    when .r? then restart
    end
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
