#encoding: utf-8
require "./triangle_chess.rb"

chess = TriangleChess.new(5)
puts "初始化棋盘:"
chess.print_board
loop do
  count = chess.step_record.count
  puts "count:#{count}"

  if count.odd?
    puts "机器人走法:"

    btime = Time.now
    score = chess.search
    tlast = ((Time.now.to_f - btime.to_f) * 1000).to_i
    step = chess.best_step
    printf("计算耗时[%sms]\n", tlast)
  else
    step = chess.player_input_step
  end

  chess.take_step(step)

  puts "第#{count}走法:"
  chess.print_board

  break if chess.is_game_over?
end
