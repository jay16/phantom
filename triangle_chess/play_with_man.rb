#encoding: utf-8
require "./triangle_chess.rb"

chess = TriangleChess.new(5)
puts "初始化棋盘:"
chess.print_board
loop do
  count = chess.step_record.count
  if count.odd?
    printf("%s ", "机器人思考中...")

    btime = Time.now
    score = chess.search
    tlast = ((Time.now.to_f - btime.to_f) * 1000).to_i
    step = chess.best_step
    puts step.to_s
    printf("耗时[%sms]\n", tlast)
  else
    step = chess.player_input_step
  end

  chess.take_step(step)

  puts "第#{count + 1}步走法:"
  chess.print_board

  if chess.is_game_over?
    puts "all steps  :#{chess.step_record.count}"
    puts "input steps:#{chess.input_record.reject(&:nil?).count}"
    puts "input step replay..."

    chess.step_record.each_with_index do |_step, index|
      printf("%-6s %-15s %s\n", "step#{index + 1}", ": (#{chess.input_record[index]})", "=> #{_step.to_s}")
    end
    break
  end
end
