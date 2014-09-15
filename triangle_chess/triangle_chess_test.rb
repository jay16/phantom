# nested test case example.
require "./triangle_chess.rb"
require 'test/unit'

class TriangleChessTest < Test::Unit::TestCase
  def setup
    @chess = TriangleChess.new
    @width_steps = {
      "2" => 6,
      "3" => 18,
      "4" => 37
    }
  end

  def test_default_board_width
    assert_equal(3, @chess.board_width)
    assert_equal(@width_steps["3"], @chess.move_gen.length)
  end

  def test_assign_board_width
    @width_steps.each_pair do |width, steps|
      chess = TriangleChess.new(width.to_i)
      assert_equal(steps, chess.move_gen.length)
    end
  end

end
