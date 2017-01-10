module ADCPTypes


export Creek, Deployment, Calibration, CrossSection, _DATABASE_DIR, bins, parse_deps, parse_cals, parse_cs

using YAML

using TidalDischargeModels.Databases

_DATABASE_DIR = Databases._ADCPDATA_DIR

type Creek{C}
    
end

Base.string{C}(::Creek{C}) = string(C)
Base.show(io::IO,creek::Creek) = print(io,"Creek: ", string(creek))

type ADCP
    serialNumber::String
    hasAnalog::Bool
    blankingDistance::Real
    cellSize::Real
    nCells::Int
    deltaT::Real
    elevation::Real
end

function bins(adcp::ADCP)
    B = adcp.blankingDistance
    C = adcp.cellSize
    N = adcp.nCells
    [B+C*i for i in 1:N]
end

function Base.show(io::IO,adcp::ADCP)
    println(io,"ADCP ",adcp.serialNumber)
    print(io,"Analog?: ", adcp.hasAnalog)
end


type Deployment
    location::Creek
    startDate::DateTime
    endDate::DateTime
    adcp::ADCP
end

function Base.show(io::IO,dep::Deployment)
    println(io,"ADCP Deployment")
    println(io,"================")
    println(io,dep.location)
    println(io,"Start time: ",dep.startDate)
    println(io,"End time: ",dep.endDate)
    print(io,dep.adcp)
end

type Calibration
    deployment::Deployment
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

type CrossSection
    location::Creek
    file::String
    Amax::Real
    lmax::Real
    hmax::Real
end

function Base.show(io::IO,cs::CrossSection)
    println(io,"Cross-section")
    println(io,"______________")
    print(io,cs.location)
end

function parse_deps{C}(creek::Creek{C})
    d = YAML.load_file(joinpath(_DATABASE_DIR,string(C),"METADATA.yaml"))
    deps = Deployment[]
    for dep in d["deployments"]
        sd = dep["startDate"]
        ed = dep["endDate"]
        sN = dep["serialNumber"]
        hA = dep["hasAnalog"]
        bD = dep["blankingDistance"]
        cS = dep["cellSize"]
        nC = dep["nCells"]
        dT = dep["deltaT"]
        aZ = dep["elevation"]
        push!(deps,Deployment(creek,sd,ed,ADCP(sN,hA,bD,cS,nC,dT,aZ)))
    end
    deps
end

function parse_cals{C}(creek::Creek{C})
    deps = parse_deps(creek)
    hs = hash.(deps)
    d = YAML.load_file(joinpath(_DATABASE_DIR,string(C),"METADATA.yaml"))
    cals = Calibration[]
    for cal in d["calibrations"]
        dep = cal["deployment"]
        sD = cal["startDate"]
        eD = cal["endDate"]
        dep_match = findfirst(hex.(hs),dep)
        push!(cals,Calibration(deps[dep_match],sD,eD))
    end
    cals
end

function parse_cs{C}(creek::Creek{C})
    cs = YAML.load_file(joinpath(_DATABASE_DIR,string(C),"METADATA.yaml"))["cross-section"]
    f = cs["file"]
    Amax = cs["Amax"]
    lmax = cs["lmax"]
    hmax = cs["hmax"]
    CrossSection(creek,f,Amax,lmax,hmax)
end

Base.hash{C}(x::Creek{C},h::UInt) = hash(C,h)
function Base.hash(x::ADCP,h::UInt)
    h = hash(x.serialNumber,h)
    h = hash(x.hasAnalog,h)
    h = hash(x.blankingDistance,h)
    h = hash(x.cellSize,h)
    h = hash(x.nCells,h)
    h = hash(x.deltaT,h)
    h = hash(x.elevation,h)
end

function Base.hash(x::Deployment,h::UInt)
    h = hash(x.location,h)
    h = hash(x.startDate,h)
    h = hash(x.endDate,h)
    hash(x.adcp,h)
end

function Base.hash(x::Calibration,h::UInt)
    h = hash(x.deployment,h)
    h = hash(x.startDate,h)
    h = hash(x.endDate,h)
end

function Base.hash(x::CrossSection,h::UInt)
    h = hash(x.location,h)
    h = hash(x.file,h)
    h = hash(x.Amax,h)
    h = hash(x.lmax,h)
    h = hash(x.hmax,h)
end

Base.:(==)(c1::Creek,c2::Creek) = hash(c1)==hash(c2)
Base.:(==)(d1::Deployment,d2::Deployment) = hash(d1)==hash(d2)
Base.:(==)(a1::ADCP,a2::ADCP) = hash(a1)==hash(a2)
Base.:(==)(c1::Calibration,c2::Calibration) = hash(c1)==hash(c2)
Base.:(==)(cs1::CrossSection,cs2::CrossSection) = hash(cs1)==hash(cs2)


end # module end
