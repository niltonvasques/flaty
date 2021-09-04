require 'gosu'
require './background'

class GameWindow < Gosu::Window
  SCREEN_WIDTH   = 1280
  SCREEN_HEIGHT  = 720

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, fullscreen: false)
    self.caption = "Ruby Game Demo"

    @background = Background.new

  end

  def update
  end

  def draw
    x = 0
    y = 0
    z = 0

    @background.draw
  end
end

window = GameWindow.new
window.show
