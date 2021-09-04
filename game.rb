require 'gosu'
require './background'
require './bird'

class GameWindow < Gosu::Window
  SCREEN_WIDTH   = 1280
  SCREEN_HEIGHT  = 720

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, fullscreen: false)
    self.caption = "Ruby Game Demo"

    @background = Background.new
    @bird = Bird.new
  end

  def update
    @background.update
    @bird.update
  end

  def draw
    @background.draw
    @bird.draw
  end
end

window = GameWindow.new
window.show
