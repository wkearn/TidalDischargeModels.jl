module ADCPDataStructures

using TidalDischargeModels.ADCPTypes, DataFrames

export ADCPData, CrossSectionData, load_data,
deployment,
pressures,
velocities,
times,
temperatures,
pitches,
rolls,
headings,
analog

type ADCPData
    dep::Deployment
    p::Vector{Float64}
    v::Array{Float64,3}
    t::Vector{DateTime}
    temp::Vector{Float64}
    pitch::Vector{Float64}
    roll::Vector{Float64}
    heading::Vector{Float64}
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
temperatures(data::ADCPData) = data.temp
pitches(data::ADCPData) = data.pitch
rolls(data::ADCPData) = data.roll
headings(data::ADCPData) = data.heading
analog(data::ADCPData) = (get(data.a1,[]),get(data.a2,[]))

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
                        hex(hash(dep),16))
    p = vec(readdlm(joinpath(data_dir,"pressure.csv")))
    v = vec(readdlm(joinpath(data_dir,"velocities.csv")))
    v = reshape_velocities(v,dep)
    t = vec(readdlm(joinpath(data_dir,"times.csv")))
    t = DateTime.(t)
    temp = vec(readdlm(joinpath(data_dir,"temperature.csv")))
    pitch= vec(readdlm(joinpath(data_dir,"pitch.csv")))
    roll = vec(readdlm(joinpath(data_dir,"roll.csv")))
    heading = vec(readdlm(joinpath(data_dir,"heading.csv")))
    if dep.adcp.hasAnalog
        a1 = vec(readdlm(joinpath(data_dir,"analog1.csv")))
        a2 = vec(readdlm(joinpath(data_dir,"analog2.csv")))
    else
        a1 = Nullable{Vector{Float64}}()
        a2 = Nullable{Vector{Float64}}()
    end
    ADCPData(dep,p,v,t,temp,pitch,roll,heading,a1,a2)
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
