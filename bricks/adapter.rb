#encoding: utf-8
require "./shapes.rb"

# 解析拼盘当前积木形状
# [graph-board, uids, klass-array]
def board_parser(board)
  return [board, []] if board.flatten.uniq == [0]

  uids, klass, _board = [], [], Array.new(BD) { Array.new(BW, 0) }
  board.flatten.uniq.each do |step|
    next if step == 0
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

    # 打印成符拼图
    for i in (0..BD-1)
      for j in (0..BW-1)
        _board[i][j] = hash.fetch("sym") if board[i][j] == step
      end
    end
  end
  return [_board, uids, klass.sort]
end

# 当前拼盘连续空白块数是否都为除5余0
def whether_pos_continue(board)
  is_continue = true
  blank_points = caculate_blank_points(board)
  if not blank_points.empty? and
    blank_points.map(&:size).join.to_i % 5 != 0
    is_continue = false
  end
  return is_continue
end

# 无用 - @shapes_hash已起这样的作用
# 当前托盘是否已经使用了该积木形状类型
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

  (0..BD-_depth).each do |d|
    break if not _pos.empty?
    (0..BW-_width).each do |w|
      _board = Array.new(_depth){ Array.new(_width, 0) }
      for i in (0..BD-1)
        for j in (0..BW-1)
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

# 把积木形状放置到拼盘上
def put_shape_to_board(board, shape, pos)
  _d, _w = pos
  _depth, _width = dw_array(shape)

  step = board.flatten.sort.last + 1
  for i in (0.._depth-1)
    for j in (0.._width-1)
      board[i+_d][j+_w] = step if shape[i][j] > 0
    end
  end
  return board
end

# 检查拼盘完空白块
def check_successfully(board, level=1)
  num = board.find_all { |row| row.uniq.include?(0) }.size
  if level > 10
  puts "%d - %s" % [level,num == 0]
  print_array(board)
  end
  num == 0
end

# 初始化shapes_hash, 每个积木形状对应的信息
def init_shapes_status(board)
  _klass = board_parser(board).last
  @shapes_hash = gen_shapes_hash if @shapes_hash.nil?
  @shapes_with_oriention.inject({}) do |hash, shape|
    uid = shape_chain(original_shape(shape)).flatten.join
    klass = @shapes_hash.fetch(uid).fetch("klass")
    hash.merge!({ uid => _klass.include?(klass) ? 1 : 0 })
  end
end

# 拼积木的主程序
def combine_bricks(board, shapes_status={}, level=1)
  shapes_status = init_shapes_status(board) if shapes_status.empty?
  _board = copy_obj(board)
  _shapes_status = copy_obj(shapes_status)

  if @shapes_without_oriention.nil?
    @shapes_without_oriention = gen_shapes_without_oriention 
    @global_boards = []
  end
  return if @global_boards.include?(board)
  @global_boards += turnover_oriention(copy_obj(board))

  @shapes_without_oriention.each do |_shape|
    turnover_oriention(_shape).each do |shape|
      next if shape.length > BD # 深度超过直接过滤
      uid = shape_chain(shape).flatten.join
      next if shapes_status[uid] == 1 # 拼盘中已使用该类型跳过
      next if not whether_pos_continue(board) # 连接空白块数有不为5倍数的跳过

      pos = whether_shape_adapte_board(board, shape) 
      next if pos.empty? # 积木形状无位置放置的跳过

      board = put_shape_to_board(board, shape, pos)
      if check_successfully(board, level+1)
        _board = board_parser(board).first
        print_array(_board)
        return
      else
        # 该积木所有形状标志为已使用
        turnover_oriention(shape).each do |tmp|
          _uid = shape_chain(tmp).flatten.join
          shapes_status[_uid] = 1
        end
        combine_bricks(board, shapes_status, level+1)
      end
    end
    board = copy_obj(_board) # 还原状态进入一次递归
    shapes_status = copy_obj(_shapes_status)
  end
end
