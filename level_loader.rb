require 'chunky_png'
require './world'
require './vector_2d'

class Tile < GameObject
  SCREEN_WIDTH   = 1280
  SCREEN_HEIGHT  = 720
  SIZE   = 18
  WIDTH  = (SCREEN_WIDTH / 50)
  HEIGHT  = (SCREEN_WIDTH / 28)

  EMPTY  = 0xFFFFFFFF
  GRASS_FLOOR = 0x002F00FF
  WOOD   = 0xCB815EFF
  HORIZONTAL_WOOD = 0x995D4FFF
  LEAF   = 0x71AA34FF
  WOOD_INTERSECTION = 0xEBA364FF
  STAR = 0xFFFF00FF

  TILES = {
    GRASS_FLOOR => 2 + 0 * 20,
    WOOD => 16 + 5 * 20,
    LEAF => 18 + 1 * 20,
    HORIZONTAL_WOOD => 19 + 5 * 20,
    WOOD_INTERSECTION => 17 + 5 * 20,
  }

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
  def self.generate(world)
    unless defined?(@@tilemap)
      @@tilemap = Gosu::Image.load_tiles("assets/tiles.png", Tile::SIZE, Tile::SIZE, tileable: true)
    end

    width = 200
    height = 28
    World.camera.bounds.width = width
    level = Level.new(200, 28)
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
                                  image: @@tilemap[18 + 1 * 20],
                                  scale_x: scale_x, scale_y: scale_y))
        end
      end
      pipe_height = [pipe_height + (rand * (10) * (rand > 0.5 ? 1 : -1)).to_i, 25].min
      pipe_height = [pipe_height, 6].max
      pipes_space = (rand * 10) % 5 + 5
      x += (rand * 100 % 6 + 9).to_i
    end
  end

  def self.load_tiles
    ChunkyPNG::Image.from_file('assets/levels/level2.png')
  end
end
