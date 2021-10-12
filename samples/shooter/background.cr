require "flaty"
require "flaty/parallax"

class Background
  FRAME_DURATION = 1000 / 60.0
  FG_SPEED = Vec2d.new(30.0 / FRAME_DURATION, 0)

  @fg : Flaty::Parallax
  @trees : Flaty::Parallax
  @mountains : Flaty::Parallax
  @big_mountain : Flaty::Parallax

  def initialize(@width : Float64, @height : Float64)
    bg_img                  = SF::Texture.from_file("assets/mountain/bg.png")
    bg_img.smooth           = true
    fg_img                  = SF::Texture.from_file("assets/mountain/foreground-trees.png")
    fg_img.smooth           = true
    trees_img               = SF::Texture.from_file("assets/mountain/distant-trees.png")
    trees_img.smooth        = true
    mountains_img           = SF::Texture.from_file("assets/mountain/mountains.png")
    mountains_img.smooth    = true
    big_mountain_img        = SF::Texture.from_file("assets/mountain/big-mountain.png")
    big_mountain_img.smooth = true

    @bg = Flaty::GameObject.new({ :x => 0, :y => 0, :width => @width, :height => @height,
                                  :image => bg_img, :camera => false, :tag => :background })

    @fg        = build_layer(fg_img, FG_SPEED)
    @trees     = build_layer(trees_img, FG_SPEED / 3)
    @mountains = build_layer(mountains_img, FG_SPEED / 6)
    @big_mountain = build_layer(big_mountain_img, FG_SPEED / 10)

    @reverse = false
  #  @reverse_at = 0
    @forward = true
  end

  def update(speed)
  #  if Gosu.button_down? Gosu::KB_R
  #    @reverse = !@reverse if (Gosu.milliseconds - @reverse_at) > 1000
  #    @reverse_at = Gosu.milliseconds
  #  end

    speed.y = 0

  #  #return if @reverse

    # ensure that the background will remains moving, but in a slow pace when the bird is not
    # accelerating
    speed = FG_SPEED / 6 if speed == 0

    @big_mountain.speed = speed / 100
    @mountains.speed = speed / 60
    @trees.speed = speed / 30
    @fg.speed = speed / 3

  #  @reverse = speed < 0
    @big_mountain.update(@reverse)
    @mountains.update(@reverse)
    @trees.update(@reverse)
    @fg.update(@reverse)
  end

  def draw
    @bg.draw
    @big_mountain.draw
    @mountains.draw
    @trees.draw
    @fg.draw
  end

  #private

  def build_layer(image, speed)
    opts = {
      :camera => false,
      :image => image,
      :width => @width,
      :height => @height,
      :y => 0,
      :speed => speed,
      :tag => :fg
    }
    Flaty::Parallax.new(0.0, @width, @width, opts)
  end
end
