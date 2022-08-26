using Enzyme

Enzyme.API.printall!(true)
# @show Enzyme.autodiff(Enzyme.EnzymeRules.f, Active(2.0))


@show Enzyme.fwddiff(Enzyme.EnzymeRules.f, BatchDuplicated(2.0, (1.0, 3.0)))

# @show Enzyme.fwddiff(Enzyme.EnzymeRules.f, Duplicated(2.0, 1.0))
# @show Enzyme.fwddiff(x->Enzyme.EnzymeRules.f(x)^2, Duplicated(2.0, 1.0))

# vec = [2.0]
# dvec = [1.0]
# 
# Enzyme.fwddiff(Enzyme.EnzymeRules.fip, Duplicated(vec, dvec))
# 
# @show vec, dvec

