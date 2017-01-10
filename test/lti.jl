println("Fitting linear, time-invariant model")
n,λ = 150,2.48
M2 = RegularizedLTIModel(n,N1,λ)

lti = estfun(M2,Q1)
