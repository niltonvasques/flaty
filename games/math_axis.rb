unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__) + '/..'))
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/..'))
end

require 'pry-byebug'
require 'method_source'
require 'gosu'
require 'flaty/flaty'
require 'math/poly'
require 'math/calculus'

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

    @points = [[0,2],[1,1],[2,2],[3,0],[4,3],[5,0],[6,3],[7,1]]
    @px = 0

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
    move_derivative(-1) if Gosu.button_down? Gosu::KB_A
    move_derivative(1)  if Gosu.button_down? Gosu::KB_D
    zoom(-1) if Gosu.button_down? Gosu::KB_NUMPAD_PLUS
    zoom(1)  if Gosu.button_down? Gosu::KB_NUMPAD_MINUS

    #animate_polynomial
  end

  def draw
    @axis_image.draw(0, 0, 0)
  end

  private

  def zoom(direction)
    @camera.zoom(direction)
    @axis_image = Gosu.render(SCREEN_WIDTH, SCREEN_HEIGHT) { draw_axis }
  end

  def move(direction)
    @camera.move(direction)
    @axis_image = Gosu.render(SCREEN_WIDTH, SCREEN_HEIGHT) { draw_axis }
  end

  def move_derivative(direction)
    precision = (@camera.width / 1000.0).abs
    @px += direction * precision
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

      @label_y = 0
      #draw_fx_and_dydx { |x| Math.sin(x**2) }
      draw_fx_and_dydx { |x| Math.sin(x) }

      #draw_fx(Gosu::Color::GREEN)           { |x| Math.sin(x)                            }
      #draw_fx(Gosu::Color::WHITE)           { |x| derivative_line(x) { |x| x**3 }        }
      #draw_fx(Gosu::Color::FUCHSIA)         { |x| 1.0/(1+Math.exp(-x))                   }
      #draw_fx(Gosu::Color::YELLOW)          { |x| Math.exp(-x)                           }
      #draw_fx(Gosu::Color::BLUE, label: fx) { |x| f.x(x)                                 }
    end
    puts t
  end

  def draw_fx_and_dydx(&block)
    label = format_equation(block.source.scan(/\{ \|x\| (.*) \}/).flatten.first)
    draw_fx(Gosu::Color::BLACK, label: label) { |x| block.call(x) }
    dxdy_label = "dy/dx #{label}"
    draw_fx(Gosu::Color::WHITE, bold: false, label: dxdy_label) do |x|
      Calculus.derivative_line(x, @px, block)
    end
  end

  LINE_THICKNESS = 3
  MIN_PRECISION = 0.000000000001
  def draw_fx(color, opts = {}, &block)
    opts = { bold: true }.merge(opts)
    precision = [(@camera.width / 1000.0).abs, MIN_PRECISION].max

    x2 = @camera.shift_x
    x1 = x2
    y1 = block.call(x1)

    while x2 <= (@camera.shift_x + @camera.width)
      y2 = block.call(x2)
      w = (x2 - x1)
      h = (y2 - y1)
      Flaty.draw_line(x1, y1, color, x2, y2, color, z = 100, mode = :default)
      if opts[:bold]
        Flaty.draw_rect(x1, y1, w, h, color, z = 100, mode = :default, thickness = LINE_THICKNESS)
      end
      x1 = x2
      y1 = y2
      x2 += precision
    end

    draw_equation_label(block, color, opts[:label])
  end

  def draw_equation_label(block, color, label)
    @label_y += 40
    label = format_equation(block.source.scan(/\{ \|x\| (.*) \}/).flatten.first) unless label
    @font.draw_text("#{label}", 20, @label_y, 100, 1.0, 1.0, color)
  end

  def format_equation(eq)
    eq = eq.gsub('**2', '²').gsub('**3', '³').gsub('**', '^').gsub('Math.log', 'ln')
    eq.gsub('Math.', '')
  end
end

game = MathAxis.new
game.show
