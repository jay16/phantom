

def print_array(container)
  _container = container.map do |row|
    row.join(",")
  end.map do |row|
    "{" + row + "}"
  end.join("\n")
  puts _container
end
def copy_array(array)
  Marshal.load(Marshal.dump(array))
end

def partition(container, array, index)
  if index.zero?
    container[0][0] = array[index]
  else
    _container = copy_array(container)

    # 每行尾追加新元素
    _container.each_with_index do |row, outer_index|
      container[outer_index] = container[outer_index].push(array[index])
    end

    # 遍历每行每个元素前插入新元素成新行
    _container.each_with_index do |row, outer_index|
      row.each_with_index do |item, inner_index|
        _row = copy_array(row)
        # 该行第一个元素，直接插入头位置
        if inner_index.zero?
          _row.unshift(array[index])
        # 该行最后一个元素, 直接插入尾位置
        elsif inner_index == row.length - 1
          _row.push(array[index])
        # 其他情况，把原行分隔，插入新元素后再合并
        else
          _row.clear
          _row.push(row.first(inner_index+1))
          _row.push(array[index])
          _row.push(row.last(row.length-inner_index - 1))
        end
        container.push(_row.flatten)
      end
    end
  end

  if index == array.length - 1
    print_array(container)
  else
    partition(container, array, index + 1)
  end

end
container = Array.new(1) { Array.new(1, nil) }

partition(container, [1,4,8,9,12,23], 0)
