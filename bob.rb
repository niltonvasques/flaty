require 'gosu'
require 'ostruct'
require 'engine/game_object'
require 'engine/math/vector_2d'
require 'engine/math/rect'

class Bob < GameObject
  IDLE_SPEED = Vector2d[0, 0].freeze
  ACCELERATION = 50.freeze # units per second
  GRAVITY = Vector2d[0, -20].freeze
  JUMP_ACCELERATION = Vector2d[0, 170].freeze # 110 m/s
  FPS_DURATION = (1.0/60).freeze # 110 m/s
  SPEED = 10.freeze
  FRAMES = 5.freeze
  JUMP_DURATION = 60.freeze # 50 ms
  RIGHT_FRAMES_INDEX   = 12.freeze
  JUMP_FRAMES_INDEX   = 28.freeze
  STEPS_PER_SECOND    = 1.freeze
  FRAME_DURATION      = (1000 / (STEPS_PER_SECOND * 10)).freeze
  FRAME_FAST_DURATION = 80.freeze
  TERMINAL_SPEED = 55.freeze # 50 m/s
  IDLE_FRAME = 10.freeze
  SIZE = 1.85

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
    update_speed

    super

    #puts "a: #{self.acceleration}, v: #{self.speed}, #{self.state}, #{self.position}"
  end

  def update_speed
    self.acceleration = GRAVITY.dup

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

    update_direction

    case self.state
    when :idle
      self.current = IDLE_FRAME
      pause
    when :jumping
      pause
      self.current = (Gosu.milliseconds / (1000 / (1 * 7))) % 7
      self.current += JUMP_FRAMES_INDEX
    else
      self.current = (Gosu.milliseconds / FRAME_DURATION) % FRAMES
    end

    play if self.state == :walking

    self.current += RIGHT_FRAMES_INDEX if self.face == :right and (self.state == :walking or self.state == :idle)
  end

  def update_direction
    self.face = :right if self.acceleration.x > 0
    self.face = :left if self.acceleration.x < 0
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
end
