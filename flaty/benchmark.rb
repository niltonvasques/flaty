module Benchmark
  NANO = 1_000_000_000

  def self.elapsed
    started_at = Time.now
    yield
    finished_at = Time.now
    started_at = started_at.to_i * NANO + started_at.nsec
    finished_at = finished_at.to_i * NANO + finished_at.nsec
    finished_at - started_at
  end
end
