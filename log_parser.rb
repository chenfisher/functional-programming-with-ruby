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
e = parser.each "log.log"
e.lazy.select {|x| x[:gender] == "male"}.select { |x| x[:age].to_i > 150 }.to_a
e.lazy.select { |x| x[:gender] == "male" }.select { |x| x[:spouse] =~ /leah/ }.to_a
a = e.lazy.select { |x| x[:gender] == "female" }.select { |x| x[:spouse] =~ /jacob/ }
a.next

# eager parse of log
parser.parse("log.log") do |h|
	puts h
end