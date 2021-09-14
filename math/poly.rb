class Poly
  attr_accessor :coefficients

  def initialize(coefficients = [])
    @coefficients = coefficients.map(&:to_f)
  end

  def x(x)
    sum = 0
    @coefficients.each_with_index do |a, index|
      sum += a * (x**index)
    end

    sum
  end

  def +(p)
    operation(p, :+)
  end

  def -(p)
    operation(p, :-)
  end

  # multiply the coefficients and sum degrees
  def *(p)
    new_coefficients = []
    @coefficients.each_with_index do |a, i|
      p.coefficients.each_with_index do |b, j|
        new_coefficients[i + j] = 0 unless new_coefficients[i + j]
        new_coefficients[i + j] += a * b
      end
    end
    Poly.new(new_coefficients)
  end

  def operation(p, op)
    max_size = [p.coefficients.size, @coefficients.size].max
    new_coefficients = []
    max_size.times do |index|
      a = 0
      a += @coefficients[index] if @coefficients[index]
      a = a.send(op, p.coefficients[index]) if p.coefficients[index]
      new_coefficients[index] = a
    end
    Poly.new(new_coefficients)
  end

  def to_s
    equation
  end

  def equation(precision = 10)
    @coefficients.map.with_index do |a, index|
      if index > 1
        "#{a.round(precision)} * x^#{index}"
      elsif index == 1
        "#{a.round(precision)} * x"
      else
        a.round(precision).to_s
      end
    end.reject { |a| a == '0.0' }.join(' + ')
  end

  def self.zero
    Poly.new([0])
  end

  def self.interpolate(points)
    raise 'Must provide at least one point.' if points.size == 0
    x = points.map(&:first)
    raise 'Not all x values are distinct.' if x.size != x.uniq.size

    terms = []
    points.each_with_index do |point, index|
      terms << single_term(points, index)
    end

    terms.reduce(Poly.zero, &:+)
  end

  def self.single_term(points, i)
    term = Poly.new([1.0])
    xi = points[i][0]
    yi = points[i][1]
    points.each_with_index do |point, j|
      next if j == i
      xj = point[0]
      term = term * Poly.new([-xj.to_f / (xi - xj), 1.0 / (xi - xj)])
    end

    term * Poly.new([yi])
  end

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
