unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__) + '/..'))
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/..'))
end

require 'pry-byebug'
require 'method_source'
require 'gosu'
require 'flaty/flaty'
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

    @bold = true
    @points = [[-2,2],[1,1],[2,2],[3,0],[4,3]]

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
    zoom(1)  if Gosu.button_down? Gosu::KB_NUMPAD_MINUS

    animate_polynomial
  end

  def draw
    @axis_image.draw(0, 0, 0)
  end

  private

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

  def animate_polynomial
    negative = 1
    negative = -1 if Flaty.seconds % 2 == 0
    @points[0][1] += ((Flaty.seconds % 3) * negative) * 0.1
    @points[1][1] += ((Flaty.seconds % 3) * negative) * 0.1
    @points[2][1] += ((Flaty.seconds % 3) * negative) * 0.5
    @points[3][1] += ((Flaty.seconds % 3) * negative) * 0.1
    @points[0][0] += ((Flaty.seconds % 3) * negative) * 0.5
    @points[0][0] = @points[1][0] - 10 if @points[0][0] <= @points[1][0]
    @axis_image = Gosu.render(SCREEN_WIDTH, SCREEN_HEIGHT) { draw_axis }
  end

  def draw_axis
    t = Benchmark.elapsed do
      @camera_debug.draw

      Flaty.paint(Gosu::Color::GRAY)

      f = Poly.interpolate(@points)
      fx = f.equation(2)

      draw_function(40, Gosu::Color::GREEN)     { |x| Math.sin(x)          }
      draw_function(80, Gosu::Color::CYAN)      { |x| Math.cos(x)          }
      draw_function(120, Gosu::Color::FUCHSIA)  { |x| 1.0/(1+Math.exp(-x)) }
      draw_function(160, Gosu::Color::YELLOW)   { |x| Math.exp(-x)         }
      draw_function(200, Gosu::Color::BLUE, fx) { |x| f.x(x)               }
    end
    puts t
  end

  LINE_THICKNESS = 3
  MIN_PRECISION = 0.000000000001
  def draw_function(y, color, label = nil, &block)
    precision = [(@camera.width / 1000.0).abs, MIN_PRECISION].max

    x2 = @camera.shift_x
    x1 = x2
    y1 = block.call(x1)

    while x2 <= (@camera.shift_x + @camera.width)
      y2 = block.call(x2)
      w = (x2 - x1)
      h = (y2 - y1)
      Flaty.draw_line(x1, y1, color, x2, y2, color, z = 100, mode = :default)
      if @bold
        Flaty.draw_rect(x1, y1, w, h, color, z = 100, mode = :default, thickness = LINE_THICKNESS)
      end
      x1 = x2
      y1 = y2
      x2 += precision
    end

    draw_equation_label(block, y, color, label)
  end

  def draw_equation_label(block, y, color, label)
    label = format_equation(block.source.scan(/\{ \|x\| (.*) \}/).flatten.first) unless label
    @font.draw_text("#{label}", 20, y, 100, 1.0, 1.0, color)
  end

  def format_equation(eq)
    eq = eq.gsub('**2', '²').gsub('**3', '³').gsub('**', '^').gsub('Math.log', 'ln')
    eq.gsub('Math.', '')
  end
end

game = MathAxis.new
game.show
