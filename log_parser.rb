# A simple, yet powerful log parser
#
# Dynamically supports any log format; just define needed format:
#   parser = Parser.new filename do
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
# It implements Enumerable, so you have everything Enumerator offers:
# (each, select, inject, etc..)
#   parser.each { |h| puts h }
#
# AND - it supports a lazy enumerator! so you can do crazy stuff with 
# a big size log file:
# 	e = parser.lazy.select { |x| x[:datetime] > 3.days.ago }.select { |x| x[:referer] = "google.com" }
# 	e.next # => will return the next matching log line
# 	e.next # => will return the next matching log line
# 	e.next ...
class Parser
	include Enumerable

	attr_reader :fields

	def initialize(filename, &block)
		@fields = []
		@file = File.open filename
		self.instance_eval(&block) if block_given?
	end

	def field(name, &block)
		@fields << [name, (block_given? ? block : proc { |value| value })]
	end

	def each
		@file.each do |line|
			yield parse_line(line)
		end
	end

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


parser = Parser.new "log.log", &patriarchs

# lazy parse of log
parser.lazy.select {|x| x[:gender] == "male"}.select { |x| x[:age].to_i > 150 }.to_a
parser.lazy.select { |x| x[:gender] == "male" }.select { |x| x[:spouse] =~ /leah/ }.to_a
a = parser.lazy.select { |x| x[:gender] == "female" }.select { |x| x[:spouse] =~ /jacob/ }
a.next

# eager parse of log
parser.each do |h|
	puts h
end