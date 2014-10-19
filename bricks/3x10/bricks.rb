require "./adapter.rb"

@step = 0
@successfully_boards = []
@successfully_uids   = []
board = Array.new(BD){ Array.new(BW, 0) }
#board = [
#  [1, 2, 2, 0, 0],
#  [1, 1, 2, 2, 0],
#  [1, 1, 2, 0, 0]
#]

_t = Time.now.to_i
combine_bricks(board)
puts "compute: %ds" % (Time.now.to_i - _t)
#@successfully_boards.each do |array|
#  print_array(array)
#end

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
