require "flaty"
require "flaty/tiles"

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

  def initialize
    scale = SF.vector2(0.8 / 32, 1.0 / 40)
    tiles = Flaty::Tiles.new("assets/seagull_tiles.png", 32, 40, scale)
    #@wings = Gosu::Sample.new('assets/sounds/dragonflap.mp3')
    #@beep = Gosu::Sample.new('assets/sounds/beep.wav')
    #play

    super({ :position => Vec2d.new(1.0, 14.0), :width => 0.8, :height => 1.0,
           :speed => IDLE_SPEED.dup, :max_speed => Vec2d.new(SPEED, SPEED), :damp => 0.8,
           :score => 0, :tiles => tiles, :current => 0, :rigidbody => true,
           :debug => Flaty::Colors::RED, :tag => :bird })
  end

  def update(delta)
  #  self.debug = Gosu::Color::RED
    update_speed

    super
  end

  def update_speed
  #  self.acceleration = Vec2d.new(0,  0)
  #  self.acceleration += Vec2d.new(-ACCELERATION, 0) if Gosu.button_down? Gosu::KB_A
  #  self.acceleration += Vec2d.new(ACCELERATION,  0) if Gosu.button_down? Gosu::KB_D
  #  self.acceleration += Vec2d.new(0, ACCELERATION) if Gosu.button_down? Gosu::KB_W
  #  self.acceleration += Vec2d.new(0, -ACCELERATION) if Gosu.button_down? Gosu::KB_S

    frame_duration = self.speed.x.abs <= IDLE ? FRAME_DURATION : FRAME_FAST_DURATION
    @current = (Flaty.elapsed_milis / frame_duration).to_i % FRAMES
    @current += LEFT_FRAMES_INDEX if turn_left?
  end

  #def collision_rect
  #  self.rect.x = self.x
  #  self.rect.y = self.y + 1
  #  self.rect.width = self.width
  #  self.rect.height = self.height - 2
  #  self.rect
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
