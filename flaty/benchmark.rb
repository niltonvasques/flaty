module Benchmark
  def self.elapsed
    started_at = Gosu.milliseconds
    yield
    Gosu.milliseconds - started_at
  end
end
