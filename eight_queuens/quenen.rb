#encoding: utf-8
MAX    = 8
STAND  = 'Q'
EMPTY  = ' '
OCCUPY = '-'
@nCount = 0

# 打印棋盘
def print_board(board)
  @nCount += 1

  puts "="*MAX + @nCount.to_s + "="*MAX
  puts board.map { |row| row.join(' ') }.join("\n")
end

# 备份棋盘
def copy_board(board)
  Marshal.load(Marshal.dump(board))
end

# 主程序
def quenen(board, row)
  # 判断棋盘位置是否越界
  return if row < 0 or row >= MAX

  # 备份棋盘
  _board = copy_board(board)

  # 遍历row行所在列数据
  for i in (0...MAX)
    # board[row][i] 不为空，则跳过
    next if board[row][i] != EMPTY

    # 走到这里，说明该位置为空，放置quenen
    board[row][i] = STAND

    # quenen - board[row][i]所属区域
    for j in (0...MAX)
      for k in (0...MAX)
        # 不是空的，可能是quenen位置，肯定不是board[row][i]的所属区域
        next if board[j][k] != EMPTY

        # quenen所在行
        if j == row
          board[j][k] = OCCUPY
        # quenen所在列
        elsif k == i
          board[j][k] = OCCUPY
        # quenen所在点东北/西南线
        elsif row + i == j + k
          board[j][k] = OCCUPY
        # quenen所在点东南/西北线
        elsif row - i == j - k
          board[j][k] = OCCUPY
        end
      end
    end

    # 最到棋盘最后一行
    # 从那里可以论证每行可以放置一个quenen?
    if row == MAX - 1
      print_board(board)
    else
      # 继续遍历下一行
      quenen(board, row + 1)
    end

    # 回溯，还原棋盘
    board = copy_board(_board)
  end
end

# 初始化棋盘
board = Array.new(MAX){ Array.new(MAX, EMPTY) }
# 从第一行开始
quenen(board, 0)

