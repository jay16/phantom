#encoding: utf-8
MAX     = 8
QUENEN  = 'Q'
EMPTY   = ' '
OCCUPY  = '-'
@nCount = 0

def print_result(board)
  @nCount += 1
  printf("===== %d =====\n", @nCount)
  for i in (0...MAX)
    for j in(0...MAX)
      printf("%s ", board[i][j])
    end
    printf("\n")
  end
  printf("\n\n")
end

def copy_array(board)
  _board = Array.new(MAX){ Array.new(MAX, EMPTY) }
  for i in (0...MAX)
    for j in (0...MAX)
      _board[i][j] = board[i][j]
    end
  end
  return _board 
end

def quenen(board, row)
  return if row < 0 or row >= MAX

  _board = copy_array(board)

  for i in (0...MAX)
    next if board[row][i] != EMPTY

    board[row][i] = QUENEN

    for j in (0...MAX)
      for k in (0...MAX)
        next if board[j][k] != EMPTY

        if j == row
          board[j][k] = OCCUPY
        elsif k == i 
          board[j][k] = OCCUPY
        elsif row + i == j + k
          board[j][k] = OCCUPY
        elsif row - i == j - k
          board[j][k] = OCCUPY
        end
      end
    end
    if row == MAX - 1
      print_result(board)
    else 
      quenen(board, row + 1)
    end

    board = copy_array(_board)
  end
end

board = Array.new(MAX){ Array.new(MAX, EMPTY) }
quenen(board, 0)
