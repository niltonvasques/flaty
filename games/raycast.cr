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
    [1,2,2,1,1,1,1,1],
    [1,0,0,0,1,0,0,1],
    [1,0,0,0,0,0,0,1],
    [1,0,0,0,1,1,1,1],
    [1,0,2,0,0,0,0,1],
    [1,0,1,1,1,1,0,1],
    [1,0,0,0,0,0,0,3],
    [1,1,1,1,1,1,3,3]
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
    move = Vec2d.new(0, 0)
    move.x -= 0.01 if Flaty.pressed?(SF::Keyboard::A)
    move.x += 0.01 if Flaty.pressed?(SF::Keyboard::D)
    move.y += 0.01 if Flaty.pressed?(SF::Keyboard::W)
    move.y -= 0.01 if Flaty.pressed?(SF::Keyboard::S)

    @angle += 0.01 if Flaty.pressed?(SF::Keyboard::Left)
    @angle -= 0.01 if Flaty.pressed?(SF::Keyboard::Right)
    @angle = normalize_angle(@angle)

    if move.x != 0 || move.y != 0
      # front and backward movement
      pdx = move.y * Math.cos(@angle)
      pdy = move.y * Math.sin(@angle)
      # left and right movement
      angle = @angle - 90 * RAD # pointing the movement to the right side of the player
      qdx = move.x * Math.cos(angle)
      qdy = move.x * Math.sin(angle)
      move = Vec2d.new(pdx + qdx, pdy + qdy)
    end

    previous = @player
    @player += move

    # solving collisions
    if wall?(@player.x, @player.y) > 0
      @player.x = @player.x - move.x
    end

    if wall?(@player.x, @player.y) > 0
      @player = previous
      @player.y = @player.y - move.y
    end
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
    ray_angle = @angle - (ANGLES / 2) * RAD
    step = ray = Vec2d.new(0, 0)
    h = v = @player
    color_h = color_v = 0

    dist_h = dist_v = 10000000000.0

    pdx = 0.5 * Math.cos(@angle)
    pdy = 0.5 * Math.sin(@angle)
    # horizontal lines
    ANGLES.times do |r|
      dof = 0.0
      atan = -1 / Math.tan(ray_angle)

      step.y = -1
      if face_up?(ray_angle)
        ray = Vec2d.new((@player.y - @player.y.ceil) * atan + @player.x, @player.y.ceil)
        step.y = 1
      else
        ray = Vec2d.new((@player.y - @player.y.floor - 0.0001) * atan + @player.x,
                        @player.y.floor - 0.0001)
      end
      if ray_angle == 0 || ray_angle == Math::PI
        ray = Vec2d.new(@player.x + pdx, @player.y + pdy)
        dof = 8
      end
      step.x = -step.y * atan

      xx, yy, dist_h, color_h = find_wall(dof, ray, step)
      h.x = xx.as(Float64)
      h.y = yy.as(Float64)
      #Flaty.draw_line(@player.x + pdx, @player.y + pdy, ray.x, ray.y, Flaty::Colors::RED)

      # vertical lines
      dof = 0.0
      atan = -Math.tan(ray_angle)

      if face_left?(ray_angle)
        ray = Vec2d.new(@player.x.floor - 0.0001,
                        (@player.x - @player.x.floor - 0.0001) * atan + @player.y)
        step = Vec2d.new(-1, 1 * atan)
      else
        ray = Vec2d.new(@player.x.ceil, (@player.x - @player.x.ceil) * atan + @player.y)
        step = Vec2d.new(1, -1 * atan)
      end

      if ray_angle == 0 || ray_angle == Math::PI
        ray = Vec2d.new(@player.x + pdx, @player.y + pdy)
        dof = 8
      end

      xx, yy, dist_v, color_v = find_wall(dof, ray, step, face_left?(ray_angle))
      v.x = xx.as(Float64)
      v.y = yy.as(Float64)

      ray = h
      side_wall = true
      tile_type = color_h
      if dist_v < dist_h
        side_wall = false
        tile_type = color_v
        ray = v
      end
      Flaty.draw_line(@player.x, @player.y, ray.x, ray.y, Flaty::Colors::GREEN)

      draw_projection(ray_angle, Math.min(dist_v, dist_h), r, wall_color(tile_type.to_i, side_wall))

      dist_h = dist_v = 10000000000.0
      ray_angle += RAD
    end
  end

  def find_wall(dof, ray, step, left = false)
    distance = 100000000000.0
    color : Int32 = 0
    while dof < 8
      color = wall?(ray.x, ray.y, left)
      if color > 0
        dof = 8
        distance = dist(@player.x, @player.y, ray.x, ray.y)
      else
        ray += step
        dof += 1
      end
    end
    [ray.x, ray.y, distance, color]
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
    return 0 unless my < 8 && my >= 0 && mx < 8 && mx >= 0
    return MAP[8 - my - 1][mx] if MAP[8 - my - 1][mx] > 0
    return MAP[8 - my - 1][mx + 1] if (left && MAP[8 - my - 1][mx + 1] > 0)
    0
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
        color = wall_color(MAP[y][x], false) if MAP[y][x] > 0 #Flaty::Colors::WHITE if MAP[y][x] == 1
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

  def wall_color(tile_type : Int32, side_wall = true)
    case tile_type
    when 1
      return SF::Color.new(200, 0, 0) if side_wall
      return SF::Color.new(240, 0, 0)
    when 2
      return SF::Color.new(0, 200, 0) if side_wall
      return SF::Color.new(0, 240, 0)
    when 3
      return SF::Color.new(0, 0, 200) if side_wall
      return SF::Color.new(0, 0, 240)
    end
    SF::Color.new(0, 0, 0)
  end

end

game = RayCast.new
game.loop
