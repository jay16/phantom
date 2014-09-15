    board.to_a.each_with_index do |row, index| 
      row.each do |hpiece|
        if hpiece.is_a?(Fixnum)
          piece = @human_map[hpiece.to_s]
          _index = -1
          @step_record.each_with_index do |_step, o_index|
            _step.each_with_index do |_piece, i_index|
              if _piece == piece
                _index = o_index
                break
              end
            end
            break if _index >= 0
          end
          color = get_color(_index)
          printf("%s", hpiece.to_s.colorize(color))
        else
          printf("%s", hpiece)
        end
      end
      printf("%s", print_step_info(index))

    end
