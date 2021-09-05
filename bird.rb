require 'gosu'
require 'ostruct'
require './game_object'

class Bird < GameObject
  FRAME_DURATION = 1000 / 60
  FG_SPEED = 30.0 / FRAME_DURATION
  SCALE = 3

  attr_reader :score

  def initialize
    bird_tiles = Gosu::Image.load_tiles('assets/seagull_tiles.png', 32, 40)

    super(tiles: bird_tiles, x: 0, y: GameWindow::SCREEN_HEIGHT / 2, current: 0,
          scale_x: SCALE, scale_y: SCALE, speed: 0)

    @scaled_width = tiles[0].width * SCALE
    @scaled_height = tiles[0].width * SCALE

    @elapsed = 0
    @score = 0

    volume  = 2
    speed   = 2
    looping = true

    steps_sound = Gosu::Sample.new('assets/sounds/dragonflap.mp3')
    steps_sound.play(volume, speed, looping)

    @beep = Gosu::Sample.new('assets/sounds/beep.wav')
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

    self.current = ((@elapsed / 220) % 4) + (self.speed < 0 ? 6 : 0)
  end

  def collect_stars(stars)
    stars.reject! do |star|
      if Gosu.distance(self.x + @scaled_width / 2, self.y + @scaled_height / 2, star.x, star.y) < 30
        @score += 10
        @beep.play
        true
      else
        false
      end
    end
  end
end
