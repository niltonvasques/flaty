require "flaty/flaty"
require "flaty/fps"

class RayCast < Flaty::GameWindow
  SCREEN_WIDTH        = 3000
  SCREEN_HEIGHT       = 1500
  CAMERA_WIDTH_UNITS  = 16.0
  CAMERA_HEIGHT_UNITS = 8.0
  FIELD_WIDTH         = CAMERA_WIDTH_UNITS / 2
  SCALE               = SCREEN_WIDTH / CAMERA_WIDTH_UNITS
  PLAYER_SIZE         = 0.1
  ANGLES              = 60

  # map
  #MAP = [
  #  [1,1,1,1,1,1,1,1],
  #  [1,0,1,0,0,0,0,1],
  #  [1,0,1,0,0,0,0,1],
  #  [1,0,1,0,0,0,0,1],
  #  [1,0,0,0,0,0,0,1],
  #  [1,0,0,0,0,1,0,1],
  #  [1,0,0,0,0,0,0,1],
  #  [1,1,1,1,1,1,1,1]
  #]
  MAP = [
    [1,1,1,1,1,1,1,1],
    [1,0,0,0,1,0,0,1],
    [1,0,0,0,0,0,0,1],
    [1,0,0,0,1,1,1,1],
    [1,0,1,0,0,0,0,1],
    [1,0,1,1,1,1,0,1],
    [1,0,0,0,0,0,0,1],
    [1,1,1,1,1,1,1,1]
  ]

  @angle : Float64

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
    @angle = Math::PI / 2.0
  end

  def update(delta)
    @player.x -= 0.01 if Flaty.pressed?(SF::Keyboard::A)
    @player.x += 0.01 if Flaty.pressed?(SF::Keyboard::D)
    @player.y += 0.01 if Flaty.pressed?(SF::Keyboard::W)
    @player.y -= 0.01 if Flaty.pressed?(SF::Keyboard::S)

    @angle += 0.01 if Flaty.pressed?(SF::Keyboard::Left)
    @angle -= 0.01 if Flaty.pressed?(SF::Keyboard::Right)
    @angle = normalize_angle(@angle)
  end

  def normalize_angle(angle)
    return angle - 2 * Math::PI if angle > 2 * Math::PI
    return angle + 2 * Math::PI if angle < 0
    angle
  end

  RAD = Math::PI / 180
  def draw(target, states)
    Flaty.paint(Flaty::Colors::GRAY)

    draw_map
    draw_rays
    draw_player
    draw_hud

    @camera_debug.draw if debug?
  end

  def dist(x1, y1, x2, y2)
    Math.sqrt((x1-x2) * (x1-x2) + (y1-y2) * (y1-y2))
  end

  def draw_rays
    ray_angle = @angle - 30 * RAD
    ray = Vec2d.new(0, 0)
    y0 = 0
    x0 = 0

    dist_t = 0.0
    dist_v = 10000000000.0
    dist_h = 10000000000.0
    h = v = @player
    pdx = 0.5 * Math.cos(@angle)
    pdy = 0.5 * Math.sin(@angle)
    # horizontal lines
    ANGLES.times do |r|
      dof = 0.0
      atan = -1 / Math.tan(ray_angle)

      y0 = -1
      if face_up?(ray_angle)
        ray.y = @player.y.ceil
        ray.x = (@player.y - ray.y) * atan + @player.x
        y0 = 1
      else
        ray.y = @player.y.floor - 0.0001
        ray.x = (@player.y - ray.y) * atan + @player.x
      end
      if ray_angle == 0 || ray_angle == Math::PI
        ray = Vec2d.new(@player.x + pdx, @player.y + pdy)
        dof = 8
      end
      x0 = -y0 * atan

      h.x, h.y, dist_h = find_wall(dof, ray, x0, y0)
      #Flaty.draw_line(@player.x + pdx, @player.y + pdy, ray.x, ray.y, Flaty::Colors::RED)

      # vertical lines
      v.x = @player.x
      v.y = @player.y
      dof = 0.0
      atan = -Math.tan(ray_angle)

      if face_left?(ray_angle)
        ray = Vec2d.new(@player.x.floor - 0.0001,
                        (@player.x - @player.x.floor - 0.0001) * atan + @player.y)
        x0 = -1
        y0 = -x0 * atan
      else
        ray = Vec2d.new(@player.x.ceil, (@player.x - @player.x.ceil) * atan + @player.y)
        x0 = 1
        y0 = -x0 * atan
      end
      if ray_angle == 0 || ray_angle == Math::PI
        ray = Vec2d.new(@player.x + pdx, @player.y + pdy)
        dof = 8
      end

      v.x, v.y, dist_v = find_wall(dof, ray, x0, y0, face_left?(ray_angle))

      ray = h
      dist_t = dist_h
      wall_color = SF::Color.new(200, 0, 0)
      if dist_v < dist_h
        ray = v
        dist_t = dist_v
        wall_color = SF::Color.new(240, 0, 0)
      end
      Flaty.draw_line(@player.x, @player.y, ray.x, ray.y, Flaty::Colors::GREEN)

      draw_projection(ray_angle, dist_t, r, wall_color)

      dist_v = 10000000000.0
      dist_h = 10000000000.0
      ray_angle += RAD
    end
  end

  def find_wall(dof, ray, x0, y0, left = false)
    distance = 100000000000.0
    while dof < 8
      if wall?(ray.x, ray.y, left)
        dof = 8
        distance = dist(@player.x, @player.y, ray.x, ray.y)
      else
        ray.x += x0
        ray.y += y0
        dof += 1
      end
    end
    [ray.x, ray.y, distance]
  end

  def draw_projection(ray_angle, dist_t, r, wall_color)
    diff_angle = normalize_angle(ray_angle - @angle)
    dist_t = dist_t * Math.cos(diff_angle) # fix fisheye

    line_width = ANGLES.to_f / FIELD_WIDTH

    line_h = (1.0 * CAMERA_HEIGHT_UNITS / 2) / dist_t
    x1 = CAMERA_WIDTH_UNITS - (r / line_width)
    y1 = 0.0
    x2 = x1
    y2 = line_h
    offset = CAMERA_HEIGHT_UNITS / 2 - line_h / 2 # draw project to right side of board
    Flaty.draw_rect(x1, y1 + offset, 1 / line_width, ( y1-y2 ).abs, wall_color)
  end

  def face_up?(angle)
    angle > 0 && angle < Math::PI
  end

  def face_left?(angle)
    angle > Math::PI/2 && angle < Math::PI + Math::PI / 2
  end

  def wall?(mx, my, left = false)
    mx = mx.to_i64
    my = my.to_i64
    return false unless my < 8 && my >= 0 && mx < 8 && mx >= 0
    return true if MAP[8 - my - 1][mx] == 1
    return true if (left && MAP[8 - my - 1][mx + 1] == 1)
    false
  end

  def draw_player
    color = Flaty::Colors::YELLOW
    Flaty.draw_center_rect(@player.x, @player.y, PLAYER_SIZE, PLAYER_SIZE, color, -@angle / RAD)
    px = @player.x
    py = @player.y
    pdx = 0.5 * Math.cos(@angle)
    pdy = 0.5 * Math.sin(@angle)
    Flaty.draw_line(px, py, px + pdx, py + pdy, color)
    Flaty.draw_text_in_pixels(@font, "angle: #{@angle}", 9, 9)
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
