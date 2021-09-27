require 'matrix'
require 'flaty/math/vector_2d'
require 'flaty/math/rect'

class Quadtree
  MAX = 4
  attr_accessor :xy, :size, :nodes, :items, :level

  def initialize(xy, size, level = 0)
    @size = size
    @xy = xy
    @nodes = []
    @items = []
    @level = level
  end

  def split
    size = @size / 2.0
    @nodes[0] = Quadtree.new(@xy.dup, size.dup, @level + 1)
    xy1 = @xy + Vector2d[size.x, 0]
    @nodes[1] = Quadtree.new(xy1, size.dup, @level + 1)
    xy2 = @xy + Vector2d[0, size.y]
    @nodes[2] = Quadtree.new(xy2, size.dup, @level + 1)
    xy3 = @xy + size
    @nodes[3] = Quadtree.new(xy3, size.dup, @level + 1)

    to_remove = []
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
    r = r.collision_rect if r.is_a? GameObject
    s = @size / 2.0
    binding.pry if r.x.nil? or r.width.nil?
    if r.x >= @xy.x and r.x + r.width <= @xy.x + s.x # left
      if r.y >= @xy.y and r.y + r.height <= @xy.y + s.y # bottom
        return 0
      end
      if r.y >= @xy.y + s.y and r.y + r.height <= @xy.y + @size.y # top
        return 2
      end
    end
    if r.x >= @xy.x + s.x and r.x + r.width <= @xy.x + @size.x # right
      if r.y >= @xy.y and r.y + r.height <= @xy.y + s.y # bottom
        return 1
      end
      if r.y >= @xy.y + s.y and r.y + r.height <= @xy.y + @size.y
        return 3
      end
    end

    return -1
  end

  def insert(r)
    i = index(r)
    if @nodes.size == 0 or i == -1
      @items << r
      split if @items.size > MAX and @nodes.size == 0
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
    items = [] + @items
    i = index(r)
    if i == -1
      if @nodes.size > 0
        s = @size / 2.0

        rect = r
        rect = r.collision_rect if r.is_a? GameObject

        left   = true if rect.x >= @xy.x - rect.width and rect.x <= @xy.x + s.x
        right  = true if rect.x >= @xy.x + s.x - rect.width and rect.x <= @xy.x + @size.x
        bottom = true if rect.y >= @xy.y - rect.height and rect.y <= @xy.y + s.y
        top    = true if rect.y >= @xy.y + s.y - rect.height and rect.y <= @xy.y + @size.y

        items += @nodes[0].query(r) if left and bottom
        items += @nodes[1].query(r) if right and bottom
        items += @nodes[2].query(r) if left and top
        items += @nodes[3].query(r) if right and top
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
    "Node{ #{@items.map(&:to_s)} - [ #{@nodes.map(&:to_s).join(',')} ] }\n"
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
