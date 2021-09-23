require 'flaty/collisions'

module Physics
  def self.elastic_collisions(bodies)
    bodies.each_index do |i|
      (i+1).upto(bodies.size - 1) do |j|
        Physics.elastic_collision(bodies[i], bodies[j])
      end
    end
  end

  def self.elastic_collision(body1, body2)
    if body1.collisions(body2) != Collision::NONE
      Physics.solve_collision(body1, body2)
      Physics.solve_collision(body2, body1)

      # https://en.wikipedia.org/wiki/Elastic_collision#One-dimensional_Newtonian
      m1 = body1.mass
      m2 = body2.mass
      u1 = body1.speed
      u2 = body2.speed

      v1 = ( ((m1-m2)/(m1+m2))*u1 ) + ( ((2*m2)/(m1+m2))*u2 )
      v2 = ( ((m2-m1)/(m1+m2))*u2 ) + ( ((2*m1)/(m1+m2))*u1 )

      body1.speed = v1
      body2.speed = v2
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
      collision |= body1.collisions(obj.collision_rect)
    end

    collided = collision != Collision::NONE

    if Collision.bottom?(collision)
      body1.position.y = body1.previous_position.y

      collision = Collision::NONE
      candidates.each do |obj|
        obj.debug = Gosu::Color::CYAN
        collision |= body1.collisions(obj.collision_rect)
      end
      body1.grounded if collision == Collision::NONE
    end

    if Collision.right?(collision)
      body1.position.y = new_position.y
      body1.position.x = body1.previous_position.x

      collision = Collision::NONE
      candidates.each do |obj|
        obj.debug = Gosu::Color::CYAN
        collision |= body1.collisions(obj.collision_rect)
      end
    end

    if Collision.left?(collision)
      body1.position.y = new_position.y
      body1.position.x = body1.previous_position.x

      collision = Collision::NONE
      candidates.each do |obj|
        obj.debug = Gosu::Color::CYAN
        collision |= body1.collisions(obj.collision_rect)
      end
    end

    if Collision.top?(collision)
      body1.position.y = body1.previous_position.y

      collision = Collision::NONE
      candidates.each do |obj|
        obj.debug = Gosu::Color::CYAN
        collision |= body1.collisions(obj.collision_rect)
      end
      body1.ceil_hit if collision == Collision::NONE
    end

    body1.reset if collision != Collision::NONE

    collided
  end

  class World
    attr_accessor :bodies

    def initialize
      @bodies = []
    end

    def update
      # collision after gravity are locking bodies X axis
      # @bodies.select(&:rigidbody).each { |body| body.acceleration = GRAVITY.dup }
      collidables = @bodies.select { |body| body.is_a? Collider }
      @bodies.each(&:update)
      Physics.elastic_collisions(collidables)
    end
  end
end
