m = KNNModel(4, 10)
m = fit(m, data[!,:Stage], data[!,:Discharge])
Qpp = predict(m, test_data[!, :Stage])

@test length(Qpp) == length(test_data[!, :Stage])
@test count(ismissing, Qpp) == 3

