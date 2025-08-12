# Fit the k means model
m = kMeansModel(3, 0, 27, 0.0)
m = estfun(m, data[!,:Stage], data[!,:Discharge])

# Evaluate the model on the test data
Qpp = evalmodel(m, test_data[!,:Stage], test_data[!,:Discharge])
evalfun(m, test_data[!,:Stage], test_data[!,:Discharge])
