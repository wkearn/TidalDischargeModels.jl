# TidalDischargeModels

[![Build Status](https://travis-ci.org/wkearn/TidalDischargeModels.jl.svg?branch=master)](https://travis-ci.org/wkearn/TidalDischargeModels.jl)

This is a Julia package to fit stage-discharge models in tidal environments as detailed in Kearney et al. 2017. Stage-discharge relationships in tidal channels. *Limnology and Oceanography: Methods* ([10.1002/lom3.10168](http://dx.doi.org/10.1002/lom3.10168)).

If you would like the version of the code used in that paper, checkout tag [v0.1.0](https://github.com/wkearn/TidalDischargeModels.jl/tree/v0.1.0).

If you have questions on how to use this code to fit stage-discharge models, the best way to get in touch is to [open an issue](https://github.com/wkearn/TidalDischargeModels.jl/issues/new) on this repository.

To install, first make sure you have a working installation of [Julia v0.5 on your system](http://julialang.org/downloads/).

# Installation

## Dependencies

TidalDischargeModels.jl depends on the currently unregistered [DischargeData.jl](https://github.com/wkearn/DischargeData.jl), which you will need to install manually.

From a Julia prompt:

```julia
julia> Pkg.clone("https://github.com/wkearn/DischargeData.jl")
```

If you want to run the tests, you'll also need to install [PIEMetData.jl](https://github.com/wkearn/PIEMetData.jl), [ADCPDataProcessing.jl](https://github.com/wkearn/ADCPDataProcessing.jl) and [TidalFluxExampleData.jl](https://github.com/wkearn/TidalFluxExampleData.jl)

```julia
julia> Pkg.clone("https://github.com/wkearn/PIEMetData.jl")
julia> Pkg.clone("https://github.com/wkearn/ADCPDataProcessing.jl")
julia> Pkg.clone("https://github.com/wkearn/TidalFluxExampleData.jl")
```

## Package installation

From the Julia prompt:

```julia
julia> Pkg.clone("https://github.com/wkearn/TidalDischargeModels")
```

I have included in the package a few modules which I use to manage acoustic Doppler current profiler data and get it into a form that lets me fit the models. You don't need to use my data management system to fit the models, however, so you can ignore all the code in the files `src/ADCPTypes.jl`, `src/ADCPDataStructures.jl`, and `src/MetData.jl`.

All you need to fit a discharge model is an instance of the `DischargeData` type and an instance of the `DischargeModel` type. The `DischargeData` basically holds stage and discharge data in two vectors. There are also vectors within the type to hold the measurement times, the cross-sectional area of the channel and the average velocity measured in the channel. You can construct a `DischargeData` instance by

```julia
julia> d = DischargeData(H,T,V,A,Q)
```

where `H`, `T`, `V`, `A`, and `Q` are the vectors of stage, measurement times (as Julia `DateTime`s), average velocity, area and discharge. If you don't have the time, velocity and area vectors, you can still fit a `DischargeModel`, so I've provided a convenience method which lets you construct a `DischargeData` using only the stage and discharge vectors:

```julia
julia> d = DischargeData(H,Q)
```

Once you have your training data in the form of a `DischargeData`, you need to construct a `DischargeModel`. There are currently seven different subtypes of `DischargeModel`:

- `BoonModel`
- `LTIModel`
- `RegularizedLTIModel`
- `VolterraModel`
- `RegularizedVolterraModel`
- `kMeansModel`
- `ThresholdModel`

Each model has a set of hyperparameters which you set in the instance you create before you fit. For example, the `RegularizedVolterraModel` has a parameter `M` for the number of lagged values of stage it looks at, a parameter `k` which determines the maximum polynomial order of the Volterra series expansion, and a parameter `λ` for the regularization strength. You'll also want a guess at the size of the training data set, `N`. It isn't critical if you don't know it at first, but creating a `RegularizedVolterraModel` will allocate enough memory to hold a training data set of size `N`. Now you can create your `DischargeModel`:

```julia
julia> model = RegularizedVolterraModel(M,N,k,λ)
```

To fit the model to a `DischargeData` we use the `estfun` helper function:

```julia
julia> volterra = estfun(model,d)
```

remembering our `DischargeData` `d` from before. Wait for the model to fit, and now `volterra` is a fit `RegularizedDischargeModel`. If you have a test data set wrapped in another `DischargeData`, say `d2`, you can estimate discharge for that test data set using `evalmodel`:

```julia
julia> Qt = evalmodel(volterra,d2)
```

There are lots of other tricks to getting this to work right, especially cross-validation, and I hope to add some documentation covering these methods soon. This code should work, but it is in a constant state of being cleaned up and expanded, so let me know by opening an issue on this repository if there is something you need or if something doesn't work the way you expect it to.

Some tests are included in the `test` directory, but these won't currently work unless you have my data on your system. I'll get an example data set up soon.
