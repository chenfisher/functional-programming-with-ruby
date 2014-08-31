# A simple, yet powerful log parser
#
# Dynamically supports any log format; just define needed format:
#   Parser.new do
#     field :datetime
#     field :url
#     field :referer do |value|
#       value == "-" ? "N/A" : value
#     end
#   end
#
# Parses each line to a structured hash; following the structure above:
# {datetime: "...", url: "...", referer: "..."}
#
# Once you have your parser, you can:
# Eager parse it:
# 	parser.parse(filename) do |hash|
#   	puts hash
# 	end
#
# It implements Enumerable, so you have everything Enumerator offers:
# (each, select, inject, etc..)
#
# AND - it supports a lazy enumerator! so you can do crazy stuff with 
# a big size log file:
# 	e = parser.lazy_parse(filename)
# 	a = e.lazy.select { |x| x[:datetime] > 3.days.ago }.select { |x| x[:referer] = "google.com" }
# 	a.next # => will return the next matching log line
# 	a.next # => will return the next matching log line
# 	a.next ...
class Parser
	include Enumerable

	attr_reader :fields

	def initialize(&block)
		@fields = []
		self.instance_eval(&block) if block_given?
	end

	def field(name, &block)
		@fields << [name, (block_given? ? block : proc { |value| value })]
	end

	def parse(filename)
		raise ArgumentError, "Please provide a block" unless block_given?

		File.open filename do |f|
			f.each do |line|
				yield parse_line(line)
			end
		end
	end

	def each(filename)
		self.close

		@file = File.open filename
		Enumerator.new do |y|
			@file.each do |line|
				y << parse_line(line)
			end
		end
	end
	alias :lazy_parse :each

	def close
		@file && @file.close || @file = nil
	end

	private

		def parse_line(line)
			line.split(" ").zip(@fields).inject({}) do |h, f|
				value = f.first
				key = f.last.first
				p = f.last.last

				h[key] = p.call(value)
				h
			end
		end
end

# usage
patriarchs = proc do
	field :name
	field :age do |value|
		value == "-" ? -1 : value
	end
	field :gender
	field :spouse
end


parser = Parser.new &patriarchs

# lazy parse of log
e = parser.lazy_parse "log.log"
e.lazy.select {|x| x[:gender] == "male"}.select { |x| x[:age].to_i > 150 }.to_a
e.lazy.select { |x| x[:gender] == "male" }.select { |x| x[:spouse] =~ /leah/ }.to_a
a = e.lazy.select { |x| x[:gender] == "female" }.select { |x| x[:spouse] =~ /jacob/ }
a.next

# eager parse of log
parser.parse("log.log") do |h|
	puts h
end