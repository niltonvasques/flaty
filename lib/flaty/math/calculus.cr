module Calculus
  MIN_VALUE = 0.000000001

  # general derivative implementation for any f(x) function
  # calculating the derivate of the block function when approach around the point px
  def self.derivative(px, block)
    dy = block.call(px + MIN_VALUE) - block.call(px)
    dx = MIN_VALUE
    dy / dx
  end

  # reduced line equation
  # y = mx + n
  # m = line angular coefficient or the line slope
  # n = line linear coefficient
  def self.derivative_line(x, px, block)
    m = self.derivative(px, block)
    n = block.call(px) - (m*px)
    m*x + n
  end

  # specific derivative implementation for sin(x), x² and x³
  # dx/dx (sin(x)) = cos(x)
  def self.sin_x_slope_line(x, px)
    slope = Math.cos(px)
    slope*x + (Math.sin(px) - (slope*px))
  end

  # dx/dx (x²) = 2x
  def self.x2_slope_line(x, px)
    slope = 2*px
    slope*x + ((px**2) - (slope*px))
  end

  # dx/dx (x³) = 3x²
  def self.x3_slope_line(x, px)
    slope = 3*px*px
    slope*x + ((px**3) - (slope*px))
  end
end
