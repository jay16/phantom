#encoding: utf-8
require "./triangle_chess.rb"

def take_step(step)
  step.each do |piece|
    x, y = *piece
    count = @step_record.count

    info = "(#{(count.odd? ? '机' : '人')}.#{count})"

    @board[x][y] = info
  end
end
@best_step = []
@step_record = []
@board = chess_board()
print_board(@board)
loop do
  count = @step_record.count

  if count.odd?
    puts "机器人走法:"

    btime = Time.now
    score = search(copy_array(@board), 0)
    tlast = ((Time.now.to_f - btime.to_f) * 1000).to_i
    step = @best_step.map { |item| item.reverse! }
    printf("计算耗时[%sms]\n", tlast)
  else
    puts "请输入第#{count}步走法?" 
    STDOUT.flush 
    input = gets.chomp 
    step = input.split(/\s/).map { |key| @human_map[key] }
  end

  take_step(step)
  @step_record.push(step)

  puts "第#{count}走法:"
  print_board(@board)

  break if is_game_over(@board)
end
