"""
A module to handle calibration of ADCP discharge to true discharge
"""
module Calibrations

export Calibration, CalibrationData, parse_cals

using TidalDischargeModels.ADCPTypes, TidalDischargeModels.ADCPDataStructures, TidalDischargeModels.DischargeDataStructures, JSON, DataFrames

#####################################################
# Definition of Calibration type and loading
# calibration definitions from METADATA.json

type Calibration
    deployment::Deployment
    cs::CrossSection
    startDate::DateTime
    endDate::DateTime
end

function Base.show(io::IO,cal::Calibration)
    println(io,"Calibration")
    println(io,"------------")
    println(io,"Start time: ",cal.startDate)
    println(io,"End time: ",cal.endDate)
    print(io,cal.deployment)    
end

function parse_cals{C}(creek::Creek{C})
    cs = parse_cs(creek)
    deps = parse_deps(creek)
    hs = hash.(deps)
    d = JSON.parsefile(joinpath(_DATABASE_DIR,string(C),"METADATA.json"))
    cals = Calibration[]
    for cal in d["calibrations"]
        dep = cal["deployment"]
        sD = DateTime(cal["startDate"])
        eD = DateTime(cal["endDate"])
        dep_match = findfirst(hex.(hs,16),dep)
        push!(cals,Calibration(deps[dep_match],cs,sD,eD))
    end
    cals
end

function Base.hash(x::Calibration,h::UInt)
    h = hash(x.deployment,h)
    h = hash(x.startDate,h)
    h = hash(x.endDate,h)
end

Base.:(==)(c1::Calibration,c2::Calibration) = hash(c1)==hash(c2)

#####################################################
# Loading calibration data

type CalibrationData
    cal::Calibration
    t::Vector{DateTime}
    Q::Vector{Float64}
    dd::DischargeData
end

function Base.show(io::IO,caldata::CalibrationData)
    println(io,caldata.cal)
    print(io,"Calibration data loaded")
end

function ADCPDataStructures.load_data(cal::Calibration)
    # Load ADCP data and convert to discharges
    ad = load_data(cal.deployment)
    cs = load_data(cal.cs)
    dd = DischargeData(ad,cs)
    
    data_dir = joinpath(_DATABASE_DIR,
                        string(cal.deployment.location),
                        "calibrations",
                        hex(hash(cal),16))
    D = readtable(joinpath(data_dir,"discharge_calibrations.csv"))
    CalibrationData(cal,DateTime(D[:DateTime]),D[:SP_Q],dd)
end

end
