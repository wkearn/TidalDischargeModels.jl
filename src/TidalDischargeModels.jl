module TidalDischargeModels

using Reexport

@reexport using Base.Dates, StatsBase, Optim

include("Databases.jl")

include("ADCPTypes.jl") # A variety of types for ADCP deployments
include("ADCPDataStructures.jl") # Types to hold loaded ADCP data
include("MetData.jl") # Types to hold meteorological data for atmospheric correction
include("DischargeDataStructures.jl") # Process ADCP data into discharges
include("Calibrations.jl") # Calibrate ADCP discharges to true discharges

@reexport using TidalDischargeModels.ADCPTypes,
TidalDischargeModels.ADCPDataStructures,
TidalDischargeModels.MetData,
TidalDischargeModels.DischargeDataStructures,
TidalDischargeModels.Calibrations

export estfun, estfun!, evalfun, evalmodel, BoonModel, LTIModel, RegularizedLTIModel, VolterraModel, RegularizedVolterraModel, kMeansModel, ThresholdModel, nash_sutcliffe, flatness

include("dischargemodels.jl")
include("utils.jl")


end # module end
