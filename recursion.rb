def factorial(n)
	n < 2 ? 1 : n * factorial(n-1)
end

def tail_factorial(n, r = 1)
	n < 2 ? r : tail_factorial(n-1, n*r)
end

factorial 10000 # stack level too deep
tail_factorial 10000 # stack level too deep

# enable tail call optimization
RubyVM::InstructionSequence.compile_option = {
  :tailcall_optimization => true,
  :trace_instruction => false
}

# reevaluate tail_factorial method to compile it with the new options
tail_factorial 10000 # now ok
factorial 10000 # still stack level too deep