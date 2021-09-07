require 'gosu'
require 'ostruct'
require './game_object'
require './vector_2d'

class Bird < GameObject
  IDLE = 2.freeze
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
          speed: IDLE_SPEED.dup, score: 0, tiles: bird_tiles, current: 0, debug: Gosu::Color::RED)
  end

  def update
    update_speed

    super
  end

  def update_speed
    self.speed =  IDLE_SPEED.dup
    self.speed =  Vector2d[-SPEED, 0] if Gosu.button_down? Gosu::KB_LEFT
    self.speed += Vector2d[SPEED,  0] if Gosu.button_down? Gosu::KB_RIGHT
    self.speed += Vector2d[0, -SPEED] if Gosu.button_down? Gosu::KB_UP
    self.speed += Vector2d[0,  SPEED] if Gosu.button_down? Gosu::KB_DOWN

    frame_duration = self.speed.x.abs <= IDLE ? FRAME_DURATION : FRAME_FAST_DURATION
    self.current = (Gosu.milliseconds / frame_duration) % FRAMES
    self.current += LEFT_FRAMES_INDEX if turn_left?
  end

  def collect_stars(stars)
    stars.reject! do |star|
      if Gosu.distance(self.x + self.width / 2, self.y + self.height / 2, star.x, star.y) < 1
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
