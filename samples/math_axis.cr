require "flaty"
require "flaty/fps"
require "flaty/math/calculus"

class MathAxis < Flaty::GameWindow
  SCREEN_WIDTH        = 1500
  SCREEN_HEIGHT       = 1500
  CAMERA_WIDTH_UNITS  = 10.0
  CAMERA_HEIGHT_UNITS = 10.0
  SCALE               = SCREEN_WIDTH / CAMERA_WIDTH_UNITS

  def initialize(@dataset = [] of {Float64, Float64})
    super(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS, SCALE, "Math Axis")

    ## assets
    @font      = SF::Font.from_file("assets/Cantarell-Regular.otf")

    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @camera.look(0, 0)
    update_camera

    axis_colors = { lines: Flaty::Colors::BLACK, text: Flaty::Colors::BLACK }
    @camera_debug = Flaty::CameraDebug.new(@camera, axis_colors)
    @fps = Flaty::FPS.new(SCREEN_WIDTH, @font)

    @px       = 0.0
    @label_y  = 0
  end

  def draw(target, states)
    Flaty.paint(Flaty::Colors::GRAY)
    @camera_debug.draw

    @label_y = 0
    draw_dataset
    if @dataset.empty?
      #draw_fx("sin(x)", Flaty::Colors::GREEN)   { |x| Math.sin(x) }
      draw_fx("1/(1+e^-x) sigmoid", Flaty::Colors::BLUE) { |x| 1.0/(1+Math.exp(-x)) }
      draw_fx("2/(1+e^(-2x))-1 tanh", Flaty::Colors::YELLOW) { |x| (2.0/(1+Math.exp(-2*x))) - 1 }
      #draw_fx("Leaky ReLU", Flaty::Colors::BLACK)     { |x| (x >= 0 ? x : 0.01 * x) }
      draw_fx("max(0,x) ReLU", Flaty::Colors::GREEN)     { |x| Math.max(0, x).to_f }
      draw_fx("e^x", Flaty::Colors::RED)     { |x| Math.exp(-x) }
    end

    #draw_fx_and_dydx("sin(x²)") { |x| Math.sin(x**2) }
    #draw_fx_and_dydx("sin(x)", Flaty::Colors::GREEN) { |x| Math.sin(x) }

    @fps.draw(@delta)
  end

  def button_down(code)
    @camera.key_pressed(self, code)

    case code
    when .a? then move_derivative(-1)
    when .d? then move_derivative(+1)
    end
  end

  def move_derivative(direction : Int32)
    precision = (@camera.width / 1000.0).abs
    @px += direction * precision
  end

  def draw_fx_and_dydx(label, color, &block : Float64 -> Float64)
    draw_fx(label, color) { |x| block.call(x) }
    dxdy_label = "dy/dx #{label}"
    draw_fx(dxdy_label, Flaty::Colors::WHITE) do |x|
      Calculus.derivative_line(x, @px.to_f, block)
    end
  end

  def draw_dataset
    return if @dataset.empty?

    max = @dataset.map { |row| row[0] }.max

    x1 = (@dataset[0][0] / max) * 5
    y1 = @dataset[0][1] * 5
    @dataset[1..-1].each do |tuple|
      x2, y2 = tuple
      x2 = (x2 / max) * 5
      y2 *= 5
      Flaty.draw_line(x1, y1, x2, y2, Flaty::Colors::GREEN)
      x1 = x2
      y1 = y2
    end
  end

  LINE_THICKNESS = 3
  MIN_PRECISION = 0.000000000001
  def draw_fx(label, color, &block : Float64 -> Float64)
    precision = Math.max((@camera.width / 1000.0).abs, MIN_PRECISION)

    x2 = @camera.rect.x
    x1 = x2
    y1 = block.call(x1)

    while x2 <= (@camera.rect.x + @camera.width)
      y2 = block.call(x2)
      w = (x2 - x1)
      h = (y2 - y1)
      if y1 < (@camera.rect.y + @camera.height) && y1 > @camera.rect.y
        Flaty.draw_line(x1, y1, x2, y2, color)
      end
      x1 = x2
      y1 = y2
      x2 += precision
    end

    draw_equation_label(label, color)
  end

  def draw_equation_label(label, color)
    @label_y += 40
    Flaty.draw_text_in_pixels(@font, label, 9, @label_y, 24, color)
  end
end

dataset = [] of {Float64, Float64}
if ARGV.size > 0 && ARGV[0] == "-stdin"
  while line = gets
    entries = line.split(",")
    dataset << {entries[0].to_f, entries[1].to_f}
  end
end

game = MathAxis.new(dataset)
game.loop
