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

module Physics
  def self.elastic_collisions(bodies)
    bodies.each_index do |i|
      (i+1).upto(bodies.size - 1) do |j|
        Physics.elastic_collision(bodies[i], bodies[j])
      end
    end
  end

  def self.elastic_collision(body1, body2)
    collision = body1.colliding?(body2)
    if collision != Collision::NONE and (body1.rigidbody or body2.rigidbody)
      Physics.solve_collision(body1, body2) if body1.rigidbody
      Physics.solve_collision(body2, body1) if body2.rigidbody
      if Collision.horizontal?(collision)
        #puts "horizontal #{body2.tag} #{body1.tag} - #{Collision.to_s(collision2)} #{body2.acceleration} #{body2.speed}"
        # https://en.wikipedia.org/wiki/Elastic_collision#One-dimensional_Newtonian
        m1 = body1.mass
        m2 = body2.mass
        u1 = body1.speed
        u2 = body2.speed

        v1 = ( ((m1-m2)/(m1+m2))*u1 ) + ( ((2*m2)/(m1+m2))*u2 )
        v2 = ( ((m2-m1)/(m1+m2))*u2 ) + ( ((2*m1)/(m1+m2))*u1 )

        body1.speed = v1
        body2.speed = v2
        #body1.speed *= 0 if [:floor, :wall, :ceil].include? body1.tag
        #body2.speed *= 0 if [:floor, :wall, :ceil].include? body2.tag
      end
    end
  end

  def self.solve_collision(body1, body2)
    self.solve_collisions(body1, [body2])
  end

  def self.solve_collisions(body1, candidates)
    new_position = body1.position.dup

    collision = Collision::NONE
    candidates.each do |obj|
      obj.debug = Gosu::Color::CYAN
      collision |= body1.colliding?(obj.collision_rect)
    end

    collided = collision != Collision::NONE

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

    collision
  end

  class World
    GRAVITY             = Vector2d[0, -9.8].freeze # -9.8 m/s

    attr_accessor :bodies, :gravity

    def initialize
      @bodies = []
      @gravity = GRAVITY
    end

    def update
      # collision after gravity are locking bodies X axis
      # @bodies.select(&:rigidbody).each { |body| body.acceleration = GRAVITY.dup }
      #body3 = @bodies.last
      #puts "#{body3.speed.round(2)} speed #{body3.acceleration.round(2)}"
      @bodies.each(&:update)
      #@bodies.select { |body| body.rigidbody }.each do |body|
      #  body.acceleration = GRAVITY * body.mass
      #end
      Physics.elastic_collisions(@bodies)
    end
  end
end
