module TidalDischargeModels

using Reexport

@reexport using Base.Dates, StatsBase, Optim, DischargeData, ADCPDataProcessing

include("MetData.jl") # Types to hold meteorological data for atmospheric correction
include("DischargeDataStructures.jl") # Process ADCP data into discharges
include("Calibrations.jl") # Calibrate ADCP discharges to true discharges

@reexport using TidalDischargeModels.MetData,
TidalDischargeModels.DischargeDataStructures,
TidalDischargeModels.Calibrations

export estfun, estfun!, evalfun, evalmodel, BoonModel, LTIModel, RegularizedLTIModel, VolterraModel, RegularizedVolterraModel, kMeansModel, ThresholdModel, nash_sutcliffe, flatness, ρ, c_p

include("dischargemodels.jl")
include("utils.jl")
include("constants.jl")

end # module end
