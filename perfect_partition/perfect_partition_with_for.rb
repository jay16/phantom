MAX = 8 if not defined?(MAX)

def print_container(container)
  result = container.collect do |row|
    row.map { |data| "{" + data + "}" }.join(",")
  end.join("\n")
  puts result
end

def copy_container(container)
  Marshal.load(Marshal.dump(container))
end

def perfect_partition_with_for
  container = Array.new(1) { Array.new(1, nil) }
  for level in (1..MAX)
    if level == 1
      container[0][0] = '1'
    else
      # 复制容器
      _container = copy_container(container)

      # 每行追加level
      _container.each_with_index do |row, index|
        if container[index].is_a?(Array)
          container[index].push(level.to_s) 
        end
      end

      # 遍历每行每个数据添加新数据
      _container.each_with_index do |row, outer_index|
        row.each_with_index do |data, inner_index|
          _row = copy_container(row)
          _row[inner_index] = _row[inner_index] + ',' + level.to_s
          container.push(_row)
        end
      end
    end
  end
  #print_container(container)
end

#perfect_partition_with_for

