m = fit(KNNModel, data[!,:Stage], data[!,:Discharge], M=4, k=10)
Qpp = predict(m, test_data[!, :Stage])

@test length(Qpp) == length(test_data[!, :Stage])
@test count(ismissing, Qpp) == 3

