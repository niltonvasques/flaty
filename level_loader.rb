require 'chunky_png'
require './world'

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
end

class LevelLoader
  def self.create_tiles(world)
    tilemap = Gosu::Image.load_tiles("assets/tiles.png", Tile::SIZE, Tile::SIZE, tileable: true)
    star_anim = Gosu::Image.load_tiles("assets/star.png", 25, 25)
    level_tiles = self.load_tiles
    World.camera.bounds.width = level_tiles.width

    tile_scale = (GameWindow::SCREEN_WIDTH / 50) / Tile::SIZE.to_f
    level_tiles.width.times do |x|
      level_tiles.height.times do |y|
        tile = level_tiles[x,y]
        if tile != Tile::EMPTY and tile != Tile::STAR
          tile_pos = Tile::TILES[tile]
          world.tiles << Tile.new(x: x, y: y, z: ZLayers::TILE, image: tilemap[tile_pos],
                                  scale_x: tile_scale, scale_y: tile_scale)
        end
        if tile == Tile::STAR
          world.stars.push(Star.new(star_anim, x: x, y: y))
        end
      end
    end
  end

  def self.load_tiles
    ChunkyPNG::Image.from_file('assets/levels/level1.png')
  end
end
