require 'gosu'
require 'pry-byebug'
require './background'
require './bird'
require './star'

module ZLayers
  BG, STARS, PLAYER, UI = *0..3
end

class GameWindow < Gosu::Window
  SCREEN_WIDTH   = 1280
  SCREEN_HEIGHT  = 720

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, fullscreen: false)
    self.caption = "Ruby Falcon in the Dusk"

    # assets
    @star_anim = Gosu::Image.load_tiles("assets/star.png", 25, 25)
    @font = Gosu::Font.new(20)
    @song = Gosu::Song.new('assets/sounds/dusk_theme.mp3')
    @song.play

    # state
    @paused = false
    @paused_at = 0

    # objects
    @background = Background.new
    @bird = Bird.new
    @stars = Array.new
  end

  def update
    return if paused?

    @bird.update
    @stars.each { |star| star.update(@bird.speed) }
    @background.update(@bird.speed)

    @bird.collect_stars(@stars)

    if rand(100) < 4 and @stars.size < 10
      @stars.push(Star.new(@star_anim))
    end

    @stars.reject! { |star| star.x < 0 }
  end

  def draw
    draw_ui

    @background.draw

    return if @paused

    @bird.draw
    @stars.each { |star| star.draw }
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    else
      super
    end
  end

  private

  def draw_ui
    @font.draw_text("FPS: #{Gosu.fps}", 10, 10, ZLayers::UI, 1.0, 1.0, Gosu::Color::GREEN)
    @font.draw_text("Score: #{@bird.score}", SCREEN_WIDTH - 100, 10, ZLayers::UI, 1.0, 1.0, Gosu::Color::RED)
  end

  def paused?
    if Gosu.button_down? Gosu::KB_P
      if (Gosu.milliseconds - @paused_at) > 1000
        @paused = !@paused
        @paused_at = Gosu.milliseconds
        if @paused
          @song.pause
          @bird.pause
        else
          @song.play
          @bird.play
        end
      end
    end
    @paused
  end
end

window = GameWindow.new
window.show
