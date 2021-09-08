require 'gosu'
require 'pry-byebug'
require './background'
require './bird'
require './star'
require './level_loader'
require './vector_2d'
require './rect'

module ZLayers
  BG, TILE, STARS, PLAYER, UI = *0..4
end

class Camera
  NOT_BOUNDED = -1
  attr_accessor :width, :height, :position, :bounds

  def initialize(width, height)
    self.width = width
    self.height = height
    self.bounds = Rect[(width / 2), (height / 2), NOT_BOUNDED, NOT_BOUNDED]
    look(width / 2, height / 2)
  end

  def look(x, y)
    y = self.bounds.y if self.bounds.y != NOT_BOUNDED and y > self.bounds.y
    x = self.bounds.x if self.bounds.x != NOT_BOUNDED and x < self.bounds.x
    x = self.bounds.width if self.bounds.width != NOT_BOUNDED and x > self.bounds.width
    self.position = Vector2d[x.to_f, y.to_f]
  end

  def width_pixels
    self.width * World::UNIT_X
  end

  def height_pixels
    self.height * World::UNIT_Y
  end

  def shift_x
    self.position.x - (self.width / 2)
  end

  def shift_y
    self.position.y - (self.height / 2)
  end

  def pixel_to_unit_x(w)
    w / World::UNIT_X.to_f
  end

  def pixel_to_unit_y(h)
    h / World::UNIT_Y.to_f
  end

  def translate_x(x)
    (x - shift_x) * World::UNIT_X
  end

  def translate_y(y)
    (y - shift_y) * World::UNIT_X
  end
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

    # assets
    @font = Gosu::Font.new(20)
    @song = Gosu::Song.new('assets/sounds/dusk_theme.mp3')
    @song.play

    # objects
    @background = Background.new
    @bird = Bird.new
    self.stars = Array.new
  end

  def self.camera
    @@camera
  end

  def update
    self.level.tiles.each { |tile| tile.debug = Gosu::Color::GREEN } if GameWindow.debug

    @bird.update

    Collision.update_collisions(@bird, @level)

    self.stars.each(&:update)
    @bird.collect_stars(stars)
    @@camera.look(@bird.x, @bird.y)

    @background.update(@bird.speed) if @@camera.position.x == @bird.x
  end

  def draw
    draw_ui

    @background.draw

    @bird.draw

    self.stars.each(&:draw)
    self.level.tiles.each(&:draw)

    draw_grid if GameWindow.debug
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
