# https://github.com/oprypin/crsfml/tree/master/docs/tutorials
require "crsfml"
require "crsfml/audio"
require "flaty/game_window"
require "flaty/camera"
require "flaty/camera_debug"
require "flaty/collisions"
require "flaty/quadtree"
require "flaty/physics"
require "flaty/game_object"

struct SF::Rect
  def self.xywh(x, y, w, h)
    SF::Rect.new(x, y, w, h)
  end

  def center
    SF::Vector2.new(left + width/2, top + height/2)
  end

  def left_bottom_origin
    SF::Vector2.new(left, top + height)
  end

  def x
    left
  end

  def y
    top
  end
end

class SF::Transformable
  def center!
    self.origin = local_bounds.center
    self
  end

  def left_bottom_origin!
    self.origin = local_bounds.left_bottom_origin
    self
  end
end

alias Vec2d = SF::Vector2(Float64)
alias Vec2i = SF::Vector2(Int32)
alias Rect  = SF::Rect(Float64)
alias RectI = SF::Rect(Int32)

struct SF::Vector2
  def round
    SF::Vector2.new(self.x.round, self.y.round)
  end

  def to_s
    "(#{self.x},#{self.y})"
  end
end

module Flaty
  RAD = Math::PI / 180
  DEFAULT_WINDOW = SF::RenderWindow.new(SF::VideoMode.new(10, 10), "Flaty")
  DEFAULT_STATES = SF::RenderStates.new(
    transform: SF::Transform.new
    .scale(1, 1)  # Allow all operations to use 1 as the size of the grid
    #.translate(0.5, 0.5)  # Move the reference point to centers of grid squares
  )

  class_property window : SF::RenderWindow = DEFAULT_WINDOW
  class_property states : SF::RenderStates = DEFAULT_STATES
  class_property camera : Camera = Camera.new(0, 0, 0)

  def self.init(window : SF::RenderWindow, states : SF::RenderStates, camera : Camera)
    Flaty.window.close() # required because of the forced window initialized on GameWindow
    Flaty.window = window
    Flaty.states = states
    Flaty.camera = camera
  end

  def self.elapsed_milis
    Flaty::GameWindow.elapsed_milis
  end

  def self.elapsed_seconds
    Flaty::GameWindow.elapsed_seconds
  end

  def self.delta
    Flaty::GameWindow.delta_seconds
  end

  def self.pressed?(code)
    SF::Keyboard.key_pressed?(code)
  end

  def self.random_color()
    SF::Color.new(rand(128) + 128, rand(128) + 128, rand(128) + 128)
  end

  def self.draw_sprite(sprite : SF::Sprite, x = 0.0, y = 0.0)
    sprite.position = SF::Vector2.new(x, -y)
    Flaty.window.draw sprite, Flaty.states
  end

  def self.draw_circle(x = 0.0, y = 0.0, radius = 1.0, color = Flaty::Colors::RED)
    connection = SF::CircleShape.new(radius)
    connection.fill_color = color
    connection.position = SF::Vector2.new(x, -y-radius*2) # xy left bottom
    Flaty.window.draw connection, Flaty.states
  end

  def self.draw_center_circle(x = 0.0, y = 0.0, radius = 1.0, color = Flaty::Colors::RED)
    connection = SF::CircleShape.new(radius)
    connection.fill_color = color
    connection.position = SF::Vector2.new(x-radius, -y-radius) # xy left bottom
    Flaty.window.draw connection, Flaty.states
  end

  def self.draw_rect(x = 0.0, y = 0.0, width = 1.0, height = 1.0, color = Flaty::Colors::RED,
      angle = 0.0)
    connection = SF::RectangleShape.new({ width, height }).left_bottom_origin!
    connection.fill_color = color
    connection.position = SF::Vector2.new(x, -y)
    connection.rotate(angle)
    Flaty.window.draw connection, Flaty.states
  end

  def self.draw_center_rect(x = 0.0, y = 0.0, width = 1.0, height = 1.0, color = Flaty::Colors::RED,
      angle = 0.0)
    connection = SF::RectangleShape.new({ width, height }).center!
    connection.fill_color = color
    connection.position = SF::Vector2.new(x, -y)
    connection.rotate(angle)
    Flaty.window.draw connection, Flaty.states
  end

  def self.draw_rect_empty(x = 0.0, y = 0.0, width = 1.0, height = 1.0, color = Flaty::Colors::RED)
    self.draw_line(x, y, x + width, y, color)
    self.draw_line(x, y + height, x + width, y + height, color)
    self.draw_line(x, y, x, y + height, color)
    self.draw_line(x + width, y, x + width, y + height, color)
  end

  def self.draw_line(x1 : Float64, y1 : Float64, x2 : Float64, y2 : Float64, color = Flaty::Colors::BLACK)
    line = SF::VertexArray.new(SF::Lines, 2)
    line[0] = SF::Vertex.new(Vec2d.new(x1, -y1), color)
    line[1] = SF::Vertex.new(Vec2d.new(x2, -y2), color)
    Flaty.window.draw(line, Flaty.states)
  end

  def self.draw_text_world(font, msg, x : Float64, y : Float64, size = 24, color = Flaty::Colors::BLACK)
    scale = Flaty.camera.scale
    world_pos = Vec2i.new((x * scale).to_i, (-y * scale).to_i)
    pixel_pos = Flaty.window.map_coords_to_pixel(world_pos, Flaty.camera.view)

    self.draw_text(font, msg, pixel_pos.x.to_i, pixel_pos.y.to_i, size, color, true)
  end

  def self.draw_text_in_pixels(font, msg, x : Int32, y : Int32, size = 24,
      color = Flaty::Colors::BLACK)
    self.draw_text(font, msg, x, y, size, color, true)
  end

  def self.draw_text(font, msg, x : Int32, y : Int32, size = 24, color = Flaty::Colors::BLACK,
      pixels = false)
    text = SF::Text.new

    # select the font
    text.font = font # font is a SF::Font

    # set the string to display
    text.string = msg

    # set the character size
    text.character_size = size # in pixels, not points!

    # set the color
    text.color = color

    text.position = Vec2i.new(x, y)

    #text.style = (SF::Text::Bold | SF::Text::Underlined)

    v = Flaty.window.view.dup
    Flaty.window.view = Flaty.window.default_view if pixels

    Flaty.window.draw text

    Flaty.window.view = v if pixels
  end

  def self.paint(color)
    Flaty.window.clear color
  end

  def self.random_color
    r = (128 * rand).to_i + 128
    g = (128 * rand).to_i + 128
    b = (128 * rand).to_i + 128
    SF::Color.new(r, g, b)
  end

  def self.playing?(sound : SF::Sound)
    sound.status == SF::SoundSource::Status::Playing
  end

  def self.norm_angle(angle)
    return angle - 2 * Math::PI if angle > 2 * Math::PI
    return angle + 2 * Math::PI if angle < 0
    angle
  end

  module Colors
    BLACK     = SF::Color.new(0,   0,     0)
    WHITE     = SF::Color.new(255, 255, 255)
    GRAY      = SF::Color.new(128, 128, 128)
    RED       = SF::Color.new(255, 0,     0)
    GREEN     = SF::Color.new(0,   255,   0)
    BLUE      = SF::Color.new(0,   0,   255)
    YELLOW    = SF::Color.new(255, 255,   0)
    CYAN      = SF::Color.new(255, 255,   0)
    DEBUG     = SF::Color.new(255, 255,   0, 128)
    RED_ALPHA = SF::Color.new(255, 0,     0, 128)
  end
end
