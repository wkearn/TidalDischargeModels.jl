struct ThresholdModel <: DischargeModel
    M::Int
    k::Int
    f::Function
    β::Matrix{Float64}
    H::Matrix{Float64}
    Q::Vector{Float64}
end

ThresholdModel(M,N,f,k=1) = ThresholdModel(M,k,f,zeros(M,k),zeros(M,N),zeros(N))

function clusters(M::ThresholdModel,H::Matrix{Float64})
    cs = zeros(Int,size(H,2))
    for i in 1:size(H,2)
        cs[i] = M.f(H[:,i])
    end
    cs
end

function estimate_by_clusters(H,Q,cs,M,k)
    β = zeros(M,k)
    for i in 1:k
        Hi = H[:,cs.==i]
        Qi = Q[cs.==i]
        β[:,i] = (Hi*Hi')\(Hi*Qi)
    end
    β
end

function StatsBase.fit(M::ThresholdModel,H::Matrix{Float64},Q::Vector{Float64})
    cs = clusters(M,H)
    β = estimate_by_clusters(H,Q,cs,M.M,M.k)
    ThresholdModel(M.M,M.k,M.f,β,H,Q)        
end

function StatsBase.fit!(M::ThresholdModel,H::Matrix{Float64},Q::Vector{Float64})
    cs = clusters(M,H)
    β = estimate_by_clusters(H,Q,cs,M.M,M.k)
    M.β = β
    M.H = H
    M.Q = Q
    M
end

StatsBase.coef(M::ThresholdModel) = M.β
StatsBase.nobs(M::ThresholdModel) = length(M.Q)
StatsBase.model_response(M::ThresholdModel) = M.Q

function StatsBase.predict(M::ThresholdModel,H)
    cs = clusters(M,H)
    Q = zeros(size(H,2))
    for i in 1:length(Q)
        Q[i] = (H[:,i]'M.β[:,cs[i]])[1]
    end
    Q
end

StatsBase.predict(M::ThresholdModel) = predict(M,M.H)

StatsBase.residuals(M::ThresholdModel) = M.Q-predict(M)
StatsBase.residuals(M::ThresholdModel,H,Q) = Q-predict(M,H)
