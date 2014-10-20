#encoding: utf-8
require "./adapter.rb"
require 'minitest/spec'
require "minitest/autorun"

describe "bricks" do

  describe "查找积木形状可放置的位置,返回偏移值, 由左至右递归" do
    before do
      @count = 0
      @shapes_hash = gen_shapes_hash if @shapes_hash.nil?
      BW  = 5 if not defined? BW # board width
      BD  = 3 if not defined? BD # board depth
    end
    it "最简单的情况" do
      board = Array.new(BD) { Array.new(BW, 0) }
      shape = [
        [1,1],
        [0,1],
        [1,1]
      ]
      is_continue = whether_pos_continue(board)
      assert_equal true, is_continue

      pos = whether_shape_adapte_board(board, shape)
      assert_equal [0,0], pos
    end

    it "最后一步" do
      board = [
        [2,1,1,0,0],
        [2,1,1,1,0],
        [2,2,2,0,0]
      ]
      is_continue = whether_pos_continue(board)
      assert_equal true, is_continue

      shape = [
        [3,3],
        [0,3],
        [3,3]
      ]

      uid = shape_chain(shape).flatten.join
      status = whether_include_this_klass(board, uid)
      assert_equal false, status

      pos = whether_shape_adapte_board(board, shape)
      assert_equal [0,3], pos

      board2 = [
        [2,1,1,3,3],
        [2,1,1,1,3],
        [2,2,2,3,3]
      ]

      board3 = put_shape_to_board(board, shape, pos)
      assert_equal board2, board3

      status = check_successfully(board3)
      assert_equal true, status
    end
    it "最后一步,情况二" do
      board = [
        [2,1,1,1,1],
        [2,2,0,1,0],
        [2,2,0,0,0]
      ]
      is_continue = whether_pos_continue(board)
      assert_equal true, is_continue

      shape = [
        [3,0,3],
        [3,3,3],
      ]
      pos = whether_shape_adapte_board(board, shape)
      assert_equal pos, [1,2]

      board2 = [
        [2,1,1,1,1],
        [2,2,3,1,3],
        [2,2,3,3,3]
      ]

      board3 = put_shape_to_board(board, shape, pos)
      assert_equal board2, board3

      status = check_successfully(board3)
      assert_equal true, status
    end
  end

end
