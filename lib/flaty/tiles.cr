class Flaty::Tiles
  property size : Int32

  def initialize(@path : String, @width : Int32, @height : Int32, @scale : Vec2d)
    @texture = SF::Texture.from_file(@path)
    @texture.smooth = true
    @sprite = SF::Sprite.new(@texture)
    @sprite.scale = @scale
    @stride = (@texture.size.x / @width).to_i.as(Int32)
    @stride_y = (@texture.size.y / @height).to_i.as(Int32)
    @size = @stride * @stride_y
  end

  def at(pos : Int32)
    i = pos % @stride
    j = (pos / @stride).to_i
    @sprite.texture_rect = SF.int_rect(i * @width, j * @height, @width, @height)
    @sprite
  end
end
