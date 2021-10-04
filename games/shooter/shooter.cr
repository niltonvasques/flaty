require "flaty"
require "./bird"

class Shooter < Flaty::GameWindow
  SCREEN_WIDTH        = 2160
  SCREEN_HEIGHT       = 1214
  CAMERA_WIDTH_UNITS  = 50.0
  CAMERA_HEIGHT_UNITS = 28.0
  SCALE               = SCREEN_WIDTH / CAMERA_WIDTH_UNITS

  def initialize
    super(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS, SCALE, "Shooter")

  #  # assets
  #  @song = Gosu::Song.new('assets/sounds/dusk_theme.mp3')
  #  @song.volume = 0.2
  #  @song.play

  #  @world = World.new
  #  @level = LevelLoader.load_level
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
    #@world = Physics::World.new
    #@background = Background.new
    #@bob = Bob.new
    @bird = Bird.new
    #@hud = HUD.new
    #@world.bodies << @bob
    #@world.bodies << @bird
  end

  def update(delta)
    @bird.update(delta)
    puts "#{@bird.position} #{@bird.speed}"
  #  super
  #  return if paused?

  #  t = Benchmark.elapsed do
  #    @world.update
  #  end
  #  @frames += 1
  #  @sum_frames += t
  end

  #def print_bench
  #  puts "#{Benchmark::NANO/(@sum_frames/@frames)} UPS"
  #end

  def draw(target, states)
  #  @world.draw
    @camera_debug.draw
    @bird.draw
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
