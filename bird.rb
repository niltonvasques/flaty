require 'gosu'
require 'ostruct'
require './game_object'

class Bird < GameObject
  SPEED = 10 # units per second
  SCALE = 3

  attr_reader :score

  def initialize
    bird_tiles = Gosu::Image.load_tiles('assets/seagull_tiles.png', 32, 40)

    super(tiles: bird_tiles, x: 1, y: 14, current: 0,
          z: ZLayers::PLAYER, scale_x: SCALE, scale_y: SCALE, speed: 0)

    @width = World.camera.pixel_to_unit_x(tiles[0].width * SCALE)
    @height = World.camera.pixel_to_unit_y(tiles[0].height * SCALE)

    @score = 0

    @wings = Gosu::Sample.new('assets/sounds/dragonflap.mp3')
    play

    @beep = Gosu::Sample.new('assets/sounds/beep.wav')
  end

  def update
    self.speed = 2
    self.speed = -SPEED if Gosu.button_down? Gosu::KB_LEFT
    self.speed = SPEED if Gosu.button_down? Gosu::KB_RIGHT

    dt_speed = self.speed * GameWindow.delta # reduce screen movement by 4

    self.x += dt_speed if self.speed.abs > 2
    self.y -= SPEED * GameWindow.delta if Gosu.button_down? Gosu::KB_UP
    self.y += SPEED * GameWindow.delta if Gosu.button_down? Gosu::KB_DOWN
    #self.x = 0 if self.x < 0
    #self.x = GameWindow::SCREEN_WIDTH - @width if self.x + @width > GameWindow::SCREEN_WIDTH
    #self.y = 0 if self.y < 0
    #self.y = GameWindow::SCREEN_HEIGHT - @height if self.y + @height > GameWindow::SCREEN_HEIGHT

    anim_speed = self.speed == 0 ? 220 : 80

    self.current = ((Gosu.milliseconds / anim_speed) % 4) + (self.speed < 0 ? 6 : 0)
  end

  def collect_stars(stars)
    stars.reject! do |star|
      if Gosu.distance(self.x + @width / 2, self.y + @height / 2, star.x, star.y) < 1
        @score += 10
        @beep.play
        true
      else
        false
      end
    end
  end

  def pause
    @wings_playing.pause
  end

  def play
    volume  = 2
    speed   = 2
    looping = true
    @wings_playing = @wings.play(volume, speed, looping)
  end
end
