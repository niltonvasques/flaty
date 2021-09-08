require 'gosu'
require 'ostruct'
require './game_object'
require './vector_2d'
require './rect'

class Bird < GameObject
  IDLE = 5.freeze
  GRAVITY = Vector2d[0, 30].freeze
  JUMP = Vector2d[0, -200].freeze
  IDLE_SPEED = Vector2d[IDLE, 0].freeze
  SPEED = 10.freeze # units per second
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
          speed: IDLE_SPEED.dup, tiles: bird_tiles, current: 0, debug: Gosu::Color::RED)
    self.angle = 30

    self.speed = IDLE_SPEED.dup
  end

  def update
    update_speed

    super
  end

  def update_speed
    self.acceleration = GRAVITY
    self.speed += self.acceleration * GameWindow.delta
    self.speed += JUMP * GameWindow.delta if Gosu.button_down? Gosu::KB_SPACE
    self.speed = Vector2d[IDLE, 10]   if self.speed.y > 10
    self.speed = Vector2d[IDLE, -10] if self.speed.y < -10 and Gosu.button_down? Gosu::KB_SPACE
    #self.speed =  Vector2d[-SPEED, 0] if Gosu.button_down? Gosu::KB_LEFT
    #self.speed += Vector2d[SPEED,  0] if Gosu.button_down? Gosu::KB_RIGHT
    #self.speed += Vector2d[0, -SPEED] if Gosu.button_down? Gosu::KB_UP
    #self.speed += Vector2d[0,  SPEED] if Gosu.button_down? Gosu::KB_DOWN

    self.angle = 0
    self.angle = 15 if self.speed.y > 0
    self.angle = -15 if self.speed.y < 0
    self.angle *= -1 if turn_left?

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

  def pause
    @wings_playing.pause
  end

  def play
    volume  = 2
    speed   = 2
    looping = true
    @wings_playing = @wings.play(volume, speed, looping)
  end

  def restart
    self.speed = IDLE_SPEED.dup
    self.position =Vector2d[1, 14]
  end

  def turn_left?
    self.speed.x < 0
  end
end
