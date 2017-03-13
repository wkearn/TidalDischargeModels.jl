module Fluxes

using TidalDischargeModels.ADCPTypes, TidalDischargeModels.ADCPDataStructures, DischargeData, TidalDischargeModels.DischargeDataStructures

type Concentration <: AbstractVector{Float64}
    C::Vector{Float64}
end

type Flux <: AbstractVector{Float64}
    F::Vector{Float64}
end

Base.size(c::Concentration) = size(c.C)
Base.size(f::Flux) = size(f.F)

Base.getindex(c::Concentration,i::Int) = getindex(c.C,i)
Base.getindex(f::Flux,i::Int) = getindex(f.F,i)

Base.:(*)(c::Concentration,dd::Discharge) = Flux(c.C.*dd.Q)

end # module end
