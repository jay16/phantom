#encoding: utf-8
require "./shapes.rb"
require "./function.rb"

# [graph-board, klass-array]
def board_parser(board)
  return [board, []] if board.flatten.uniq == [0]

  uids, klass, _board = [], [], Array.new(@BD) { Array.new(@BW, 0) }
  board.flatten.uniq.each do |step|
    next if step == 0
    shape = Array.new(@BD) { Array.new(@BW, 0) }
    for i in (0..@BD-1)
      for j in (0..@BW-1)
        shape[i][j] = 1 if board[i][j] == step
      end
    end
    _shape = original_shape(shape)
    uid = shape_chain(_shape).flatten.join
    hash = @shapes_hash.fetch(uid)
    klass.push(hash.fetch("klass"))
    uids.push(uid)

    for i in (0..@BD-1)
      for j in (0..@BW-1)
        _board[i][j] = hash.fetch("sym") if board[i][j] == step
      end
    end
  end
  return [_board, uids, klass.sort]
end

def whether_pos_continue(board)
  is_continue = true
  blank_points = caculate_blank_points(board)
  if not blank_points.empty? and
    blank_points.find_all { |points| points.size%5 != 0 }.size > 0
    is_continue = false
  end
  return is_continue
end

def whether_include_this_klass(board, uid)
  return false if board.flatten.uniq == [0]

  _klass = board_parser(board).last
  hash = @shapes_hash.fetch(uid)
  klass = hash.fetch("klass")
  _klass.include?(klass)
end

# 按积木形状的宽度对board进行切割
# 查找匹配位置 - 自左向右
def whether_shape_adapte_board(board, shape)
  _depth, _width = dw_array(shape)
  _chain, _pos = shape_chain(shape)[0], []

  (0..@BD-_depth).each do |d|
    break if not _pos.empty?
    (0..@BW-_width).each do |w|
      _board = Array.new(_depth){ Array.new(_width, 0) }
      for i in (0..@BD-1)
        for j in (0..@BW-1)
          if i >= d and i < d + _depth and
             j >= w and j < w + _width
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
      board[i+_d][j+_w] = @step if shape[i][j] > 0
    end
  end
  return board
end

def check_successfully(board, level=1)
  num = board.find_all { |row| row.uniq.include?(0) }.size
  #puts "%d - %s" % [level,num == 0]
  #print_array(board)
  num == 0
end

def init_shapes_status(board)
  _klass = board_parser(board).last
  @shapes_with_oriention.inject({}) do |hash, shape|
    uid = shape_chain(shape).flatten.join
    klass = @shapes_hash.fetch(uid).fetch("klass")
    hash.merge!({ uid => _klass.include?(klass) ? 1 : 0 })
  end
end

# main
def combine_bricks(board, shapes_status={}, level=1)
  shapes_status = init_shapes_status(board) if shapes_status.empty?
  _board = copy_array(board)
  _shapes_status = copy_array(shapes_status)

  @shapes_without_oriention.each do |_shape|
    turnover_oriention(_shape).each do |shape|
      next if shape.length > @BD
      uid = shape_chain(shape).flatten.join
      next if shapes_status[uid] == 1
      next if whether_include_this_klass(board, uid)
      next if not whether_pos_continue(board) 

      pos = whether_shape_adapte_board(board, shape)
      next if pos.empty?

      board = put_shape_to_board(board, shape, pos)
      if check_successfully(board, level)
        _board, _uids, _klass = board_parser(board)
        if not @successfully_boards.include?(_board)
          print_array(_board)
          @successfully_uids.push(_uids)
          @successfully_boards.push(_board)
        end
        return
      else
        turnover_oriention(shape).each do |tmp|
          _uid = shape_chain(tmp).flatten.join
          shapes_status[_uid] = 1
        end
        combine_bricks(board, shapes_status, level+1)
      end
    end
    board = copy_array(_board)
    shapes_status = copy_array(_shapes_status)
  end
end


