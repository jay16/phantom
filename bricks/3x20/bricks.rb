require "./adapter.rb"
require "./3x10.rb"

@LEN = 5 # brick length
@BW  = 20 # board width
@BD  = 3 # board depth
@count = 0
@step  = 0
@successfully_boards = []
@successfully_uids   = []
# 3x5
#board_3x5 = Array.new(3){ Array.new(5, 0) }
board = Array.new(@BD){ Array.new(@BW, 0) }
_t = Time.now.to_i
combine_bricks(board)
puts "compute 3x5: [%d] - %ds" % [@successfully_boards.size, (Time.now.to_i - _t)]
exit

# 3x10
_t = Time.now.to_i
@solutions_3x10 = []
solutions_3x10(@successfully_uids)
@solutions_3x10 = uniq_array(@solutions_3x10).last
puts "compute 3x10: [%d] - %ds" % [@solutions_3x10.size, (Time.now.to_i - _t)]

# 3x20
def board_to_digit(board)
  for i in (0..board.length-1)
    for j in (0..board.first.length-1)
      if board[i][j].is_a?(String)
        board[i][j] = @symbols.key(board[i][j]).to_i
      end
    end
  end
  return board
end
boards = copy_array(@successfully_boards)
@BW    = 15 # board width
@count = 0
@successfully_boards = []
@successfully_uids   = []
_t = Time.now.to_i
board = Array.new(@BD){ Array.new(@BW, 0) }
boards.each do |_board|
  board_3x5 = Array.new(3){ Array.new(15, 0) }
  _board2 = _concate_array(_board, board_3x5)
  _board3 = board_to_digit(_board2)
  combine_bricks(_board3)
end
puts "compute 3x10: [%d] - %ds" % [@successfully_boards.size, (Time.now.to_i - _t)]
uniq_array(@successfully_boards).first.each do |_board|
  print_array(_board)
end
