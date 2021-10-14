require "flaty/flaty"
require "flaty/fps"

def sigmoid(x : Float64)
  1.0 / (1.0 + Math.exp(-x))
end

class Neuron
  property activation, weights

  def initialize(@activation : Float64 = 0.0, weights = 0)
    @weights = Array(Float64).new(weights) { rand }
  end
end

class Layer
  property neurons

  def initialize(neurons : Int32, next_layer_size : Int32 = 0)
    @neurons = Array(Neuron).new(neurons) { Neuron.new(0.0, next_layer_size) }
  end

  def feed(inputs : Array(Float64))
    @neurons.each_with_index { |n, index| n.activation = inputs[index] }
  end

  def feed_forward(previous_layer : Layer)
    @neurons.each_with_index do |neuron, index|
      neuron.activation = previous_layer.weighted_sum(index)
    end
  end

  def weighted_sum(index)
    sigmoid(@neurons.reduce(0.0) { |acc, neuron| neuron.activation * neuron.weights[index] })
  end

  def size
    @neurons.size
  end
end

class Network
  property layers

  def initialize(@layers : Array(Layer))
  end

  def feed_forward(inputs : Array(Float64))
    @layers.first.feed(inputs)
    1.upto(@layers.size - 1) { |i| @layers[i].feed_forward(@layers[i - 1]) }
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
    @network.feed_forward([1.0, 2.0, 3.0])
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
      layer.neurons.each_with_index do |neuron, index|
        nx = y * 1.5 + 1.0
        ny = (index + 1) * distance
        Flaty.draw_center_circle(nx, ny, radius, Flaty::Colors::BLACK)
        Flaty.draw_text_world(@font, "#{neuron.activation}", nx, ny, 24, Flaty::Colors::YELLOW)

        if y + 1 < @network.layers.size
          next_layer = @network.layers[y + 1]
          distance_2 = 10.0 / (next_layer.size + 1)
          next_layer.neurons.size.times do |connected_neuron|
            Flaty.draw_line(y * 1.5 + 1.0, (index + 1) * distance, (y + 1) * 1.5 + 1.0,
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
