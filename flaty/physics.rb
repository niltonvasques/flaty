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
      collision |= Collision::BOTTOM if obj2.y > obj1.y
      collision |= Collision::TOP if obj2.y < obj1.y

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

module Physics
  def self.solve_collision(body1, body2)
    self.solve_collisions(body1, [body2])
  end

  def self.solve_collisions(body1, candidates)
    new_position = body1.position.dup

    collision = Collision::NONE

    candidates.each do |obj|
      #binding.pry
      obj.debug = Gosu::Color::CYAN
      collision |= body1.colliding?(obj.collision_rect)
    end

    if Collision.bottom?(collision)
      body1.position.y = body1.previous_position.y

      collision = Collision::NONE
      candidates.each do |obj|
        obj.debug = Gosu::Color::CYAN
        collision |= body1.colliding?(obj.collision_rect)
      end
      body1.grounded if collision == Collision::NONE
    end

    if Collision.right?(collision)
      body1.position.y = new_position.y
      body1.position.x = body1.previous_position.x

      collision = Collision::NONE
      candidates.each do |obj|
        obj.debug = Gosu::Color::CYAN
        collision |= body1.colliding?(obj.collision_rect)
      end
    end

    if Collision.left?(collision)
      body1.position.y = new_position.y
      body1.position.x = body1.previous_position.x

      collision = Collision::NONE
      candidates.each do |obj|
        obj.debug = Gosu::Color::CYAN
        collision |= body1.colliding?(obj.collision_rect)
      end
    end

    if Collision.top?(collision)
      body1.position.y = body1.previous_position.y

      collision = Collision::NONE
      candidates.each do |obj|
        obj.debug = Gosu::Color::CYAN
        collision |= body1.colliding?(obj.collision_rect)
      end
      body1.ceil_hit if collision == Collision::NONE
    end

    body1.reset if collision != Collision::NONE
  end
end