require 'gosu'
require 'pry-byebug'
require './engine/camera'
require './hud'
require './background'
require './bird'
require './bob'
require './star'
require './level_loader'
require './engine/math/vector_2d'
require 'engine/math/rect'

module ZLayers
  BG, TILE, STARS, PLAYER, UI = *0..4
end

class World
  CAMERA_WIDTH_UNITS  = 50
  CAMERA_HEIGHT_UNITS = 28

  attr_accessor :level, :stars

  def initialize
    # objects
    @background = Background.new
    @bird = Bob.new
    @hud = HUD.new
    self.stars = Array.new
  end

  def update
    self.level.tiles.each { |tile| tile.debug = Gosu::Color::GREEN } if GameWindow.debug

    @bird.update

    Physics.solve_collisions(@bird, @level)

    self.stars.each(&:update)
    @bird.collect_stars(stars)
    GameWindow.camera.look(@bird.x, @bird.y)

    @background.update(@bird.speed) if GameWindow.camera.position.x == @bird.x

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
    GameWindow.camera.width.times do |x|
      Gosu.draw_line(x * GameWindow.camera.unit_x, 0, color, x * GameWindow.camera.unit_x, GameWindow.height, color, z = 100, mode = :default)
    end
    GameWindow.camera.height.times do |y|
      Gosu.draw_line(0, y * GameWindow.camera.unit_y, color, GameWindow.width, y * GameWindow.camera.unit_y, color, z = 100, mode = :default)
    end
  end
end
