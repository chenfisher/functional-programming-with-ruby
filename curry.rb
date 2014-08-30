# currying
calc = proc { |op, a, b| a.send(op, b) }

add = calc.curry.(:+)
sub = calc.curry.(:-)
mul = calc.curry.(:*)
div = calc.curry.(:/)

inc = add.curry.(1)

# partial (a private case of currying)
# multiple arguments can be applied
increment = calc.curry.(:+, 1)
double = calc.curry.(:*, 2) # can also be mul.curry.(2)
triple = calc.curry.(:*, 3) # can also be mul.curry.(3)