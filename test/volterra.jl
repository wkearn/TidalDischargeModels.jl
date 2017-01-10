println("Fitting Volterra series model")
n,k,λ= 19,5,logspace(0,6,20)[15]
M3 = RegularizedVolterraModel(n,N1,k,λ)

volterra = estfun(M3,Q1)
