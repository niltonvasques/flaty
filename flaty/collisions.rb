module Collider
  def detect(shape2)
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

  def self.detect(obj1, obj2)
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

  def self.to_s(collision)
    result = ""
    result += "top " if self.top? collision
    result += "bottom " if self.bottom? collision
    result += "left " if self.left? collision
    result += "right " if self.right? collision
    result
  end
end
