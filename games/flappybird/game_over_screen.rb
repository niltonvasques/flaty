class GameOverScreen
  attr_accessor :score

  def initialize
    @font = Gosu::Font.new(20)
    self.score = 0
  end

  def update
  end

  def draw
    @font.draw_text("Score: #{self.score}", GameWindow::SCREEN_WIDTH - 100, 10,
                    ZLayers::UI, 1.0, 1.0, Gosu::Color::GREEN)
    @font.draw_text("GAME OVER!!", 100, GameWindow::SCREEN_HEIGHT / 2,
                    ZLayers::UI, 2.0, 2.0, Gosu::Color::RED)
  end
end
