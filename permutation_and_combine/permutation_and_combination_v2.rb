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
#     old process steps:
#     [] => 1(i) => [1] => 2(ia) => [1,2] => 3(ia)   => [1,2,3]
#                                         => 3(ib.1) => [3,1,2]
#                                         => 3(ib.2) => [1,3,2]
#                       => 2(ib) => [2,1] => 3(ia)   => [2,1,3]
#                                         => 3(ib.2) => [3,2,1]
#                                         => 3(ib.1) => [2,3,1]
#     new process steps:
#     [] => 1(i) => [1] => nil(i) => [1,nil] => 2(ib.1)   => [2,1,nil] => 3(ib.2)   => [3,2,1,nil]
#                                                                      => 3(ib.1)   => [2,3,1,nil]
#                                                                      => 3(ib.nil) => [2,1,3,nil]
#                                            => 2(ib.nil) => [1,2,nil] => 3(ib.1)   => [3,1,2,nil]
#                                                                      => 3(ib.2)   => [1,3,2,nil]
#                                                                      => 3(ib.nil) => [1,2,3,nil]

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

def permutation(array, row = [], index = 0)
  _row = _copy_array(row)
  if index.zero?
    _row = [array[index], nil]
    permutation(array, _row, index + 1)
  else
    # 遍历每行每个元素前插入新元素成新行
    row.each_with_index do |item, _index|
      puts "_index: #{_index}"
      exit if _index >= array.length * 2
      # 该行第一个元素，直接插入头位置
      if _index.zero?
        _row.unshift(array[index])
      # 该行最后一个元素, 直接插入尾位置
      elsif _index == row.length- 1
        _row.push(array[index])
      # 其他情况，把原行分隔，插入新元素后再合并
      else
        _row.insert(_index, array[index])
      end
      if index == array.length - 1
        puts _row.to_s
      else
        permutation(array, _row, index + 1)
      end
    end
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
  permutation(array)
end
