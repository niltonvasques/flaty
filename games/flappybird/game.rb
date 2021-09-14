unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__) + '/../..'))
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../..'))
end

require 'gosu'
require 'pry-byebug'
require 'flaty/flaty'
require 'games/flappybird/world'
require 'games/flappybird/level_loader'

class FlappyBird < GameWindow
  SCREEN_WIDTH   = 1280
  SCREEN_HEIGHT  = 720

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, fullscreen: false)
    self.caption = "Flappy Bird in the Dusk"

    # assets
    @font = Gosu::Font.new(25)

    @world = World.new
    LevelLoader.generate(@world)
  end

  def update
    super
    return if paused?

    @world.update
  end

  def draw
    @world.draw

    if @world.game_over
      x = GameWindow.width / 2 - GameWindow.camera.unit_x
      @font.draw_text("GAME OVER", x, 10, 10, 2.0, 2.0, Gosu::Color::RED, mode = :default)
    end
  end

  def button_down(id)
    if id == Gosu::KB_R
      @world.restart
      LevelLoader.generate(@world)
    else
      super
    end
  end
end

window = FlappyBird.new
window.show
