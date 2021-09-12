require 'gosu'
require 'pry-byebug'
require './engine/camera'
require './hud'
require './background'
require './bird'
require './bob'
require './star'
require './level_loader'
require './vector_2d'
require './rect'

module ZLayers
  BG, TILE, STARS, PLAYER, UI = *0..4
end

class World
  SCREEN_WIDTH   = 1280
  SCREEN_HEIGHT  = 720
  CAMERA_WIDTH_UNITS  = 50
  CAMERA_HEIGHT_UNITS = 28
  UNIT_X = SCREEN_WIDTH / CAMERA_WIDTH_UNITS.to_f
  UNIT_Y = SCREEN_HEIGHT / CAMERA_HEIGHT_UNITS.to_f

  attr_accessor :level, :stars

  def initialize
    @@camera = Camera.new(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @@camera.look(CAMERA_WIDTH_UNITS / 2.0, CAMERA_HEIGHT_UNITS / 2.0)

    # objects
    @background = Background.new
    @bird = Bob.new
    @hud = HUD.new
    self.stars = Array.new
  end

  def self.camera
    @@camera
  end

  def update
    self.level.tiles.each { |tile| tile.debug = Gosu::Color::GREEN } if GameWindow.debug

    @bird.update

    Physics.solve_collisions(@bird, @level)

    self.stars.each(&:update)
    @bird.collect_stars(stars)
    @@camera.look(@bird.x, @bird.y)

    @background.update(@bird.speed) if @@camera.position.x == @bird.x

    @hud.update(@bird.score)
  end

  def draw
    @background.draw

    @bird.draw

    self.stars.each(&:draw)
    self.level.tiles.each(&:draw)

    draw_grid if GameWindow.debug

    @hud.draw
  end

  def pause
    @bird.pause
  end

  def play
    @bird.play
  end

  private

  def draw_grid
    color = Gosu::Color::YELLOW
    CAMERA_WIDTH_UNITS.times do |x|
      Gosu.draw_line(x * UNIT_X, 0, color, x * UNIT_X, SCREEN_HEIGHT, color, z = 100, mode = :default)
    end
    CAMERA_HEIGHT_UNITS.times do |y|
      Gosu.draw_line(0, y * UNIT_Y, color, SCREEN_WIDTH, y * UNIT_Y, color, z = 100, mode = :default)
    end
  end
end
