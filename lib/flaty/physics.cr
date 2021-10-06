require "flaty"

module Physics
  def self.elastic_collisions(bodies, quad)
    total = 0
    bodies.each_index do |i|
      candidates = quad.query(bodies[i])
      candidates.each do |body|
        next if body == bodies[i]
        Physics.elastic_collision(bodies[i], body)
        total += 1
      end
    end
    #puts "#{total} total collisions procesing"
  end

  def self.basic_collisions(bodies, quad)
    total = 0
    bodies.each_index do |i|
      candidates = quad.query(bodies[i])
      candidates.each do |body|
        next if body == bodies[i]
        Physics.basic_collision(bodies[i], body)
        total += 1
      end
    end
    #puts "#{total} total collisions procesing"
  end

  # https://en.wikipedia.org/wiki/Elastic_collision#One-dimensional_Newtonian
  def self.basic_collision(body1, body2)
    if body1.collisions(body2) != Collision::NONE && (body1.rigidbody || body2.rigidbody)
      Physics.solve_collision(body1, body2)
      Physics.solve_collision(body2, body1)
    end
  end

  def self.elastic_collision(body1, body2)
    if body1.collisions(body2) != Collision::NONE && (body1.rigidbody || body2.rigidbody)
      Physics.solve_collision(body1, body2)
      Physics.solve_collision(body2, body1)

      # https://gamedev.stackexchange.com/questions/104042/2d-multiple-circle-collision-response
