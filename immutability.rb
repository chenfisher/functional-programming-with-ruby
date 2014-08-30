class MutableCriteria
	def initialize(query)
		@query = query
	end

	def where(query)
		@query.merge! query
	end
end

class ImmutableCriteria
	def initialize(query)
		@query = query.dup.freeze
	end

	def where(query)
		ImmutableCriteria.new @query.merge(query)
	end
end

# ImmutableCriteria can be chained by definition
