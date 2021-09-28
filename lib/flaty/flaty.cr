# https://github.com/oprypin/crsfml/tree/master/docs/tutorials
require "crsfml"
require "crsfml/audio"
require "flaty/game_window"
require "flaty/camera"

struct SF::Rect
  def self.xywh(x, y, w, h)
    SF::Rect.new(x, y - h, w, h)
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
    top + height
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

alias Vec2d = SF::Vector2(Float32)
alias Vec2i = SF::Vector2(Int32)
alias Rect  = SF::Rect(Float32)
alias RectI = SF::Rect(Int32)

module Flaty
  DEFAULT_WINDOW = SF::RenderWindow.new(SF::VideoMode.new(10, 10), "Flaty")
  DEFAULT_STATES = SF::RenderStates.new(
    transform: SF::Transform.new
    .scale(1, 1)  # Allow all operations to use 1 as the size of the grid
    #.translate(0.5, 0.5)  # Move the reference point to centers of grid squares
  )

  class_property window : SF::RenderWindow = DEFAULT_WINDOW
  class_property states : SF::RenderStates = DEFAULT_STATES

  def self.init(window : SF::RenderWindow, states : SF::RenderStates)
    Flaty.window.close()
    Flaty.window = window
    Flaty.states = states
  end

  def self.random_color()
    SF::Color.new(rand(128) + 128, rand(128) + 128, rand(128) + 128)
  end

  def self.draw_rect(x = 0.0, y = 0.0, width = 1.0, height = 1.0, color = Flaty::Colors::RED)
    #connection = SF::RectangleShape.new({ width, height }) #.center!
    connection = SF::RectangleShape.new({ width, height }).left_bottom_origin!
    connection.fill_color = color
    connection.position = SF::Vector2.new(x, y)
    Flaty.window.draw connection, Flaty.states
  end

  def self.draw_text(font, msg, x, y, size = 24, color = Flaty::Colors::BLACK)
    text = SF::Text.new

    # select the font
    text.font = font # font is a SF::Font

    # set the string to display
    text.string = msg

    # set the character size
    text.character_size = size # in pixels, not points!

    # set the color
    text.color = color

    text.position = Vec2i.new(x.to_i, y.to_i)

    # set the text style
    #text.style = (SF::Text::Bold | SF::Text::Underlined)

    Flaty.window.draw text
  end

  def self.paint(color)
    Flaty.window.clear color
  end

  module Colors
    BLACK = SF::Color.new(0,   0,     0)
    GRAY  = SF::Color.new(128, 128, 128)
    RED   = SF::Color.new(255, 0,     0)
    GREEN = SF::Color.new(0,   255,   0)
    BLUE  = SF::Color.new(0,   0,   255)
  end
end
