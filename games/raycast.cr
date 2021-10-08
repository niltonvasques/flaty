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
    draw_player
    draw_rays
    draw_hud

    @camera_debug.draw if debug?
  end

  def dist(x1, y1, x2, y2)
    Math.sqrt((x1-x2) * (x1-x2) + (y1-y2) * (y1-y2))
  end

  def draw_rays
    ray_angle = @angle - 30 * RAD
    rx = 0.0
    ry = 0.0
    y0 = 0
    x0 = 0

    dist_t = 0.0
    dist_v = 10000000000.0
    dist_h = 10000000000.0
    hx = vx = @player.x
    hy = vy = @player.y
    pdx = 0.5 * Math.cos(@angle)
    pdy = 0.5 * Math.sin(@angle)
    angles = 60
    # horizontal lines
    angles.times do |r|
      dof = 0.0
      atan = -1 / Math.tan(ray_angle)

      if (ray_angle > 0 && ray_angle < Math::PI) # up
        ry = @player.y.ceil
        rx = (@player.y - ry) * atan + @player.x
        y0 = 1
        x0 = -y0 * atan
      else
        ry = @player.y.floor - 0.0001
        rx = (@player.y - ry) * atan + @player.x
        y0 = -1
        x0 = -y0 * atan
      end
      if ray_angle == 0 || ray_angle == Math::PI
        rx = @player.x + pdx
        ry = @player.y + pdy
        y0 = -1
        x0 = -y0 * atan
        dof = 8
      end

      while dof < 8
        mx = rx.to_i64
        my = ry.to_i64
        if my < 8 && my >= 0 && mx < 8 && mx >= 0 && MAP[8 - my - 1][mx] == 1
          dof = 8
          dist_h = dist(@player.x, @player.y, rx, ry)
        else
          rx += x0
          ry += y0
          dof += 1
        end
        hx = rx
        hy = ry
      end
      #Flaty.draw_line(@player.x + pdx, @player.y + pdy, rx, ry, Flaty::Colors::RED)

      # vertical lines
      vx = @player.x
      vy = @player.y
      dof = 0.0
      atan = -Math.tan(ray_angle)

      left = true

      if (ray_angle > Math::PI/2 && ray_angle < Math::PI + Math::PI/2)
        rx = @player.x.floor - 0.0001
        ry = (@player.x - rx) * atan + @player.y
        x0 = -1
        y0 = -x0 * atan
      else
        left = false
        rx = @player.x.ceil
        ry = (@player.x - rx) * atan + @player.y
        x0 = 1
        y0 = -x0 * atan
      end
      if ray_angle == 0 || ray_angle == Math::PI
        rx = @player.x + pdx
        ry = @player.y + pdy
        dof = 8
      end

      rrx = rx
      rry = ry
      while dof < 8
        mx = rx.to_i64
        my = ry.to_i64
        if my < 8 && my >= 0 && mx < 8 && mx >= 0 && (MAP[8 - my - 1][mx] == 1 || (left && MAP[8 - my - 1][mx + 1] == 1) ) #|| (!left && MAP[8 - my - 1][mx - 1] == 1))
          dof = 8
          dist_v = dist(@player.x, @player.y, rx, ry)
        else
          rx += x0
          ry += y0
          dof += 1
        end
        vx = rx
        vy = ry
      end
      #puts "(#{@player.x.round(2)}, #{@player.y.round(2)})p (#{rrx.round(2)}, #{rry.round(2)}) o (#{rx.round(2)},#{ry.round(2)}) r #{(ray_angle / RAD).round} angle #{left ? "left" : "right"}"
      rx = hx
      ry = hy
      dist_t = dist_h
      if dist_v < dist_h
        rx = vx
        ry = vy
        dist_t = dist_v
      end
      dist_v = 10000000000.0
      dist_h = 10000000000.0
      Flaty.draw_line(@player.x, @player.y, rx, ry, Flaty::Colors::GREEN)

      diff_angle = normalize_angle(ray_angle - @angle)
      dist_t = dist_t * Math.cos(diff_angle) # fix fisheye

      line_width = angles.to_f / FIELD_WIDTH

      line_h = (1.0 * CAMERA_HEIGHT_UNITS / 2) / dist_t
      x1 = CAMERA_WIDTH_UNITS - (r / line_width)
      y1 = 0.0
      x2 = x1
      y2 = line_h
      offset = CAMERA_HEIGHT_UNITS / 2 - line_h / 2
      Flaty.draw_rect(x1, y1 + offset, 1 / line_width, ( y1-y2 ).abs, Flaty::Colors::RED)
      ray_angle += RAD
    end
    #Flaty.draw_line(@player.x + pdx, @player.y + pdy, vx, vy, Flaty::Colors::GREEN)
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
