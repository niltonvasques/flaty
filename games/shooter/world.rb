require 'gosu'
require 'pry-byebug'
require 'flaty/flaty'
require 'games/shooter/hud'
require 'games/shooter/background'
require 'games/shooter/bird'
require 'games/shooter/bob'
require 'games/shooter/star'
require 'games/shooter/level_loader'

module ZLayers
  BG, TILE, STARS, PLAYER, UI = *0..4
end

class World
  CAMERA_WIDTH_UNITS  = 50
  CAMERA_HEIGHT_UNITS = 28

  attr_accessor :level, :stars, :world

  def initialize
    @camera = GameWindow.camera
    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @camera.bounds.x = CAMERA_WIDTH_UNITS / 2.0
    @camera.bounds.y = CAMERA_HEIGHT_UNITS / 2.0
    @camera.look(CAMERA_WIDTH_UNITS / 2.0, CAMERA_HEIGHT_UNITS / 2.0)
    @camera_debug = CameraDebug.new(@camera)

    # objects
    @world = Physics::World.new
    @background = Background.new
    @bob = Bob.new
    @bird = Bird.new
    @hud = HUD.new
    @world.bodies << @bob
    @world.bodies << @bird
  end

  def level=(level)
    @level = level
    @world.bodies += @level.tiles
  end

  def update
    @level.tiles.each { |tile| tile.debug = Gosu::Color::GREEN } if GameWindow.debug

    @world.update

    @level.stars.each(&:update)
    @bob.collect_stars(@level.stars)
    GameWindow.camera.look(@bob.x, @bob.y)

    @background.update(@bob.speed) if GameWindow.camera.position.x == @bob.x

    @hud.update(@bob.score)
  end

  def draw
    @background.draw

    @bob.draw
    @bird.draw

    @level.stars.each(&:draw)
    @level.tiles.each(&:draw)

    @hud.draw

    if GameWindow.debug
      @camera_debug.draw
      @world.draw_quad
    end
  end

  def pause
    @bob.pause
  end

  def play
    @bob.play
  end
end
