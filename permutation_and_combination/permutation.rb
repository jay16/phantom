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

class Permutation
  attr_accessor :container, :array
  def initialize(container = nil, array = [])
    @container = container || Array.new(1) { Array.new(1, nil) }
    @array     = array
  end

  def _copy_array(array)
    Marshal.load(Marshal.dump(array))
  end

  def print_array(container)
    puts "all has [#{container.count}] kind permutations!"
    puts container.map { |row| "{" + row.join(",") + "}" }.join("\n")
  end

  def permutation(container = @container, array = @array , index = 0)
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
          _row.insert(inner_index, array[index])
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

    block_given? ? yield : permutation

    _time_duration= ((Time.now.to_f - _time_begin)*1000).to_i
    printf("%s [%sms]\n", prompt, _time_duration)
  end
end

#container = Array.new(1) { Array.new(1, nil) }
#array = [1,2,3]
#
#permutation = Permutation.new(container, array)
#permutation._prompt_duration_time "执行时间:"
