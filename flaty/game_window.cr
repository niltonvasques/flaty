class GameWindow
  SCREEN_WIDTH   = 1280
  SCREEN_HEIGHT  = 720
  CAMERA_WIDTH_UNITS  = 100
  CAMERA_HEIGHT_UNITS = 56
  SCALE = 20

  def initialize(width = SCREEN_WIDTH, height = SCREEN_HEIGHT, scale = SCALE)
    @@width = width
    @@height = height

    #@@camera = Camera.new(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    #@@camera.look(CAMERA_WIDTH_UNITS / 2.0, CAMERA_HEIGHT_UNITS / 2.0)

    # state
    @paused = false
    @paused_at = 0
    @@updated_at = 0
    @@delta_seconds = 0
    @@debug = false

    @scale = scale

    @states = SF::RenderStates.new(
      transform: SF::Transform.new
      .scale(@scale, @scale)  # Allow all operations to use 1 as the size of the grid
      .translate(0.5, 0.5)  # Move the reference point to centers of grid squares
    )

    @window = SF::RenderWindow.new(
      SF::VideoMode.new(width * @scale, height * @scale), "Snakes",
      settings: SF::ContextSettings.new(depth: 24, antialiasing: 8)
    )
    @window.framerate_limit = 10
  end

  def self.width
    @@width
  end

  def self.height
    @@height
  end

  def self.delta
    @@delta_seconds
  end

  def self.debug
    @@debug
  end

  def self.camera
    @@camera
  end

  def needs_cursor?; false; end

  def update
    #@@delta_seconds = (Gosu.milliseconds - @@updated_at) / 1000.0
    #@@updated_at = Gosu.milliseconds
  end

  def draw(window)
  end

  #def button_down(id)
  #  if id == Gosu::KB_ESCAPE
  #    close
  #  elsif id == Gosu::KB_O
  #    @@debug = !@@debug
  #  else
  #    super
  #  end
  #end

  #def paused?
  #  if Gosu.button_down? Gosu::KB_P
  #    if (Gosu.milliseconds - @paused_at) > 1000
  #      @paused = !@paused
  #      @paused_at = Gosu.milliseconds
  #      if @paused
  #        paused if defined? paused
  #      else
  #        play if defined? play
  #      end
  #    end
  #  end
  #  @paused
  #end

  def button_down(code)
  end

  def loop
    while @window.open?
      while event = @window.poll_event()
        if (
            event.is_a?(SF::Event::Closed) ||
            (event.is_a?(SF::Event::KeyPressed) && event.code.escape?)
        )
          @window.close()
        elsif event.is_a? SF::Event::KeyPressed
          button_down(event.code)
          #case event.code
          #when .a?
          #  snake1.turn Left
          #when .w?
          #  snake1.turn Up
          #when .d?
          #  snake1.turn Right
          #when .s?
          #  snake1.turn Down

          #when .left?
          #  snake2.turn Left
          #when .up?
          #  snake2.turn Up
          #when .right?
          #  snake2.turn Right
          #when .down?
          #  snake2.turn Down
          #end
        end
      end

      update()

      @window.clear SF::Color::Black
      draw(@window)
      #@window.draw field, states

      @window.display()
    end
  end
end
