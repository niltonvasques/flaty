require "flaty"

class Quadtree(T)
  MAX = 4
  property xy : Vec2d, size : Vec2d
  property nodes : Array(Quadtree(T))
  property items : Array(T)
  property level : Int32

  def initialize(xy, size, level = 0)
    @size = size
    @xy = xy
    @nodes = Array(Quadtree(T)).new
    @items = Array(T).new
    @level = level
  end

  def split
    size = @size / 2.0
    @nodes << Quadtree(T).new(@xy, size, @level + 1)
    xy1 = @xy + Vec2d.new(size.x, 0)
    @nodes << Quadtree(T).new(xy1, size, @level + 1)
    xy2 = @xy + Vec2d.new(0, size.y)
    @nodes << Quadtree(T).new(xy2, size, @level + 1)
    xy3 = @xy + size
    @nodes << Quadtree(T).new(xy3, size, @level + 1)

    to_remove = [] of T
    @items.each do |item|
      i = index(item)
      if i != -1
        @nodes[i].insert(item)
        to_remove << item
      end
    end
    to_remove.each { |item| @items.delete(item) }
  end

  # ---------
  # | 2 | 3 |
  # ---------
  # | 0 | 1 |
  # ---------
  def index(r)
    r = r.collision_rect if r.is_a? Flaty::GameObject
    s = @size / 2.0
    if r.x >= @xy.x && r.x + r.width <= @xy.x + s.x # left
      if r.y >= @xy.y && r.y + r.height <= @xy.y + s.y # bottom
        return 0
      end
      if r.y >= @xy.y + s.y && r.y + r.height <= @xy.y + @size.y # top
        return 2
      end
    end
    if r.x >= @xy.x + s.x && r.x + r.width <= @xy.x + @size.x # right
      if r.y >= @xy.y && r.y + r.height <= @xy.y + s.y # bottom
        return 1
      end
      if r.y >= @xy.y + s.y && r.y + r.height <= @xy.y + @size.y
        return 3
      end
    end

    return -1
  end

  def insert(r)
    i = index(r)
    if @nodes.size == 0 || i == -1
      @items << r
      split if @items.size > MAX && @nodes.size == 0
      return
    end
    @nodes[i].insert(r)
  end

  # ---------
  # | 2 | 3 |
  # ---------
  # | 0 | 1 |
  # ---------
  def query(r)
    items = ([] of T) + @items
    i = index(r)
    if i == -1
      if @nodes.size > 0
        s = @size / 2.0

        rect = r
        rect = r.collision_rect if r.is_a? Flaty::GameObject

        left   = true if rect.x >= @xy.x - rect.width && rect.x <= @xy.x + s.x
        right  = true if rect.x >= @xy.x + s.x - rect.width && rect.x <= @xy.x + @size.x
        bottom = true if rect.y >= @xy.y - rect.height && rect.y <= @xy.y + s.y
        top    = true if rect.y >= @xy.y + s.y - rect.height && rect.y <= @xy.y + @size.y

        items += @nodes[0].query(r) if left && bottom
        items += @nodes[1].query(r) if right && bottom
        items += @nodes[2].query(r) if left && top
        items += @nodes[3].query(r) if right && top
      end
    else
      if @nodes.size > 0
        items += @nodes[i].query(r)
      end
    end
    items
  end

  def clear
    @items.clear
    @nodes.clear
  end

  def to_s
    "Node{ #{@items.map { |i| i.to_s }} - [ #{@nodes.to_s} ] }\n"
  end
end
#
#t = Quadtree.new(Vector2d[0,0], Vector2d[10, 10])
#t.split
#
#puts t.nodes
#puts t.size
#puts t.xy
#puts t.index(Rect[1,1, 2,2])
#puts t.index(Rect[6,1,2,2])
#puts t.index(Rect[1,6,2,2])
#puts t.index(Rect[6,6,2,2])
#puts t.index(Rect[5,6,2,2])
#
#
#t.insert(Rect[5,6,2,2])
#t.insert(Rect[4,6,2,2])
#t.insert(Rect[1,6,2,2])
#
#t.to_s.each_line { |s| puts s }
#
#q = Rect[4,5,4,4]
#puts "...querying #{q.to_s}"
#puts t.query(q)
