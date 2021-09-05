require 'gosu'
require 'pry-byebug'
require './background'
require './bird'
require './star'
require './level_loader'

module ZLayers
  BG, STARS, PLAYER, UI = *0..3
end

class DuskLevel
  def initialize
    # assets
    @star_anim = Gosu::Image.load_tiles("assets/star.png", 25, 25)
    @font = Gosu::Font.new(20)
    @song = Gosu::Song.new('assets/sounds/dusk_theme.mp3')
    @song.play

    @level_tiles = Level.new

    # objects
    @background = Background.new
    @bird = Bird.new
    @stars = Array.new
  end

  def update
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

    @bird.draw
    @stars.each { |star| star.draw }

    @level_tiles.draw
  end

  def pause
    @song.pause
    @bird.pause
  end

  def play
    @song.play
    @bird.play
  end

  private

  def draw_ui
    @font.draw_text("FPS: #{Gosu.fps}", 10, 10, ZLayers::UI, 1.0, 1.0, Gosu::Color::GREEN)
    @font.draw_text("Score: #{@bird.score}", GameWindow::SCREEN_WIDTH - 100, 10,
                    ZLayers::UI, 1.0, 1.0, Gosu::Color::RED)
  end
end
