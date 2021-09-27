require 'gosu'
require 'flaty/game_window'
require 'flaty/camera_debug'
require 'flaty/game_object'
require 'flaty/math/vector_2d'
require 'flaty/math/rect'
require 'flaty/quadtree'
require 'flaty/benchmark'
require 'flaty/time'

class Flaty

  MIN_PRECISION = 0.000000000001
  def self.draw_circle(center, radius, c = Gosu::Color::BLACK, z = 0)
    color = Gosu::Color::BLACK
    precision = [(GameWindow.camera.width / 1000.0).abs, MIN_PRECISION].max

    # circle equation
    # y² = r² - x²
    x2 = -radius
    x1 = x2
    y1 = Math.sqrt(radius*radius - x1*x1)

    while x2 <= radius
      y2 = Math.sqrt(radius*radius - x2*x2)
      w = (x2 - x1)
      h = (y2 - y1)
      Flaty.draw_line(x1 + center.x, y1 + center.y, c, x2 + center.x, y2 + center.y, c, z)
      Flaty.draw_line(x1 + center.x, -y1 + center.y, c, x2 + center.x, -y2 + center.y, c, z)
      x1 = x2
      y1 = y2
      x2 += precision
    end
    x2 = radius
    y2 = Math.sqrt(radius*radius - x2*x2)
    w = (x2 - x1)
    h = (y2 - y1)
    Flaty.draw_line(x1 + center.x, y1 + center.y, c, x2 + center.x, y2 + center.y, c, z)
    Flaty.draw_line(x1 + center.x, -y1 + center.y, c, x2 + center.x, -y2 + center.y, c, z)
  end

  def self.draw_rect(x, y, width = 1, height = 1, c = Gosu::Color::BLACK, z = 0, mode = :default,
                     thickness = 0)
    camera = GameWindow.camera
    x = camera.translate_x(x)
    y = camera.translate_y(y) - (camera.unit_y * height)
    w = width * camera.unit_x + thickness
    h = height * camera.unit_y + thickness
    Gosu.draw_rect(x, y, w, h, c, z, mode)
  end

  def self.draw_rect_empty(x, y, width = 1, height = 1, c = Gosu::Color::BLACK, z = 0)
    camera = GameWindow.camera
    Flaty.draw_line(x, y, c, x + width, y, c, z)
    Flaty.draw_line(x, y + height, c, x + width, y + height, c, z)
    Flaty.draw_line(x, y, c, x, y + height, c, z)
    Flaty.draw_line(x + width, y, c, x + width, y + height, c, z)
  end

  def self.draw_line(x1, y1, c1, x2, y2, c2, z = 0, mode = :default)
    camera = GameWindow.camera
    x1 = camera.translate_x(x1)
    y1 = camera.translate_y(y1)
    x2 = camera.translate_x(x2)
    y2 = camera.translate_y(y2)
    Gosu.draw_line(x1, y1, c1, x2, y2, c2, z, mode)
  end

  def self.draw_text(font, text, x, y, z = 0, color = Gosu::Color::BLACK)
    camera = GameWindow.camera
    x = camera.translate_x(x)
    y = camera.translate_y(y)
    font.draw_text(text, x, y, z, 1.0, 1.0, color)
  end

  def self.paint(color)
    Gosu.draw_rect(0, 0, GameWindow.width, GameWindow.height, color, 0)
  end

  def self.seconds
    Gosu.milliseconds / Second.in_millis
  end

  def self.random_color
    r = (0xff * rand).to_i
    g = (0xff * rand).to_i
    b = (0xff * rand).to_i
    Gosu::Color.argb(0x5f000000 + (r << 16) + (g << 8) + (b))
  end
end
