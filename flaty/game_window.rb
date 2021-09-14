require 'gosu'.freeze
require 'pry-byebug'
require 'flaty/camera'

class GameWindow < Gosu::Window
  SCREEN_WIDTH   = 1280
  SCREEN_HEIGHT  = 720
  CAMERA_WIDTH_UNITS  = 100
  CAMERA_HEIGHT_UNITS = 56

  def initialize(width = SCREEN_WIDTH, height = SCREEN_HEIGHT, opts = {})
    @@width = width
    @@height = height
    super(width, height, opts)

    @@camera = Camera.new(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @@camera.look(CAMERA_WIDTH_UNITS / 2.0, CAMERA_HEIGHT_UNITS / 2.0)

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

  def self.camera
    @@camera
  end

  def needs_cursor?; false; end

  def update
    @@delta_seconds = (Gosu.milliseconds - @@updated_at) / 1000.0
    @@updated_at = Gosu.milliseconds
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    elsif id == Gosu::KB_O
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
