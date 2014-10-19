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
  _shapes += shapes_with_oriention
end

@shapes_without_oriention.each_with_index do |shape, index|
  turnover_oriention(shape).uniq.each do |_shape|
    uid = shape_chain(_shape).flatten.join
    @shapes_hash[uid] = {
      "shape" => _shape,
      "klass" => index,
      "sym"   => @symbols.fetch(index.to_s)
    }
  end
end
#puts @shapes_hash.size
#@shapes_hash.each_pair do |uid, hash| 
#  print_array(hash.fetch("shape"))
#  puts "klass: %d, symbol: %s, uid: %s" % [hash.fetch("klass"), hash.fetch("sym"), uid]
#  puts "="*10
#end
#exit
#
#puts @shapes_without_oriention.count
#@shapes_without_oriention.each do |shape|
#  print_array(shape)
#end

def whether_continue(board)
  is_continue = true
  @closed_lines = []
  get_closed_line(board)
  if not @closed_lines.empty? 
    line = @closed_lines.sort.first
    points = activate_points(board, line)
    if points.size % 5 != 0
      is_continue = false
    end
  end
  return is_continue
end

def get_closed_line(board)
  for i in (0..BW-1)
    if board[0][i] == 1
      _get_closed_line(board, [].push([0, i]))
    end
  end
end

def _get_closed_line(board, line=[])
  x, y = line.last
  if x == BD-1
    @closed_lines.push(line)
    return line
  end

  _board = copy_array(board)
  # 优先深度递归
  if x+1 <= BD-1 and board[x+1][y] == 1
    _get_closed_line(board, line.push([x+1, y]))
    board = copy_array(_board)
  elsif y+1 <= BW-1 and board[x][y+1] == 1
    _get_closed_line(board, line.push([x, y+1]))
    board = copy_array(_board)
  end
end

def activate_points(board, closed_line)
  points = []
  for i in (0..BD-1)
    for j in (0..BW-1)
      if j < closed_line.find_all { |item| item[0] == i }.map(&:last).sort.reverse.first
        points.push([i,j]) if board[i][j] == 0
      end
    end
  end
  return points
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
            _board, _uids = board_to_graph(board)
            if not @successfully_uids.include?(_uids)
              @successfully_uids.push(_uids)
              @successfully_boards.push(_board)
            end
            return
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

def board_to_graph(board)
  uids, klass, _board = [], [], Array.new(BD) { Array.new(BW, 0) }
  board.flatten.uniq.each do |step|
    shape = Array.new(BD) { Array.new(BW, 0) }
    for i in (0..BD-1)
      for j in (0..BW-1)
        shape[i][j] = 1 if board[i][j] == step
      end
    end
    _shape = original_shape(shape)
    uid = shape_chain(_shape).flatten.join
    hash = @shapes_hash.fetch(uid)
    klass.push(hash.fetch("klass"))
    uids.push(uid)

    for i in (0..BD-1)
      for j in (0..BW-1)
        _board[i][j] = hash.fetch("sym") if board[i][j] == step
      end
    end
  end
  return [_board, klass.sort]
end

@step = 0
@successfully_boards = []
@successfully_uids   = []
board = Array.new(BD){ Array.new(BW, 0) }
_t = Time.now.to_i
combine_bricks(board)
puts "compute: %ds" % (Time.now.to_i - _t)

_t = Time.now.to_i
puts "=====result====="
puts "kines: %d" % @successfully_boards.uniq.size
@successfully_boards.uniq.each do |array|
  print_array(array)
end
puts "print: %ds" % (Time.now.to_i - _t)
