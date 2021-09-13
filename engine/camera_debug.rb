class CameraDebug
  Z = 100
  def initialize(camera, colors = {})
    @colors = {
      origin: Gosu::Color::RED,
      lines: Gosu::Color::YELLOW,
      text: Gosu::Color::WHITE
    }.merge(colors)
    @camera = camera
    @font = Gosu::Font.new(15)
  end

  def draw
    update_step

    draw_origin
    draw_rows
    draw_columns
  end

  private

  def update_step
    @step = @camera.width / 100.0
    if @camera.width > 2
      @step = @step.ceil
    else
      @step = @camera.width / 10.0
    end
    @center_x = @camera.position.x.to_i
    @center_y = @camera.position.y.to_i
  end

  def draw_origin
    new_x = @camera.translate_x(0)
    Gosu.draw_line(new_x, 0, @colors[:origin], new_x, GameWindow.height, @colors[:origin], Z)
    @font.draw_text('0', new_x + 5, 5, Z, 1.0, 1.0, @colors[:text])

    new_y = @camera.translate_y(0)
    Gosu.draw_line(0, new_y, @colors[:origin], GameWindow.width, new_y, @colors[:origin], Z)
    @font.draw_text('0', 5, new_y - 15, Z, 1.0, 1.0, @colors[:text])
  end

  def draw_rows
    y = (@center_y - @camera.height.ceil)
    while y <= (@center_y + @camera.height.ceil)
      y += @step and next if y == 0
      new_y = @camera.translate_y(y)
      Gosu.draw_line(0, new_y, @colors[:lines], GameWindow.width, new_y, @colors[:lines], Z)
      @font.draw_text("#{format(y)}", 5, new_y - 15, Z, 1.0, 1.0, @colors[:text])
      y += @step
    end
  end

  def draw_columns
    x = (@center_x - @camera.width.ceil)
    while x <= (@center_x + @camera.width.ceil)
      x += @step and next if x == 0
      new_x = @camera.translate_x(x)
      Gosu.draw_line(new_x, 0, @colors[:lines], new_x, GameWindow.height, @colors[:lines], Z)
      @font.draw_text("#{format(x)}", new_x + 5, 5, Z, 1.0, 1.0, @colors[:text])
      x += @step
    end
  end

  def format(x)
    return ('%.5f' % x) if @camera.width < 2
    x
  end
end
