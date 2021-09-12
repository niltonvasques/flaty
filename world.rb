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
require 'engine/camera_debug'

module ZLayers
  BG, TILE, STARS, PLAYER, UI = *0..4
end

class World
  CAMERA_WIDTH_UNITS  = 50
  CAMERA_HEIGHT_UNITS = 28

  attr_accessor :level, :stars

  def initialize
    @camera = GameWindow.camera
    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    #GameWindow.camera.bounds.x = CAMERA_WIDTH_UNITS / 2.0
    @camera.bounds.y = CAMERA_HEIGHT_UNITS / 2.0
    @camera.look(CAMERA_WIDTH_UNITS / 2.0, CAMERA_HEIGHT_UNITS / 2.0)
    @camera_debug = CameraDebug.new(@camera)

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
    #puts "#{GameWindow.camera.position} - #{GameWindow.camera.width}, #{GameWindow.camera.height}"

    @background.update(@bird.speed) if GameWindow.camera.position.x == @bird.x

    @hud.update(@bird.score)
  end

  def draw
    @background.draw

    @bird.draw

    self.stars.each(&:draw)
    self.level.tiles.each(&:draw)

    @hud.draw

    @camera_debug.draw if GameWindow.debug
  end

  def pause
    @bird.pause
  end

  def play
    @bird.play
  end
end
