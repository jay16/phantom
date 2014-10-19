#encoding: utf-8
def caculate_blank_points(board)
  @blank_points, blank_points = [], []
  for i in (0..BD-1)
    for j in (0..BW-1)
      next if board[i][j] > 0
      if not @blank_points.include?([i,j])
        _blank_points = copy_array(@blank_points)
        _caculate_blank_points(board, [i,j])
        _new_points = @blank_points - _blank_points
        blank_points.push(_new_points) if not _new_points.empty?
      end
    end
  end
  return blank_points
end

def _caculate_blank_points(_board, pos)
  board = copy_array(_board)
  x, y = pos
  @blank_points.push(pos) if not @blank_points.include?(pos)
  if x-1 >= 0 and board[x-1][y] == 0
    pos = [x-1, y]
    board[x-1][y] = 1
    @blank_points.push(pos) if not @blank_points.include?(pos)
    _caculate_blank_points(board, pos)
  end
  if x+1 <= BD-1 and board[x+1][y] == 0
    pos = [x+1, y]
    board[x+1][y] = 1
    @blank_points.push(pos) if not @blank_points.include?(pos)
    _caculate_blank_points(board, pos)
  end
  if y-1 >=0 and board[x][y-1] == 0
    pos = [x, y-1]
    board[x][y-1] = 1
    @blank_points.push(pos) if not @blank_points.include?(pos)
    _caculate_blank_points(board, pos)
  end
  if y+1 <= BW-1 and board[x][y+1] == 0
    pos = [x, y+1]
    board[x][y+1] = 1
    @blank_points.push(pos) if not @blank_points.include?(pos)
    _caculate_blank_points(board, pos)
  end
end

