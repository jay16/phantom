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
  attr_accessor :board, :step_record, :input_record, :best_step, :human_map, :piece_map, :board_width

  def initialize(board_width = 4)
    @piece_map    = []
    @piece_used   = []
    @human_map    = {}
    @best_step    = []
    @step_record  = []
    @input_record = []
    @board_width  = board_width || 3
    @board        = chess_board
  end

  # 三角棋盘
  def chess_board
    real_width = @board_width * 2 - 1
    real_board = Array.new(real_width) { Array.new(real_width, " ") }
    init_board(real_board, 0, @board_width - 1)
  end

  # 复制棋盘
  def _copy_array(board)
    Marshal.load(Marshal.dump(board))
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
  #
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
    puts "=" * board.length * 2
    board.to_a.each_with_index do |row, index| 
      row.each do |hpiece|
        if hpiece.is_a?(Fixnum)
          printf("%s ", hpiece)
        elsif HH.include?(hpiece)
          unless (_index = HH.index(hpiece)).nil?
            color = _get_color(_index)
            printf("%s ", hpiece.to_s.colorize(color))
          else
            printf("%s ", hpiece.to_s)
          end
        else
          printf("%s ", " ")
        end
      end
      printf("%s", print_step_info(index))
    end
    #board.to_a.each_with_index do |row, index| 
    #  printf("%s", row.join(" ") + " " * @board_width * 3 + print_step_info(index))
    #end

    board.count.upto(@step_record.count-1).each do |index|
      printf("%s", board.last.join(" ") + " " * board.count * 3 + print_step_info(index))
    end if @step_record.count > board.count
  end

  def print_step_info(index)
    if not @step_record.empty? and index <= @step_record.length - 1
      color = _get_color(index)
      "step#{index+1}: " + "#{HH[index]}".colorize(color) + "\n"
    end || "\n"
  end

  def _get_color(index)
    return COLORS.at(index % COLORS.count).to_sym
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

  def search(board = @board, level = 1)
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
      _max = scores.max
      if level == 1
        @best_step = steps.at(scores.index(_max))
      end

      return _max
    else
      _min = scores.min
      if level == 1
        @best_step = steps.at(scores.index(_min))
      end

      return _min
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

  def _is_orient_horizontal(one, two)
    one[0] == two[0] and one[1] == two[1] - 2
  end
  def _is_orient_leftdown(one, two)
    one[0] == two[0] - 1 and  one[0] + one[1] == two[0] + two[1]
  end
  def _is_orient_rightdown(one, two)
    one[0] == two[0] - 1 and  one[0] - one[1] == two[0] - two[1]
  end

  def _is_step_on_line(step, input)
    _is_continue = true
    _latest, _orient = [], -1
    step.sort_by! { |piece| piece[0] }
    #_orient: 0 - horization, 1 - left_down, 2 - right_down
    step.each_with_index do |piece, index|
      if index == 0
        _is_continue = true
      elsif index == 1
        if _is_orient_horizontal(_latest, piece)
          _orient = 0
        elsif _is_orient_leftdown(_latest, piece)
          _orient = 1
        elsif _is_orient_rightdown(_latest, piece)
          _orient = 2
        else
          _is_continue = false
        end
      elsif index > 1
        if _orient == 0 and not _is_orient_horizontal(_latest, piece)
            _is_continue = false
        elsif _orient == 1 and not _is_orient_leftdown(_latest, piece)
            _is_continue = false
        elsif _orient == 2 and not _is_orient_rightdown(_latest, piece)
            _is_continue = false
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

  def check_step_available(input)
    step   = []

    # marke sure all number
    _input = input.gsub(/\s/, "")
    if _input != /\d+/.match(_input).to_s
      warn "WARNING: [#{input}] is dirty, please input number"
      return step
    end

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

    unless (_is_all_human_map and _is_step_on_line(step, input))
      step.clear
    end
    return step
  end

  def player_input_step
    puts "请输入第#{@step_record.count + 1}步走法?" 
    STDOUT.flush 
    input = gets.chomp 
    if (step = check_step_available(input)).empty?
      player_input_step
    else
      if @input_record.count < @step_record.count
        @input_record.push(nil)
      end
      @input_record.push(input)
      puts "[#{input}] => #{step.to_s} => ok"
      return step
    end
  end
end

