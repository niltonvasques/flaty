require 'gosu'
require 'ostruct'
require './vector_2d'

module Collision
  NONE, LEFT, RIGHT, TOP, BOTTOM = *[0, 1, 2, 4, 8]

  def self.top?(collision)
    collision & TOP == TOP
  end

  def self.bottom?(collision)
    collision & BOTTOM == BOTTOM
  end

  def self.left?(collision)
    collision & LEFT == LEFT
  end

  def self.right?(collision)
    collision & RIGHT == RIGHT
  end

  def self.detect(obj1, obj2)
    if (obj1.x + obj1.width >= obj2.x and obj1.x <= obj2.x + obj2.width and
        obj1.y + obj1.height >= obj2.y and obj1.y <= obj2.y + obj2.height)
      collision = Collision::NONE
      collision |= Collision::RIGHT if obj2.x < obj1.x
      collision |= Collision::LEFT if obj2.x > obj1.x
      collision |= Collision::BOTTOM if obj2.y < obj1.y
      collision |= Collision::TOP if obj2.y > obj1.y

      return collision
    end

    Collision::NONE
  end

  def self.to_s(collision)
    result = ""
    result += "top " if self.top? collision
    result += "bottom " if self.bottom? collision
    result += "left " if self.left? collision
    result += "right " if self.right? collision
    result
  end
end

class GameObject < OpenStruct
  #attr_accessor :image, :width, :height, :x, :y, :z, :speed

  def initialize(opts = {})
    default = {
      position: Vector2d[0,0], z: 0,
      speed: 0, scale_x: 1, scale_y: 1, current: 0, camera: true, debug: false
    }
    super(default.merge(opts))

    unless current_image.nil?
      self.width = World.camera.pixel_to_unit_x(current_image.width * self.scale_x)
      self.height = World.camera.pixel_to_unit_y(current_image.height * self.scale_y)
    end
  end

  def x; self.position.x; end
  def y; self.position.y; end

  def update
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
