using Clustering, Distances, LinearAlgebra

struct kMeansModel <: DischargeModel
    M::Int
    k::Int
    λ::Real
    centers::Matrix{Float64}
    β::Matrix{Float64}
    H::Matrix{Float64}
    Q::Vector{Float64}
end

function clusters(M::kMeansModel,H)
    D = pairwise(Euclidean(),H,M.centers, dims=2)
    map(x->x[2], findmin(D, dims=2)[2])
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

function StatsBase.fit(::Type{kMeansModel},
                       h::AbstractVector{S},
                       q::AbstractVector{T};
                       M=1, k=1, λ=0.0) where {S, T}
    H,Q = preparedata(h, q, M)

    km = kmeans(H,k,init=:kmcen,tol=1e-32)
    β = zeros(M,k)
    for i in 1:k
        Hi = H[:,assignments(km).==i]
        Qi = Q[assignments(km).==i]
        β[:,i] = (Hi*Hi'+λ*I)\(Hi*Qi)
    end
    kMeansModel(M,k,λ,km.centers,β,H,Q)
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

function StatsBase.predict(M::kMeansModel, H::Matrix{Float64})
    clus = clusters(M,H)
    Q = zeros(size(H,2))
    for i in 1:length(Q)
        Q[i] = (H[:,i]'M.β[:,clus[i]])[1]
    end
    Q
end

StatsBase.predict(M::kMeansModel) = predict(M,M.H)

function StatsBase.predict(m::kMeansModel, h::AbstractVector{T}) where T
    Q = Array{Union{Missing, Float64}}(missing, length(h))
    for i in m.M:length(h)
        ht = h[i:-1:i-m.M+1]
        if !any(ismissing, ht)
            ht = convert(Vector{nonmissingtype(T)},ht)
            D = colwise(Euclidean(), ht, m.centers)
            c = argmin(D)
            Q[i] = dot(ht, m.β[:,c])
        end
    end
    Q
end

StatsBase.residuals(M::kMeansModel) = M.Q-predict(M)
StatsBase.residuals(M::kMeansModel,H,Q) = Q-predict(M,H)
