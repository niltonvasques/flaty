require 'gosu'
require 'pry-byebug'
require './dusk_level'

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

    @dusk_level = DuskLevel.new
  end

  def self.delta
    @@delta_seconds
  end

  def needs_cursor?; false; end

  def update
    @@delta_seconds = (Gosu.milliseconds - @@updated_at) / 1000.0
    @@updated_at = Gosu.milliseconds
    return if paused?

    @dusk_level.update
  end

  def draw
    @dusk_level.draw
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
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
          @dusk_level.pause
        else
          @dusk_level.play
        end
      end
    end
    @paused
  end
end

window = GameWindow.new
window.show
