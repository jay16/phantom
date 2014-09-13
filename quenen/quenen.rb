#encoding: utf-8
MAX    = 8
STAND  = 'Q'
EMPTY  = ' '
OCCUPY = '-'
@nCount = 0

# ��ӡ����
def print_board(board)
  @nCount += 1

  puts "="*MAX + @nCount.to_s + "="*MAX
  puts board.map { |row| row.join(' ') }.join("\n")
end

# ��������
def copy_board(board)
  Marshal.load(Marshal.dump(board))
end

# ������
def quenen(board, row)
  # �ж�����λ���Ƿ�Խ��
  return if row < 0 or row >= MAX

  # ��������
  _board = copy_board(board)

  # ����row������������
  for i in (0...MAX)
    # board[row][i] ��Ϊ�գ�������
    next if board[row][i] != EMPTY

    # �ߵ����˵����λ��Ϊ�գ�����quenen
    board[row][i] = STAND

    # quenen - board[row][i]��������
    for j in (0...MAX)
      for k in (0...MAX)
        # ���ǿյģ�������quenenλ�ã��϶�����board[row][i]����������
        next if board[j][k] != EMPTY

        # quenen������
        if j == row
          board[j][k] = OCCUPY
        # quenen������
        elsif k == i
          board[j][k] = OCCUPY
        # quenen���ڵ㶫��/������
        elsif row + i == j + k
          board[j][k] = OCCUPY
        # quenen���ڵ㶫��/������
        elsif row - i == j - k
          board[j][k] = OCCUPY
        end
      end
    end

    # ��������һ��
    # �����������֤ÿ�п��Է���һ��quenen?
    if row == MAX - 1
      print_board(board)
    else
      # ����������һ��
      quenen(board, row + 1)
    end

    # ���ݣ���ԭ����
    board = copy_board(_board)
  end
end

# ��ʼ������
board = Array.new(MAX){ Array.new(MAX, EMPTY) }
# �ӵ�һ�п�ʼ
quenen(board, 0)

