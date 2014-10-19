require "./base.rb"

@shapes_without_oriention, @shapes_hash = [], {}
@shapes_with_oriention = @shapes_with_oriention.uniq
  .map { |arr| original_shape(arr) }.uniq

_shapes = []
@shapes_with_oriention.each do |shape|
  next if _shapes.include?(shape)
  @shapes_without_oriention.push(shape)
  uid = shape_chain(shape).flatten.join
  shapes_with_oriention = turnover_oriention(shape)
  @shapes_hash[uid] = shapes_with_oriention
  _shapes += shapes_with_oriention
end

#puts @shapes_without_oriention.count
#@shapes_without_oriention.each do |shape|
#  print_array(shape)
#end

@less_3_levels = @shapes_with_oriention.find_all { |_array| _array.length <=3 }
puts @less_3_levels.count
#@less_3_levels.each do |shape|
#  print_array(shape)
#end
#
def whether_continue(board)
  is_continue = true
  index = get_closed_index(board)
  if index >= 0
    if activate_points(board, index).size % 5 != 0
      is_continue = false
    end
  end

  return is_continue
end

def get_closed_index(board)
  _index = -1
  board.transpose.each_with_index do |row, index|
    if row.uniq == [1]
      _index = index
      break
    end
  end
  return _index
end

def activate_points(board, index)
  points = []
  for i in (0..BD-1)
    for j in (0..BW-1)
      if j < index
        points.push([i,j]) if board[i][j] == 0
      end
    end
  end
  return points
end

# 按积木形状的宽度对board进行切割
# 查找匹配位置 - 自左向右
def whether_shape_adapte_board(board, shape)
  _depth, _width = dw_array(shape) 
  _chain = shape_chain(shape)[0]

  #puts shape.to_s
  #puts "[%d,%d] [%d,%d] " % [_d,_w,_depth,_width]
  _pos = []
  (0..BD-_depth).each do |d|
    break if not _pos.empty?
    (0..BW-_width).each do |w|
      _board = Array.new(_depth){ Array.new(_width, 0) }
      for i in (0..BD-1)
        for j in (0..BW-1)
          if i >= d and i < d + _depth and
             j >= w and j < w + _width
             begin
               if board[i][j].nil?
                 puts print_array(board)
                 exit
               end
             _board[i-d][j-w] = board[i][j]
             rescue => e
               puts "[%d,%d]" % [i-d,j-w]
               puts board[i][j]
               puts shape.to_s
               puts e.message
               exit
             end
          end # if
        end # for i
      end # for j

      chain = shape_chain(_board)[0]
      #chain.pop
      #_chain.pop
      if (_chain - chain).join == _chain.join
        _pos = [d, w]
        break
      end
    end
  end
  return _pos
end

def put_shape_to_board(board, shape, pos)
  _d, _w = pos
  _depth, _width = dw_array(shape)

  @step += 1
  for i in (0.._depth-1)
    for j in (0.._width-1)
      board[i+_d][j+_w] = @step if shape[i][j] == 1
    end
  end
  return board
end

def check_successfully(board)
  num = board.map { |row| row.find_all { |item| item == 0 }.length }.reduce(:+)
  num == 0
end

def init_shapes_status
  status = @shapes_without_oriention.inject({}) do |hash, shape|
    hash.merge!({shape_chain(shape).flatten.join => 0})
  end
  puts status.size
  #puts status.to_s
  return status
end

puts @shapes_without_oriention.size
def combine_bricks(board, shapes_status={})
  shapes_status = init_shapes_status if shapes_status.empty?
  _board = copy_array(board)
  _shapes_status = copy_array(shapes_status)

  #@less_3_levels
  @shapes_without_oriention.each do |_shape|
    turnover_oriention(_shape).each do |shape|
      uid = shape_chain(shape).flatten.join
      next if shapes_status[uid] == 1
      if whether_continue(board)
        pos = whether_shape_adapte_board(board, shape)
        if not pos.empty?
          board = put_shape_to_board(board, shape, pos)
          if check_successfully(board)
            @successfully_boards.push(board_to_graph(board))
          else
            turnover_oriention(shape).each do |tmp|
              _uid = shape_chain(tmp).flatten.join
              shapes_status[_uid] = 1
            end
            combine_bricks(board, shapes_status)
          end
        end
        board = copy_array(_board)
        shapes_status = copy_array(_shapes_status)
      end
    end
  end
end

def board_to_shapes(board)
  shapes = []
  board.flatten.uniq.each do |step|
    shape = Array.new(BD) { Array.new(BW, 0) }
    for i in (0..BD-1)
      for j in (0..BW-1)
        shape[i][j] = 1 if board[i][j] == step
      end
    end
    shapes.push(original_shape(shape))
  end
  return shapes
end

def board_to_graph(array)
  hash = {}
  array.flatten.uniq.each_with_index do |item, index|
    hash[item.to_s] = @symbols.fetch(index.to_s)
  end
  for i in (0..BD-1)
    for j in (0..BW-1)
      array[i][j] = hash.fetch(array[i][j].to_s)
    end
  end
  return array
end

def uniq_successfully_boards
  boards = copy_array(@successfully_boards.uniq)
  boards_split_shapes = boards.map { |board| board_to_shapes(board) }
  _boards_split_shapes = copy_array(boards_split_shapes)
  boards_all = []
  boards_uniq = []
  _boards_split_shapes.each_with_index do |board, index|
    next if boards_all.include?(board)


    boards_uniq.push(boards[index])
    boards_all.push board
  end
  return boards_uniq
end

@step = 0
@successfully_boards = []
board = Array.new(BD){ Array.new(BW, 0) }
_t = Time.now.to_i
combine_bricks(board)
puts "compute: %ds" % (Time.now.to_i - _t)

_t = Time.now.to_i
puts "=====result====="
puts "all: %d" % @successfully_boards.uniq.size
boards_uniq = uniq_successfully_boards.uniq
puts "uniq: %d" % boards_uniq.size
boards_uniq.uniq.each do |array|
  print_array(array)
end
puts "uniq: %ds" % (Time.now.to_i - _t)
