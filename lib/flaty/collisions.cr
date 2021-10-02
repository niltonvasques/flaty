module Collider
  def detect(shape)
    collisions(shape)
  end

  def collisions(shape)
    false
  end
end

module Collision
  NONE   = 0
  LEFT   = 1
  RIGHT  = 2
  TOP    = 4
  BOTTOM = 8

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

  def self.horizontal?(collision)
    self.left?(collision) || self.right?(collision)
  end

  def self.vertical?(collision)
    self.bottom?(collision) || self.top?(collision)
  end

  def self.detect_rect(obj1, obj2)
    return Collision::NONE if obj1.x + obj1.width < obj2.x
    return Collision::NONE if obj1.x > obj2.x + obj2.width
    return Collision::NONE if obj1.y + obj1.height < obj2.y
    return Collision::NONE if obj1.y > obj2.y + obj2.height

    collision = Collision::NONE
    collision |= Collision::RIGHT if obj1.x < obj2.x && (obj1.x + obj1.width) > obj2.x && (obj1.x + obj1.width) < (obj2.x + obj2.width)
    collision |= Collision::LEFT if obj1.x > obj2.x && (obj1.x + obj1.width) > (obj2.x + obj2.width) && obj1.x < (obj2.x + obj2.width)
    collision |= Collision::BOTTOM if obj1.y > obj2.y
    collision |= Collision::TOP if obj1.y < obj2.y

    collision
  end

  def self.detect_circle(obj1, obj2)
    a = obj1.x - obj2.x
    b = obj1.y - obj2.y
    squared_hypot = a*a + b*b
    squared_radius = (obj1.radius + obj2.radius) * (obj1.radius + obj2.radius)

    if (squared_hypot < squared_radius)
      return circle_direction(obj1.x, obj1.y, obj2.x, obj2.y)
    end

    Collision::NONE
  end

  # https://stackoverflow.com/questions/401847/circle-rectangle-collision-detection-intersection
  def self.detect_circle_rect(circle, rect)
    rect_half_width = rect.width / 2.0
    rect_half_height = rect.height / 2.0

    rx = rect.x + rect_half_width
    ry = rect.y + rect_half_height

    a = (circle.x - rx).abs
    b = (circle.y - ry).abs

    return Collision::NONE if a > rect_half_width + circle.radius
    return Collision::NONE if b > rect_half_height + circle.radius

    return circle_direction(circle.x, circle.y, rx, ry) if a <= rect_half_width
    return circle_direction(circle.x, circle.y, rx, ry) if b <= rect_half_height

    distance = (a - rect_half_width) ** 2 + (b - rect_half_height) ** 2
    return circle_direction(circle.x, circle.y, rx, ry) if distance <= (circle.radius ** 2)

    Collision::NONE
  end

  def self.circle_direction(x1, y1, x2, y2)
    collision = Collision::NONE
    if x1 - x2 < 0
      collision |= Collision::LEFT
    else
      collision |= Collision::RIGHT
    end
    if y1 - y2 < 0
      collision |= Collision::TOP
    else
      collision |= Collision::BOTTOM
    end
    collision
  end

  def self.detect_circle_point(circle, point)
    a = circle.x - point.x
    b = circle.y - point.y
    squared_hypot = a*a + b*b
    squared_radius = circle.radius * circle.radius

    if (squared_hypot < squared_radius)
      collision = Collision::NONE
      collision |= Collision::RIGHT if circle.x > point.x
      collision |= Collision::LEFT if circle.x < point.x
      collision |= Collision::BOTTOM if circle.y > point.y
      collision |= Collision::TOP if circle.y < point.y

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
