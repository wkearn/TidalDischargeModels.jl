# TidalDischargeModels

[![CI](https://github.com/wkearn/TidalDischargeModels.jl/actions/workflows/ci.yaml/badge.svg)](https://github.com/wkearn/TidalDischargeModels.jl/actions/workflows/ci.yaml)

This is a Julia package to fit stage-discharge models in tidal environments as detailed in Kearney et al. 2017. Stage-discharge relationships in tidal channels. *Limnology and Oceanography: Methods* ([10.1002/lom3.10168](http://dx.doi.org/10.1002/lom3.10168)).

If you would like the version of the code used in that paper, checkout tag [v0.1.0](https://github.com/wkearn/TidalDischargeModels.jl/tree/v0.1.0).

If you have questions on how to use this code to fit stage-discharge models, the best way to get in touch is to [open an issue](https://github.com/wkearn/TidalDischargeModels.jl/issues/new) on this repository.

To install, first make sure you have a working installation of [Julia v0.5 on your system](http://julialang.org/downloads/).

# Installation

From the Julia prompt, type `]` to enter the package prompt, then add
the TidalDischargeModels.jl package from its address on GitHub:

```julia
pkg> add https://github.com/wkearn/TidalDischargeModels
```

This should install the necessary dependencies and
TidalDischargeModels. Once the installation completes, type a
backspace to get back to the Julia prompt and import the package

```julia
julia> using TidalDischargeModels
```

# Usage

The basic interface for fitting a model is provided through the `fit` function:

```julia
julia> m = fit(KNNModel, h, q, M = 10, k = 25)
```

and a fitted model can be applied to a new stage time series with `predict`:

```julia
julia> predict(m, h_test)
```

The first argument to `fit` is the name of a model. At the moment only
a k-nearest neighbors model, `KNNModel`, and a k-means model
`kMeansModel` are supported through this interface. The second and
third options are vectors containing stage and discharge data,
respectively. You should obtain these from your data in whatever way
makes the most sense. If you have data in a CSV file with columns for
"Stage" and "Discharge", for example, you can use

```julia
julia> using CSV, DataFrames
julia> df = CSV.read("data.csv")
julia m = fit(KNNModel, df[!, :Stage], df[!, :Discharge], M = 10, k = 25)
```

The `test/` directory contains some example data from the USGS and the
`test/data.jl` script shows how these can be loaded into julia.

The model hyperparameters are set with keyword arguments. All models
take an argument `M`, which stands for the number of previous timesteps
of the stage that are considered when modeling the discharge.

`kMeansModel` and `KNNModel` both take a parameter `k`, which stands
for the number of clusters in the `kMeansModel` and the number of
neighbors to consider in the `KNNModel`.

The `kMeansModel` also takes a parameter `λ` (you can type this at the
Julia prompt using LaTeX completion: type "\lambda" and then hit
TAB). This is a regularization parameter that makes the fitted model
less sensitive to the data. If you run into a `SingularException` when
fitting the `kMeansModel`, you should increase `λ`.

The model fitting will still work if there are missing values in the
stage or discharge data. Missing discharge data points are discarded
during fitting. A window of size `M` following a missing stage data
point is discarded because those points do not have complete stage
trajectories.

Prediction will also work with missing stage data, but time steps
whose prediction depends on a missing stage data point will be labeled
as missing.

If you would like to fit a model to multiple time series, you can pass
the data as a vector of vectors:

```julia
julia> m = fit(KNNModel, [h1, h2, h3], [q1, q2, q3], M=10, k=25)
```

Do not concatenate the time series into a single vector and fit the
model to that vector. If you do this, the lagged stage values used at
the beginning of the second time series will come from the first time
series, which is almost certainly not what you want. Pass a vector of
vectors to the `fit` function instead, and it will handle the
processing of these data correctly.




