#encoding: utf-8

class TriangleChess
  HH = %w[~ ! @ # $ % ^ & * ? : - + = _ | \ { } < >]
  CONTINUE_MAX = 3
  attr_accessor :board, :step_record, :best_step, :human_map, :piece_map

  def initialize(board_width = 3)
    @piece_map    = []
    @piece_used   = []
    @human_map    = {}
    @best_step    = []
    @step_record  = []
    @board_width  = board_width || 3
    @board        = chess_board
  end

  # 复制棋盘
  def _copy_array(board)
    Marshal.load(Marshal.dump(board))
  end

  # 三角棋盘
  def chess_board
    real_width = @board_width * 2 - 1
    real_board = Array.new(real_width) { Array.new(real_width, " ") }
    init_board(real_board, 0, @board_width - 1)
  end

  # 三角棋盘本质还是方形棋盘
  #  x
  #  |_ y
  #  step1
  #         [0,3]
  #      [1,2] 
  #   [2,1] 
  #[3,0] 
  #  step2
  #         [0,3]
  #      [1,2] [1,4]
  #   [2,1] [2,3] 
  #[3,0] [3,2] 
  #  step3
  #         [0,3]
  #      [1,2] [1,4]
  #   [2,1] [2,3] [2,5]
  #[3,0] [3,2] [3,4]
  #  step4
  #         [0,3]
  #      [1,2] [1,4]
  #   [2,1] [2,3] [2,5]
  #[3,0] [3,2] [3,4] [3,6]
  def init_board(board = @board, x = 0, y = @board_width - 1, level = 1)
    _board = _copy_array(board)
    x.upto(@board_width - 1).each_with_index do |_x, _index|
      _y = x + y - _x
      _board[_x][_y] = @human_map.count
      @human_map[@human_map.count.to_s] = [_x, _y]
      @piece_map.push([_x,_y])
    end

    if x == @board_width - 1 
      return _board
    else
      init_board(_board, x + 1, y + 1, level + 1)
    end
  end

  def print_board(board = @board)
    puts "=" * @board.length * 2
    board.to_a.each_with_index do |row, index| 
      puts row.join(" ") + " " * 8 + print_step_info(index)
    end
  end

  def print_step_info(index)
    if not @step_record.empty? and index <= @step_record.length - 1
      "step#{index}: #{HH[index]}"
    end || ""
  end

  def _is_piece_available(board = @board, piece)
    x, y = *piece
    board[x][y].is_a?(Fixnum)
  end

  def _push_gen(gen, piece)
    if gen.empty?
      gen.push([piece])
    elsif gen.length < 3
      _last = _copy_array(gen.last)
      gen.push(_last.push(piece))
    end
  end

  # count available step
  #  x
  #  |_ y
  #         [0,3]
  #      [1,2] [1,4]
  #   [2,1] [2,3] [2,5]
  #[3,0] [3,2] [3,4] [3,6]
  #
  def move_gen(gen, board = @board, index = 0)
    _board = _copy_array(board)
    _piece_available = @piece_map - @piece_used
    _piece = _piece_available.at(index)
    x, y   = *_piece

    # left-down
    _gen1 = []
    # [0,3] -> [1,2] -> [2,1] -> [3,0]
    x.upto(@board_width - 1).each do |_x|
      _piece = [_x, x + y - _x]
      break if not _is_piece_available(_board, _piece)

      _push_gen(_gen1, _piece) 
    end

    # horizontal
    _gen2 = []
    # [3, 0] -> [3, 2] -> [3, 4] -> [3, 6]
    y.upto(@board_width * 2).each do |_y|
      _piece = [x, _y]
      break if not _is_piece_available(_board, _piece)

      _push_gen(_gen2, _piece) 
    end

    # right-down
    _gen3 = []
    # [0,3] -> [1,4] -> [2,5] -> [3,6]
    x.upto(@board_width).each do |_x|
      _piece = [_x, y - x + _x]
      break if not _is_piece_available(_board, _piece)

      _push_gen(_gen3, _piece) 
    end

    gen = (gen + _gen1 + _gen2 + _gen3).uniq

    if _piece_available.empty? or index == _piece_available.count - 1
      return gen
    else
      move_gen(gen, _board,index + 1)
    end
  end

  def is_game_over?(board = @board)
    board.flatten.uniq.find_all { |item| item.is_a?(Fixnum) }.empty?
  end

  def search(board = @board, level = 0)
    _board = _copy_array(board)
    steps = move_gen([], _board, 0)
    scores = Array.new(steps.length)
    steps.each_with_index do |step, index|
      step.each do |piece|
        x, y = *piece
        _board[x][y] =  "+"
      end
      if is_game_over?(_board)
        scores[index] = (level.even? ? -1 : +1) * 100
      else
        scores[index] = search(_board, level + 1)
      end
      board = _copy_array(_board)
    end

    if level.even?
      max = scores.max
      scores.each_with_index do |score, index|
        if level == 0 and score == max
          @best_step = steps[index]#.map { |item| item.reverse! }
          break
        end
      end
      return max
    else
      min = scores.min
      scores.each_with_index do |score, index|
        if level == 0 and score == min
          @best_step = steps[index]#.map { |item| item.reverse! }
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
      @piece_used.push(piece)
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

