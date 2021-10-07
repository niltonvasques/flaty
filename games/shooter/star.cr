require "flaty"

class Star < Flaty::GameObject
  def update
    @current = (Flaty.elapsed_milis / 100 % @tiles.as(Flaty::Tiles).size).to_i
  end
end
