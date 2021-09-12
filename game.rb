unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
end

require 'gosu'.freeze
require 'pry-byebug'
require 'engine/game_window'
require 'world'
require 'level_loader'

class Game < GameWindow
  def initialize
    super()
    self.caption = "Ruby Falcon in the Dusk"

    # assets
    @song = Gosu::Song.new('assets/sounds/dusk_theme.mp3')
    @song.volume = 0.2
    @song.play

    @world = World.new
    LevelLoader.create_tiles(@world)
  end

  def update
    super
    return if paused?

    @world.update
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
