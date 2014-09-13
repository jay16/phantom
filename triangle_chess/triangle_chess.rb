#encoding: utf-8

class TriangleChess
  HH = %w[~ ! @ # $ % ^ & * ? : - + = _ | \ { } < >]
  attr_accessor :board, :step_record, :best_step, :human_map, :piece_map

  def initialize(board_width = 3)
    @piece_map    = []
    @human_map    = {}
    @best_step    = []
    @step_record  = []
    @board        = chess_board(board_width)
  end

  # 复制棋盘
  def copy_array(board)
    Marshal.load(Marshal.dump(board))
  end

  # 三角棋盘
  def chess_board(board_width)
    real_width = board_width * 2 - 1
    real_board = Array.new(real_width) { Array.new(real_width, " ") }
    init_board(real_board, board_width - 1, 0)
  end

  # 三角棋盘本质还是方形棋盘
  def init_board(board, x, y, level = 1)
    x.downto(x + 1 - (board.length-x)).each_with_index do |_x, _index|
      _y = x + y - _x
      board[_y][_x] = @human_map.count
      @human_map[@human_map.count.to_s] = [_y, _x]
      @piece_map.push([_x,_y])
    end

    if x == board.length - 1
      return board
    else
      init_board(copy_array(board), x + 1, y + 1, level + 1)
    end
  end

  def print_board(board = @board)
    puts "="*@board.length*2
    board.to_a.each_with_index do |row, index| 
      puts row.join(" ") + " "*8 + print_step_info(index)
    end
  end

  def print_step_info(index)
    if not @step_record.empty? and index <= @step_record.length - 1
      "step#{index}: #{HH[index]}"
    else
      ""
    end
  end

  def _push_gen(gen, piece)
    if gen.empty?
      gen.push([piece])
    else
      _last = copy_array(gen.last)
      gen.push(_last.push(piece))
    end
  end

  # count available step
  def move_gen(gen, board = @board, index = 0)
    piece = @piece_map[index]
    x, y  = *piece

    _is_continue   = true
    _max_continue  = 3
    _continue_time = 1

    # left-down
    _gen1 = []
    _continue_time = 1
    y.upto(board.length).each do |_y|
      break if _continue_time > _max_continue

      _piece = [x + y - _y, _y]
      if @piece_map.include?(_piece) and _is_continue
        if board[_y][x + y - _y].is_a?(Fixnum)
          _push_gen(_gen1, _piece) 
          _continue_time += 1
        end
      else
        _is_continue = false
        next
      end
    end

    # horizontal
    _gen2 = []
    _continue_time = 0
    x.upto(board.length).each do |_x|
      break if _continue_time > _max_continue

      _piece = [_x, y]
      if @piece_map.include?(_piece) and _is_continue
        if board[y][_x].is_a?(Fixnum)
          _push_gen(_gen2, _piece) 
          _continue_time += 1
        end
      else
        _is_continue = false
        next
      end
    end

    # right-down
    _gen3 = []
    _continue_time = 0
    x.upto(board.length).each do |_x|
      break if _continue_time > _max_continue

      _piece = [_x, y - x + _x]
      if @piece_map.include?(_piece) and _is_continue
        if board[y - x + _x][_x].is_a?(Fixnum)
          _push_gen(_gen3, _piece) 
          _continue_time += 1
        end
      else
        _is_continue = false
        next
      end
    end

    gen = (gen + _gen1 + _gen2 + _gen3).uniq

    if index == @piece_map.length - 1
      return gen
    else
      move_gen(gen, copy_array(board),index + 1)
    end
  end

  def is_game_over(board = @board)
    board.flatten.uniq.find_all { |item| item.is_a?(Fixnum) }.empty?
  end

  def search(board = copy_array(@board), level = 0)
    _board = copy_array(board)
    steps = move_gen([], board, 0)
    scores = Array.new(steps.length)
    steps.each_with_index do |step, index|
      step.each do |piece|
        x, y = *piece
        board[y][x] = [(index.even? ? "even" : "odd"),index].join
      end
      if is_game_over(board)
        scores[index] = (level.even? ? -1 : +1) * 100
      else
        scores[index] = search(copy_array(board), level + 1)
      end
      board = copy_array(_board)
    end

    if level.even?
      max = scores.max
      scores.each_with_index do |score, index|
        if level == 0 and score == max
          @best_step = steps[index].map { |item| item.reverse! }
          break
        end
      end
      return max
    else
      min = scores.min
      scores.each_with_index do |score, index|
        if level == 0 and score == min
          @best_step = steps[index].map { |item| item.reverse! }
          break
        end
      end
      return min
    end
  end

  def take_step(step)
    @step_record.push(step)
    step.each do |piece|
      x, y = *piece
      @board[x][y] = HH.at(@step_record.count - 1)
    end
  end

  def check_step_available(input)
    step = []
    if input.strip.empty?
      warn "WARNGIN: please input your step!"
    end

    _steps = input.split(/\s/).uniq
    if _steps.length > 3
      warn "WARNING: steps maxinum is 3"
    else
      _steps.each do |human|
        if human.to_i <= @human_map.count - 1
          piece = @human_map[human]
          x, y = *piece
          if @board[x][y].is_a?(Fixnum)
            step.push(piece)
          else
            warn "WARNING: [#{human}] already take!"
            break
          end
        else
          warn "WARNING: [#{human}] not available!"
          break
        end
      end
    end

    step.each do |piece|
      # check is on line
    end
    return step
  end

  def player_input_step
    puts "请输入第#{@step_record.count}步走法?" 
    STDOUT.flush 
    input = gets.chomp 
    if (step = check_step_available(input)).empty?
      player_input_step
    else
      return step
    end
  end
end

#chess = TriangleChess.new(3)
#chess.print_board
#puts chess.is_game_over
#puts chess.print_board(chess.board)
#puts chess.move_gen([]).count
