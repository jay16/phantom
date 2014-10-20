#encoding: utf-8
require "./shapes.rb"
require "./3x10.rb"
require 'minitest/spec'
require "minitest/autorun"

describe "bricks" do
  describe "3x10" do
    before do
      @LEN = 5 # brick length
      @BW  = 15 # board width
      @BD  = 3 # board depth
      @count = 0
      @step  = 0
    end
    it "3x5拼到3x15" do
      board_3x5  = Array.new(3) { Array.new(5, 1) }
      board_3x15 = Array.new(3) { Array.new(10, 0) }
      board = _concate_array(board_3x5, board_3x15)
    end
  end
end
