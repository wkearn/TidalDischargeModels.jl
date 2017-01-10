module ADCPDataStructures

using TidalDischargeModels.ADCPTypes, DataFrames

export ADCPData, CalibrationData, CrossSectionData, load_data,
deployment,
pressures,
velocities,
times,
analog

type ADCPData
    dep::Deployment
    p::Vector{Float64}
    v::Array{Float64,3}
    t::Vector{DateTime}
    a1::Nullable{Vector{Float64}}
    a2::Nullable{Vector{Float64}}    
end

function Base.show(io::IO,data::ADCPData)
    println(io,data.dep)
    print(io,"ADCP data loaded")
end

deployment(data::ADCPData) = data.dep
pressures(data::ADCPData) = data.p
velocities(data::ADCPData) = data.v
times(data::ADCPData) = data.t
analog(data::ADCPData) = (get(data.a1,[]),get(data.a2,[]))

type CalibrationData
    cal::Calibration
    t::Vector{DateTime}
    Q::Vector{Float64}
    adcp::Nullable{ADCPData}
end

function Base.show(io::IO,caldata::CalibrationData)
    println(io,caldata.cal)
    if isnull(caldata.adcp)
        println(io,"ADCP data not loaded")
    else
        println(io,"ADCP data loaded")
    end
    print(io,"Calibration data loaded")
end

type CrossSectionData
    cs::CrossSection
    x::Vector{Float64}
    z::Vector{Float64}
end

function Base.show(io::IO,csdata::CrossSectionData)
    println(io,csdata.cs)
    print(io,"Cross section data loaded")
end

function load_data(dep::Deployment)
    data_dir = joinpath(_DATABASE_DIR,
                        string(dep.location),
                        "deployments",
                        hex(hash(dep)))
    p = vec(readdlm(joinpath(data_dir,"pressure.csv")))
    v = vec(readdlm(joinpath(data_dir,"velocities.csv")))
    v = reshape_velocities(v,dep)
    t = vec(readdlm(joinpath(data_dir,"times.csv")))
    t = DateTime.(t)
    if dep.adcp.hasAnalog
        a1 = vec(readdlm(joinpath(data_dir,"analog1.csv")))
        a2 = vec(readdlm(joinpath(data_dir,"analog2.csv")))
    else
        a1 = Nullable{Vector{Float64}}()
        a2 = Nullable{Vector{Float64}}()
    end
    ADCPData(dep,p,v,t,a1,a2)
end

function load_data(cal::Calibration,load_dep=false)
    data_dir = joinpath(_DATABASE_DIR,
                        string(cal.deployment.location),
                        "calibrations",
                        hex(hash(cal)))
    D = readtable(joinpath(data_dir,"discharge_calibrations.csv"))
    if load_dep
        dep_data = load_data(cal.deployment)
    else
        dep_data = Nullable{ADCPData}()
    end
    CalibrationData(cal,DateTime(D[:DateTime]),D[:SP_Q],dep_data)
end

function reshape_velocities(v::Vector{Float64},dep::Deployment)
    n = dep.adcp.nCells
    m = div(length(v),n*3)
    reshape(v,(n,m,3)...)
end

function load_data(cs::CrossSection)
    data_path = joinpath(_DATABASE_DIR,
                        string(cs.location),
                        cs.file)
    D = readtable(data_path)
    CrossSectionData(cs,D[1:end-1,:Distance],D[1:end-1,:Elevation])
end

end # module end
