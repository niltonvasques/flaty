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
    @camera = GameWindow.camera
    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    #GameWindow.camera.bounds.x = CAMERA_WIDTH_UNITS / 2.0
    @camera.bounds.y = CAMERA_HEIGHT_UNITS / 2.0
    @camera.look(CAMERA_WIDTH_UNITS / 2.0, CAMERA_HEIGHT_UNITS / 2.0)

    # objects
    @background = Background.new
    @bird = Bob.new
    @hud = HUD.new
    self.stars = Array.new

    @font = Gosu::Font.new(15)
  end

  def update
    self.level.tiles.each { |tile| tile.debug = Gosu::Color::GREEN } if GameWindow.debug

    @bird.update

    Physics.solve_collisions(@bird, @level)

    self.stars.each(&:update)
    @bird.collect_stars(stars)
    GameWindow.camera.look(@bird.x, @bird.y)
    #puts "#{GameWindow.camera.position} - #{GameWindow.camera.width}, #{GameWindow.camera.height}"

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
    origin_color = Gosu::Color::RED
    yellow = Gosu::Color::YELLOW
    center_x = @camera.position.x.to_i
    center_y = @camera.position.y.to_i
    (center_x - @camera.width).upto(center_x + @camera.width) do |x|
      color = x == 0 ? origin_color : yellow
      new_x = @camera.translate_x(x)
      Gosu.draw_line(new_x, 0, color, new_x, GameWindow.height, color, z = 100, mode = :default)
      @font.draw_text("#{x}", new_x + 10, 10, ZLayers::UI, 1.0, 1.0, Gosu::Color::WHITE)
    end
    (center_y - @camera.height).upto(center_y + @camera.height) do |y|
      color = y == 0 ? origin_color : yellow
      new_y = @camera.translate_y(y)
      Gosu.draw_line(0, new_y, color, GameWindow.width, new_y, color, z = 100, mode = :default)
      @font.draw_text("#{y}", 10, new_y, ZLayers::UI, 1.0, 1.0, Gosu::Color::WHITE)
    end
  end
end
