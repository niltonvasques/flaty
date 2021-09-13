unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
end

require 'gosu'.freeze
require 'pry-byebug'
require 'engine/game_window'
require 'engine/camera_debug'
require 'method_source'

class MathAxis < GameWindow
  SCREEN_WIDTH   = 1500
  SCREEN_HEIGHT  = 1500
  CAMERA_WIDTH_UNITS  = 20
  CAMERA_HEIGHT_UNITS = 20

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, fullscreen: false)
    self.caption = 'Math Axis'

    @camera = GameWindow.camera
    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @camera.look(0, 0)
    @camera_debug = CameraDebug.new(@camera)

    # assets
    @font = Gosu::Font.new(25)
  end

  def update
    super
    return if paused?

  end

  def draw
    #puts "delta: #{GameWindow.delta.round(4)}"
    @camera_debug.draw

    draw_function(-10, 10, 40, Gosu::Color::GREEN)   { |x| Math.sin(x) }
    draw_function(-10, 10, 80, Gosu::Color::CYAN)    { |x| Math.cos(x) }
    draw_function(-10, 10, 120, Gosu::Color::FUCHSIA) { |x| 1.0/(1+Math.exp(-x)) }
  end

  def draw_function(min, max, y, color, &block)
    source_str = block.source.scan(/\{ \|x\| (.*) \}/).flatten.first
    @font.draw_text("#{source_str}", 20, y, 100, 1.0, 1.0, color)
    x2 = min
    x1 = x2
    y1 = block.call(x1)
    while x2 <= max
      y2 = block.call(x2)
      px1 = @camera.translate_x(x1)
      py1 = @camera.translate_y(y1)
      px2 = @camera.translate_x(x2)
      py2 = @camera.translate_y(y2)
      Gosu.draw_line(px1, py1, color, px2, py2, color, z = 100, mode = :default)
      x1 = x2
      y1 = block.call(x1)
      x2 += 0.01
    end
  end
end

game = MathAxis.new
game.show
