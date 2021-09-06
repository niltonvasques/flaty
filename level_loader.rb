require 'chunky_png'

module Tile
  SCREEN_WIDTH   = 1280
  SCREEN_HEIGHT  = 720
  SIZE   = 18
  WIDTH  = (SCREEN_WIDTH / 50)
  HEIGHT  = (SCREEN_WIDTH / 28)

  EMPTY  = 0xFFFFFFFF
  WOOD   = 0xCB815EFF
  HORIZONTAL_WOOD = 0x995D4FFF
  LEAF   = 0x71AA34FF
  WOOD_INTERSECTION = 0xEBA364FF
  STAR = 0xFFFF00FF

  TILES = {
    WOOD => 16 + 5 * 20,
    LEAF => 18 + 1 * 20,
    HORIZONTAL_WOOD => 19 + 5 * 20,
    WOOD_INTERSECTION => 17 + 5 * 20,
  }
end

class Level < GameObject
  def initialize
    super({ x: 0, y: 0 })
    @tiles = Gosu::Image.load_tiles("assets/tiles.png", Tile::SIZE, Tile::SIZE, tileable: true)
    @star_anim = Gosu::Image.load_tiles("assets/star.png", 25, 25)
    @level_tiles = LevelLoader.load
    @stars = Array.new
    puts "level x: #{self.x}"
    create_stars
  end

  def update(speed)
    delta = Gosu.milliseconds - self.updated_at
    self.updated_at = Gosu.milliseconds

    self.x -= (speed * (delta / 1000.0)) / Tile::SIZE.to_f

    @stars.each { |star| star.update(speed) }
    #if rand(100) < 4 and @stars.size < 10
    #  @stars.push(Star.new(@star_anim))
    #end
  end

  def draw
    tile_scale = (GameWindow::SCREEN_WIDTH / 50) / Tile::SIZE.to_f
    @level_tiles.width.times do |x|
      screen_x = (GameWindow::SCREEN_WIDTH / 50) * (x + self.x)
      @level_tiles.height.times do |y|
        screen_y = ((GameWindow::SCREEN_HEIGHT / @level_tiles.height) * (y+1+self.y))
        tile = @level_tiles[x,y]
        if tile != Tile::EMPTY and tile != Tile::STAR
          tile_pos = Tile::TILES[tile]
          @tiles[tile_pos].draw(screen_x, screen_y, ZLayers::TILE, scale_x = tile_scale, scale_y = tile_scale)
        end
      end
    end
    puts "#{@stars.size}"
    @stars.first.print
    @stars.each { |star| star.draw }
  end

  def create_stars
    tile_scale = (GameWindow::SCREEN_WIDTH / 50) / Tile::SIZE.to_f
    @level_tiles.width.times do |x|
      screen_x = (GameWindow::SCREEN_WIDTH / 50) * (x + self.x)
      #puts "screen_x: #{screen_x}"
      @level_tiles.height.times do |y|
        screen_y = ((GameWindow::SCREEN_HEIGHT / @level_tiles.height) * (y+1+self.y))
        tile = @level_tiles[x,y]
        if tile == Tile::STAR
          #tile_pos = Tile::TILES[tile]
          @stars.push(Star.new(@star_anim, x: screen_x, y: screen_y))
          #@tiles[tile_pos].draw(screen_x, screen_y, ZLayers::TILE, scale_x = tile_scale, scale_y = tile_scale)
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
