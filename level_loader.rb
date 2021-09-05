require 'chunky_png'

module Tile
  SIZE   = 18

  EMPTY  = 0xFFFFFFFF
  WOOD   = 0xCB815EFF
  HORIZONTAL_WOOD = 0x995D4FFF
  LEAF   = 0x71AA34FF
  WOOD_INTERSECTION = 0xEBA364FF

  TILES = {
    WOOD => 16 + 5 * 20,
    LEAF => 18 + 1 * 20,
    HORIZONTAL_WOOD => 19 + 5 * 20,
    WOOD_INTERSECTION => 17 + 5 * 20,
  }
end

class Level
  def initialize
    @tiles = Gosu::Image.load_tiles("assets/tiles.png", Tile::SIZE, Tile::SIZE, tileable: true)
    @level_tiles = LevelLoader.load
  end

  def update
  end

  def draw
    tile_scale = (GameWindow::SCREEN_WIDTH / @level_tiles.width) / Tile::SIZE.to_f
    @level_tiles.width.times do |x|
      screen_x = (GameWindow::SCREEN_WIDTH / @level_tiles.width) * x
      @level_tiles.height.times do |y|
        screen_y = ((GameWindow::SCREEN_HEIGHT / @level_tiles.height) * (y+1))
        tile = @level_tiles[x,y]
        if tile != Tile::EMPTY
          tile_pos = Tile::TILES[tile]
          @tiles[tile_pos].draw(screen_x, screen_y, 10, scale_x = tile_scale, scale_y = tile_scale)
        end
      end
    end
  end
end

class LevelLoader
  def self.load
    tiles = ChunkyPNG::Image.from_file('assets/levels/level1.png')
  end
end
