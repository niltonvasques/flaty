module Poly
  # f(x) is a function that finds the unique curve polynomial
  # that interpolates the given list of points
  def self.f(x, points)
    n = points.size
    sum = 0

    n.times do |i|
      prod = points[i][1]

      n.times do |j|
        prod = ((x - points[j][0]) / (points[i][0] - points[j][0])) * prod if j != i
      end

      sum += prod
    end
    sum
  end
end
