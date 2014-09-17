# nested test case example.
#require 'test/unit'
require "./permutation.rb"
require 'minitest/spec'
require "minitest/autorun"

describe Permutation do

  def _factorial(num)
    return num if num == 1 
    num * _factorial(num - 1)
  end

  describe "make sure _factorial work normally" do
    it "should return expect value" do
      assert_equal _factorial(2), 2
      assert_equal _factorial(3), 2*3
      assert_equal _factorial(4), 2*3*4
      assert_equal _factorial(5), 2*3*4*5
    end
  end

  before do
    @permutation = Permutation.new
  end
  describe "when play with permutation and combination" do
    it "should return 2 different combinations when offer a array with 2 elements" do
      array = [2,3]
      @permutation.array = array
      @permutation.permutation
      assert_equal _factorial(array.length), @permutation.container.uniq.length
    end

    it "should return 2*3 different combinations when offer a array with 3 elements" do
      array = [2,3,4]
      @permutation.array = array
      @permutation.permutation
      assert_equal _factorial(array.length), @permutation.container.uniq.length
    end

    it "should return 2*3*4 different combinations when offer a array with 4 elements" do
      array = [2,3,4,5]
      @permutation.array = array
      @permutation.permutation
      assert_equal _factorial(array.length), @permutation.container.uniq.length
    end
  end

end
