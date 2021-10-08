require "flaty/flaty"
require "flaty/fps"

class RayCast < Flaty::GameWindow
  SCREEN_WIDTH        = 1500
  SCREEN_HEIGHT       = 1500
  CAMERA_WIDTH_UNITS  = 8.0
  CAMERA_HEIGHT_UNITS = 8.0
  SCALE               = SCREEN_WIDTH / CAMERA_WIDTH_UNITS
  PLAYER_SIZE         = 0.1

  # map
  MAP = [
    [1,1,1,1,1,1,1,1],
    [1,0,1,0,0,0,0,1],
    [1,0,1,0,0,0,0,1],
    [1,0,1,0,0,0,0,1],
    [1,0,0,0,0,0,0,1],
    [1,0,0,0,0,1,0,1],
    [1,0,0,0,0,0,0,1],
    [1,1,1,1,1,1,1,1]
  ]

  def initialize
    super(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS, SCALE, "RayCast")

    @camera.size(CAMERA_WIDTH_UNITS, CAMERA_HEIGHT_UNITS)
    @camera.look(CAMERA_WIDTH_UNITS / 2, CAMERA_HEIGHT_UNITS / 2)
    update_camera

    axis_colors = { lines: Flaty::Colors::WHITE, text: Flaty::Colors::WHITE }
    @camera_debug = Flaty::CameraDebug.new(@camera, axis_colors)

    ## assets
    @font      = SF::Font.from_file("assets/Cantarell-Regular.otf")

    @fps = Flaty::FPS.new(SCREEN_WIDTH, @font)

    @player = Vec2d.new(3, 3)
    @angle = 0.0
  end

  def update(delta)
    @player.x -= 0.01 if Flaty.pressed?(SF::Keyboard::A)
    @player.x += 0.01 if Flaty.pressed?(SF::Keyboard::D)
    @player.y += 0.01 if Flaty.pressed?(SF::Keyboard::W)
    @player.y -= 0.01 if Flaty.pressed?(SF::Keyboard::S)

    @angle -= 1 if Flaty.pressed?(SF::Keyboard::Left)
    @angle += 1 if Flaty.pressed?(SF::Keyboard::Right)
  end

  RAD = Math::PI / 180
  def draw(target, states)
    Flaty.paint(Flaty::Colors::GRAY)

    draw_map
    draw_player
    draw_hud

    @camera_debug.draw if debug?
  end

  def draw_player
    color = Flaty::Colors::YELLOW
    Flaty.draw_center_rect(@player.x, @player.y, PLAYER_SIZE, PLAYER_SIZE, color, @angle)
    px = @player.x
    py = @player.y
    pdx = 0.5 * Math.cos(-@angle * RAD)
    pdy = 0.5 * Math.sin(-@angle * RAD)
    Flaty.draw_line(px, py, px + pdx, py + pdy, color)
  end

  def draw_map
    space  = 0.02
    width  = 1.0 - space
    height = 1.0 - space

    MAP.size.times do |y|
      MAP.size.times do |x|
        px = x + space
        py = (MAP.size - y - 1) + space
        color = Flaty::Colors::BLACK
        color = Flaty::Colors::WHITE if MAP[y][x] == 1
        Flaty.draw_rect(px, py, width, height, color)
      end
    end
  end

  def button_down(code)
    @camera.key_pressed(self, code)
  end

  def draw_hud
    @fps.draw(@delta)
  end
end

game = RayCast.new
game.loop
