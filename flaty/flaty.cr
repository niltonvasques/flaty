module Flaty
  def self.random_color()
    SF::Color.new(rand(128) + 128, rand(128) + 128, rand(128) + 128)
  end
end
