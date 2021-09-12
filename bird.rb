require 'gosu'
require 'ostruct'
require './game_object'
require './engine/math/vector_2d'
require './rect'

class Bird < GameObject
  IDLE = 2.freeze
  IDLE_SPEED = Vector2d[IDLE, 0].freeze
  ACCELERATION = 20.freeze # units per second
  SPEED = 10.freeze
  SCALE = 3.freeze
  FRAMES = 4.freeze
  LEFT_FRAMES_INDEX   = 6.freeze
  FRAME_DURATION      = 220.freeze
  FRAME_FAST_DURATION = 80.freeze

  def initialize
    bird_tiles = Gosu::Image.load_tiles('assets/seagull_tiles.png', 32, 40)
    @wings = Gosu::Sample.new('assets/sounds/dragonflap.mp3')
    @beep = Gosu::Sample.new('assets/sounds/beep.wav')
    play

    super(position: Vector2d[1, 14], z: ZLayers::PLAYER, scale_x: SCALE, scale_y: SCALE,
          speed: IDLE_SPEED.dup, max_speed: Vector2d[SPEED, SPEED], damp: 0.8,
          score: 0, tiles: bird_tiles, current: 0, debug: Gosu::Color::RED)
  end

  def update
    update_speed

    super
  end

  def update_speed
    self.acceleration = Vector2d[0,  0]
    self.acceleration += Vector2d[-ACCELERATION, 0] if Gosu.button_down? Gosu::KB_LEFT
    self.acceleration += Vector2d[ACCELERATION,  0] if Gosu.button_down? Gosu::KB_RIGHT
    self.acceleration += Vector2d[0, -ACCELERATION] if Gosu.button_down? Gosu::KB_UP
    self.acceleration += Vector2d[0,  ACCELERATION] if Gosu.button_down? Gosu::KB_DOWN
    #self.speed =  IDLE_SPEED.dup
    #self.speed =  Vector2d[-SPEED, 0] if Gosu.button_down? Gosu::KB_LEFT
    #self.speed += Vector2d[SPEED,  0] if Gosu.button_down? Gosu::KB_RIGHT
    #self.speed += Vector2d[0, -SPEED] if Gosu.button_down? Gosu::KB_UP
    #self.speed += Vector2d[0,  SPEED] if Gosu.button_down? Gosu::KB_DOWN

    frame_duration = self.speed.x.abs <= IDLE ? FRAME_DURATION : FRAME_FAST_DURATION
    self.current = (Gosu.milliseconds / frame_duration) % FRAMES
    self.current += LEFT_FRAMES_INDEX if turn_left?
  end

  def collision_rect
    self.rect.x = self.x
    self.rect.y = self.y + 1
    self.rect.width = self.width
    self.rect.height = self.height - 2
    self.rect
  end

  def collect_stars(stars)
    stars.reject! do |star|
      #if Gosu.distance(self.x + self.width / 2, self.y + self.height / 2, star.x, star.y) < 1
      if Collision.detect(collision_rect, star) != Collision::NONE
        self.score += 10
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

  def turn_left?
    self.speed.x < 0
  end
end
