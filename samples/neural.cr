require "flaty/flaty"
require "flaty/fps"
require "flaty/math/matrix"

def sigmoid(x : Float64)
  1.0 / (1.0 + Math.exp(-x))
end

#weights = Matrix.rows([
#  [1,2,3],
#  [4,5,6],
#  [7,8,9],
#])
#activations = Matrix.rows([
#  [0.5],
#  [0.2],
#  [0.9],
#])
class Layer
  property mat_a, mat_w, mat_b

  def initialize(neurons : Int32, next_layer_size : Int32 = 0)
    @mat_a = Matrix(Float64).new(neurons, 1) { |idx, row, col| 0.0 }
    @mat_b = Matrix(Float64).new(neurons, 1) { |idx, row, col| (rand * -10.0) }
    @mat_w = Matrix(Float64).new(next_layer_size, neurons) { |idx, row, col| rand }
  end

  def feed(inputs : Array(Float64))
    inputs.each_with_index { |input, index| @mat_a[index, 0] = input }
  end

  def neurons
    @mat_a.round(2).to_a.zip(@mat_b.round(2))
  end

  def forward(previous_layer : Layer)
    puts previous_layer.mat_w
    puts "*"
    puts previous_layer.mat_a
    puts "+"
    puts @mat_b
    @mat_a = (previous_layer.mat_w * previous_layer.mat_a) + @mat_b
    @mat_a.map! { |value| sigmoid(value) }
    puts "="
    puts @mat_a
  end

  def size
    @mat_a.rows.size
  end
end

class Network
  property layers

  def initialize(@layers : Array(Layer))
  end

  def feed_forward(inputs : Array(Float64))
    @layers.first.feed(inputs)
    1.upto(@layers.size - 1) { |i| @layers[i].forward(@layers[i - 1]) }
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
  end

  def update(delta)
  end

  def draw(target, states)
    Flaty.paint(Flaty::Colors::GRAY)

    radius = 0.4
    max_size = @network.layers.first.size
    @network.layers.size.times do |y|
      layer = @network.layers[y]
      distance = 10.0 / (layer.size + 1)
      layer.neurons.each_with_index do |neuron, index|
        nx = y * 1.5 + 1.0
        ny = (index + 1) * distance
        Flaty.draw_center_circle(nx, ny, radius, Flaty::Colors::BLACK)
        Flaty.draw_text_world(@font, neuron.to_s, nx, ny, 24, Flaty::Colors::YELLOW)

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
#layers = [Layer.new(3, 2), Layer.new(2, 1), Layer.new(1)]
#network = Network.new(layers)
#network.feed_forward([1.0, 2.0, 3.0])
#layers[1].forward(layers[0])
#puts network.layers[0].mat_a
#puts network.layers[0].mat_w
#puts network.layers[0].mat_w * network.layers[0].mat_a
#puts Matrix.rows([[1,1,1], [1,1,1]])
#puts "X"
#puts Matrix.columns([[2,2,2]])
#puts "="
##puts Matrix.rows([[1,1,1], [1,1,1]]) * Matrix.columns([[2,2,2]])
#puts Matrix.rows([[1,2],[3,4]]) * Matrix.columns([[1,2]])
#puts Matrix.rows([[1,2,3],[3,4,5],[3,4,5]]) * Matrix.columns([[1,2,3]])
#weights = Matrix.rows([
#  [1,2,3],
#  [4,5,6],
#  [7,8,9],
#])
#activations = Matrix.rows([
#  [0.5],
#  [0.2],
#  [0.9],
#])
#puts weights * activations
#puts Matrix.rows([[4]]) * Matrix.columns([[1,2,3,5]])
