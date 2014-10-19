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

def caculate_blank_points(board)
  @blank_points, blank_points = [], []
  for i in (0..BD-1)
    for j in (0..BW-1)
      next if board[i][j] == 1
      if not @blank_points.include?([i,j])
        _blank_points = copy_array(@blank_points)
        _caculate_blank_points(board, [i,j])
        _new_points = @blank_points - _blank_points
        blank_points.push(_new_points) if not _new_points.empty?
      end
    end
  end
  return blank_points
end

def _caculate_blank_points(board, pos)
  x, y = pos
  @blank_points.push(pos) if not @blank_points.include?(pos)
  if x+1 <= BD-1 and board[x+1][y] == 0
    pos = [x+1, y]
    _caculate_blank_points(board, pos)
  end
  if y+1 <= BW-1 and board[x][y+1] == 0
    pos = [x, y+1]
    @blank_points.push(pos) if not @blank_points.include?(pos)
    _caculate_blank_points(board, pos)
  end
end

def whether_continue(board)
  is_continue = true
  blank_points = caculate_blank_points(board)
  if not blank_points.empty? and
    blank_points.find_all { |points| points.size%5 != 0 }.size > 0
    is_continue = false
  end
  return is_continue
end

# 按积木形状的宽度对board进行切割
# 查找匹配位置 - 自左向右
def whether_shape_adapte_board(board, shape)
  _depth, _width = dw_array(shape)
  _chain = shape_chain(shape)[0]
  _pos = []

  (0..BD-_depth).each do |d|
    break if not _pos.empty?
    (0..BW-_width).each do |w|
      _board = Array.new(_depth){ Array.new(_width, 0) }
      for i in (0..BD-1)
        for j in (0..BW-1)
          if i >= d and i < d + _depth and
             j >= w and j < w + _width
             if board[i][j].nil?
               puts print_array(board)
               exit
             end
             _board[i-d][j-w] = board[i][j]
          end # if
        end # for i
      end # for j

      chain = shape_chain(_board)[0]
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
  return status
end

puts @shapes_without_oriention.size
def combine_bricks(board, shapes_status={})
  shapes_status = init_shapes_status if shapes_status.empty?
  _board = copy_array(board)
  _shapes_status = copy_array(shapes_status)

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
def solutions_3x10(klass)
  klass.each do |_klass|
    solutions = _solution(klass, [].push(_klass))
    if solutions.size == 2
      concate_array(solutions)
    end
  end
end
def _solution(klass, store=[])
  klass.each do |_klass|
    next if store.include?(_klass)
    if store.find_all { |t| t - _klass == t }.size == store.size
      store.push(_klass)
    end
  end
  return store
end

def concate_array(combines)
  one, two = combines
  @successfully_uids.each_with_index do |klass, index|
    one = @successfully_boards[index] if one == klass
    two = @successfully_boards[index] if two == klass
  end
  board1 = _concate_array(one, two)
  board2 = _concate_array(two, one)
  @solutions_3x10.push(board1)
  @solutions_3x10.push(board2)
end

def _concate_array(one, two)
  board = Array.new(3) { Array.new(10, 0) }
  for i in (0..2)
    for j in (0..9)
      if j < 5
        board[i][j] = one[i][j]
      else
        board[i][j] = two[i][j-5]
      end
    end
  end
  return board
end
def uniq_array(boards)
  _all, _uniq = [], []
  copy_array(boards).each do |board|
    next if _all.include?(board)
    _uniq.push(board)

    _all.push(board)
    _all.push(board.reverse)
    _all.push(board.transpose)
    _all.push(board.map { |row| row.reverse })
  end
end

_t = Time.now.to_i
puts "="*10
@solutions_3x10 = []
solutions_3x10(@successfully_uids)
uniq_array(@solutions_3x10).each do |array|
  print_array(array)
end
puts "print: %ds" % (Time.now.to_i - _t)
