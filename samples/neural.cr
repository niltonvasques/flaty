require "flaty/flaty"
require "flaty/fps"
require "flaty/math/matrix"

def sigmoid(x : Float64)
  1.0 / (1.0 + Math.exp(-x))
end

# does input layer have biases?
# does output layer have biases?
class Layer
  property mat_a, mat_w, mat_b

  def initialize(neurons : Int32, previous_layer_size : Int32 = 0, @type = :hidden)
    @mat_a = Matrix(Float64).new(neurons, 1) { 0.0 }
    @mat_b = Matrix(Float64).new(neurons, 1) { @type == :input ? 0.0 : rand }
    @mat_w = Matrix(Float64).new(neurons, previous_layer_size) { rand }
  end

  def feed(inputs : Array(Float64))
    inputs.each_with_index { |input, index| @mat_a[index, 0] = sigmoid(input) }
  end

  def neurons
    @mat_a.round(2).to_a.zip(@mat_b.round(2))
  end

  def forward(previous_layer : Layer)
    #puts "#{@mat_w.column_count} w #{previous_layer.mat_a.row_count} a"
    #puts @mat_w
    #puts "*"
    #puts previous_layer.mat_a
    #puts "+"
    #puts @mat_b
    @mat_a = (@mat_w * previous_layer.mat_a) + @mat_b
    @mat_a.map! { |value| sigmoid(value) }
    #puts "="
    #puts @mat_a
  end

  def back_propagate(cost : Matrix(Float64))
    return if @type == :input
    n = Network::LEARNING_RATE
    mat = Matrix(Float64).new(@mat_b.rows.size, 1, 0)
    i = 0
    cost.each_with_index { |v, row, col| mat[i] = v / @mat_b[i]; i += 1}
    mat = mat * n
    @mat_b -= mat

    delta = cost * n
    i = 0
    delta2 = Matrix(Float64).new(@mat_a.rows.size, 1, 0)
    cost.each_with_index { |v, row, col| delta2[i] = delta[i] * @mat_a[i]; i += 1 }

    puts "delta"
    puts "#{@mat_a}"
    puts "#{delta}"
    puts "#{delta2}"

    #mat = Matrix(Float64).new(@mat_w.rows.size, 1, 0)
    #i = 0
    #cost.each_with_index { |v, row, col| mat[i] = v / @mat_w[i]; i += 1}
    #mat = mat * n
    #@mat_w -= delta2
  end

  def size
    @mat_a.rows.size
  end
end

class Network
  LEARNING_RATE = 0.5

  property layers

  def initialize(@layers : Array(Layer))
  end

  def feed_forward(inputs : Array(Float64))
    @layers.first.feed(inputs)
    1.upto(@layers.size - 1) { |i| @layers[i].forward(@layers[i - 1]) }
  end

  def back_propagate(expected : Matrix(Float64))
    c = cost(expected)
    #@layers.reverse.each { |layer| layer.back_propagate(c) }
    @layers.last.back_propagate(c)
  end

  def cost(expected : Matrix(Float64))
    (@layers.last.mat_a - expected).map! { |v| v * v } #.reduce(0) { |acc, v| acc + v }
  end
end

class Neural < Flaty::GameWindow
  SCREEN_WIDTH        = 1500
  SCREEN_HEIGHT       = 1500
  CAMERA_WIDTH_UNITS  = 10.0
  CAMERA_HEIGHT_UNITS = 10.0
  SCALE               = SCREEN_WIDTH / CAMERA_WIDTH_UNITS

  def initialize
    super(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS, SCALE, "Neural Visualizer")

    ## assets
    @font      = SF::Font.from_file("assets/Cantarell-Regular.otf")

    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @camera.look(CAMERA_WIDTH_UNITS / 2, CAMERA_HEIGHT_UNITS / 2)
    update_camera

    axis_colors   = { lines: Flaty::Colors::WHITE, text: Flaty::Colors::WHITE }
    @camera_debug = Flaty::CameraDebug.new(@camera, axis_colors)

    @fps    = Flaty::FPS.new(SCREEN_WIDTH, @font)
    #@network = Network.new([Layer.new(7, 5), Layer.new(5, 5), Layer.new(5, 3), Layer.new(3, 2), Layer.new(2)])
    #@network.feed_forward([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0])
    @network = Network.new([Layer.new(3, 0, :input), Layer.new(2, 3), Layer.new(2, 2)])
    @network.feed_forward([1.0, 2.0, 3.0])
    puts "cost: "
    puts @network.cost(Matrix.columns([[1.0, 0.0]]))
    @network.back_propagate(Matrix.columns([[1.0, 0.0]]))
    puts "after propagation: "
    @network.feed_forward([1.0, 2.0, 3.0])
    puts @network.cost(Matrix.columns([[1.0, 0.0]]))
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
            cnx = (y + 1) * 1.5 + 1.0
            cny = (connected_neuron + 1) * distance_2

            Flaty.draw_line(nx, ny, cnx, cny, Flaty::Colors::WHITE)

            cny += (ny-cny)/2.0
            cnx -= 1.7/2
            #w = layer.mat_w[connected_neuron, index]
            #Flaty.draw_text_world(@font, "#{w.round(2)}", cnx, cny, 16, Flaty::Colors::RED)
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
