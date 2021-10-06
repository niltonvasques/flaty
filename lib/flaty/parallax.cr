require "flaty"

class Flaty::Parallax < Flaty::GameObject

  def initialize(@x1 : Float64, @x2 : Float64, @scaled_width : Float64, opts)
    super(opts)
  end

  # connecting two images one after the other in the horizontal path
  # with this strategy, when the ending of one image appears, the next one is already on the screen
  def update(backward)
    local_speed = self.speed.x * Flaty.delta

    if !backward
      if @x1 + @scaled_width > 0 && (@x2 > @x1 || @x2 + @scaled_width < 0)
        @x1 -= local_speed
        @x2 = @x1 + @scaled_width
      else
        @x2 -= local_speed
        @x1 = @x2 + @scaled_width
      end
      return
    end

    if @x1 < @width && (@x2 < @x1 || @x2 > @width)
      @x1 += local_speed
      @x2 = @x1 - @scaled_width
    else
      @x2 += local_speed
      @x1 = @x2 - @scaled_width
    end
  end

  def draw
    x = Flaty.camera.rect.x
    y = Flaty.camera.rect.y
    Flaty.draw_sprite(@sprite.as(SF::Sprite), @x1 + x, self.y + @height + y)
    Flaty.draw_sprite(@sprite.as(SF::Sprite), @x2 + x, self.y + @height + y)
  end
end
