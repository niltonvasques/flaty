require 'gosu'
require 'ostruct'
require './vector_2d'
require './physics'

class GameObject < OpenStruct
  #attr_accessor :image, :width, :height, :x, :y, :z, :speed

  def initialize(opts = {})
    default = {
      position: Vector2d[0,0], z: 0, previous_position: Vector2d[0,0],
      speed: Vector2d[0,0], scale_x: 1, scale_y: 1, current: 0, camera: true, debug: false
    }
    super(default.merge(opts))
    self.previous_position = self.position.dup

    unless current_image.nil?
      self.width = World.camera.pixel_to_unit_x(current_image.width * self.scale_x)
      self.height = World.camera.pixel_to_unit_y(current_image.height * self.scale_y)
    end
  end

  def x; self.position.x; end
  def y; self.position.y; end

  def update
    self.previous_position = self.position.dup

    self.position += self.speed * GameWindow.delta
  end

  def reset
    self.position = self.previous_position
  end

  def draw
    return if outside_window?

    new_x = self.x
    new_y = self.y

    if self.camera
      new_x = World.camera.translate_x(self.x)
      new_y = World.camera.translate_y(self.y)
    end

    current_image.draw(new_x, new_y, z, scale_x = self.scale_x, scale_y = self.scale_y)
    if self.debug and GameWindow.debug
      Gosu.draw_rect(new_x, new_y, width * World::UNIT_X, height * World::UNIT_Y,
                     self.debug, z = 100, mode = :add)
    end
  end

  def outside_window?
    self.x > GameWindow::SCREEN_WIDTH or (self.x + current_image.width * self.scale_x) < 0
  end

  def current_image
    return image if image
    tiles[current]
  end

  def colliding?(obj)
    Collision.detect(obj, self)
  end
end
