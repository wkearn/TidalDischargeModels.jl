type BoonModel <: DischargeModel
    M
    β
    H
    Q
end

BoonModel(N) = BoonModel(2,zeros(2),zeros(2,N),zeros(N))

function boon(h,β)
    β[1]*abs(h[1]).^β[2]*(h[1]-h[2])
end

function boon(H::Matrix{Float64},β)
    Q = zeros(size(H,2))
    for i in 1:length(Q)
        Q[i] = boon(H[:,i],β)
    end
    Q
end

function boon_gradient!(storage,h,β)
    storage[1] = abs(h[1]).^β[2]*(h[1]-h[2])
    storage[2] = β[1]*β[2]*abs(h[1]).^(β[2]-1)*(h[1]-h[2])
    storage
end

boon_gradient(h,β) = boon_gradient!(zeros(2),h,β)

function boon_gradient(H::Matrix{Float64},β)
    storage = zeros(2,size(H,2))
    for i in 1:size(H,2)
        storage[:,i] = boon_gradient(H[:,i],β)
    end
    storage
end

function ssr(H,Q,β)    
    0.5*sum(abs2,Q-boon(H,β))
end

function gssr!(storage,H,Q,β)
    rs = Q-boon(H,β)
    gs = boon_gradient(H,β)
    
    storage[1] = dot(rs,vec(gs[1,:]))
    storage[2] = dot(rs,vec(gs[2,:]))
    storage
end

function StatsBase.fit(M::BoonModel,H::Matrix{Float64},Q::Vector{Float64})
    β = optimize(β->ssr(H,Q,β),M.β).minimizer
    BoonModel(2,β,H,Q)
end

function StatsBase.fit!(M::BoonModel,H::Matrix{Float64},Q::Vector{Float64})
    β = optimize(β->ssr(H,Q,β),M.β,ftol=1e-32).minimizer
    M.β = β
    M.H = H
    M.Q = Q
    M
end

#(β,g) -> gssr!(g,H,Q,β)
StatsBase.coef(M::BoonModel) = M.β
StatsBase.nobs(M::BoonModel) = length(M.Q)
StatsBase.model_response(M::BoonModel) = M.Q

function StatsBase.predict(M::BoonModel,H)
    Q = zeros(size(H,2))
    for i in 1:length(Q)
        Q[i] = boon(H[:,i],M.β)
    end
    Q
end
StatsBase.predict(M::BoonModel) = predict(M,M.H)

StatsBase.residuals(M::BoonModel) = M.Q-predict(M)
StatsBase.residuals(M::BoonModel,H,Q) = Q-predict(M,H)
