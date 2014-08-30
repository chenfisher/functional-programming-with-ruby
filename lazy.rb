fib = Enumerator.new do |y|
  a = b = 1
  loop do
    y << a
    a, b = b, a + b
  end
end

fib.take(10)

# use 'select' to take the first 10 even fib numbers
fib.select { |x| x%2 == 0 }.take(10)
# only Cbuck Norris can run this (select runs infinitely)

# use lazy enumerator
fib.lazy.select { |x| x%2 == 0 }.first(10)

# implementation of lazy select on enumerator
# source: http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-core/19679
class Enumerator 
  def lazy_select(&block) 
    Enumerator.new do |yielder| 
      self.each do |val| 
	      yielder.yield(val) if block.call(val) 
      end 
    end 
  end 
end

fib.lazy_select { |x| x%2 == 0 }.first(10)
