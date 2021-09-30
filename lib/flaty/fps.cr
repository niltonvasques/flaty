class Flaty::FPS
  def initialize(@width : Int32, @font : SF::Font)
    @fps_list = [] of Float64
  end

  def draw(delta)
    @fps_list << (1.0/delta.as_seconds).round(2)
    @fps_list = @fps_list[2..@fps_list.size] if @fps_list.size > 1000
    fps = "FPS: #{(@fps_list.sum / @fps_list.size).to_i}"
    Flaty.draw_text_in_pixels(@font, fps, @width-(fps.size * 12), 9, 20, Flaty::Colors::GREEN)
  end
end
