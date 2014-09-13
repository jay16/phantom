SYM = { 
  "+" => 0,
  "-" => 0,
  "*" => 1,
  "/" => 1,
  "(" => -1,
  ")" => -1
}

# 分解字符串为数组
# (10+1)/2 => (, 10, +, 1, ), /, 2
def split_str(str)
  arr = Array.new
  str.gsub(/\s/,"").each_char do |char|
    if arr.empty? # 数据为空,直接插入
      arr.push(char)
    elsif SYM.keys.include?(char) # 操作符直接插入
      arr.push(char)
    else # 走到这里即是数字
      if not SYM.keys.include?(arr.last) # 数据最后字符不会操作符则追加
        arr[-1] = arr.last + char 
      else # 否则直接插入
        arr.push(char)
      end
    end
  end
  return arr
end

# 转换为后缀表达式逻辑:
# 从左到右遍历中缀表达式的每个数字和符号，
#     若是数字就输出，即成为后缀表达式的一部分；
#     若是符号，就判断当前符号与栈顶符号的优先级，
#         如果是右括号或者是优先级低于栈顶符号（乘除优先加减），则栈顶元素依次出栈并输出（全部输出，如
#         果是右括号，则到左括号输出为止），当前符号进栈，如此进行直到最终输出后缀表达式。
def convert_post_cal(arr)
  stack = Array.new
  post_cal = Array.new
  arr.each do |char|
    if SYM.keys.include?(char)
      if stack.empty?
        stack.push(char)
      else
        if char == ")" # 匹配括号
          _stack = stack.reverse
          index = _stack.index("(") # 最近一个(之前的运算符都出栈
          post_cal.push(_stack.first(index)).flatten # flatten: [1,[2,3],4] => [1, 2, 3, 4]
          stack = _stack.last(stack.length - index - 1).reverse # 按原序返回栈
        else # 优先级高可出栈,否则出栈
          cal_sym = SYM.find_all { |k, v| v >= 0 }.map { |k, v| k }
          if cal_sym.include?(char) and # 操作符
            cal_sym.include?(stack.last) and 
            SYM[stack.last] > SYM[char]

            if stack.include?("(") # 有(则出栈至(
              _stack = stack.reverse
              index = _stack.index("(")
              post_cal.push(_stack.first(index)).flatten!
              stack = _stack.last(stack.length - index)
            else # 无(则全部出栈
              post_cal.push(stack.reverse).flatten!
              stack.clear
            end
          end

          stack.push(char)
        end
      end
    else
      post_cal.push(char)
    end
   #puts "post_cal:#{post_cal.to_s}"
   #puts "stack:#{stack.to_s}"
  end
  return post_cal.push(stack.reverse).flatten!
end


# 后缀运算
def post_cal(arr)
  cal_sym = SYM.find_all { |k, v| v >= 0 }.map { |k, v| k }
  stack = Array.new
  arr.each do |char|
    if cal_sym.include?(char)
      two = stack.pop
      one = stack.pop
      cal = eval(one + char + two).to_s
      stack.push(cal)
    else
      stack.push(char)
    end
    #puts "stack:#{stack.to_s}"
  end
  return stack
end

def caculaute(str)
  puts str.gsub!(/\s/,"")
  arr = split_str(str)
  puts arr.to_s
  arr = convert_post_cal(arr)
  puts arr.to_s
  puts post_cal(arr)
end

str = "1+2*(3+4)/7+8*2"
str= "1+2*(4+4)/4+8*2"
caculaute(str)

str = "(3+9)*4/6+10-4*2"
caculaute(str)

str = "((1+2)*3+4*5)*6+7*8"
caculaute(str)

str = "(1+2)*(3+4)/7+3*((8-2)+2)"
caculaute(str)

str = "(((3+2)*(1+2)+5)*2+5)*2"
caculaute(str)

str = "2*(5+2*(5+(2+1)*(2+3)))"
caculaute(str)

