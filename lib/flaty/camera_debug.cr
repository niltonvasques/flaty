require "flaty"

class Flaty::CameraDebug
  DEFAULT_COLORS = {
    origin: Flaty::Colors::RED,
    lines: Flaty::Colors::YELLOW,
    text: Flaty::Colors::WHITE
  }
  @colors : NamedTuple(origin: SF::Color, lines: SF::Color, text: SF::Color)
  @step = 1.0

  def initialize(@camera : Camera, colors)
    @colors = DEFAULT_COLORS.merge(colors)
    @font   = SF::Font.from_file("assets/Cantarell-Regular.otf")
  end

  def draw
    update_step

    draw_rows
    draw_columns
    draw_origin
  end

  def update_step
    @step = @camera.width / 100.0
    return @step = @step.ceil if @camera.width > 2
    return @step = 0.1 if @camera.width > 0.4
    @step = 0.01
  end

  def draw_origin
    x = @camera.rect.x.floor
    y = @camera.rect.y.floor
    Flaty.draw_line(0, y, 0, y + @camera.height + 1, @colors[:origin])
    Flaty.draw_line(x, 0, x + @camera.width + 1, 0, @colors[:origin])
  end

  def draw_rows
    x = @camera.rect.x.floor
    y = @camera.rect.y.floor
    while y <= (@camera.rect.y + @camera.height.ceil + 1)
      if y == 0
        y += @step
        next
      end
      Flaty.draw_line(x, y, x + @camera.width + 1, y, @colors[:lines])
      Flaty.draw_text_world(@font, "#{format(y)}", @camera.rect.x, y, 15, @colors[:text])
      y += @step
    end
  end

  def draw_columns
    x = @camera.rect.x.floor
    y = @camera.rect.y.floor
    while x <= (@camera.rect.x + @camera.width.ceil)
      if x == 0
        x += @step
        next
      end
      Flaty.draw_line(x, y, x, y + @camera.height + 1, @colors[:lines])
      ty = (@camera.rect.y + @camera.height)
      Flaty.draw_text_world(@font, "#{format(x)}", x, ty, 15, @colors[:text])
      x += @step
    end
  end

  def format(x)
    return ("%.2f" % x) if @camera.width < 2
    x
  end
end
