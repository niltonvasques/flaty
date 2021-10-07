require "flaty"
require "stumpy_png"
require "./star"

class Block < Flaty::RectGameObject
#  SCREEN_WIDTH   = 1280
#  SCREEN_HEIGHT  = 720
  SIZE              = 18
  SCALE             = Vec2d.new(1.0 / SIZE, 1.0 / SIZE)
#  WIDTH  = (SCREEN_WIDTH / 50)
#  HEIGHT  = (SCREEN_WIDTH / 28)

  EMPTY             = 0xFFFFFFFF
  GRASS_FLOOR       = 0x002F00FF
  WOOD              = 0xCB815EFF
  HORIZONTAL_WOOD   = 0x995D4FFF
  LEAF              = 0x71AA34FF
  WOOD_INTERSECTION = 0xEBA364FF
  STAR              = 0xFFFF00FF

  TILES = {
    GRASS_FLOOR => 2 + 0 * 20,
    WOOD => 16 + 5 * 20,
    LEAF => 18 + 1 * 20,
    HORIZONTAL_WOOD => 19 + 5 * 20,
    WOOD_INTERSECTION => 17 + 5 * 20,
  }

  TILES_NAME = {
    GRASS_FLOOR => "GRASS_FLOOR",
    WOOD => "WOOD",
    LEAF => "LEAF",
    HORIZONTAL_WOOD => "HORIZONTAL_WOOD",
    WOOD_INTERSECTION => "WOOD_INTERSECTION",
  }

  def initialize(opts)
    #default = { debug: Gosu::Color::GREEN }
    super(opts)
  end
end

class Level
  property width, height, tilesmap, stars

  def initialize(@width : Int32, @height : Int32)
    @tilesmap = { } of Int32 => Block
    @stars = [] of Star
  end

  def add_tile(tile)
    @tilesmap[tile.y.to_i * @width + tile.x.to_i] = tile
  end

  def at(x, y)
    @tilesmap[y.to_i * @width + x.to_i]
  end
#
#  # get the tiles that envolves some object in its 4 sides (top, bottom, left and right)
#  def around(object)
#    tiles = []
#    start_x = object.x.to_i
#    start_y = object.y.to_i
#    # top object tiles row
#    # * * * * <---
#    # *     *
#    # * * * *
#    start_x.upto((object.x + object.width).ceil - 1) do |x|
#      tiles << at(x, start_y) unless at(x, start_y).nil?
#    end
#
#    # bottom object tiles row
#    # * * * *
#    # *     *
#    # * * * * <---
#    start_y = (object.y + object.height).to_i
#    start_x.upto((object.x + object.width).to_i) do |x|
#      tiles << at(x, start_y) unless at(x, start_y).nil?
#    end
#
#    # left side object tiles columns
#    # ||
#    # \/
#    # * * * *
#    # *     *
#    # * * * *
#    start_y = object.y.ceil
#    start_x = object.x.to_i
#    start_y.upto((object.y + object.height).to_i) do |y|
#      tiles << at(start_x, y) unless at(start_x, y).nil?
#    end
#
#    # right side object tiles column
#    #       ||
#    #       \/
#    # * * * *
#    # *     *
#    # * * * *
#    start_x = (object.x + object.width).to_i
#    start_y.upto((object.y + object.height).to_i) do |y|
#      tiles << at(start_x, y) unless at(start_x, y).nil?
#    end
#    #binding.pry
#    tiles
#  end
#
  def tiles
    @tilesmap.values
  end
end

class LevelLoader
  def self.rgb_to_hex(rgba : Tuple(UInt8, UInt8, UInt8, UInt8))
    (rgba[0].to_i64 << 24) + (rgba[1].to_i64 << 16) + (rgba[2].to_i64 << 8) + rgba[3].to_i64
  end

  def self.load_level
    tilemap = Flaty::Tiles.new("assets/tiles.png", Block::SIZE, Block::SIZE, Block::SCALE)
    star_scale = SF.vector2(1.0 / 25, 1.0 / 25)
    star_anim     = Flaty::Tiles.new("assets/star.png", 25, 25, star_scale)
    level_tiles = self.load_tiles
    level = Level.new(level_tiles.width, level_tiles.height)

    level_tiles.width.times do |x|
      level_tiles.height.times do |y|
        tile = rgb_to_hex(level_tiles[x,y].to_rgba)
        new_y = (level_tiles.height - y - 1)

        if tile != Block::EMPTY && tile != Block::STAR
          tile_pos = Block::TILES[tile]
          block = Block.new({
            :position => Vec2d.new(x.to_f, new_y.to_f), :current => tile_pos,
            :tiles => tilemap, :tag => :floor
          })
          level.add_tile(block)
        end
        if tile == Block::STAR
          star = Star.new({ :tiles => star_anim, :position => Vec2d.new(x.to_f, new_y.to_f),
                           :width => 1.0, :height => 1.0, :tag => :star })
          level.stars << star
        end
      end
    end

    level
  end
#
  def self.load_tiles
    StumpyPNG.read("assets/levels/level1.png")
  end
end
