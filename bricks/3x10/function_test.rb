#encoding: utf-8
require "./shapes.rb"
require "./function.rb"
require 'minitest/spec'
require "minitest/autorun"

describe "bricks" do

  def all_blank_points(board)
    points = []
    for i in (0..BD-1)
      for j in (0..BW-1)
        points.push([i, j]) if board[i][j] == 0
      end
    end
    return points
  end

  describe "计算连续空白块, 由左至右递归" do
    it "空白的拼盘应该返回它自己" do
      board = Array.new(BD) { Array.new(BW, 0) }
      blank_points = caculate_blank_points(board)
      all_points = all_blank_points(board)
      
      assert_equal blank_points.size, 1
      assert_equal blank_points.first.sort, all_points.sort
    end

    it "贴边" do
      board = [
        [1, 2, 2, 0, 0],
        [1, 2, 2, 2, 0],
        [1, 1, 1, 0, 0]
      ]
      blank_points = caculate_blank_points(board)
      assert_equal 1, blank_points.size
      assert_equal all_blank_points(board).sort, blank_points.first.sort
    end
    it "内陷" do
      board = [
        [1, 1, 1, 1, 1],
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0]
      ]
      blank_points = caculate_blank_points(board)
      assert_equal blank_points.size, 1
      assert_equal blank_points.first.sort, all_blank_points(board).sort
    end
     
    it "垂直分成两部分" do
      board = [
        [0, 0, 1, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 1, 0, 0]
      ]
      blank_points = caculate_blank_points(board)
      assert_equal blank_points.size, 2

      @blank_points = []
      _caculate_blank_points(board, [0,0])
      _first = @blank_points
      assert_equal blank_points.first.sort, _first.sort

      @blank_points = []
      _caculate_blank_points(board, [0,3])
      _second = @blank_points
      assert_equal blank_points.last.sort, _second.sort
    end

    it "垂直分成三部分" do
      board = [
        [0, 1, 0, 1, 0],
        [0, 1, 0, 1, 0],
        [0, 1, 0, 1, 0]
      ]
      blank_points = caculate_blank_points(board)
      assert_equal blank_points.size, 3

      @blank_points = []
      _caculate_blank_points(board, [0,0])
      _first = @blank_points
      assert_equal blank_points.first.sort, _first.sort

      @blank_points = []
      _caculate_blank_points(board, [0,2])
      _second = @blank_points
      assert_equal blank_points[1].sort, _second.sort

      @blank_points = []
      _caculate_blank_points(board, [0,4])
      _third = @blank_points
      assert_equal blank_points.last.sort, _third.sort
    end

    it "水平切分成两部分" do
      board = [
        [0, 0, 0, 0, 0],
        [1, 1, 1, 1, 1],
        [0, 0, 0, 0, 0]
      ]
      blank_points = caculate_blank_points(board)
      assert_equal blank_points.size, 2

      @blank_points = []
      _caculate_blank_points(board, [0,0])
      _first = @blank_points
      assert_equal blank_points.first.sort, _first.sort

      @blank_points = []
      _caculate_blank_points(board, [2,0])
      _second = @blank_points
      assert_equal blank_points.last.sort, _second.sort
    end

    it "十字架分成四部分" do
      board = [
        [0, 0, 1, 0, 0],
        [1, 1, 1, 1, 1],
        [0, 0, 1, 0, 0]
      ]
      blank_points = caculate_blank_points(board)
      assert_equal blank_points.size, 4

      @blank_points = []
      _caculate_blank_points(board, [0,0])
      _first = @blank_points
      assert_equal blank_points.first.sort, _first.sort

      @blank_points = []
      _caculate_blank_points(board, [0,3])
      _second = @blank_points
      assert_equal blank_points[1].sort, _second.sort

      @blank_points = []
      _caculate_blank_points(board, [2,0])
      _third = @blank_points
      assert_equal blank_points[2].sort, _third.sort

      @blank_points = []
      _caculate_blank_points(board, [2,3])
      _four = @blank_points
      assert_equal blank_points.last.sort, _four.sort
    end

    it "镂空成分成三部分" do
      board = [
        [0, 1, 1, 1, 0],
        [0, 1, 0, 1, 0],
        [0, 1, 1, 1, 0]
      ]
      blank_points = caculate_blank_points(board)
      assert_equal blank_points.size, 3

      @blank_points = []
      _caculate_blank_points(board, [0,0])
      _first = @blank_points
      assert_equal blank_points.first.sort, _first.sort

      @blank_points = []
      _caculate_blank_points(board, [0,4])
      _second = @blank_points
      assert_equal blank_points[1].sort, _second.sort

      @blank_points = []
      _caculate_blank_points(board, [1,2])
      _last = @blank_points
      assert_equal blank_points.last.sort, _last.sort
    end
    it "逆向" do
      board = [
        [0, 1, 1, 1, 0],
        [0, 1, 0, 1, 0],
        [0, 0, 0, 0, 0]
      ]
      blank_points = caculate_blank_points(board)
      assert_equal blank_points.size, 1
      assert_equal blank_points.first.sort, all_blank_points(board).sort
    end
  end
end
