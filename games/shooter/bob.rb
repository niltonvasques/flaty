require 'gosu'
require 'ostruct'
require 'flaty/flaty'

class Bob < GameObject
  SIZE              = 1.85 # 1.85 meters tall

  # velocity
  IDLE_SPEED        = Vector2d[0, 0].freeze
  ACCELERATION      = 50.freeze # 50 m/s
  GRAVITY           = Vector2d[0, -20].freeze # -20 m/s = 72 km/h
  TERMINAL_SPEED    = 55.freeze # 50 m/s = 200 km/h
  JUMP_ACCELERATION = Vector2d[0, 170].freeze # 110 m/s
  SPEED             = 7.freeze # 7 m/s = 25 km/h

  JUMP_DURATION = 60.freeze # 50 ms
  FPS_DURATION  = (1.0/60).freeze # 110 m/s

  # animation frames
  FRAMES                 = 10.freeze
  JUMP_FRAMES            = 7.freeze
  RIGHT_FRAMES_INDEX     = 12.freeze
  JUMP_FRAMES_INDEX      = 28.freeze
  STEPS_PER_SECOND       = 1.5.freeze
  RUNNING_FRAME_DURATION = (1000 / (STEPS_PER_SECOND * FRAMES)).freeze
  FRAME_FAST_DURATION    = 80.freeze
  IDLE_FRAME_INDEX       = 10.freeze

  def initialize
    bob_tiles = Gosu::Image.load_tiles('assets/bob2.png', 130, 150, tileable: true)
    @steps = Gosu::Sample.new('assets/sounds/steps.wav')
    @beep = Gosu::Sample.new('assets/sounds/beep.wav')
    @jump_at = -2000
    @jumping = false
    play

    scale = GameWindow.camera.scale(bob_tiles[0].height, SIZE)

    super(position: Vector2d[0, 4], z: ZLayers::PLAYER, scale_x: scale, scale_y: scale,
          speed: IDLE_SPEED.dup, max_speed: Vector2d[SPEED, TERMINAL_SPEED], damp: 0.8,
          score: 0, tiles: bob_tiles, current: 0, debug: Gosu::Color::RED,
          state: :idle, face: :right)
  end

  def update
    self.debug = Gosu::Color::RED
    update_speed

    super

    #puts "a: #{self.acceleration}, v: #{self.speed}, #{self.state}, #{self.position}"
  end

  def update_speed
    self.acceleration = GRAVITY.dup

    update_movement

    update_direction

    update_animation

    play if self.state == :walking
  end

  def update_movement
    if Gosu.button_down? Gosu::KB_LEFT
      self.acceleration += Vector2d[-ACCELERATION, 0]
      self.state = :walking if self.state != :jumping
    end

    if Gosu.button_down? Gosu::KB_RIGHT
      self.acceleration += Vector2d[ACCELERATION,  0]
      self.state = :walking if self.state != :jumping
    end

    self.state = :idle if self.state == :walking and self.speed.y <= -0.5

    if Gosu.button_down? Gosu::KB_SPACE and self.state != :jumping
      @jump_at = Gosu.milliseconds
      @jumping = true
      self.state = :jumping
      self.acceleration += JUMP_ACCELERATION * (FPS_DURATION / GameWindow.delta)
    end

    if (Gosu.milliseconds - @jump_at) > JUMP_DURATION
      @jumping = false
    else
      self.acceleration += JUMP_ACCELERATION * (FPS_DURATION / GameWindow.delta)
    end
  end

  def update_direction
    self.face = :right if self.acceleration.x > 0
    self.face = :left if self.acceleration.x < 0
  end

  def update_animation
    case self.state
    when :idle
      self.current = IDLE_FRAME_INDEX
      pause
    when :jumping
      pause
      self.current = (Gosu.milliseconds / (Second.in_millis / JUMP_FRAMES)) % JUMP_FRAMES
      self.current += JUMP_FRAMES_INDEX
    else
      self.current = (Gosu.milliseconds / RUNNING_FRAME_DURATION) % FRAMES
    end

    if self.face == :right
      self.current += RIGHT_FRAMES_INDEX
    end
  end

  def grounded
    super
    self.state = :idle
  end

  def collect_stars(stars)
    stars.reject! do |star|
      #if Gosu.distance(self.x + self.width / 2, self.y + self.height / 2, star.x, star.y) < 1
      if Collision.detect(collision_rect, star) != Collision::NONE
        self.score += 10
        @beep.play(0.2)
        true
      else
        false
      end
    end
  end

  def pause
    if !@steps_playing.nil? and !@steps_playing.paused?
      @steps_playing.pause
    end
  end

  def play
    if @steps_playing.nil? or @steps_playing.paused?
      return @steps_playing.resume if @steps_playing
      volume  = 2
      speed   = 1.5
      looping = true
      @steps_playing = @steps.play(volume, speed, looping)
    end
  end

  def turn_left?
    self.speed.x < 0
  end

  def grounded
    self.speed.y = 0
  end

  def ceil_hit
    self.speed.y = 0
  end
end
