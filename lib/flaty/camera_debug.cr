require "flaty"

class CameraDebug
  DEFAULT_COLORS = {
    origin: Flaty::Colors::RED,
    lines: Flaty::Colors::YELLOW,
    text: Flaty::Colors::WHITE
  }
  @colors : NamedTuple(origin: SF::Color, lines: SF::Color, text: SF::Color)
  @step = 1_f32

  def initialize(@camera : Camera, colors)
    @colors = DEFAULT_COLORS.merge(colors)
    @font   = SF::Font.from_file("assets/Cantarell-Regular.otf")
  end

  def draw
    update_step

    draw_origin
    draw_rows
    draw_columns
  end

  #private

  def update_step
    @step = @camera.width / 100_f32
    if @camera.width > 2
      @step = @step.ceil
    else
      @step = @camera.width / 10_f32
    end
  end

  def draw_origin
    x = @camera.shift_x.floor
    y = @camera.shift_y.floor
    Flaty.draw_line(0, y, 0, y + @camera.height + 1, @colors[:origin])
    Flaty.draw_line(x, 0, x + @camera.width + 1, 0, @colors[:origin])
  end

  def draw_rows
    x = @camera.shift_x.floor
    y = @camera.shift_y.floor
    while y <= (@camera.shift_y + @camera.height.ceil + 1)
      if y == 0
        y += @step
        next
      end
      Flaty.draw_line(x, y, x + @camera.width + 1, y, @colors[:lines])
      tx = @camera.shift_x * @camera.scale
      ty = y * @camera.scale
      Flaty.draw_text(@font, "#{format(y)}", tx, ty, 20, @colors[:text])
      y += @step
    end
  end

  def draw_columns
    x = @camera.shift_x.floor
    y = @camera.shift_y.floor
    while x <= (@camera.shift_x + @camera.width.ceil)
      if x == 0
        x += @step
        next
      end
      Flaty.draw_line(x, y, x, y + @camera.height + 1, @colors[:lines])
      tx = x * @camera.scale
      ty = (@camera.shift_y + @camera.height) * @camera.scale
      Flaty.draw_text(@font, "#{format(x)}", tx, ty, 20, @colors[:text])
      x += @step
    end
  end

  def format(x)
    return ("%.5f" % x) if @camera.width < 2
    x
  end
end
