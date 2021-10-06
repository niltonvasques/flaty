require "flaty"
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

  #  # assets
  #  @song = Gosu::Song.new('assets/sounds/dusk_theme.mp3')
  #  @song.volume = 0.2
  #  @song.play

  #  @world = World.new
    @level = LevelLoader.load_level
  #  @world.level = @level
  #  @frames = 0
  #  @sum_frames = 0
    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @camera.bounds.left = CAMERA_WIDTH_UNITS / 2.0
    @camera.bounds.top = CAMERA_HEIGHT_UNITS / 2.0
    @camera.look(CAMERA_WIDTH_UNITS / 2.0, CAMERA_HEIGHT_UNITS / 2.0)
    update_camera
    @camera_debug = Flaty::CameraDebug.new(@camera)

    # objects
    @world = Physics::World.new(@camera)
    #@world.gravity.y = 0
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

    @level.tiles.each { |tile| tile.debug = nil } if Flaty::GameWindow.debug?
    @world.update(delta)

    @camera.look(@bob.x, @bob.y)
    update_camera

    @background.update(@bob.speed)
  end

  def draw(target, states)
    @background.draw

    @level.tiles.each { |t| t.draw }
    if Flaty::GameWindow.debug?
      @camera_debug.draw
      @world.draw_quad
    end
    @bob.draw
    @bird.draw
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
