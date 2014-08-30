class Parser

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

	def lazy_parse(filename)
		self.close

		@file = File.open filename
		Enumerator.new do |y|
			@file.each do |line|
				y << parse_line(line)
			end
		end.lazy
	end

	def close
		@file && @file.close
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
default = proc do
	field :name
	field :age do |value|
		value == "-" ? -1 : value
	end
	field :gender
	field :spouse
end


parser = Parser.new &default

# lazy parse of log
e = parser.lazy_parse "/Users/chen/projects/talks/fp/log.log"
e.select {|x| x[:gender] == "male"}.select { |x| x[:age] > 150 }.to_a
e.select { |x| x[:gender] == "male" }.select { |x| x[:spouse] =~ /leah/ }.to_a
e.select { |x| x[:gender] == "female" }.select { |x| x[:spouse] =~ /jacob/ }.to_a

# eager parse of log
parser.parse("log.log") do |h|
	puts h
end