module TidalDischargeModels

using Reexport

@reexport using Dates, StatsBase, Optim

export estfun, estfun!, evalfun, evalmodel, BoonModel, LTIModel, RegularizedLTIModel, VolterraModel, RegularizedVolterraModel, kMeansModel, ThresholdModel, nash_sutcliffe, flatness, ρ, c_p

include("utils.jl")
include("dischargemodels.jl")
include("statsutils.jl")
include("constants.jl")

end # module end
