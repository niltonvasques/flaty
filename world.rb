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
    @camera.bounds.x = CAMERA_WIDTH_UNITS / 2.0
    @camera.bounds.y = CAMERA_HEIGHT_UNITS / 2.0
    @camera.look(CAMERA_WIDTH_UNITS / 2.0, CAMERA_HEIGHT_UNITS / 2.0)
    @camera_debug = CameraDebug.new(@camera)

    # objects
    @background = Background.new
    @bob = Bob.new
    @bird = Bird.new
    @hud = HUD.new
    self.stars = Array.new
  end

  def update
    self.level.tiles.each { |tile| tile.debug = Gosu::Color::GREEN } if GameWindow.debug

    @bob.update
    @bird.update

    Physics.solve_collisions(@bob, @level.around(@bob.collision_rect))
    Physics.solve_collisions(@bird, @level.around(@bird.collision_rect))
    if @bob.colliding?(@bird) != Collision::NONE
      Physics.solve_collision(@bird, @bob)
      Physics.solve_collision(@bob, @bird)
    end

    self.stars.each(&:update)
    @bob.collect_stars(stars)
    GameWindow.camera.look(@bob.x, @bob.y)
    #puts "#{GameWindow.camera.position} - #{GameWindow.camera.width}, #{GameWindow.camera.height}"

    @background.update(@bob.speed) if GameWindow.camera.position.x == @bob.x

    @hud.update(@bob.score)
  end

  def draw
    @background.draw

    @bob.draw
    @bird.draw

    self.stars.each(&:draw)
    self.level.tiles.each(&:draw)

    @hud.draw

    @camera_debug.draw if GameWindow.debug
  end

  def pause
    @bob.pause
  end

  def play
    @bob.play
  end
end
