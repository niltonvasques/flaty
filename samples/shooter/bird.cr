require "flaty"

class Bird < Flaty::RectGameObject
  IDLE                = 2.0
  IDLE_SPEED          = Vec2d.new(IDLE, 0.0)
  ACCELERATION        = 20.0 # units per second
  SPEED               = 10.0
  SCALE               = 3
  FRAMES              = 4
  LEFT_FRAMES_INDEX   = 6
  FRAME_DURATION      = 220
  FRAME_FAST_DURATION = 80
  WIDTH               = 2.0
  HEIGHT              = 2.5
  TILE_WIDTH          = 32
  TILE_HEIGHT         = 40
  TILE_SCALE          = SF.vector2(WIDTH / TILE_WIDTH, HEIGHT / TILE_HEIGHT)

  def initialize
    tiles = Flaty::Tiles.new("assets/seagull_tiles.png", TILE_WIDTH, TILE_HEIGHT, TILE_SCALE)
    wings_buffer = SF::SoundBuffer.from_file("assets/sounds/dragonflap.wav")
    @wings       = SF::Sound.new(wings_buffer)
    @wings.loop = true
    @wings.pitch = 2.5
    @wings.volume = 10
    play

    super({ :position => Vec2d.new(1.0, 14.0), :width => WIDTH, :height => HEIGHT,
           :speed => IDLE_SPEED.dup, :max_speed => Vec2d.new(SPEED, SPEED), :damp => 0.8,
           :score => 0, :tiles => tiles, :current => 0, :rigidbody => true,
           :debug => Flaty::Colors::RED_ALPHA, :tag => :bird })
  end

  def update(delta)
    self.debug = Flaty::Colors::RED_ALPHA
    update_speed

    super
    if self.acceleration.x.abs != 0
      @wings.pitch = 5
    else
      @wings.pitch = 2.5
    end
  end

  def update_speed
    self.force.y = 0 # nullify gravity effects to fly

    self.acceleration = Vec2d.new(0,  0)

    self.acceleration += Vec2d.new(-ACCELERATION, 0) if Flaty.pressed?(SF::Keyboard::A)
    self.acceleration += Vec2d.new(ACCELERATION,  0) if Flaty.pressed?(SF::Keyboard::D)
    self.acceleration += Vec2d.new(0, ACCELERATION) if Flaty.pressed?(SF::Keyboard::W)
    self.acceleration += Vec2d.new(0, -ACCELERATION) if Flaty.pressed?(SF::Keyboard::S)

    frame_duration = self.speed.x.abs <= IDLE ? FRAME_DURATION : FRAME_FAST_DURATION
    @current = (Flaty.elapsed_milis / frame_duration).to_i % FRAMES
    @current += LEFT_FRAMES_INDEX if turn_left?
  end

  def collision_rect
    @rect.left   = self.x
    @rect.top    = self.y + 0.9
    @rect.width  = @width
    @rect.height = @height - 2.0
    @rect
  end

  def previous_collision_rect
    @rect.left = @previous_position.x
    @rect.top = @previous_position.y + 0.9
    @rect.width = @width
    @rect.height = @height - 2.0
    @rect
  end

  def pause
    return unless Flaty.playing?(@wings)
    @wings.pause
  end

  def play
    return if Flaty.playing?(@wings)
    @wings.play
  end

  def turn_left?
    self.speed.x < 0
  end
end
