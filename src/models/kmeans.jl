using Clustering, Distances

struct kMeansModel <: DischargeModel
    M::Int
    k::Int
    λ::Real
    centers::Matrix{Float64}
    β::Matrix{Float64}
    H::Matrix{Float64}
    Q::Vector{Float64}
end

kMeansModel(M,N,k=1,λ=0.0) = kMeansModel(M,k,λ,zeros(M,k),zeros(M,k),zeros(M,N),zeros(N))

function clusters(M::kMeansModel,H)
    D = pairwise(Euclidean(),H,M.centers)
    map(x->ind2sub(size(D),x)[2],findmin(D,2)[2])
end

function StatsBase.fit(M::kMeansModel,H::Matrix{Float64},Q::Vector{Float64})
    km = kmeans(H,M.k,init=:kmcen,tol=1e-32)
    β = zeros(M.M,M.k)
    for i in 1:M.k
        Hi = H[:,assignments(km).==i]
        Qi = Q[assignments(km).==i]
        β[:,i] = (Hi*Hi'+M.λ*I)\(Hi*Qi)
    end
    kMeansModel(M.M,M.k,M.λ,km.centers,β,H,Q)
end

function StatsBase.fit!(M::kMeansModel,H::Matrix{Float64},Q::Vector{Float64})
    km = kmeans(H,M.k,init=:kmcen,tol=1e-32)
    M.centers = km.centers
    β = zeros(M.M,M.k)
    for i in 1:M.k
        Hi = H[:,assignments(km).==i]
        Qi = Q[assignments(km).==i]
        β[:,i] = (Hi*Hi'+M.λ*I)\(Hi*Qi)
    end
    M.β = β
    M.H = H
    M.Q = Q
    M
end

StatsBase.coef(M::kMeansModel) = M.β
StatsBase.nobs(M::kMeansModel) = length(M.Q)
StatsBase.model_response(M::kMeansModel) = M.Q

function StatsBase.predict(M::kMeansModel,H)
    clus = clusters(M,H)
    Q = zeros(size(H,2))
    for i in 1:length(Q)
        Q[i] = (H[:,i]'M.β[:,clus[i]])[1]
    end
    Q
end

StatsBase.predict(M::kMeansModel) = predict(M,M.H)

StatsBase.residuals(M::kMeansModel) = M.Q-predict(M)
StatsBase.residuals(M::kMeansModel,H,Q) = Q-predict(M,H)
