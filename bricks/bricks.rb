require "./adapter.rb"

BW  = 10 if not defined? BW # board width
BD  = 3 if not defined? BD # board depth
@count = 0 # 打印拼盘时记录是第几个
board = Array.new(BD){ Array.new(BW, 0) }
@_t = Time.now.to_f
combine_bricks(board)

