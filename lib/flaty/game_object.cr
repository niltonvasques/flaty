require "flaty"

class Flaty::GameObject

  property position : Vec2d
  property previous_position : Vec2d
  property speed : Vec2d
  property acceleration : Vec2d
  property mass : Float64
  property rect : Rect

  def initialize(opts = {} of Symbol => (Int32 | Vec2d | Rect | Float64 | Bool))
    default = {
      :position => Vec2d.new(0,0),
      :previous_position => Vec2d.new(0,0),
      :rect => Rect.xywh(0.0, 0.0, 0.0, 0.0),
      :mass => 1.0,
      :acceleration => Vec2d.new(0,0),
      :speed => Vec2d.new(0,0),
      :max_speed => Vec2d.new(0,0),
      :damp => 1.0,
      :elasticity => 1.0,
      :scale_x => 1.0,
      :scale_y => 1.0,
      :angle => 0.0,
      :current => 0,
      :camera => true,
      :debug => false
    }.merge(opts)

    @position          = default[:position].as Vec2d
    @rect              = default[:rect].as Rect
    @mass              = default[:mass].as Float64
    @speed             = default[:speed].as Vec2d
    @acceleration      = default[:acceleration].as Vec2d
    @max_speed         = default[:max_speed].as Vec2d
    @elasticity        = default[:elasticity].as Float64
    @damp              = default[:damp].as Float64
    @current           = default[:current].as Int32
    @previous_position = default[:position].as Vec2d

#    unless current_image.nil?
#      self.width = GameWindow.camera.pixel_to_unit_x(current_image.width * self.scale_x)
#      self.height = GameWindow.camera.pixel_to_unit_y(current_image.height * self.scale_y)
#    end
  end

  def x; @position.x; end
  def y; @position.y; end

  def center
    Vec2d.new(@position.x + @width/2.0, @position.y + @height/2.0)
  end

#  def update
#    update_width_height
#    self.previous_position = self.position.dup
#
#    self.speed += self.acceleration * GameWindow.delta
#    self.speed.x = self.max_speed.x if self.speed.x > 0 and self.speed.x.abs > self.max_speed.x
#    self.speed.x = -self.max_speed.x if self.speed.x < 0 and self.speed.x.abs > self.max_speed.x
#    self.speed.y = self.max_speed.y if self.speed.y > 0 and self.speed.y.abs > self.max_speed.y
#    self.speed.y = -self.max_speed.y if self.speed.y < 0 and self.speed.y.abs > self.max_speed.y
#    self.speed.y *= self.damp if self.acceleration.y == 0
#    self.speed.x *= self.damp if self.acceleration.x == 0
#    self.speed.x = 0 if self.speed.x.abs < 0.01
#
#    self.position += self.speed * GameWindow.delta
#  end
#
#  def reset
#    self.position = self.previous_position
#  end
#
#  def draw
#    unless current_image.nil?
#      self.width = GameWindow.camera.pixel_to_unit_x(current_image.width * self.scale_x)
#      self.height = GameWindow.camera.pixel_to_unit_y(current_image.height * self.scale_y)
#    end
#    return if outside_window?
#
#    new_pos = self.position
#
#    new_pos = GameWindow.camera.translate(self) if self.camera
#
#    draw_obj(new_pos.x, new_pos.y, z)
#    if self.debug and GameWindow.debug
#      Gosu.draw_rect(new_pos.x, new_pos.y, width * GameWindow.camera.unit_x,
#                     height * GameWindow.camera.unit_y, self.debug, z = 100, mode = :add)
#    end
#  end
#
#  def draw_obj(x, y, z)
#    current_image.draw(x, y, z, scale_x = self.scale_x, scale_y = self.scale_y)
#  end
#
#  def update_width_height
#    unless current_image.nil?
#      self.width = GameWindow.camera.pixel_to_unit_x(current_image.width * self.scale_x)
#      self.height = GameWindow.camera.pixel_to_unit_y(current_image.height * self.scale_y)
#    end
#  end
#
#  def grounded
#  end
#
#  def ceil_hit
#  end
#
#  def outside_window?
#    return false unless self.camera
#    not GameWindow.camera.visible?(self)
#  end
#
#  def current_image
#    return image if image
#    tiles[current] if tiles
#  end
#end
#
#class RectGameObject < GameObject
#  include Collider
#
#  def collisions(obj)
#    case obj
#    when CircleGameObject then Collision.detect_circle_rect(obj, self.collision_rect)
#    when RectGameObject   then Collision.detect_rect(self.collision_rect, obj)
#    when Rect             then Collision.detect_rect(self.collision_rect, obj)
#    else Collision::NONE
#    end
#  end
#
#  def collision_rect
#    self.rect.x = self.x
#    self.rect.y = self.y
#    self.rect.width = self.width
#    self.rect.height = self.height
#    self.rect
#  end
#end
#
#class CircleGameObject < GameObject
#  include Collider
#
#  def initialize(opts = {})
#    super({ radius: 1 }.merge(opts))
#    self.width = self.radius * 2.0
#    self.height = self.radius * 2.0
#  end
#
#  def center
#    self.position
#  end
#
#  def collision_rect
#    self.rect.x = self.x - self.radius
#    self.rect.y = self.y - self.radius
#    self.rect.width = self.radius * 2
#    self.rect.height = self.radius * 2
#    self.rect
#  end
#
#  def collisions(obj)
#    case obj
#    when CircleGameObject then Collision.detect_circle(self, obj)
#    when RectGameObject   then Collision.detect_circle_rect(self, obj)
#    when Rect             then Collision.detect_circle_rect(self, obj)
#    else Collision::NONE
#    end
#  end
#
#  def draw
#    draw_debug
#    return draw_image if current_image
#    Flaty.draw_circle(self.center, self.radius, self.color)
#  end
#
#  def draw_image
#    if current_image
#      self.scale_x = self.width / GameWindow.camera.pixel_to_unit_x(current_image.width.to_f)
#      self.scale_y = self.height / GameWindow.camera.pixel_to_unit_y(current_image.height.to_f)
#    end
#    return if outside_window?
#
#    new_pos = self.position
#
#    new_pos = GameWindow.camera.translate(self.collision_rect) if self.camera
#
#    draw_obj(new_pos.x, new_pos.y, z)
#    if self.debug and GameWindow.debug
#      Gosu.draw_rect(new_pos.x, new_pos.y, width * GameWindow.camera.unit_x,
#                     height * GameWindow.camera.unit_y, self.debug, z = 100, mode = :add)
#    end
#  end
#
#  def draw_obj(x, y, z)
#    current_image.draw(x, y, z, self.scale_x, self.scale_y, self.color, :add)
#  end
#
#  def draw_debug
#    if GameWindow.debug
#      Flaty.draw_line(self.center.x, self.center.y, self.color, self.center.x + self.speed.x, self.center.y + self.speed.y, self.color)
#      if self.theta
#        msg = "#{self.theta} #{self.speed.round}"
#        msg += " #{self.phi}" if self.phi
#        Flaty.draw_text(Collisions.font, msg, self.x, self.y) if self.theta
#      end
#      Flaty.draw_circle(self.center, self.radius, self.color) unless current_image
#    end
#  end
#
#  def update_width_height
#  end
end
