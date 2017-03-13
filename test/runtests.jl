using TidalDischargeModels, TidalFluxExampleData
TDM = TidalDischargeModels

creek = Creek{:sweeney}()

include("deployments.jl")
include("adcpdata.jl")
include("crosssections.jl")
include("dischargedata.jl")

N1 = length(Q1.cp)
N2 = length(Q2.cp)

include("boon.jl")
include("lti.jl")
include("volterra.jl")
include("kmeans.jl")

include("summarystats.jl")

                                      