#      if body1.collisions(body2) != Collision::NONE
#        #puts "# second iteration needed #{Gosu.milliseconds} #"
#        Physics.solve_collision(body1, body2)
#        Physics.solve_collision(body2, body1)
#      end
#
      # http://www.sciencecalculators.org/mechanics/collisions/
      # https://en.wikipedia.org/wiki/Elastic_collision#Two-Dimensional_Collision_With_Two_Moving_Objects
      m1 = body1.mass
      m2 = body2.mass
      u1 = body1.speed
      u2 = body2.speed
      v1 = body1.speed
      v2 = body2.speed
      theta1 = Math.atan2(v1.y, v1.x) # radians
      theta2 = Math.atan2(v2.y, v2.x)
      cx = (body1.center.x - body2.center.x)
      cy = (body1.center.y - body2.center.y)
      phi = Math.atan2(cy, cx)
      phi = 0 if [body1.tag, body2.tag].includes?(:right_wall)
      phi = (Math::PI / 2) if [body1.tag, body2.tag].includes?(:ceil)
      phi = (Math::PI) if [body1.tag, body2.tag].includes?(:left_wall)
      phi = (Math::PI / 2) if [body1.tag, body2.tag].includes?(:floor)

      v1s = Math.sqrt(v1.x**2 + v1.y**2)
      v2s = Math.sqrt(v2.x**2 + v2.y**2)

      pi_rad = 180 / Math::PI
      #puts "#{(theta1 * pi_rad).round} theta1 #{(theta2 * pi_rad).round} theta2 #{(phi * pi_rad).round} phi"
      #puts "#{v1s.round} v1s #{v2s.round} v2s #{v1.round} v1 #{v2.round} v2"

      v1x = (v1s * Math.cos(theta1-phi)*(m1-m2) + 2*m2*v2s*Math.cos(theta2-phi))
      v1x /= (m1+m2)
      v1x *= Math.cos(phi)
      v1x += v1s*Math.sin(theta1-phi)*Math.cos(phi + Math::PI/2)

      v1y = (v1s * Math.cos(theta1-phi)*(m1-m2) + 2*m2*v2s*Math.cos(theta2-phi))
      v1y /= (m1+m2)
      v1y *= Math.sin(phi)
      v1y += v1s*Math.sin(theta1-phi)*Math.sin(phi + Math::PI/2)
      new_v1 = Vec2d.new(v1x, v1y)

      v2x = (v2s * Math.cos(theta2-phi)*(m2-m1) + 2*m1*v1s*Math.cos(theta1-phi))
      v2x /= (m1+m2)
      v2x *= Math.cos(phi)
      v2x += v2s*Math.sin(theta2-phi)*Math.cos(phi + Math::PI/2)

      v2y = (v2s * Math.cos(theta2-phi)*(m2-m1) + 2*m1*v1s*Math.cos(theta1-phi))
      v2y /= (m1+m2)
      v2y *= Math.sin(phi)
      v2y += v2s*Math.sin(theta2-phi)*Math.sin(phi + Math::PI/2)
      new_v2 = Vec2d.new(v2x, v2y)
      #puts "[#{v2x.round} #{v2y.round}] new v2"

      #puts "#{new_v1.round} new_v1 #{new_v2.round} new_v2 | #{v1.round} v1 #{v2.round} v2"
      body1.speed = new_v1
      body2.speed = new_v2
      #body1.theta = (theta1 * pi_rad).round
      #body2.theta = (theta2 * pi_rad).round
      #body1.phi = (phi * pi_rad).round
      #body2.phi = (phi * pi_rad).round

      body2.speed.x = body2.speed.x * body2.damp if body1.tag == :floor
      body2.speed.y = body2.speed.y * body2.elasticity #if body1.tag == :floor
      body1.speed.x = body1.speed.x * body1.damp if body2.tag == :floor
      body1.speed.y = body1.speed.y * body1.elasticity #if body2.tag == :floor
    end
  end

  def self.solve_collision(body1, body2)
    self.solve_collisions(body1, [body2])
  end

  def self.solve_collisions(body1, candidates)
    new_position = body1.position.dup

    collision = Collision::NONE
    candidates.each do |obj|
      obj.debug = Flaty::Colors::DEBUG
      collision |= body1.collisions(obj)
    end

    collided = collision != Collision::NONE

    if Collision.bottom?(collision)
      body1.position.y = body1.previous_position.y

      collision = Collision::NONE
      candidates.each do |obj|
        obj.debug = Flaty::Colors::DEBUG
        collision |= body1.collisions(obj)
      end
      body1.grounded if collision == Collision::NONE
    end

    if Collision.right?(collision)
      body1.position.y = new_position.y
      body1.position.x = body1.previous_position.x

      collision = Collision::NONE
      candidates.each do |obj|
        obj.debug = Flaty::Colors::DEBUG
        collision |= body1.collisions(obj)
      end
    end

    if Collision.left?(collision)
      body1.position.y = new_position.y
      body1.position.x = body1.previous_position.x

      collision = Collision::NONE
      candidates.each do |obj|
        obj.debug = Flaty::Colors::DEBUG
        collision |= body1.collisions(obj)
      end
    end

    if Collision.top?(collision)
      body1.position.y = body1.previous_position.y

      collision = Collision::NONE
      candidates.each do |obj|
        obj.debug = Flaty::Colors::DEBUG
        collision |= body1.collisions(obj)
      end
      body1.ceil_hit if collision == Collision::NONE
    end

    body1.reset if collision != Collision::NONE

    collided
  end

  class World
    GRAVITY = Vec2d.new(0, -9.8) # -9.8 m/s

    property bodies, collision_type, gravity

    def initialize(@camera : Flaty::Camera)
      @bodies = [] of Flaty::GameObject
      @gravity = GRAVITY
      qx = @camera.rect.x
      qy = @camera.rect.y
      qw = @camera.rect.width
      qh = @camera.rect.height
      @quadtree = Quadtree(Flaty::GameObject).new(Vec2d.new(qx, qy), Vec2d.new(qw, qh))
      @collision_type = :basic
    end

    def update_quad_rect
      @quadtree.xy.x = @camera.rect.x
      @quadtree.xy.y = @camera.rect.y
      @quadtree.size.x = @camera.rect.width
      @quadtree.size.y = @camera.rect.height
    end

    def update(delta)
      @quadtree.clear
      update_quad_rect
      # collision after gravity are locking bodies X axis
      updatables = @bodies.select { |b| b.rigidbody }
      updatables.each { |body| body.force = @gravity.dup }
      collidables = @bodies.select { |body| body.is_a? Collider }
      collidables.each do |body|
       @quadtree.insert(body) #unless body.outside_window?
      end
      updatables.each { |b| b.update(delta) }

      case @collision_type
      when :basic
        Physics.basic_collisions(updatables, @quadtree)
      when :elastic
        Physics.elastic_collisions(updatables, @quadtree)
      end
    end

    def draw_quad
      draw(@quadtree)
    end

    def draw(quad)
      c = Flaty::Colors::RED
      quad.nodes.each do |node|
        x = node.xy.x
        y = node.xy.y

        Flaty.draw_rect_empty(x, y, node.size.x, node.size.y, c)
      end
      quad.nodes.each { |q| draw(q) }
    end
  end
end
