unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
end

require 'pry-byebug'
require 'method_source'
require 'gosu'
require 'engine/game_window'
require 'engine/camera_debug'
require 'engine/benchmark'
require 'engine/benchmark'
require 'math/poly'

class MathAxis < GameWindow
  SCREEN_WIDTH   = 1500
  SCREEN_HEIGHT  = 1500
  CAMERA_WIDTH_UNITS  = 10
  CAMERA_HEIGHT_UNITS = 10

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, fullscreen: false)
    self.caption = 'Math Axis'

    @camera = GameWindow.camera
    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @camera.look(0, 0)
    axis_colors = { lines: Gosu::Color::BLACK, text: Gosu::Color::BLACK }
    @camera_debug = CameraDebug.new(@camera, axis_colors)

    # assets
    @font = Gosu::Font.new(25)

    # caching rendered axis
    @axis_image = Gosu.render(SCREEN_WIDTH, SCREEN_HEIGHT) { draw_axis }
    @axis_image.save('axis.png')
  end

  def update
    super
    return if paused?

    move(Vector2d[0, 1])  if Gosu.button_down? Gosu::KB_UP
    move(Vector2d[0, -1]) if Gosu.button_down? Gosu::KB_DOWN
    move(Vector2d[-1, 0]) if Gosu.button_down? Gosu::KB_LEFT
    move(Vector2d[1, 0])  if Gosu.button_down? Gosu::KB_RIGHT
    zoom(-1) if Gosu.button_down? Gosu::KB_NUMPAD_PLUS
    zoom(1) if Gosu.button_down? Gosu::KB_NUMPAD_MINUS
  end

  def draw
    @axis_image.draw(0, 0, 0)
  end

  MAX_CAMERA_SIZE = 10000000
  MIN_CAMERA_SIZE = 0.01
  def zoom(units)
    units *= @camera.width / 10.0
    return if units < 0 and @camera.width <= MIN_CAMERA_SIZE
    return if units > 0 and @camera.width >= MAX_CAMERA_SIZE
    @camera.size(@camera.width + units, @camera.height + units)
    @axis_image = Gosu.render(SCREEN_WIDTH, SCREEN_HEIGHT) { draw_axis }
  end

  def move(direction)
    unit = @camera.width / 20.0
    @camera.position += (direction * unit)
    @axis_image = Gosu.render(SCREEN_WIDTH, SCREEN_HEIGHT) { draw_axis }
  end

  def draw_axis
    puts Benchmark.elapsed {
      @camera_debug.draw

      Gosu.draw_rect(0, 0, GameWindow.width, GameWindow.height, Gosu::Color::GRAY, 0)

      pts = [[0,0],[1,1],[2,5],[3,0],[4,3],[5,4],[6,-1],[7,2],[10,2]]

      draw_function(40, Gosu::Color::GREEN)    { |x| Math.sin(x)          }
      draw_function(80, Gosu::Color::CYAN)     { |x| Math.cos(x)          }
      draw_function(120, Gosu::Color::FUCHSIA) { |x| 1.0/(1+Math.exp(-x)) }
      draw_function(160, Gosu::Color::BLUE)    { |x| Math.exp(-x)         }
      draw_function(200, Gosu::Color::RED)     { |x| Poly.f(x, pts)       }
      #draw_function(240, Gosu::Color::RED) { |x| (25.0/6)*x + (3/2.0)*(x**2) + (-5/3.0)*(x**3) }
    }
  end

  LINE_THICKNESS = 3
  MIN_PRECISION = 0.000000000001
  def draw_function(y, color, &block)
    precision = [(@camera.width / 1000.0).abs, MIN_PRECISION].max
    source_str = format_equation(block.source.scan(/\{ \|x\| (.*) \}/).flatten.first)
    @font.draw_text("#{source_str}", 20, y, 100, 1.0, 1.0, color)
    x2 = @camera.shift_x
    x1 = x2
    y1 = block.call(x1)
    while x2 <= (@camera.shift_x + @camera.width)
      y2 = block.call(x2)
      px1 = @camera.translate_x(x1)
      py1 = @camera.translate_y(y1)
      px2 = @camera.translate_x(x2)
      py2 = @camera.translate_y(y2)
      w = (px2 - px1 + LINE_THICKNESS)
      h = (py2 - py1 + LINE_THICKNESS)
      Gosu.draw_line(px1, py1, color, px2, py2, color, z = 100, mode = :default)
      Gosu.draw_rect(px1, py1, w, h, color, z = 100, mode = :default)
      x1 = x2
      y1 = block.call(x1)
      x2 += precision
    end
  end

  def format_equation(eq)
    eq = eq.gsub('**2', '²').gsub('**3', '³').gsub('**', '^').gsub('Math.log', 'ln')
    eq.gsub('Math.', '')
  end
end

game = MathAxis.new
game.show
