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
    #@wings = Gosu::Sample.new('assets/sounds/dragonflap.mp3')
    #@beep = Gosu::Sample.new('assets/sounds/beep.wav')
    #play

    super({ :position => Vec2d.new(1.0, 14.0), :width => WIDTH, :height => HEIGHT,
           :speed => IDLE_SPEED.dup, :max_speed => Vec2d.new(SPEED, SPEED), :damp => 0.8,
           :score => 0, :tiles => tiles, :current => 0, :rigidbody => true,
           :debug => Flaty::Colors::RED, :tag => :bird })
  end

  def update(delta)
  #  self.debug = Gosu::Color::RED
    update_speed

    super
    #puts "#{speed} s #{acceleration} a"
  end

  def update_speed
    #self.acceleration.y = 0
    frame_duration = self.speed.x.abs <= IDLE ? FRAME_DURATION : FRAME_FAST_DURATION
    @current = (Flaty.elapsed_milis / frame_duration).to_i % FRAMES
    @current += LEFT_FRAMES_INDEX if turn_left?
  end

  def button_down(code)
    case code
    when .a? then self.acceleration += Vec2d.new(-ACCELERATION, 0)
    when .d? then self.acceleration += Vec2d.new(ACCELERATION,  0)
    when .w? then self.acceleration += Vec2d.new(0, ACCELERATION)
    when .s? then self.acceleration += Vec2d.new(0, -ACCELERATION)
    end
  end

  def button_up(code)
    self.acceleration = Vec2d.new(0,  0) if code.a? || code.d? || code.w? || code.s?
  end

  #def collision_rect
  #  @rect.left   = self.x
  #  @rect.top    = self.y - 0.5
  #  @rect.width  = @width + 1.0
  #  @rect.height = @height + 0.2
  #  @rect
  #end

  #def collect_stars(stars)
  #  stars.reject! do |star|
  #    if Collision.detect(collision_rect, star) != Collision::NONE
  #      self.score += 10
  #      @beep.play
  #      true
  #    else
  #      false
  #    end
  #  end
  #end

  #def pause
  #  @wings_playing.pause
  #end

  #def play
  #  volume  = 2
  #  speed   = 2
  #  looping = true
  #  @wings_playing = @wings.play(volume, speed, looping)
  #end

  def turn_left?
    self.speed.x < 0
  end
end
