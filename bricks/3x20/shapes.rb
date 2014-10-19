@LEN = 5 # brick length
@BW  = 10 # board width
@BD  = 3 # board depth
@symbols = {
  "0" => "*",
  "1" => "&",
  "2" => "+",
  "3" => "!",
  "4" => "(",
  "5" => "%",
  "6" => "^",
  "7" => "~",
  "8" => "?",
  "9" => "$",
  "10" => ")",
  "11" => "#"
}

def copy_array(array)
  Marshal.load(Marshal.dump(array))
end

def dw_array(array)
  return [0,0] if array.empty?
  depth = array.length
  width = array.first.length
  return [depth, width]
end

@count = 0
def print_array(array)
  puts "the %sth" % (@count += 1)
  array.each do |row|
    row.each do |data|
      printf("%s ", (data == 0 ? "-" : data.to_s))
    end
    printf("\n")
  end
  puts "="*10
end

@shapes_with_oriention = []
def _gen_shapes(array, level=1)
  if level == @LEN
    @shapes_with_oriention.push(array)
    return 
  end
  _array = copy_array(array)

  for i in (0..@LEN-1)
    for j in (0..@LEN-1)
      next if array[i][j] == 0

      # right
      if j + 1 <= @LEN - 1  and array[i][j+1] == 0
        array[i][j+1] = 1
        _gen_shapes(array, level+1)
        array = copy_array(_array)
      end
      # left
      if j - 1 >= 0 and array[i][j-1] == 0
        array[i][j-1] = 1
        _gen_shapes(array, level+1)
        array = copy_array(_array)
      end
      # bottom
      if i + 1 <= @LEN - 1 and array[i+1][j] == 0
        array[i+1][j] = 1
        _gen_shapes(array, level+1)
        array = copy_array(_array)
      end
      # top
      if i - 1 >= 0 and array[i-1][j] == 0
        array[i-1][j] = 1
        _gen_shapes(array, level+1)
        array = copy_array(_array)
      end
    end
  end
end

def gen_shapes(array, level=1)
  _array = copy_array(array)
  for row in (0..@LEN-1)
    array[row][0] = 1 
    _gen_shapes(array, 1)
    array = copy_array(_array)
  end
end

array = Array.new(@LEN){ Array.new(@LEN, 0) }
gen_shapes(array)

def _original_shape(array)
  _array = copy_array(array)
  # 1. 逆向删除
  # 2. 注意数据下标
  _array.reverse.each_with_index do |row, index|
    if row.uniq == [0]
      array.delete_at(_array.length - 1 - index)
    end
  end
  array
end

# 还原积木形状
# 删除数组空行
def original_shape(array)
  array = _original_shape(array)
  array = _original_shape(array.transpose)
  array.transpose
end

# 积木形状去重
# 每个积木形状可以旋转四个方向
def four_orientions(array)
  _four, _lambda = [], lambda { |row| row.reverse }
  # original
  _four.push array
  # right_bottom
  _four.push array.transpose
  # bottom_left
  _four.push array.reverse.map(&_lambda)
  # left_top
  _four.push array.transpose.reverse.map(&_lambda)
  return _four
end
def turnover_oriention(array)
  _lambda = lambda { |arr| original_shape(arr) }
  (four_orientions(array).map(&_lambda) + 
   four_orientions(array.reverse).map(&_lambda)).uniq
end
# 
def shape_chain(shape)
  _chain, _i = [], 1
  dw = dw_array(shape).join.to_i
  shape.transpose.each do |row|
    row.each do |item|
     _chain.push(_i) if item and item > 0
      _i += 1
    end
  end
  return [_chain, dw]
end


@shapes_without_oriention, @shapes_hash = [], {}
@shapes_with_oriention = @shapes_with_oriention.uniq
  .map { |arr| original_shape(arr) }.uniq

_shapes = []
@shapes_with_oriention.each do |shape|
  next if _shapes.include?(shape)
  @shapes_without_oriention.push(shape)
  _shapes += turnover_oriention(shape)
end

@shapes_without_oriention.each_with_index do |shape, index|
  turnover_oriention(shape).each do |_shape|
    uid = shape_chain(_shape).flatten.join
    @shapes_hash[uid] = {
      "shape" => _shape,
      "klass" => index,
      "sym"   => @symbols.fetch(index.to_s)
    }
  end
end

puts @shapes_hash.size
