module Flaty
  class GameWindow
    SCREEN_WIDTH        = 1280
    SCREEN_HEIGHT       = 720
    CAMERA_WIDTH_UNITS  = 100.0
    CAMERA_HEIGHT_UNITS = 56.0
    SCALE               = 20

    property camera

    def initialize(width = SCREEN_WIDTH, height = SCREEN_HEIGHT, scale : Float64 = SCALE,
                   title = "Window")
      @@width = width
      @@height = height

      @camera = Camera.new(width, height, scale)
      @camera.look(CAMERA_WIDTH_UNITS / 2.0, CAMERA_HEIGHT_UNITS / 2.0)

      # state
      @paused = false
      @paused_at = 0
      @debug = false

      @scale = scale

      @clock = SF::Clock.new
      @delta_clock = SF::Clock.new
      @delta = SF::Time.new()

      # Allow all operations to use 1 as the size of the grid
      # vertical flip reference
      # https://gamedev.stackexchange.com/questions/149062/how-to-mirror-reflect-flip-a-4d-transformation-matrix
      t = SF::Transform.new(
        1, 0, 0,
        0, 1, 0,
        0, 0, 1
      )
      #t.translate(0, -(height - 1) * @scale)
      #t.translate(0, (height + 1) * @scale)
      t.scale(@scale, @scale)
      @states = SF::RenderStates.new(transform: t)

      @window = SF::RenderWindow.new(
        SF::VideoMode.new((width * @scale).to_i, (height * @scale).to_i), title,
        settings: SF::ContextSettings.new(depth: 24, antialiasing: 8)
      )
      @window.framerate_limit = 120
      Flaty.init(@window, @states, @camera)
    end

    def debug?
      @debug
    end

    def update_camera
      @window.view = @camera.view
    end

    def elapsed_time
      @clock.elapsed_time.as_milliseconds
    end

    def elapsed_seconds
      @clock.elapsed_time.as_seconds
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

    def self.camera
      @@camera
    end

    def needs_cursor?; false; end

    def update(delta)
    end

    def draw(window, states)
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

    def paused?
      @paused
    end

    def button_down(code)
    end

    def loop
      while @window.open?
        @delta = @delta_clock.restart
        while event = @window.poll_event()
          if (
              event.is_a?(SF::Event::Closed) ||
              (event.is_a?(SF::Event::KeyPressed) && event.code.escape?)
          )
            @window.close()
          elsif event.is_a? SF::Event::KeyPressed
            @paused = !@paused if event.code.p?
            @debug = !@debug if event.code.d?
            button_down(event.code)
          end
        end

        update(@delta)

        @window.clear SF::Color::Black
        draw(@window, @states)
        #@window.draw field, states

        @window.display()
      end
    end
  end
end
