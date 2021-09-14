require 'gosu'
require 'ostruct'
require 'flaty/math/rect'

class Bird < GameObject
  IDLE                = 5.freeze
  GRAVITY             = Vector2d[0, -30].freeze
  JUMP                = Vector2d[0, 200].freeze
  IDLE_SPEED          = Vector2d[IDLE, 0].freeze
  IDLE_ACCELERATION   = Vector2d[200, 0].freeze
  SPEED               = 10.freeze # units per second
  SCALE               = 3.freeze
  FRAMES              = 4.freeze
  LEFT_FRAMES_INDEX   = 6.freeze
  FRAME_DURATION      = 220.freeze
  FRAME_FAST_DURATION = 80.freeze

  def initialize
    bird_tiles = Gosu::Image.load_tiles('assets/seagull_tiles.png', 32, 40)
    @wings = Gosu::Sample.new('assets/sounds/dragonflap.mp3')
    @beep = Gosu::Sample.new('assets/sounds/beep.wav')
    play

    super(position: Vector2d[1, 14], z: ZLayers::PLAYER, scale_x: SCALE, scale_y: SCALE,
          speed: IDLE_SPEED.dup,
          max_speed: Vector2d[IDLE, SPEED], tiles: bird_tiles, current: 0, debug: Gosu::Color::RED)
    self.angle = 30
  end

  def update
    update_speed

    super
  end

  def draw_obj(x, y, z)
    if self.angle != 0
      center = -0.4
      center = 0.2 if self.angle < 0
      current_image.draw_rot(x, y, z, angle = self.angle,
                             center_x = center, center_y = 0,
                             scale_x = self.scale_x, scale_y = self.scale_y)
    else
      super(x, y, z)
    end
  end

  def update_speed
    self.acceleration = GRAVITY + IDLE_ACCELERATION
    self.acceleration = JUMP + IDLE_ACCELERATION if Gosu.button_down? Gosu::KB_SPACE

    self.angle = 0
    self.angle = 15 if self.speed.y < 0
    self.angle = -15 if self.speed.y > 0
    self.angle *= -1 if turn_left?

    frame_duration = self.speed.y < 0 ? FRAME_DURATION : FRAME_FAST_DURATION
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
