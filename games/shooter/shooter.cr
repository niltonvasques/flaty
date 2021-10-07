require "flaty"
require "flaty/fps"
require "./bird"
require "./bob"
require "./background"
require "./level_loader"

class Shooter < Flaty::GameWindow
  SCREEN_WIDTH        = 2160
  SCREEN_HEIGHT       = 1214
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
    @level = LevelLoader.load_level
    @background = Background.new(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @bob = Bob.new
    @bird = Bird.new
    #@hud = HUD.new
    @world.bodies << @bob
    @world.bodies << @bird
    @world.bodies += @level.tiles
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

  def draw(target, states)
    @background.draw

    @level.tiles.each { |t| t.draw }
    @level.stars.each { |t| t.draw }
    if Flaty::GameWindow.debug?
      @camera_debug.draw
      @world.draw_quad
    end
    @bob.draw
    @bird.draw
    @fps.draw(@delta)
    Flaty.draw_text_in_pixels(@font, "Score: #{@bob.score}", 9, 9)
  end

  def button_down(code)
    @camera.key_pressed(self, code)
  end

  #def play
  #  @song.play
  #  @world.play
  #end

  #def paused
  #  @song.pause
  #  @world.pause
  #end
end

game = Shooter.new
game.loop
