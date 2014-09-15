#encoding: utf-8
class String
  COLORS = {
    :red => "\033[31m",
    :green => "\033[32m",
    :yellow => "\033[33m",
    :blue => "\033[34m"
  }
  def colorize(color)
    "#{COLORS[color]}#{self}\033[0m"
  end
end

class TriangleChess
  HH = %w[~ ! @ # $ % ^ & * ? : - + = _ | \ { } < >]
  CONTINUE_MAX = 3
  COLORS = %w[red green yellow blue]
  attr_accessor :board, :step_record, :best_step, :human_map, :piece_map, :board_width

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
    x.upto(@board_width - 1).each do |_x|
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
      printf("%s", row.join(" ") + " " * @board_width * 3 + print_step_info(index))
    end

    if @step_record.count > board.count
      board.count.upto(@step_record.count-1).each do |index|
        printf("%s", board.last.join(" ") + " " * @board_width * 3 + print_step_info(index))
      end
    end
  end

  def print_step_info(index)
    if not @step_record.empty? and index <= @step_record.length - 1
      color = get_color(index)
      "step#{index+1}: " + "#{HH[index]}".colorize(color) + "\n"
    end || "\n"
  end

  def get_color(index)
    COLORS.at(index % COLORS.count).to_sym
  end

  def _is_piece_available?(board = @board, piece)
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
  def move_gen(gen = [], board = @board, index = 0)
    _board = _copy_array(board)
    _piece_available = @piece_map - @piece_used
    _piece = _piece_available.at(index)
    x, y   = *_piece
    _gen = []

    # left-down
    # [0,3] -> [1,2] -> [2,1] -> [3,0]
    x.upto(@board_width - 1).each do |_x|
      _piece = [_x, x + y - _x]
      break if not _is_piece_available?(_board, _piece)

      _push_gen(_gen, _piece) 
    end
    gen += _gen

    # horizontal
    # [3, 0] -> [3, 2] -> [3, 4] -> [3, 6]
    _gen.clear
    (y..@board_width * 2).step(2) do |_y|
      _piece = [x, _y]
      break if not _is_piece_available?(_board, _piece)

      _push_gen(_gen, _piece) 
    end
    gen += _gen

    # right-down
    # [0,3] -> [1,4] -> [2,5] -> [3,6]
    _gen.clear
    x.upto(@board_width).each do |_x|
      _piece = [_x, y - x + _x]
      break if not _is_piece_available?(_board, _piece)

      _push_gen(_gen, _piece) 
    end
    gen += _gen


    if _piece_available.empty? or index == _piece_available.count - 1
      return gen.uniq
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

    if level.odd?
      max = scores.max
      if level.zero?
        _index = scores.index(max)
        @best_step = steps[_index]
      end

      return max
    else
      min = scores.min
      if level.zero?
        _index = scores.index(min)
        @best_step = steps[_index]
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

  def _check_step_available(step, input)
    if step.empty?
      warn "WARNGIN: please input your step!"
      return false
    elsif step.count > 3
      warn "WARNING: every step maxinum piece is 3, your [#{input}] is #{step.count}"
      return false
    elsif step.count == 1
      if not _is_piece_available?(@board, step.first)
        warn "WARNING: the piece [#{input}] already taken!"
        return false
      end
    else
      _is_all_available = true
      step.each do |piece|
        if not _is_piece_available?(@board, step.first)
          _is_all_available = false
          warn "WARNING: are you sure [#{input}] all available!"
          break
        end
      end
      return false if not _is_all_available

      _is_continue = true
      step.sort_by! { |piece| piece[0] }
      _first, _second, _latest, _orient = [], [], [], -1
      #_orient: 0 - horization, 1 - left_down, 2 - right_down
      step.each_with_index do |piece, index|
        if index == 0
          _first = piece
        elsif index == 1
          _second = piece
          if _first[0] == _second[0]
            _orient = 0
          elsif _first[0] + _first[1] == _second[0] + _second[1] and _first[0] + 1 == _second[0]
            _orient = 1
          elsif _first[0] - _first[1] == _second[0] - _second[1] and _first[0] + 1 == _second[0]
            _orient = 2
          else
            _is_continue = false
          end
        elsif index > 1
          if _orient == 0
            unless (piece[0] == _latest[0] and piece[1] == _latest[1] + 2)
              _is_continue = false
            end
          elsif _orient == 1
            unless (piece[0] == _latest[0] + 1 and  piece[0] + piece[1] == _latest[0] + _latest[1])
              _is_continue = false
            end
          elsif _orient == 2
            unless (piece[0] == _latest[0] + 1 and  piece[0] - piece[1] == _latest[0] - _latest[1])
              _is_continue = false
            end
          end
        end
        if not _is_continue
          warn "WARNGIN: are you sure [#{input}] in a line!"
          break 
        end

        _latest = _copy_array(piece)
      end
      return _is_continue
    end
    return true
  end
  def check_step_available(input)
    step   = []
    _is_all_human_map = true
    input.strip.split(/\s/).uniq.each do |human|
      if human.to_i <= @human_map.count - 1
        piece = @human_map[human]
        step.push(piece)
      else
        warn "WARNING: [#{human}] is a dirty piece!"
        _is_all_human_map = false
        break
      end
    end
    unless (_is_all_human_map and _check_step_available(step, input))
      step.clear
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

