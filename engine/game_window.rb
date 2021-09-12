require 'gosu'.freeze
require 'pry-byebug'

class GameWindow < Gosu::Window
  SCREEN_WIDTH   = 1280
  SCREEN_HEIGHT  = 720

  def initialize(width = SCREEN_WIDTH, height = SCREEN_HEIGHT, opts = {})
    @@width = width
    @@height = height
    super(width, height, opts)

    # state
    @paused = false
    @paused_at = 0
    @@updated_at = 0
    @@delta_seconds = 0
    @@debug = false
  end

  def self.width
    @@width
  end

  def self.height
    @@height
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
          paused if defined? paused
        else
          play if defined? play
        end
      end
    end
    @paused
  end
end
