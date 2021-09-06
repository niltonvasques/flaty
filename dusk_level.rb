require 'gosu'
require 'pry-byebug'
require './background'
require './bird'
require './star'
require './level_loader'

module ZLayers
  BG, TILE, STARS, PLAYER, UI = *0..4
end

class DuskLevel
  def initialize
    # assets
    @font = Gosu::Font.new(20)
    @song = Gosu::Song.new('assets/sounds/dusk_theme.mp3')
    @song.play

    @level = Level.new

    # objects
    @background = Background.new
    @bird = Bird.new
    @stars = Array.new
  end

  def update
    @bird.update
    @background.update(@bird.speed)
    @level.update(@bird.speed)

    @bird.collect_stars(@level.stars)
  end

  def draw
    draw_ui

    @background.draw

    @bird.draw

    @level.draw
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
