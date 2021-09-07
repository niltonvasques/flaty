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

  def around(x, y)
    tiles = []
    tiles << at(x + 1, y) unless at(x + 1, y).nil?
    tiles << at(x - 1, y) unless at(x - 1, y).nil?
    tiles << at(x, y + 1) unless at(x, y + 1).nil?
    tiles << at(x, y - 1) unless at(x, y - 1).nil?
    tiles
  end

  def tiles
    @tilesmap.values
  end
end

class LevelLoader
  def self.create_tiles(world)
    tilemap = Gosu::Image.load_tiles("assets/tiles.png", Tile::SIZE, Tile::SIZE, tileable: true)
    star_anim = Gosu::Image.load_tiles("assets/star.png", 25, 25)
    level_tiles = self.load_tiles
    World.camera.bounds.width = level_tiles.width
    level = Level.new(level_tiles.width, level_tiles.height)
    world.level = level

    scale_x = (World::UNIT_X) / Tile::SIZE.to_f
    scale_y = (World::UNIT_Y) / Tile::SIZE.to_f
    level_tiles.width.times do |x|
      level_tiles.height.times do |y|
        tile = level_tiles[x,y]
        if tile != Tile::EMPTY and tile != Tile::STAR
          tile_pos = Tile::TILES[tile]
          level.add_tile(Tile.new(position: Vector2d[x, y], z: ZLayers::TILE,
                                  image: tilemap[tile_pos],
                                  scale_x: scale_x, scale_y: scale_y))
        end
        if tile == Tile::STAR
          world.stars.push(Star.new(star_anim, position: Vector2d[x, y]))
        end
      end
    end
  end

  def self.load_tiles
    ChunkyPNG::Image.from_file('assets/levels/level1.png')
  end
end
