require 'gosu'
require 'pry-byebug'
require './dusk_level'

class GameWindow < Gosu::Window
  SCREEN_WIDTH   = 1280
  SCREEN_HEIGHT  = 720

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, fullscreen: false)
    self.caption = "Ruby Falcon in the Dusk"

    @dusk_level = DuskLevel.new
  end

  def update
    @dusk_level.update
  end

  def draw
    @dusk_level.draw
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    else
      super
    end
  end
end

window = GameWindow.new
window.show
