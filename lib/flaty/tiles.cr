class Flaty::Tiles
  def initialize(@path : String, @width : Int32, @height : Int32, @scale : Vec2d)
    @texture = SF::Texture.from_file(@path)
    @sprite = SF::Sprite.new(@texture)
    @sprite.scale = @scale
    @stride = (@texture.size.x / @width).to_i.as(Int32)
  end

  def at(pos : Int32)
    i = pos % @stride
    j = (pos / @stride).to_i
    @sprite.texture_rect = SF.int_rect(i * @width, j * @height, @width, @height)
    @sprite
  end
end
