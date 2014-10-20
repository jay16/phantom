#encoding: utf-8
require "./util.rb"

LEN = 5 # 积木长度 
# 打印拼图时，一个开关类型的积木使用同一个符号
SYMBOLS = {
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

# 生成所有可能的积木形状
def gen_shapes(array, level=1)
  _array = copy_obj(array)
  @shapes_with_oriention = [] # 子函数需要共享的变量
  for row in (0..LEN-1)
    array[row][0] = 1 
    _gen_shapes(array, 1)
    array = copy_obj(_array)
  end
  return @shapes_with_oriention
end

def _gen_shapes(array, level=1)
  if level == LEN # 积木节数
    @shapes_with_oriention.push(array)
    return 
  end

  _array = copy_obj(array)
  for i in (0..LEN-1)
    for j in (0..LEN-1)
      next if array[i][j] == 0

      # right
      if j + 1 <= LEN - 1  and array[i][j+1] == 0
        array[i][j+1] = 1
        _gen_shapes(array, level+1)
        array = copy_obj(_array)
      end
      # left
      if j - 1 >= 0 and array[i][j-1] == 0
        array[i][j-1] = 1
        _gen_shapes(array, level+1)
        array = copy_obj(_array)
      end
      # bottom
      if i + 1 <= LEN - 1 and array[i+1][j] == 0
        array[i+1][j] = 1
        _gen_shapes(array, level+1)
        array = copy_obj(_array)
      end
      # top
      if i - 1 >= 0 and array[i-1][j] == 0
        array[i-1][j] = 1
        _gen_shapes(array, level+1)
        array = copy_obj(_array)
      end
    end
  end
end

# 还原积木形状
# 删除数组空行、列
def original_shape(array)
  array = _original_shape(array)
  array = _original_shape(array.transpose)
  array.transpose
end

def _original_shape(array)
  _array = copy_obj(array)
  # 1. 逆向删除
  # 2. 注意数据下标
  _array.reverse.each_with_index do |row, index|
    array.delete_at(_array.length-1-index) if row.uniq == [0]
  end
  return array
end

# 积木形状的所有可能变形
def turnover_oriention(array)
  _lambda = lambda { |arr| original_shape(arr) }
  (four_orientions(array).map(&_lambda) + 
   four_orientions(array.reverse).map(&_lambda)).uniq
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

# 每个积木开关有唯一标识: uid = shape_chain(shape).flatten.join
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

# 生成积木形状(无方向变化) - 12 种
def gen_shapes_without_oriention
  _shapes, shapes_without_oriention = [], []
  array = Array.new(LEN){ Array.new(LEN, 0) }
  gen_shapes(array).uniq
    .map { |arr| original_shape(arr) }.uniq
    .each do |shape|
        next if _shapes.include?(shape)
        shapes_without_oriention.push(shape)
        _shapes += turnover_oriention(shape)
    end
  return shapes_without_oriention
end

# 生成hash对应表
def gen_shapes_hash
  shapes_hash = {}
  gen_shapes_without_oriention.each_with_index do |shape, index|
    turnover_oriention(shape).uniq.each do |_shape|
      uid = shape_chain(_shape).flatten.join
      shapes_hash[uid] = {
        "shape" => _shape,   # 积木形状
        "klass" => index,    # 该积木形状的类型
        "sym"   => SYMBOLS.fetch(index.to_s) # 对应的符号，拼成功时打印时使用
      }
    end
  end
  return shapes_hash
end

puts gen_shapes_hash.size
