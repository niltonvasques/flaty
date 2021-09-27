module Benchmark
  #NANO = 1_000_000_000
  NANO = 1

  def self.elapsed
    started_at = Time.now.to_f
    yield
    finished_at = Time.now.to_f
    #started_at = started_at.to_i * NANO + started_at.nsec
    #finished_at = finished_at.to_i * NANO + finished_at.nsec
    finished_at - started_at
  end
end
