println("Fitting kmeans model")
n,k,λ = 150,4,0.0
M4 = kMeansModel(n,N1,k,λ)
kmm = estfun(M4,Q1)
