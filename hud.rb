class HUD
  def initialize
    @font = Gosu::Font.new(20)
    @score = 0
  end

  def update(score = 0)
    @score = score
  end

  def draw
    @font.draw_text("FPS: #{Gosu.fps}", 10, 10, ZLayers::UI, 1.0, 1.0, Gosu::Color::GREEN)
    @font.draw_text("Score: #{@score}", GameWindow::SCREEN_WIDTH - 100, 10,
                    ZLayers::UI, 1.0, 1.0, Gosu::Color::RED)
  end
end
