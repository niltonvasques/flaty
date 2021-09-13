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
    center_x = @camera.position.x.to_i
    center_y = @camera.position.y.to_i
    (center_x - @camera.width.to_i).upto(center_x + @camera.width.to_i) do |x|
      color = x == 0 ? @colors[:origin] : @colors[:lines]
      new_x = @camera.translate_x(x)
      Gosu.draw_line(new_x, 0, color, new_x, GameWindow.height, color, z = Z, mode = :default)
      @font.draw_text("#{x}", new_x + 5, 5, Z, 1.0, 1.0, @colors[:text])
    end
    (center_y - @camera.height.to_i).upto(center_y + @camera.height.to_i) do |y|
      color = y == 0 ? @colors[:origin] : @colors[:lines]
      new_y = @camera.translate_y(y)
      Gosu.draw_line(0, new_y, color, GameWindow.width, new_y, color, z = Z, mode = :default)
      @font.draw_text("#{y}", 5, new_y - 15, Z, 1.0, 1.0, @colors[:text])
    end
  end
end
