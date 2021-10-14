require "flaty/flaty"
require "flaty/fps"

class Neuron
  property activation, weights

  def initialize(@activation : Float64 = 0.0, weights = 0)
    @weights = Array(Float64).new(weights, 0.0)
  end
end

class Layer
  property neurons

  def initialize(neurons : Int32, next_layer_size : Int32 = 0)
    @neurons = Array(Neuron).new(neurons) { Neuron.new(0.0, next_layer_size) }
  end

  def size
    @neurons.size
  end
end

class Network
  property layers

  def initialize(@layers : Array(Layer))
  end
end

class Neural < Flaty::GameWindow
  SCREEN_WIDTH        = 1500
  SCREEN_HEIGHT       = 1500
  CAMERA_WIDTH_UNITS  = 10.0
  CAMERA_HEIGHT_UNITS = 10.0
  SCALE               = SCREEN_WIDTH / CAMERA_WIDTH_UNITS

  def initialize
    super(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS, SCALE, "RayCast")

    ## assets
    @font      = SF::Font.from_file("assets/Cantarell-Regular.otf")

    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @camera.look(CAMERA_WIDTH_UNITS / 2, CAMERA_HEIGHT_UNITS / 2)
    update_camera

    axis_colors   = { lines: Flaty::Colors::WHITE, text: Flaty::Colors::WHITE }
    @camera_debug = Flaty::CameraDebug.new(@camera, axis_colors)

    @fps    = Flaty::FPS.new(SCREEN_WIDTH, @font)
    #@network = Network.new([Layer.new(7, 5), Layer.new(5, 5), Layer.new(5, 3), Layer.new(3, 2), Layer.new(2)])
    @network = Network.new([Layer.new(3, 2), Layer.new(2, 1), Layer.new(1)])
    puts "#{@network.layers.first.neurons.size}"
  end

  def update(delta)
  end

  def draw(target, states)
    Flaty.paint(Flaty::Colors::GRAY)

    radius = 0.4
    max_size = @network.layers.first.neurons
    @network.layers.size.times do |y|
      layer = @network.layers[y]
      distance = 10.0 / (layer.size + 1)
      layer.neurons.size.times do |neuron|
        Flaty.draw_center_circle(y * 1.5 + 1.0, (neuron + 1) * distance, radius, Flaty::Colors::BLACK)

        if y + 1 < @network.layers.size
          next_layer = @network.layers[y + 1]
          distance_2 = 10.0 / (next_layer.size + 1)
          next_layer.neurons.size.times do |connected_neuron|
            Flaty.draw_line(y * 1.5 + 1.0, (neuron + 1) * distance, (y + 1) * 1.5 + 1.0,
                            (connected_neuron + 1) * distance_2, Flaty::Colors::WHITE)
          end
        end
      end
    end

    @fps.draw(@delta)
    @camera_debug.draw if debug?
  end

  def button_down(code)
    @camera.key_pressed(self, code)
  end
end

game = Neural.new
game.loop
