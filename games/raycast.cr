require "flaty/flaty"
require "flaty/fps"

class RayCast < Flaty::GameWindow
  SCREEN_WIDTH        = 1500
  SCREEN_HEIGHT       = 1500
  CAMERA_WIDTH_UNITS  = 8.0
  CAMERA_HEIGHT_UNITS = 8.0
  SCALE               = SCREEN_WIDTH / CAMERA_WIDTH_UNITS

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
  end

  def update(delta)
  end

  def draw(target, states)
    Flaty.paint(Flaty::Colors::GRAY)

    draw_hud

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

    @camera_debug.draw if debug?
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
