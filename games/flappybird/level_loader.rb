require 'chunky_png'
require 'flaty/flaty'

class Tile < GameObject
  SCREEN_WIDTH   = 1280
  SCREEN_HEIGHT  = 720
  SIZE   = 18
  WIDTH  = (SCREEN_WIDTH / 50)
  HEIGHT  = (SCREEN_WIDTH / 28)

  GRASS_FLOOR       = 2 + 0 * 20
  WOOD              = 16 + 5 * 20
  LEAF              = 18 + 1 * 20
  HORIZONTAL_WOOD   = 19 + 5 * 20
  WOOD_INTERSECTION = 17 + 5 * 20

  def initialize(opts = {})
    default = { debug: Gosu::Color::GREEN }
    super(default.merge(opts))
  end
end

class Level
  attr_accessor :width, :height, :tilesmap

  def initialize(width, height)
    @width = width
    @height = height
    @tilesmap = { }
  end

  def add_tile(tile)
    @tilesmap[tile.y * @width + tile.x] = tile
  end

  def at(x, y)
    @tilesmap[y.to_i * @width + x.to_i]
  end

  # get the tiles that envolves some object in its 4 sides (top, bottom, left and right)
  def around(object)
    tiles = []
    start_x = object.x.to_i
    start_y = object.y.to_i
    # top object tiles row
    # * * * * <---
    # *     *
    # * * * *
    start_x.upto((object.x + object.width).ceil - 1) do |x|
      tiles << at(x, start_y) unless at(x, start_y).nil?
    end

    # bottom object tiles row
    # * * * *
    # *     *
    # * * * * <---
    start_y = (object.y + object.height).to_i
    start_x.upto((object.x + object.width).to_i) do |x|
      tiles << at(x, start_y) unless at(x, start_y).nil?
    end

    # left side object tiles columns
    # ||
    # \/
    # * * * *
    # *     *
    # * * * *
    start_y = object.y.ceil
    start_x = object.x.to_i
    start_y.upto((object.y + object.height).to_i) do |y|
      tiles << at(start_x, y) unless at(start_x, y).nil?
    end

    # right side object tiles column
    #       ||
    #       \/
    # * * * *
    # *     *
    # * * * *
    start_x = (object.x + object.width).to_i
    start_y.upto((object.y + object.height).to_i) do |y|
      tiles << at(start_x, y) unless at(start_x, y).nil?
    end
    tiles
  end

  def tiles
    @tilesmap.values
  end
end

class LevelLoader
  MIN_VERTICAL_SPACE   = 5
  MIN_HORIZONTAL_SPACE = 9
  MIN_PIPE_HEIGHT      = 6
  MAX_PIPE_HEIGHT      = 25

  def self.generate(world, width = 200, height = 28)
    unless defined?(@@tilemap)
      @@tilemap = Gosu::Image.load_tiles("assets/tiles.png", Tile::SIZE, Tile::SIZE, tileable: true)
    end

    GameWindow.camera.bounds.width = width

    level = Level.new(width, height)
    world.level = level

    scale_x = (World::UNIT_X) / Tile::SIZE.to_f
    scale_y = (World::UNIT_Y) / Tile::SIZE.to_f

    x = 20
    pipes_space = 6
    pipe_height = 14
    while x < width
      height.times do |y|
        if y > pipe_height or y < pipe_height - pipes_space
          level.add_tile(Tile.new(position: Vector2d[x, y], z: ZLayers::TILE,
                                  image: @@tilemap[Tile::LEAF],
                                  scale_x: scale_x, scale_y: scale_y))
        end
      end
      pipe_height = [pipe_height + (rand * (10) * (rand > 0.5 ? 1 : -1)).to_i, MAX_PIPE_HEIGHT].min
      pipe_height = [pipe_height, MIN_PIPE_HEIGHT].max
      pipes_space = (rand * 10) % 5 + MIN_VERTICAL_SPACE
      x += (rand * 100 % 6 + MIN_HORIZONTAL_SPACE).to_i
    end
  end
end
