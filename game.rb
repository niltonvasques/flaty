require 'gosu'
require 'pry-byebug'
require './background'
require './bird'

module ZLayers
  BG, PLAYER, UI = *0..2
end

class GameWindow < Gosu::Window
  SCREEN_WIDTH   = 1280
  SCREEN_HEIGHT  = 720

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, fullscreen: false)
    self.caption = "Ruby Game Demo"

    @background = Background.new
    @bird = Bird.new
    @font = Gosu::Font.new(20)
  end

  def update
    @background.update
    @bird.update
  end

  def draw
    draw_fps
    @background.draw
    @bird.draw
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    else
      super
    end
  end

  private

  def draw_fps
    @font.draw_text("FPS: #{Gosu.fps}", 10, 10, ZLayers::UI, 1.0, 1.0, Gosu::Color::GREEN)
  end
end

window = GameWindow.new
window.show
