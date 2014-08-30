# the sum of the first 10 numbers dividable by 3

# imperative - focuses on 'how'
count = 0; sum = 0; i = 0
while count < 10
	if i % 3 == 0
		sum += i
		count += 1
	end

	i += 1
end
puts sum

# functional (using enumerators) - focuses on 'what'
(0..10000).select { |x| x%3 == 0 }.take(10).reduce(:+)