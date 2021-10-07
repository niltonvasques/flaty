require "flaty"
require "flaty/tiles"

class Flaty::GameObject
  include Collider

  property position : Vec2d
  property previous_position : Vec2d
  property width : Float64
  property height : Float64
  property speed : Vec2d
  property acceleration : Vec2d
  property force : Vec2d
  property damp : Float64
  property elasticity : Float64
  property mass : Float64
  property rect : Rect
  property color : SF::Color
  property rigidbody : Bool
  property tag : Symbol
  property debug : (SF::Color | Nil)
  property image : (SF::Texture | Nil)
  property sprite : (SF::Sprite | Nil)

  alias GameObjectOpts = (Int32 | Vec2d | Rect | Float64 | Bool | SF::Color)

  def initialize(opts = {} of Symbol => GameObjectOpts)
    default = {
      :position => Vec2d.new(0,0),
      :previous_position => Vec2d.new(0,0),
      :image => nil,
      :sprite => nil,
      :tiles => nil,
      :rect => Rect.xywh(0.0, 0.0, 0.0, 0.0),
      :mass => 1.0,
      :acceleration => Vec2d.new(0,0),
      :force => Vec2d.new(0,0),
      :speed => Vec2d.new(0,0),
      :max_speed => Vec2d.new(100,100),
      :damp => 1.0,
      :elasticity => 1.0,
      :scale_x => 1.0,
      :scale_y => 1.0,
      :width => 1.0,
      :height => 1.0,
      :angle => 0.0,
      :current => 0,
      :camera => true,
      :debug => nil,
      :rigidbody => false,
      :color => Flaty::Colors::BLUE,
    }.merge(opts)

    @position          = default[:position].as Vec2d
    @rect              = default[:rect].as Rect
    @mass              = default[:mass].as Float64
    @speed             = default[:speed].as Vec2d
    @acceleration      = default[:acceleration].as Vec2d
    @force             = default[:force].as Vec2d
    @max_speed         = default[:max_speed].as Vec2d
    @elasticity        = default[:elasticity].as Float64
    @damp              = default[:damp].as Float64
    @current           = default[:current].as Int32
    @previous_position = default[:position].as Vec2d
    @color             = default[:color].as SF::Color
    @width             = default[:width].as Float64
    @height            = default[:height].as Float64
    @rigidbody         = default[:rigidbody].as Bool
    @camera            = default[:camera].as Bool
    @debug             = default[:debug].as (SF::Color | Nil)
    @tag               = default[:tag].as Symbol
    @image             = default[:image].as (SF::Texture | Nil)
    @tiles             = default[:tiles].as (Flaty::Tiles | Nil)
    @sprite            = default[:sprite].as (SF::Sprite | Nil)

    setup_sprite
  end

  def x; @position.x; end
  def y; @position.y; end

  def setup_sprite
    if @image != nil
      texture = @image.as SF::Texture
      @sprite = SF::Sprite.new(texture)
      scale = SF.vector2(@width / texture.size.x, @height / texture.size.y)
      @sprite.as(SF::Sprite).scale = scale
    end
  end

  def center
    @position + Vec2d.new(@width / 2.0, @height / 2.0)
  end

  def previous_center
    @previous_position + Vec2d.new(@width / 2.0, @height / 2.0)
  end

  def update(delta)
    #update_width_height
    @previous_position = @position

    forces = (@acceleration + @force)

    @speed += forces * delta.as_seconds * @mass
    @speed.x = @max_speed.x if @speed.x > 0 && @speed.x.abs > @max_speed.x
    @speed.x = -@max_speed.x if @speed.x < 0 && @speed.x.abs > @max_speed.x
    @speed.y = @max_speed.y if @speed.y > 0 && @speed.y.abs > @max_speed.y
    @speed.y = -@max_speed.y if @speed.y < 0 && @speed.y.abs > @max_speed.y
    @speed.y *= @damp if forces.y == 0
    @speed.x *= @damp if forces.x == 0
    @speed.x = 0 if @speed.x.abs < 0.01

    @position += @speed * delta.as_seconds
  end

  def reset
    @position = @previous_position
  end

  def draw
    sprite = current_sprite
    return if sprite == nil

    x = @position.x
    y = @position.y + @height
    unless @camera
      x = Flaty.camera.rect.x
      y = Flaty.camera.rect.y + @height
    end
    Flaty.draw_sprite(sprite.as(SF::Sprite), x, y)

    if @debug && GameWindow.debug?
      rect = self.collision_rect
      Flaty.draw_rect(rect.x, rect.y, rect.width, rect.height, @debug.as(SF::Color))
    end
  end

  #  def draw_obj(x, y, z)
  #    current_image.draw(x, y, z, scale_x = @scale_x, scale_y = @scale_y)
  #  end
  #
  #  def update_width_height
  #    unless current_image.nil?
  #      @width = GameWindow.camera.pixel_to_unit_x(current_image.width * @scale_x)
  #      @height = GameWindow.camera.pixel_to_unit_y(current_image.height * @scale_y)
  #    end
  #  end
  #
  def grounded
  end

  def ceil_hit
  end

  def previous_collision_rect
    @rect.left = @previous_position.x
    @rect.top = @previous_position.y
    @rect.width = @width
    @rect.height = @height
    @rect
  end

  def collision_rect
    @rect.left = x
    @rect.top = y
    @rect.width = @width
    @rect.height = @height
    @rect
  end
  #
  #  def outside_window?
  #    return false unless @camera
  #    not GameWindow.camera.visible?(@
  #  end
  #
  def current_sprite
    return @sprite if @sprite
    @tiles.as(Flaty::Tiles).at(@current) if @tiles
  end

  def normal_rays
    left_rays  = [] of Tuple(Vec2d, Vec2d)
    right_rays = [] of Tuple(Vec2d, Vec2d)
    up_rays    = [] of Tuple(Vec2d, Vec2d)
    down_rays  = [] of Tuple(Vec2d, Vec2d)

    {left_rays, right_rays, up_rays, down_rays}
  end
