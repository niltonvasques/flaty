require 'matrix'

class Rect < Vector
  def x; self[0]; end
  def y; self[1]; end
  def width; self[2]; end
  def height; self[3]; end

  def x=(x); self[0] = x; end
  def y=(y); self[1] = y; end
  def width=(width); self[2] = width; end
  def height=(height); self[3] = height; end
end
