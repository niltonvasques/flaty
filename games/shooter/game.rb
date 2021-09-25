unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__) + '/../..'))
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../..'))
end

require 'gosu'.freeze
require 'pry-byebug'
require 'flaty/flaty'
require 'games/shooter/world'
require 'games/shooter/level_loader'

class Game < GameWindow
  SCREEN_WIDTH   = 2160
  SCREEN_HEIGHT  = 1214
  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, fullscreen: false)
    self.caption = "Ruby Falcon in the Dusk"

    # assets
    @song = Gosu::Song.new('assets/sounds/dusk_theme.mp3')
    @song.volume = 0.2
    @song.play

    @world = World.new
    LevelLoader.create_tiles(@world)
    @frames = 0
    @sum_frames = 0
  end

  def update
    super
    return if paused?

    t = Benchmark.elapsed do
      @world.update
    end
    @frames += 1
    @sum_frames += t
  end

  def print_bench
    puts "#{Benchmark::NANO/(@sum_frames/@frames)} UPS"
  end

  def draw
    @world.draw
  end

  def play
    @song.play
    @world.play
  end

  def paused
    @song.pause
    @world.pause
  end
end

game = Game.new
game.show
game.print_bench
