m = KNNModel(4, 10)
m = fit(m, data[!,:Stage], data[!,:Discharge])
Qpp = predict(m, test_data[!, :Stage])

