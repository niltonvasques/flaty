require "flaty"
require "flaty/fps"
require "./bird"
require "./bob"
require "./background"
require "./level_loader"

class Shooter < Flaty::GameWindow
  SCREEN_WIDTH        = 2160
  SCREEN_HEIGHT       = 1214
  SCREEN_CENTER       = Vec2i.new((SCREEN_WIDTH / 2).to_i, (SCREEN_HEIGHT / 2).to_i)
  CAMERA_WIDTH_UNITS  = 50.0
  CAMERA_HEIGHT_UNITS = 28.0
  SCALE               = SCREEN_WIDTH / CAMERA_WIDTH_UNITS

  @level : Level

  def initialize
    super(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS, SCALE, "Shooter")

    # assets
    @font        = SF::Font.from_file("assets/Cantarell-Regular.otf")
    @song        = SF::Music.from_file("assets/sounds/dusk_theme.ogg")
    @song.volume = 5
    @song.play

    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @camera.bounds.left = CAMERA_WIDTH_UNITS / 2.0
    @camera.bounds.top = CAMERA_HEIGHT_UNITS / 2.0
    @camera.look(CAMERA_WIDTH_UNITS / 2.0, CAMERA_HEIGHT_UNITS / 2.0)
    update_camera
    @camera_debug = Flaty::CameraDebug.new(@camera)

    # objects
    @fps = Flaty::FPS.new(SCREEN_WIDTH, @font)
    @world = Physics::World.new(@camera)
    @world.collision_type = :normal
    @level = LevelLoader.load_level
    @background = Background.new(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @bob = Bob.new
    @bird = Bird.new
    #@world.bodies << @bob
    @world.bodies << @bird
    @world.bodies += @level.tiles

    @rays = false
  end

  def update(delta)
    return if paused?

    bob_x = @bob.x
    @level.tiles.each { |tile| tile.debug = nil } if Flaty::GameWindow.debug?
    @level.stars.each { |t| t.update }
    @world.update(delta)
    @bob.collect_stars(@level.stars)

    @camera.look(@bob.x, @bob.y)
    update_camera

    # only move the parallax if bob horizontal position changed
    @background.update(@bob.speed) if bob_x != @bob.x && @camera.position.x == @bob.x
  end

  RAD = Math::PI / 180
  def draw(target, states)
    @background.draw

    @level.tiles.each { |t| t.draw }
    @level.stars.each { |t| t.draw }

    @bob.draw
    @bird.draw

    if @rays
      draw_ray_traces(@bird)
      draw_ray_trace_normal(@bird)
    end

    if Flaty::GameWindow.debug?
      @camera_debug.draw
      @world.draw_quad
    end

    draw_hud
  end

  def draw_ray_trace_normal(body)
    c = origin = body.center

    rect = body.collision_rect
    start = rect.x
    while start < rect.x + rect.width
      c = Vec2d.new(start, origin.y) + Vec2d.new(0, body.speed.y)
      Flaty.draw_line(start, origin.y, c.x, c.y, Flaty::Colors::RED)
      start += 0.1
    end

    start = rect.y
    while start < rect.y + rect.height
      c = Vec2d.new(origin.x, start) + Vec2d.new(body.speed.x, 0)
      Flaty.draw_line(origin.x, start, c.x, c.y, Flaty::Colors::RED)
      start += 0.1
    end
  end

  def draw_ray_trace(body)
    origin = body.center
    #origin.x = origin.x + body.collision_rect.width / 2 if body.speed.x > 0
    #origin.x = origin.x - body.collision_rect.width / 2 if body.speed.x < 0
    #origin.y = origin.y + body.collision_rect.height / 2 if body.speed.y > 0
    #origin.y = origin.y - body.collision_rect.height / 2 if body.speed.y < 0

    c = body.center + body.speed
    Flaty.draw_line(origin.x, origin.y, c.x, c.y, Flaty::Colors::RED)

    -10.upto(10) do |angle|
      vx = body.speed.x * Math.cos(angle * RAD) - body.speed.y * Math.sin(angle * RAD)
      vy = body.speed.x * Math.sin(angle * RAD) + body.speed.y * Math.cos(angle * RAD)
      c = origin + Vec2d.new(vx, vy)
      Flaty.draw_line(origin.x, origin.y, c.x, c.y, Flaty::Colors::RED)
    end
  end

  def draw_ray_traces(body)
    origin = body.center
    c = body.center + body.speed
    Flaty.draw_line(origin.x, origin.y, c.x, c.y, Flaty::Colors::BLUE)

    rect = body.collision_rect
    start = rect.x
    while start < rect.x + rect.width
      c = Vec2d.new(start, origin.y) + body.speed
      Flaty.draw_line(start, origin.y, c.x, c.y, Flaty::Colors::BLUE)
      start += 0.1
    end

    start = rect.y
    while start < rect.y + rect.height
      c = Vec2d.new(origin.x, start) + body.speed
      Flaty.draw_line(origin.x, start, c.x, c.y, Flaty::Colors::BLUE)
      start += 0.1
    end
  end

  def draw_hud
    @fps.draw(@delta)
    Flaty.draw_text_in_pixels(@font, "Score: #{@bob.score}", 9, 9)
    if paused?
      size = 100
      x = SCREEN_CENTER.x - 200
      Flaty.draw_text_in_pixels(@font, "PAUSED", x, SCREEN_CENTER.y, 100, Flaty::Colors::WHITE)
    end
  end

  def button_down(code)
    @camera.key_pressed(self, code)
    @rays = !@rays if code.r?
  end

  def play
    @song.play
    @bird.play
  end

  def paused
    @bird.pause
    @song.pause
  end
end

game = Shooter.new
game.loop
