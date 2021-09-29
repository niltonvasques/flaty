require "flaty"

class Camera
  NOT_BOUNDED = -1_f32
  #attr_accessor :width, :height, :position, :bounds
  property view
  property width
  property height
  property scale
  property position
  property rect

  #attr_reader :unit_x, :unit_y
  @bounds : Rect
  @rect : Rect
  @view : SF::View

  def initialize(width : Float32, height : Float32, scale : Float32)
    @bounds = Rect.xywh(NOT_BOUNDED, NOT_BOUNDED, NOT_BOUNDED, NOT_BOUNDED)
    @rect = Rect.xywh(0_f32, 0_f32, width, height)

    @width       = uninitialized Float32
    @height      = uninitialized Float32
    @position    = uninitialized Vec2d
    @scale       = scale
    @view        = SF::View.new(Vec2d.new(0, 0), Vec2d.new(width, height))
    @screen_size = Vec2d.new(width * scale, height * scale)

    size(width, height)
    look(width / 2, height / 2)
  end

  def look(x : Float32, y : Float32)
    y = @bounds.y if @bounds.y != NOT_BOUNDED && y < @bounds.y
    x = @bounds.x if @bounds.x != NOT_BOUNDED && x < @bounds.x
    x = @bounds.width if @bounds.width != NOT_BOUNDED && x > @bounds.width
    @position = Vec2d.new(x, y)
    @view.center = Vec2d.new(@position.x, -@position.y) * @scale
    update_rect
  end

  def size(width : Float32, height : Float32)
    previous_width = @width
    @width = Math.max(width, 0_f32)
    @height = Math.max(height, 0_f32)
    @view.size = Vec2d.new(@width, @height) * @scale
    update_rect
  end

  def update_rect
    @rect.left = @position.x - @width / 2.0
    @rect.top = @position.y - @height / 2.0
    @rect.width = @width
    @rect.height = @height
  end

  MAX_CAMERA_SIZE = 10000000_f32
  MIN_CAMERA_SIZE = 0.01_f32
  def zoom(units : Float32)
    units *= @width / 10.0
    return if units < 0 && @width <= MIN_CAMERA_SIZE
    return if units > 0 && @width >= MAX_CAMERA_SIZE
    size(@width + units, @height + units)
  end

  def move(direction : Vec2d)
    unit = @width / 20_f32
    @position += (direction * unit)
  end

  #def visible?(obj)
  #  rect = obj
  #  rect = rect.collision_rect if obj.is_a? CircleGameObject
  #  return false if rect.x > (@position.x + @width / 2.0)
  #  return false if rect.x + rect.width < (@position.x - @width / 2.0)
  #  return false if rect.y > (@position.y + @height / 2.0)
  #  return false if rect.y + rect.height < (@position.y - @height / 2.0)
  #  true
  #end

  def width_pixels
    @width * @scale
  end

  def height_pixels
    @height * @scale
  end

  def pixel_to_unit_x(w : Float32)
    w / @scale
  end

  def pixel_to_unit_y(h : Float32)
    h / @scale
  end

  def scale(size_in_pixels : Float32, size_in_units : Float32)
    (@scale * size_in_units) / size_in_pixels
  end

  #def translate_x(x)
  #  (x - shift_x) * @unit_x
  #end

  #def translate_y(y)
  #  # Since gosu draw (0,0) at left top, we need to invert the y coordinate
  #  GameWindow.height - ((y - shift_y) * @unit_y)
  #end

  #def translate(obj)
  #  # Since gosu draw (0,0) at left top, we need to invert the y coordinate
  #  Vector2d[translate_x(obj.x), translate_y(obj.y + obj.height)]
  #end
end
