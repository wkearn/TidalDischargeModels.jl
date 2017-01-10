type RegularizedLTIModel <: DischargeModel
    M::Int
    λ::Float64
    β::Vector{Float64}
    H::Matrix{Float64}
    Q::Vector{Float64}
end

RegularizedLTIModel(M,N,λ=0.0) = RegularizedLTIModel(M,λ,zeros(M),zeros(M,N),zeros(N))

function StatsBase.fit(M::RegularizedLTIModel,H::Matrix{Float64},Q::Vector{Float64})
    U,s,V = svd(H')
    D = diagm(s./(s.^2+M.λ^2))
    RegularizedLTIModel(M.M,M.λ,V*D*U'Q,H,Q)
end

function StatsBase.fit!(M::RegularizedLTIModel,H::Matrix{Float64},Q::Vector{Float64})
    U,s,V = svd(H')
    D = diagm(s./(s.^2+M.λ^2))
    M.β = V*D*U'Q
    M.H = H
    M.Q = Q
    M
end

StatsBase.coef(M::RegularizedLTIModel) = M.β
StatsBase.nobs(M::RegularizedLTIModel) = length(M.Q)
StatsBase.model_response(M::RegularizedLTIModel) = M.Q
StatsBase.predict(M::RegularizedLTIModel) = M.H'M.β
StatsBase.predict(M::RegularizedLTIModel,H) = H'M.β
StatsBase.residuals(M::RegularizedLTIModel) = M.Q - predict(M)
StatsBase.residuals(M::RegularizedLTIModel,H,Q) = Q-predict(M,H)
