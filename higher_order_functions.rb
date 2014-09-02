names = ["abraham", "isaac", "jacob"]

# procs
capitalize = proc { |x| x.capitalize }
reverse = proc { |x| x.reverse }

# usage
names.map &capitalize
names.map &reverse
names.map(&reverse).map(&capitalize) # iterates twice over the array!

# obviously we do not really need capitalize and reverse procs since
# we can do this with the String's capitalize and reverse methods:
names.map(&:capitalize).map(&:reverse)
# but we define the procs for the purpose of demonstration

# compose a function from two functions
def compose(f1, f2)
	proc { |*args| f1.call(f2.call(*args)) }
end

# usage
reverse_and_capitalize = compose capitalize, reverse
names.map &reverse_and_capitalize # iterates only once over the array

# a cool hack
class Proc
	def self.compose(f1, f2)
		proc { |*args| f1.call(f2.call(*args)) }
	end

  def &(f)
    Proc.compose(self, f)
  end
end

# usage
r_and_c = reverse & capitalize
r_and_c_and_greet = reverse & capitalize & proc { |x| "Hello #{x}"}
names.map &r_and_c_and_greet