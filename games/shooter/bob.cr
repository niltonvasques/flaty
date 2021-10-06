require "flaty"

class Bob < Flaty::RectGameObject
  # velocity
  IDLE_SPEED        = Vec2d.new(0, 0)
  ACCELERATION      = 50.0 # 50 m/s
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
    tiles     = Flaty::Tiles.new("assets/bob2.png", TILE_WIDTH, TILE_HEIGHT, TILE_SCALE)
  #  @steps = Gosu::Sample.new('assets/sounds/steps.wav')
  #  @beep = Gosu::Sample.new('assets/sounds/beep.wav')
    @jump_at  = -2000
    @jumping  = false
    @grounded = false
    @state    = :idle
    @face     = :right
  #  play

    super({ :position => Vec2d.new(0, 4), :width => WIDTH, :height => HEIGHT, :mass => 5.0,
           :speed => IDLE_SPEED.dup, :max_speed => Vec2d.new(SPEED, TERMINAL_SPEED), :damp => 0.8,
           :score => 0, :tiles => tiles, :current => 0, :debug => Flaty::Colors::RED,
           :rigidbody => true, :tag => :bob })
  end

  def update(delta)
    #  self.debug = Gosu::Color::RED
    update_speed

    super

    if @jumping
      f = (@acceleration + @force)
      puts "#{f} forces #{f * delta.as_seconds} dt #{delta.as_seconds} #{@speed} sp"
    end

    #  #puts "a: #{self.acceleration}, v: #{self.speed}, #{self.state}, #{self.position}"
  end

  def update_speed
    self.acceleration = Vec2d.new(0, 0)

    update_movement

    update_direction

    update_animation

  #  play if self.state == :walking
  end

  def update_movement
    if SF::Keyboard.key_pressed?(SF::Keyboard::Left)
      self.acceleration += Vec2d.new(-ACCELERATION, 0)
      @state = :walking if @state != :jumping
    end

    if SF::Keyboard.key_pressed?(SF::Keyboard::Right)
      self.acceleration += Vec2d.new(ACCELERATION,  0)
      @state = :walking if @state != :jumping
    end

    @state = :idle if @state == :walking && self.speed.x.abs < 0.5

    if SF::Keyboard.key_pressed?(SF::Keyboard::Space) && @state != :jumping
      @jump_at = Flaty.elapsed_milis
      @jumping = true
      @state = :jumping
      @grounded = false
      self.acceleration += JUMP_ACCELERATION * Flaty.delta
    end

    if @jumping && (Flaty.elapsed_milis - @jump_at) > JUMP_DURATION
      puts "#{(Flaty.elapsed_milis - @jump_at)} jumping stop"
      @jumping = false
    elsif @jumping
      puts "#{(Flaty.elapsed_milis - @jump_at)} jumping"
      self.acceleration += JUMP_ACCELERATION * Flaty.delta
    end
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
    #puts "#{@current} current"
  end

  def button_down(code)
    #case code
    #when .left?
    #  self.acceleration -= Vec2d.new(ACCELERATION,  0)
    #  puts @state
    #  @state = :walking if @state != :jumping
    #  puts @state
    #when .right?
    #  self.acceleration += Vec2d.new(ACCELERATION,  0)
    #  puts @state
    #  @state = :walking if @state != :jumping
    #  puts @state
    #when .space?
    #  @jump_at = Flaty.elapsed_milis
    #  @jumping = true
    #  @state = :jumping
    #  self.acceleration += JUMP_ACCELERATION * Flaty.delta
    #end
  end

  def button_up(code)
    #if code.up? || code.down? || code.left? || code.right? || code.space?
    #  #@state = :idle
    #  self.acceleration = Vec2d.new(0,  0)
    #end
  end

  def grounded
    self.speed.y = 0
    @state = :idle
    @grounded = true
  end

  #def ceil_hit
  #  self.speed.y = 0
  #end

  #def collect_stars(stars)
  #  stars.reject! do |star|
  #    #if Gosu.distance(self.x + self.width / 2, self.y + self.height / 2, star.x, star.y) < 1
  #    if Collision.detect_rect(collision_rect, star) != Collision::NONE
  #      self.score += 10
  #      @beep.play(0.2)
  #      true
  #    else
  #      false
  #    end
  #  end
  #end

  #def pause
  #  if !@steps_playing.nil? and !@steps_playing.paused?
  #    @steps_playing.pause
  #  end
  #end

  #def play
  #  if @steps_playing.nil? or @steps_playing.paused?
  #    return @steps_playing.resume if @steps_playing
  #    volume  = 2
  #    speed   = 1.5
  #    looping = true
  #    @steps_playing = @steps.play(volume, speed, looping)
  #  end
  #end

  def turn_left?
    self.speed.x < 0
  end
end
