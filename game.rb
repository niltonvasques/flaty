require 'gosu'
require 'pry-byebug'
require './world'
require './level_loader'
require './game_over_screen'

class GameWindow < Gosu::Window
  SCREEN_WIDTH   = 1280
  SCREEN_HEIGHT  = 720

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, fullscreen: false)
    self.caption = "Ruby Falcon in the Dusk"

    # state
    @paused = false
    @paused_at = 0
    @@updated_at = 0
    @@delta_seconds = 0
    @@debug = false

    @world = World.new
    @game_over = GameOverScreen.new
    LevelLoader.generate(@world)
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

    unless @world.game_over
      @world.update
      @game_over.score = @world.score
    end
  end

  def draw
    unless @world.game_over
      @world.draw
    else
      @game_over.draw
    end
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    elsif id == Gosu::KB_D
      @@debug = !@@debug
    elsif id == Gosu::KB_R
      @world.restart
      LevelLoader.generate(@world)
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
          @world.pause
        else
          @world.play
        end
      end
    end
    @paused
  end
end

window = GameWindow.new
window.show
