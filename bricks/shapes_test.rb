#encoding: utf-8
require "./shapes.rb"
require 'minitest/spec'
require "minitest/autorun"

describe "bricks" do

  describe "积木形状的生成、归类" do
    before do
      BW  = 5 if not defined? BW # board width
      BD  = 3 if not defined? BD # board depth
    end
    it "归类" do
      shape1 = [
        [1,1],
        [0,1],
        [1,1]
      ]
      shape2 = [
        [1,1,1],
        [1,0,1],
      ]
      shapes = turnover_oriention(shape1)
      assert_equal 4, shapes.size
      assert_equal true, shapes.include?(shape2)
    end
  end

end
