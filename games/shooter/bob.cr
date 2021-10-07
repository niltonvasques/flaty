require "flaty"
require "./star"

class Bob < Flaty::RectGameObject
  # velocity
  IDLE_SPEED        = Vec2d.new(0, 0)
  ACCELERATION      = 2.5 # 50 m/s
  GRAVITY           = Vec2d.new(0, -20) # -20 m/s = 72 km/h
  TERMINAL_SPEED    = 55.0 # 50 m/s = 200 km/h
  JUMP_ACCELERATION = Vec2d.new(0, 10000.0) # 110 m/s
  SPEED             = 7.0 # 7 m/s = 25 km/h

  JUMP_DURATION = 40 # 50 ms
  FPS_DURATION  = (1.0/60) # 110 m/s

  # animation frames
  SIZE                   = 1.85 # 1.85 meters tall
  WIDTH                  = SIZE
  HEIGHT                 = SIZE
  TILE_WIDTH             = 130
  TILE_HEIGHT            = 150
  TILE_SCALE             = SF.vector2(WIDTH / TILE_WIDTH, HEIGHT / TILE_HEIGHT)
  FRAMES                 = 10
  JUMP_FRAMES            = 7
  RIGHT_FRAMES_INDEX     = 12
  JUMP_FRAMES_INDEX      = 28
  STEPS_PER_SECOND       = 1.5
  RUNNING_FRAME_DURATION = (1000 / (STEPS_PER_SECOND * FRAMES))
  FRAME_FAST_DURATION    = 80
  IDLE_FRAME_INDEX       = 10

  def initialize
    tiles        = Flaty::Tiles.new("assets/bob2.png", TILE_WIDTH, TILE_HEIGHT, TILE_SCALE)
    steps_buffer = SF::SoundBuffer.from_file("assets/sounds/steps.wav")
    beep_buffer  = SF::SoundBuffer.from_file("assets/sounds/beep.wav")
    @steps       = SF::Sound.new(steps_buffer)
    @beep        = SF::Sound.new(beep_buffer)
    @steps.loop  = true
    @steps.pitch = 1.5
    @beep.volume = 10

    @jump_at     = -2000
    @jumping     = false
    @grounded    = false
    @state       = :idle
    @face        = :right
    @score       = 0

    super({ :position => Vec2d.new(0, 4), :width => WIDTH, :height => HEIGHT, :mass => 5.0,
           :speed => IDLE_SPEED.dup, :max_speed => Vec2d.new(SPEED, TERMINAL_SPEED), :damp => 0.8,
           :score => 0, :tiles => tiles, :current => 0, :debug => Flaty::Colors::RED_ALPHA,
           :rigidbody => true, :tag => :bob })
  end

  def update(delta)
    self.debug = Flaty::Colors::RED_ALPHA
    update_speed

    super
  end

  def update_speed
    self.acceleration = Vec2d.new(0, 0)

    update_movement

    update_direction

    update_animation

    if @state == :walking
      play
    else
      pause
    end
  end

  def update_movement
    if Flaty.pressed?(SF::Keyboard::Left)
      self.acceleration += Vec2d.new(-ACCELERATION, 0)
      @state = :walking if @state != :jumping
    end

    if Flaty.pressed?(SF::Keyboard::Right)
      self.acceleration += Vec2d.new(ACCELERATION,  0)
      @state = :walking if @state != :jumping
    end

    @state = :idle if @state == :walking && self.speed.x.abs < 0.5

    if Flaty.pressed?(SF::Keyboard::Space) && @state != :jumping
      @jump_at = Flaty.elapsed_milis
      @jumping = true
      @state = :jumping
      @grounded = false
      self.acceleration += JUMP_ACCELERATION * Flaty.delta
    end

    if @jumping && (Flaty.elapsed_milis - @jump_at) > JUMP_DURATION
      @jumping = false
    elsif @jumping
      self.acceleration += JUMP_ACCELERATION * Flaty.delta
    end
  end

  def collision_rect
    @rect.left = x + WIDTH / 4
    @rect.top = y
    @rect.width = @width - WIDTH / 2
    @rect.height = @height
    @rect
  end

  def update_direction
    @face = :right if self.acceleration.x > 0
    @face = :left if self.acceleration.x < 0
  end

  def update_animation
    case @state
    when :idle
      @current = IDLE_FRAME_INDEX
      # pause
    when :jumping
      # pause
      @current = (Flaty.elapsed_milis / RUNNING_FRAME_DURATION).to_i % JUMP_FRAMES
      @current += JUMP_FRAMES_INDEX
    else
      @current = (Flaty.elapsed_milis / RUNNING_FRAME_DURATION).to_i % FRAMES
    end

    if @face == :right
      @current += RIGHT_FRAMES_INDEX
    end
  end

  def grounded
    self.speed.y = 0
    @state = :idle
    @grounded = true
  end

  #def ceil_hit
  #  self.speed.y = 0
  #end

  def collect_stars(stars : Array(Star))
    stars.reject! do |star|
  #    #if Gosu.distance(self.x + self.width / 2, self.y + self.height / 2, star.x, star.y) < 1
      if Collision.detect_rect(self, star) != Collision::NONE
        @score += 10
        @beep.play
        true
      else
        false
      end
    end
  end

  def pause
    return unless Flaty.playing?(@steps)
    @steps.stop
  end

  def play
    return if Flaty.playing?(@steps)
    @steps.play
  end

  def turn_left?
    self.speed.x < 0
  end
end
