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

  #CAMERA_WIDTH_UNITS  = 28
  #CAMERA_HEIGHT_UNITS = 14

  attr_accessor :level, :stars

  def initialize
    # objects
    @background = Background.new
    @bird = Bob.new
    @hud = HUD.new
    self.stars = Array.new

    puts GameWindow.camera.unit_x

    GameWindow.camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    #GameWindow.camera.bounds.x = CAMERA_WIDTH_UNITS / 2.0
    GameWindow.camera.bounds.y = CAMERA_HEIGHT_UNITS / 2.0
    GameWindow.camera.look(CAMERA_WIDTH_UNITS / 2.0, CAMERA_HEIGHT_UNITS / 2.0)
  end

  def update
    self.level.tiles.each { |tile| tile.debug = Gosu::Color::GREEN } if GameWindow.debug

    @bird.update

    Physics.solve_collisions(@bird, @level)

    self.stars.each(&:update)
    @bird.collect_stars(stars)
    GameWindow.camera.look(@bird.x, @bird.y)
    puts "#{GameWindow.camera.position} - #{GameWindow.camera.width}, #{GameWindow.camera.height}"

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
    first = Gosu::Color::RED
    color = Gosu::Color::YELLOW
    (GameWindow.camera.width * -1).upto(0) do |x|
      new_x = GameWindow.camera.translate_x(x)
      Gosu.draw_line(new_x, 0, color, new_x, GameWindow.height, color, z = 100, mode = :default)
    end
    GameWindow.camera.width.times do |x|
      c = x < 1 ? first : color
      new_x = GameWindow.camera.translate_x(x)
      Gosu.draw_line(new_x, 0, c, new_x, GameWindow.height, c, z = 100, mode = :default)
    end
    (GameWindow.camera.height * -1).upto(0) do |y|
      new_y = GameWindow.camera.translate_y(y)
      Gosu.draw_line(0, new_y, color, GameWindow.width, new_y, color, z = 100, mode = :default)
    end
    GameWindow.camera.height.times do |y|
      c = y < 1 ? first : color
      new_y = GameWindow.camera.translate_y(y)
      Gosu.draw_line(0, new_y, c, GameWindow.width, new_y, c, z = 100, mode = :default)
    end
  end
end
