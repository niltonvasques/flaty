require "flaty"
require "flaty/math/calculus"

class MathAxis < Flaty::GameWindow
  SCREEN_WIDTH        = 1500
  SCREEN_HEIGHT       = 1500
  CAMERA_WIDTH_UNITS  = 10.0
  CAMERA_HEIGHT_UNITS = 10.0
  SCALE               = SCREEN_WIDTH / CAMERA_WIDTH_UNITS

  def initialize
    super(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS, SCALE, "Math Axis")

    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @camera.look(0, 0)
    update_camera

    axis_colors = { lines: Flaty::Colors::BLACK, text: Flaty::Colors::BLACK }
    @camera_debug = Flaty::CameraDebug.new(@camera, axis_colors)

    @points   = [[0,2],[1,1],[2,2],[3,0],[4,3],[5,0],[6,3],[7,1]]
    @fps_list = [] of Float64
    @px       = 0.0
    @label_y  = 0

    ## assets
    @font      = SF::Font.from_file("assets/Cantarell-Regular.otf")

  #  # caching rendered axis
  #  @axis_image = Gosu.render(SCREEN_WIDTH, SCREEN_HEIGHT) { draw_axis }
  #  @axis_image.save('axis.png')
  end

  def draw(target, states)
    Flaty.paint(Flaty::Colors::GRAY)
    @camera_debug.draw

    @label_y = 0
    draw_fx("sin(x)", Flaty::Colors::GREEN)   { |x| Math.sin(x) }
    draw_fx("1/(1+e^-x)", Flaty::Colors::RED) { |x| 1.0/(1+Math.exp(-x)) }
    draw_fx("e^x", Flaty::Colors::YELLOW)     { |x| Math.exp(-x) }

    draw_fx_and_dydx("sin(x²)") { |x| Math.sin(x**2) }

    @fps_list << (1.0/@delta.as_seconds).round(2)
    @fps_list = @fps_list[2..@fps_list.size] if @fps_list.size > 1000
    fps = "FPS: #{(@fps_list.sum / @fps_list.size).to_i}"
    Flaty.draw_text_in_pixels(@font, fps, SCREEN_WIDTH-(fps.size * 12), 9, 20, Flaty::Colors::GREEN)
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

  def draw_fx_and_dydx(label, &block : Float64 -> Float64)
    draw_fx(label, Flaty::Colors::BLACK) { |x| block.call(x) }
    dxdy_label = "dy/dx #{label}"
    draw_fx(dxdy_label, Flaty::Colors::WHITE) do |x|
      Calculus.derivative_line(x, @px.to_f, block)
    end
  end

  LINE_THICKNESS = 3
  MIN_PRECISION = 0.000000000001
  def draw_fx(label, color, &block : Float64 -> Float64)
  #  opts = { bold: true }.merge(opts)
    precision = Math.max((@camera.width / 1000.0).abs, MIN_PRECISION)

    x2 = @camera.rect.x
    x1 = x2
    y1 = block.call(x1)

    while x2 <= (@camera.rect.x + @camera.width)
      y2 = block.call(x2)
      w = (x2 - x1)
      h = (y2 - y1)
      #puts "#{x1} x1 #{y1} x2 #{x2} x2 #{y2} y2"
      unless y1 > (@camera.rect.y + @camera.height) || y1 < @camera.rect.y
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

game = MathAxis.new
game.loop
