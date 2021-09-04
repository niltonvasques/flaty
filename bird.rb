require 'gosu'
require 'ostruct'
require './game_object'

class Bird < GameObject
  FRAME_DURATION = 1000 / 60
  FG_SPEED = 30.0 / FRAME_DURATION
  SCALE = 3

  def initialize
    bird_tiles = Gosu::Image.load_tiles('assets/seagull_tiles.png', 32, 40)

    super(tiles: bird_tiles, x: 0, y: GameWindow::SCREEN_HEIGHT / 2, current: 0,
          scale_x: SCALE, scale_y: SCALE, speed: 0)

    @scaled_width = tiles[0].width * SCALE
    @scaled_height = tiles[0].width * SCALE

    @elapsed = 0
  end

  def update
    @elapsed += FRAME_DURATION

    prev_x = self.x

    self.x -= 5 if Gosu.button_down? Gosu::KB_LEFT
    self.x += 5 if Gosu.button_down? Gosu::KB_RIGHT
    self.y -= 5 if Gosu.button_down? Gosu::KB_UP
    self.y += 5 if Gosu.button_down? Gosu::KB_DOWN
    self.x = 0 if self.x < 0
    self.x = GameWindow::SCREEN_WIDTH - @scaled_width if self.x + @scaled_width > GameWindow::SCREEN_WIDTH
    self.y = 0 if self.y < 0
    self.y = GameWindow::SCREEN_HEIGHT - @scaled_height if self.y + @scaled_height > GameWindow::SCREEN_HEIGHT

    self.speed = 0
    self.speed = -FG_SPEED if Gosu.button_down? Gosu::KB_LEFT
    self.speed = FG_SPEED if Gosu.button_down? Gosu::KB_RIGHT

    self.current = ((@elapsed / 200) % 4) + (self.speed < 0 ? 6 : 0)
  end
end
