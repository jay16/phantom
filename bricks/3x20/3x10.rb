#encoding: utf-8
require "./shapes"

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
  board = Array.new(@BD) { Array.new(@BW, 0) }
  for i in (0..@BD-1)
    for j in (0..@BW-1)
      if j < one.first.length
        board[i][j] = one[i][j]
      else
        board[i][j] = two[i][j-one.first.length]
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

    _all += turnover_oriention(board)
  end
  [_uniq, _all.uniq]
end

