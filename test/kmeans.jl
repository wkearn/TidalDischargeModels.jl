m = fit(kMeansModel, data[!,:Stage], data[!,:Discharge], M=3, k=27)
Qpp = predict(m, test_data[!, :Stage])

@test length(Qpp) == length(test_data[!, :Stage])
@test count(ismissing, Qpp) == 2
