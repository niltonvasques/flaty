require 'gosu'.freeze
require 'pry-byebug'
require './world'
require './level_loader'

class GameWindow < Gosu::Window
  SCREEN_WIDTH   = 1280
  SCREEN_HEIGHT  = 720

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, fullscreen: false)
    self.caption = "Ruby Falcon in the Dusk"

    # assets
    @song = Gosu::Song.new('assets/sounds/dusk_theme.mp3')
    @song.volume = 0.2
    @song.play

    # state
    @paused = false
    @paused_at = 0
    @@updated_at = 0
    @@delta_seconds = 0
    @@debug = false

    @world = World.new
    LevelLoader.create_tiles(@world)
  end

  def self.delta
    @@delta_seconds
  end

  def self.debug
    @@debug
  end

  def needs_cursor?; false; end

  def update
    @@delta_seconds = (Gosu.milliseconds - @@updated_at) / 1000.0
    @@updated_at = Gosu.milliseconds
    return if paused?

    @world.update
  end

  def draw
    @world.draw
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    elsif id == Gosu::KB_D
      @@debug = !@@debug
    else
      super
    end
  end

  def paused?
    if Gosu.button_down? Gosu::KB_P
      if (Gosu.milliseconds - @paused_at) > 1000
        @paused = !@paused
        @paused_at = Gosu.milliseconds
        if @paused
          @song.pause
          @world.pause
        else
          @song.play
          @world.play
        end
      end
    end
    @paused
  end
end

window = GameWindow.new
window.show
