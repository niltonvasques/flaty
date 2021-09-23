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
    if body1.collisions(body2) != Collision::NONE and (body1.rigidbody or body2.rigidbody)
      Physics.solve_collision(body1, body2)
      Physics.solve_collision(body2, body1)

      # https://en.wikipedia.org/wiki/Elastic_collision#One-dimensional_Newtonian
      m1 = body1.mass
      m2 = body2.mass
      u1 = body1.speed
      u2 = body2.speed
      v1 = body1.speed
      v2 = body2.speed

      #v1 = ( ((m1-m2)/(m1+m2))*u1 ) + ( ((2*m2)/(m1+m2))*u2 )
      #v2 = ( ((m2-m1)/(m1+m2))*u2 ) + ( ((2*m1)/(m1+m2))*u1 )

      #body1.speed = v1
      #body2.speed = v2

      #https://en.wikipedia.org/wiki/Elastic_collision#Two-Dimensional_Collision_With_Two_Moving_Objects
      theta1 = Math.atan2(v1.y, v1.x) # radians
      theta2 = Math.atan2(v2.y, v2.x)
      cx = (body1.x - body2.x).abs
      cy = (body1.y - body2.y).abs
      phi = Math.atan2(cy, cx)

      v1s = Math.sqrt(v1.x**2 + v1.y**2)
      v2s = Math.sqrt(v2.x**2 + v2.y**2)

      pi_rad = 180 / Math::PI
      puts "#{(theta1 * pi_rad).round} theta1 #{(theta2 * pi_rad).round} theta2 #{(phi * pi_rad).round} phi"
      puts "#{v1s.round} v1s #{v2s.round} v2s #{v1.round} v1 #{v2.round} v2"

      v1x = (v1s * Math.cos(theta1-phi)*(m1-m2) + 2*m2*v2s*Math.cos(theta2-phi))
      v1x /= (m1+m2)
      v1x *= Math.cos(phi) + v1s*Math.sin(theta1-phi)*Math.cos(phi + Math::PI/2)

      v1y = (v1s * Math.cos(theta1-phi)*(m1-m2) + 2*m2*v2s*Math.cos(theta2-phi))
      v1y /= (m1+m2)
      v1y *= Math.sin(phi) + v1s*Math.sin(theta1-phi)*Math.sin(phi + Math::PI/2)
      new_v1 = Vector2d[v1x, v1y]

      v2x = (v2s * Math.cos(theta2-phi)*(m2-m1) + 2*m1*v1s*Math.cos(theta1-phi))
      v2x /= (m1+m2)
      v2x *= Math.cos(phi) + v2s*Math.sin(theta2-phi)*Math.cos(phi + Math::PI/2)

      v2y = (v2s * Math.cos(theta2-phi)*(m2-m1) + 2*m1*v1s*Math.cos(theta1-phi))
      v2y /= (m1+m2)
      v2y *= Math.sin(phi) + v2s*Math.sin(theta2-phi)*Math.sin(phi + Math::PI/2)
      new_v2 = Vector2d[v2x, v2y]
      puts "[#{v2x.round} #{v2y.round}] new v2"

      puts "#{new_v1.round} new_v1 #{new_v2.round} new_v2 | #{v1.round} v1 #{v2.round} v2"
      body1.speed = new_v1
      body2.speed = new_v2
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
