require 'matrix'

class Vector2d < Vector
  def x; self[0]; end
  def y; self[1]; end
  def x=(x); self[0] = x; end
  def y=(y); self[1] = y; end
end
