module TidalDischargeModels

using Reexport

@reexport using Base.Dates, StatsBase, Optim, TidalFluxQuantities

export estfun, estfun!, evalfun, evalmodel, BoonModel, LTIModel, RegularizedLTIModel, VolterraModel, RegularizedVolterraModel, kMeansModel, ThresholdModel, nash_sutcliffe, flatness, ρ, c_p

include("dischargemodels.jl")
include("utils.jl")
include("constants.jl")

end # module end
