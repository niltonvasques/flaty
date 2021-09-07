require 'gosu'
require 'ostruct'
require './game_object'
require './vector_2d'

class Bird < GameObject
  IDLE_SPEED = Vector2d[2, 0].freeze
  SPEED = 10 # units per second
  SCALE = 3

  attr_reader :score

  def initialize
    bird_tiles = Gosu::Image.load_tiles('assets/seagull_tiles.png', 32, 40)

    super(tiles: bird_tiles, position: Vector2d[1, 14], current: 0, debug: Gosu::Color::RED,
          z: ZLayers::PLAYER, scale_x: SCALE, scale_y: SCALE, speed: IDLE_SPEED.dup)

    @score = 0

    @wings = Gosu::Sample.new('assets/sounds/dragonflap.mp3')
    play

    @beep = Gosu::Sample.new('assets/sounds/beep.wav')
    self.previous_position = self.position.dup
  end

  def update(collision = Collision::NONE)
    self.previous_position = self.position.dup
    if Collision.right?(collision)
      self.speed = Vector2d[0,0]
    else
      self.speed = IDLE_SPEED.dup
    end
    self.speed = Vector2d[-SPEED, 0] if Gosu.button_down? Gosu::KB_LEFT and !Collision.left?(collision)
    self.speed = Vector2d[SPEED, 0] if Gosu.button_down? Gosu::KB_RIGHT and !Collision.right?(collision)

    self.speed.y = -SPEED if Gosu.button_down? Gosu::KB_UP and !Collision.top?(collision)
    self.speed.y = SPEED if Gosu.button_down? Gosu::KB_DOWN and !Collision.bottom?(collision)

    dt_speed = self.speed * GameWindow.delta

    self.position += dt_speed

    anim_speed = self.speed == IDLE_SPEED ? 220 : 80

    self.current = ((Gosu.milliseconds / anim_speed) % 4) + (self.speed.x < 0 ? 6 : 0)
  end

  def reset
    self.position = self.previous_position
  end

  def collect_stars(stars)
    stars.reject! do |star|
      if Gosu.distance(self.x + self.width / 2, self.y + self.height / 2, star.x, star.y) < 1
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
