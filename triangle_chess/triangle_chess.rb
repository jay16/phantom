#encoding: utf-8
BOARD_WIDTH = 4
@chess_pieces = []

# 三角棋盘
def chess_board
  real_width = BOARD_WIDTH * 2 - 1
  real_board = Array.new(real_width) { Array.new(real_width, nil) }
  init_board(real_board, BOARD_WIDTH - 1, 0)
end

# 复制棋盘
def copy_array(board)
  Marshal.load(Marshal.dump(board))
end

@human_map = {}
# 三角棋盘本质还是方形棋盘
def init_board(board, x, y, level = 1)
  x.downto(x + 1 - (board.length-x)).each_with_index do |_x, _index|
    _y = x + y - _x
    human_key = (level*10 + _index)
    board[_y][_x] = human_key
    @human_map[human_key.to_s] = [_y, _x]
    @chess_pieces.push([_x,_y])
  end

  if x == board.length - 1
    return board
  else
    init_board(copy_array(board), x + 1, y + 1, level + 1)
  end
end

def print_board(board)
  puts "\n\n" + "="*10
  puts board.to_a.map { |row| row.join(" "*3) }#.join("\n")
  puts "="*10 + "\n\n"
end

#print_board(chess_board)
#puts @chess_pieces.to_s

def push_gen(gen, piece)
  if gen.empty?
    gen.push([piece])
  else
    _last = copy_array(gen.last)
    gen.push(_last.push(piece))
  end
end

# count available step
def move_gen(gen, board, index)
  piece = @chess_pieces[index]
  x, y = *piece

  # left-down
  _gen1 = []
  y.upto(board.length).each do |_y|
    _piece = [x + y - _y, _y]
    next if not @chess_pieces.include?(_piece)
    push_gen(_gen1, _piece) if board[_y][x + y - _y].is_a?(Fixnum)
  end

  # horizontal
  _gen2 = []
  x.upto(board.length).each do |_x|
    _piece = [_x, y]
    next if not @chess_pieces.include?(_piece)
    push_gen(_gen2, _piece) if board[y][_x].is_a?(Fixnum)
  end

  # right-down
  _gen3 = []
  x.upto(board.length).each do |_x|
    _piece = [_x, y - x + _x]
    next if not @chess_pieces.include?(_piece)
    push_gen(_gen3, _piece) if board[y - x + _x][_x].is_a?(Fixnum)
  end

  gen = (gen + _gen1 + _gen2 + _gen3).uniq

  if index == @chess_pieces.length - 1
    return gen
  else
    move_gen(gen, copy_array(board),index + 1)
  end
end

def is_game_over(board)
  board.flatten.uniq.find_all { |item| item.is_a?(Fixnum) }.empty?
end

@best_step = []
def search(board, level)
  _board = copy_array(board)
  steps = move_gen([], board, 0)
  scores = Array.new(steps.length)
  steps.each_with_index do |step, index|
    step.each do |piece|
      x, y = *piece
      board[y][x] = [(index.even? ? "even" : "odd"),index].join
    end
    if is_game_over(board)
      scores[index] = (level.even? ? -1 : +1) * 100
    else
      scores[index] = search(copy_array(board), level + 1)
    end
    board = copy_array(_board)
  end

  if level.even?
    max = scores.max
    scores.each_with_index do |score, index|
      if level == 0 and score == max
        @best_step = steps[index]
        break
      end
    end
    return max
  else
    min = scores.min
    scores.each_with_index do |score, index|
      if level == 0 and score == min
        @best_step = steps[index]
        break
      end
    end
    return min
  end
end

#@board = chess_board()
#print_board(@board)
#puts search(@board, 0)
#puts @best_step
