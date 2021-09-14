require 'gosu'
require 'engine/game_window'
require 'engine/camera_debug'
require 'engine/benchmark'
require 'engine/engine'
require 'engine/time'

class Flaty
  def self.draw_rect(x, y, width = 1, height = 1, c = Gosu::Color::BLACK, z = 0, mode = :default)
    camera = GameWindow.camera
    x = camera.translate_x(x)
    y = camera.translate_y(y) - (camera.unit_y * height)
    w = width * camera.unit_x
    h = height * camera.unit_y
    Gosu.draw_rect(x, y, w, h, c, z, mode)
  end
end
