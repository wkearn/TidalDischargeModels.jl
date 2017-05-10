using TidalDischargeModels
TDM = TidalDischargeModels

TDM.Databases.setADCPdatadir!("/home/wkearn/Documents/graduate/projects/plum_island/TIDE/data/discharge/database")
TDM.Databases.setmetdatadir!("/home/wkearn/Documents/graduate/projects/plum_island/TIDE/data/met")

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

                                      