end

class Flaty::RectGameObject < Flaty::GameObject
  include Collider

  def collisions(obj)
    case obj
    when CircleGameObject then Collision.detect_circle_rect(obj, self)
    when RectGameObject then Collision.detect_rect(self, obj)
    when Rect             then Collision.detect_rect(self, obj)
    else
      Collision::NONE
    end
  end

  def draw_rays
    #draw_ray_trace
    #draw_ray_traces
    draw_ray_trace_normal
  end

  def draw_ray_trace_normal
    normal_rays.each do |rays|
      rays.each { |r| Flaty.draw_line(r[0].x, r[0].y, r[1].x, r[1].y, Flaty::Colors::RED) }
    end
  end

  def normal_rays
    body = self
    c = origin = body.center

    left_rays  = [] of Tuple(Vec2d, Vec2d)
    right_rays = [] of Tuple(Vec2d, Vec2d)
    up_rays    = [] of Tuple(Vec2d, Vec2d)
    down_rays  = [] of Tuple(Vec2d, Vec2d)

    rect = body.previous_collision_rect
    start = rect.x + 0.1
    y = body.previous_center.y
    while start < rect.x + rect.width - 0.1
      c = Vec2d.new(start, y) + Vec2d.new(0, 2)
      up_rays << {Vec2d.new(start, y), Vec2d.new(c.x, c.y)}

      c = Vec2d.new(start, y) + Vec2d.new(0, -2)
      down_rays << {Vec2d.new(start, y), Vec2d.new(c.x, c.y)}
      start += 0.1
    end

    start = rect.y + 0.1
    x = body.previous_center.x
    while start < rect.y + rect.height - 0.1
      c = Vec2d.new(x, start) + Vec2d.new(2, 0)
      right_rays << {Vec2d.new(x, start), Vec2d.new(c.x, c.y)}

      c = Vec2d.new(x, start) + Vec2d.new(-2, 0)
      left_rays << {Vec2d.new(x, start), Vec2d.new(c.x, c.y)}
      start += 0.1
    end

    {left_rays, right_rays, up_rays, down_rays}
  end

  def draw_ray_trace
    body = self
    origin = body.center

    c = body.center + body.speed
    Flaty.draw_line(origin.x, origin.y, c.x, c.y, Flaty::Colors::RED)

    -10.upto(10) do |angle|
      vx = body.speed.x * Math.cos(angle * RAD) - body.speed.y * Math.sin(angle * RAD)
      vy = body.speed.x * Math.sin(angle * RAD) + body.speed.y * Math.cos(angle * RAD)
      c = origin + Vec2d.new(vx, vy)
      Flaty.draw_line(origin.x, origin.y, c.x, c.y, Flaty::Colors::RED)
    end
  end

  def draw_ray_traces
    body = self
    origin = body.center
    c = body.center + body.speed
    Flaty.draw_line(origin.x, origin.y, c.x, c.y, Flaty::Colors::BLUE)

    rect = body.collision_rect
    start = rect.x
    while start < rect.x + rect.width
      c = Vec2d.new(start, origin.y) + body.speed
      Flaty.draw_line(start, origin.y, c.x, c.y, Flaty::Colors::BLUE)
      start += 0.1
    end

    start = rect.y
    while start < rect.y + rect.height
      c = Vec2d.new(origin.x, start) + body.speed
      Flaty.draw_line(origin.x, start, c.x, c.y, Flaty::Colors::BLUE)
      start += 0.1
    end
  end

end

class Flaty::CircleGameObject < Flaty::GameObject
  include Collider

  property radius

  def initialize(@radius : Float64, opts)
    super(opts)
    @width = @radius * 2.0
    @height = @radius * 2.0

    setup_sprite
  end

  def collision_rect
    @rect.left = @position.x
    @rect.top = @position.y - @radius
    @rect.width = @radius * 2
    @rect.height = @radius * 2
    @rect
  end

  def collisions(obj)
    case obj
    when CircleGameObject then Collision.detect_circle(self, obj)
    when RectGameObject   then Collision.detect_circle_rect(self, obj)
    when Rect             then Collision.detect_circle_rect(self, obj)
    else Collision::NONE
    end
  end

  def draw
    draw_debug
    return super if @sprite || @tiles
    Flaty.draw_circle(@position.x, @position.y, @radius, @color)
  end

  def draw_debug
    if GameWindow.debug?
      Flaty.draw_line(center.x, center.y, center.x + @speed.x, center.y + @speed.y, @color)
      #if @theta
      #  msg = "#{@theta} #{@speed.round}"
      #  msg += " #{@phi}" if @phi
      #  Flaty.draw_text(Collisions.font, msg, @x, @y) if @theta
      #end
      #Flaty.draw_circle(@center, @radius, @color) unless current_image
    end
  end

  def update_width_height
  end
end
