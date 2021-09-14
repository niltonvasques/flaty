require 'gosu'
require 'pry-byebug'
require 'games/shooter/background'
require 'games/flappybird/bird'
require 'games/shooter/star'
require 'games/flappybird/level_loader'
require 'flaty/flaty'

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

  attr_accessor :level, :game_over, :score

  def initialize
    @camera = GameWindow.camera
    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @camera.bounds.x = CAMERA_WIDTH_UNITS / 2.0
    @camera.bounds.y = CAMERA_HEIGHT_UNITS / 2.0
    @camera.look(CAMERA_WIDTH_UNITS / 2.0, CAMERA_HEIGHT_UNITS / 2.0)
    @camera_debug = CameraDebug.new(@camera)

    # assets
    @font = Gosu::Font.new(20)
    @song = Gosu::Song.new('assets/sounds/dusk_theme.mp3')
    @song.play

    # objects
    @background = Background.new
    @bird = Bird.new
    self.game_over = false
  end

  def update
    return if self.game_over
    self.level.tiles.each { |tile| tile.debug = Gosu::Color::GREEN } if GameWindow.debug

    @bird.update

    collided = Physics.solve_collisions(@bird, @level.around(@bird.collision_rect))

    @background.update(@bird.speed)

    self.game_over = true if collided

    @camera.look(@bird.x, @camera.position.y)
  end

  def draw
    draw_ui

    @background.draw

    @bird.draw

    self.level.tiles.each(&:draw)

    #draw_grid if GameWindow.debug
    @camera_debug.draw if GameWindow.debug
  end

  def pause
    @song.pause
    @bird.pause
  end

  def play
    @song.play
    @bird.play
  end

  def score
    (@bird.position.x.to_i / 10).to_i * 10
  end

  def restart
    @bird.restart
    self.game_over = false
  end

  private

  def draw_ui
    @font.draw_text("FPS: #{Gosu.fps}", 10, 10, ZLayers::UI, 1.0, 1.0, Gosu::Color::GREEN)
    @font.draw_text("Score: #{score}", GameWindow::SCREEN_WIDTH - 200, 10,
                    ZLayers::UI, 2.0, 2.0, Gosu::Color::BLACK)
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
