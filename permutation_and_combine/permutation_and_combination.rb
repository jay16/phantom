#encoding: utf-8
# subject: 
#     permutation and combination - 排列与组合
# description: 
#     when the length of array waiting to deal is N,
#     then there will N! kind permutation
#     eg:
#     [1,2,3] => 3! => 3*2*1 => 6 kind permutation
#
# soluation logic:
#     illustration:
#         i  : insert a new element
#         ia : insert after tail.
#         ib : insert before every element. (traversal)
#     process steps:
#     [] => 1(i) => [1] => 2(ia) => [1,2] => 3(ia)   => [1,2,3]
#                                         => 3(ib.1) => [3,1,2]
#                                         => 3(ib.2) => [1,3,2]
#                       => 2(ib) => [2,1] => 3(ia)   => [2,1,3]
#                                         => 3(ib.2) => [3,2,1]
#                                         => 3(ib.1) => [2,3,1]

def print_array(container)
  puts "all has [#{container.count}] kind permutations!"
  _container = container.map do |row|
    "{" + row.join(",") + "}"
  end.join("\n")
  puts _container
end
def _copy_array(array)
  Marshal.load(Marshal.dump(array))
end

def permutation(container, array, index = 0)
  if index.zero?
    container[0][0] = array[index]
  else
    _container = _copy_array(container)

    # 每行尾追加新元素
    _container.each_with_index do |row, outer_index|
      container[outer_index] = container[outer_index].push(array[index])
    end

    # 遍历每行每个元素前插入新元素成新行
    _container.each_with_index do |row, outer_index|
      row.each_with_index do |item, inner_index|
        _row = _copy_array(row)
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
    permutation(container, array, index + 1)
  end

end

def _prompt_duration_time(prompt = "duration:", &block)
  _time_begin= Time.now.to_f
  yield
  _time_duration= ((Time.now.to_f - _time_begin)*1000).to_i
  printf("%s [%sms]\n", prompt, _time_duration)
end

_prompt_duration_time "执行时间:" do
  container = Array.new(1) { Array.new(1, nil) }
  array = [1,2,3]
  permutation(container, array)
end
