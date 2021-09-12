class CameraDebug
  Z = 100
  def initialize(camera)
    @camera = camera
    @font = Gosu::Font.new(15)
  end

  def draw
    origin_color = Gosu::Color::RED
    yellow = Gosu::Color::YELLOW
    center_x = @camera.position.x.to_i
    center_y = @camera.position.y.to_i
    (center_x - @camera.width).upto(center_x + @camera.width) do |x|
      color = x == 0 ? origin_color : yellow
      new_x = @camera.translate_x(x)
      Gosu.draw_line(new_x, 0, color, new_x, GameWindow.height, color, z = Z, mode = :default)
      @font.draw_text("#{x}", new_x + 10, 10, Z, 1.0, 1.0, Gosu::Color::WHITE)
    end
    (center_y - @camera.height).upto(center_y + @camera.height) do |y|
      color = y == 0 ? origin_color : yellow
      new_y = @camera.translate_y(y)
      Gosu.draw_line(0, new_y, color, GameWindow.width, new_y, color, z = Z, mode = :default)
      @font.draw_text("#{y}", 10, new_y, Z, 1.0, 1.0, Gosu::Color::WHITE)
    end
  end
end
