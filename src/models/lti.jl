struct LTIModel <: DischargeModel
    M::Int
    β::Vector{Float64}
    H::Matrix{Float64}
    Q::Vector{Float64}
end

LTIModel(M,N) = LTIModel(M,zeros(M),zeros(M,N),zeros(N))

function StatsBase.fit(M::LTIModel,H::Matrix{Float64},Q::Vector{Float64})
    LTIModel(M.M,H'\Q,H,Q)
end

function StatsBase.fit!(M::LTIModel,H::Matrix{Float64},Q::Vector{Float64})
    M.β = H'\Q
    M.H = H
    M.Q = Q
    M
end

StatsBase.coef(M::LTIModel) = M.β
StatsBase.nobs(M::LTIModel) = length(M.Q)
StatsBase.model_response(M::LTIModel) = M.Q
StatsBase.predict(M::LTIModel) = M.H'M.β
StatsBase.predict(M::LTIModel,H) = H'M.β
StatsBase.residuals(M::LTIModel) = M.Q-predict(M)
StatsBase.residuals(M::LTIModel,H,Q) = Q-predict(M,H)
