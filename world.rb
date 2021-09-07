require 'gosu'
require 'pry-byebug'
require './background'
require './bird'
require './star'
require './level_loader'

module ZLayers
  BG, TILE, STARS, PLAYER, UI = *0..4
end

class Camera
  attr_accessor :width, :height, :x, :y

  def initialize(width, height)
    self.width = width
    self.height = height
    self.x = self.y = 0
  end

  def look(x, y)
    self.x = x
    self.y = y
  end
end

class World
  CAMERA_WIDTH_UNITS  = 50
  CAMERA_HEIGHT_UNITS = 28

  attr_accessor :tiles, :stars

  def initialize
    @camera = Camera.new(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)

    # assets
    @font = Gosu::Font.new(20)
    @song = Gosu::Song.new('assets/sounds/dusk_theme.mp3')
    @song.play

    # objects
    @background = Background.new
    @bird = Bird.new
    self.stars = Array.new
    self.tiles = Array.new
  end

  def update
    @bird.update

    self.stars.each { |star| star.update(@bird.speed) }
    self.tiles.each { |tile| tile.update(@bird.speed) }

    @background.update(@bird.speed)

    @bird.collect_stars(stars)
  end

  def draw
    draw_ui

    @background.draw

    @bird.draw

    self.stars.each(&:draw)
    self.tiles.each(&:draw)
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
