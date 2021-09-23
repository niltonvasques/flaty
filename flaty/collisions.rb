module Collider
  def detect(shape)
    collisions(shape)
  end

  def collisions(shape)
    false
  end
end

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

  def self.horizontal?(collision)
    self.left?(collision) or self.right?(collision)
  end

  def self.vertical?(collision)
    self.bottom?(collision) or self.top?(collision)
  end

  def self.detect_rect(obj1, obj2)
    if (obj1.x + obj1.width >= obj2.x and obj1.x <= obj2.x + obj2.width and
        obj1.y + obj1.height >= obj2.y and obj1.y <= obj2.y + obj2.height)
      collision = Collision::NONE
      collision |= Collision::RIGHT if obj1.x < obj2.x and (obj1.x + obj1.width) > obj2.x and (obj1.x + obj1.width) < (obj2.x + obj2.width)
      collision |= Collision::LEFT if obj1.x > obj2.x and (obj1.x + obj1.width) > (obj2.x + obj2.width) and obj1.x < (obj2.x + obj2.width)
      collision |= Collision::BOTTOM if obj1.y > obj2.y
      collision |= Collision::TOP if obj1.y < obj2.y

      return collision
    end

    Collision::NONE
  end

  def self.detect_circle(obj1, obj2)
    a = obj1.x - obj2.x
    b = obj1.y - obj2.y
    squared_hypot = a*a + b*b
    squared_radius = (obj1.radius + obj2.radius) * (obj1.radius + obj2.radius)

    if (squared_hypot < squared_radius)
      collision = Collision::NONE
      collision |= Collision::RIGHT if obj1.x > obj2.x
      collision |= Collision::LEFT if obj1.x < obj2.x
      collision |= Collision::BOTTOM if obj1.y > obj2.y
      collision |= Collision::TOP if obj1.y < obj2.y

      return collision
    end

    Collision::NONE
  end

  # naive circle rect collision
  def self.detect_circle_rect(circle, rect)
    circle_rect = Rect[circle.x - circle.radius, circle.y - circle.radius,
                       circle.radius * 2, circle.radius * 2]
    self.detect_rect(circle_rect, rect)
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
