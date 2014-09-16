#encoding: utf-8
MAX    = 8
EMPTY  = ' '
OCCUPY = '-'
STAND  = 'Q'
@nCount = 0

def print_board(board)
  @nCount += 1

  puts "=" * MAX + @nCount.to_s + "=" * MAX
  puts board.map { |row| row.join(' ') }.join("\n")
end

def copy_board(board)
  Marshal.load(Marshal.dump(board))
end

def quenen(board, col)
  return if col < 0 or col >= MAX

  _board = copy_board(board)

  for i in (0...MAX)
    next if board[i][col] != EMPTY

    board[i][col] = STAND

    for j in (0...MAX)
      for k in (0...MAX)
        next if board[j][k] != EMPTY
        
        if j == i or
           k == col or
           i + col == j + k or
           i - col == j - k 
          board[j][k] = OCCUPY 
        end
      end
    end

    if col == MAX - 1
      print_board(board)
    else
      quenen(board, col + 1)
    end

    board = copy_board(_board)
  end
end

board = Array.new(MAX) { Array.new(MAX, EMPTY) }
quenen(board, 0)
