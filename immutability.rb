class MutableCriteria
	def initialize(query)
		@query = query
	end

	def where(query)
		@query = "#{@query} and #{query}"
	end
end

class ImmutableCriteria
	def initialize(query)
		@query = query.dup.freeze
	end

	def where(query)
		ImmutableCriteria.new "#{@query} and #{query}"
	end
end