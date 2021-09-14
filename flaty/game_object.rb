require 'gosu'
require 'ostruct'
require 'flaty/math/vector_2d'
require 'flaty/physics'

class GameObject < OpenStruct
  #attr_accessor :image, :width, :height, :x, :y, :z, :speed

  def initialize(opts = {})
    default = {
      position: Vector2d[0,0], z: 0, previous_position: Vector2d[0,0], acceleration: Vector2d[0,0],
      speed: Vector2d[0,0], scale_x: 1, scale_y: 1, current: 0, camera: true, debug: false,
      rect: Rect[0, 0, 0, 0], max_speed: Vector2d[0, 0], damp: 0.8, angle: 0
    }
    super(default.merge(opts))
    self.previous_position = self.position.dup

    unless current_image.nil?
      self.width = GameWindow.camera.pixel_to_unit_x(current_image.width * self.scale_x)
      self.height = GameWindow.camera.pixel_to_unit_y(current_image.height * self.scale_y)
    end
  end

  def x; self.position.x; end
  def y; self.position.y; end

  def collision_rect
    self.rect.x = self.x
    self.rect.y = self.y
    self.rect.width = self.width
    self.rect.height = self.height
    self.rect
  end

  def update
    unless current_image.nil?
      self.width = GameWindow.camera.pixel_to_unit_x(current_image.width * self.scale_x)
      self.height = GameWindow.camera.pixel_to_unit_y(current_image.height * self.scale_y)
    end
    self.previous_position = self.position.dup

    self.speed += self.acceleration * GameWindow.delta
    self.speed.x = self.max_speed.x if self.speed.x > 0 and self.speed.x.abs > self.max_speed.x
    self.speed.x = -self.max_speed.x if self.speed.x < 0 and self.speed.x.abs > self.max_speed.x
    self.speed.y = self.max_speed.y if self.speed.y > 0 and self.speed.y.abs > self.max_speed.y
    self.speed.y = -self.max_speed.y if self.speed.y < 0 and self.speed.y.abs > self.max_speed.y
    self.speed.y *= self.damp if self.acceleration.y == 0
    self.speed.x *= self.damp if self.acceleration.x == 0
    self.speed.x = 0 if self.speed.x.abs < 0.01

    self.position += self.speed * GameWindow.delta
  end

  def reset
    self.position = self.previous_position
  end

  def draw
    unless current_image.nil?
      self.width = GameWindow.camera.pixel_to_unit_x(current_image.width * self.scale_x)
      self.height = GameWindow.camera.pixel_to_unit_y(current_image.height * self.scale_y)
    end
    return if outside_window?

    new_pos = self.position

    new_pos = GameWindow.camera.translate(self) if self.camera

    draw_obj(new_pos.x, new_pos.y, z)
    if self.debug and GameWindow.debug
      Gosu.draw_rect(new_pos.x, new_pos.y, width * GameWindow.camera.unit_x,
                     height * GameWindow.camera.unit_y, self.debug, z = 100, mode = :add)
    end
  end

  def draw_obj(x, y, z)
    current_image.draw(x, y, z, scale_x = self.scale_x, scale_y = self.scale_y)
  end

  def grounded
    self.speed.y = 0
  end

  def ceil_hit
    self.speed.y = 0
  end

  def outside_window?
    return false unless self.camera
    not GameWindow.camera.visible?(self)
  end

  def current_image
    return image if image
    tiles[current]
  end

  def colliding?(obj)
    Collision.detect(obj, self.collision_rect)
  end
end
