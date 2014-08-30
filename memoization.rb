def fib(n)
	n <= 1 ? n : fib(n - 1) + fib(n - 2)
end


require 'memoist'
extend Memoist

def fib_with_memo(n)
	n <= 1 ? n : fib_with_memo(n - 1) + fib_with_memo(n - 2)
end
memoize :fib_with_memo


def time
	start = Time.now
	result = yield
	puts "#{Time.now - start} seconds"
	result
end