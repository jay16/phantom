# nested test case example.
require "./triangle_chess.rb"
require 'test/unit'

class TriangleChessTest < Test::Unit::TestCase
  def setup
    @chess = TriangleChess.new
    @width_steps = {
      "2" => 6,
      "3" => 18,
      "4" => 37,
      "5" => 63
    }
  end

  def test_default_board_width
    default_width = 4
    assert_equal(default_width, @chess.board_width)
    assert_equal(@width_steps[default_width.to_s], @chess.move_gen.length)
  end

  def test_assign_board_width
    @width_steps.each_pair do |width, steps|
      chess = TriangleChess.new(width.to_i)
      assert_equal(steps, chess.move_gen.length)
    end
  end

  #  x
  #  |_ y
  #         [0,3]
  #      [1,2] [1,4]
  #   [2,1] [2,3] [2,5]
  #[3,0] [3,2] [3,4] [3,6]
  def test_orient_with_two_piece
    h_one = [1,2]
    h_two = [1,4]

    assert @chess._is_orient_horizontal(h_one, h_two)
    assert !@chess._is_orient_leftdown(h_one, h_two)
    assert !@chess._is_orient_rightdown(h_one, h_two)

    l_one = [2,3]
    l_two = [3,2]
    assert @chess._is_orient_leftdown(l_one, l_two)
    assert !@chess._is_orient_horizontal(l_one, l_two)
    assert !@chess._is_orient_rightdown(l_one, l_two)

    r_one = [2,3]
    r_two = [3,4]
    assert @chess._is_orient_rightdown(r_one, r_two)
    assert !@chess._is_orient_horizontal(r_one, r_two)
    assert !@chess._is_orient_leftdown(r_one, r_two)
  end

  #  x
  #  |_ y
  #         [0,3]
  #      [1,2] [1,4]
  #   [2,1] [2,3] [2,5]
  #[3,0] [3,2] [3,4] [3,6]
  def test_step_on_line
    h_step = [[2,1],[2,3],[2,5]]
    l_step = [[1,4],[2,3],[3,2]]
    r_step = [[1,2],[2,3],[3,4]]

    assert @chess._is_step_on_line(h_step, "horizonal")
    assert @chess._is_step_on_line(l_step, "leftdown")
    assert @chess._is_step_on_line(r_step, "rightdown")

    b_step = [[0,3],[3,0]]
    t_step = [[2,3],[3,2],[3,4]]
    assert !@chess._is_step_on_line(b_step, "boundary")
    assert !@chess._is_step_on_line(t_step, "triangle")
  end
end
