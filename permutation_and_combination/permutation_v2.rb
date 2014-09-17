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

def _copy_array(array)
  Marshal.load(Marshal.dump(array))
end

def permutation(array, row = [], level = 0)
  if level >= array.length
    row.pop
    puts row.to_s
    return # stop recursion
  end

  if level == 0
    row = [array[0], "$"]
    permutation(array, row, level + 1)
  else
    _row = _copy_array(row)
    # 遍历每行每个元素前插入新元素成新行
    (0..row.length-1).each do |index|
      row.insert(index, array[level])

      permutation(array, row, level + 1)
      row = _copy_array(_row)
    end
  end
end

 permutation([1,2,3], [], 0)
