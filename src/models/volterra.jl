# Implementation of Franz and Scholkopf
# A unifying view of Wiener and Volterra theory and polynomial
# kernel regression

abstract VolterraKernel

export AdaptiveKernel,
InhomogeneousPolyKernel,
GaussianKernel,
VovkKernel

immutable AdaptiveKernel <: VolterraKernel
    a::Vector{Float64}
end

(k::AdaptiveKernel)(h) = sum(k.a.^2.*[h^n for n in 0:length(k.a)-1])
(k::AdaptiveKernel)(x1,x2) = k(dot(x1,x2))
weights(k::AdaptiveKernel,n) = k.a[n+1]
weights(k::AdaptiveKernel) = k.a

immutable InhomogeneousPolyKernel <: VolterraKernel
    p
end

(k::InhomogeneousPolyKernel)(h) = (1+h)^k.p
(k::InhomogeneousPolyKernel)(x1,x2) = k(dot(x1,x2))
weights(k::InhomogeneousPolyKernel,n) = binomial(k.p,n)
weights(k::InhomogeneousPolyKernel) = [weights(k,n) for n in 0:p]

immutable GaussianKernel <: VolterraKernel
end

(k::GaussianKernel)(h) = exp(h)
(k::GaussianKernel)(x1,x2) = k(dot(x1,x2))
weights(k::GaussianKernel,n) = 1/factorial(n)

immutable VovkKernel <: VolterraKernel
    α
end

(k::VovkKernel)(h) = (1-h)^(-k.α)
(k::VovkKernel)(x1,x2) = k(dot(x1,x2))
weights(k::VovkKernel,n) = binomial(-k.α,n)*(-1)^n

## Now we need to do kernel regression

"""
Form the kernel matrix out of a data matrix.
"""
kernel_matrix(k::VolterraKernel,X1,X2) = map(k,X1'X2)
kernel_matrix(k::VolterraKernel,X) = kernel_matrix(k,X,X)


type VolterraModel <: DischargeModel
    M::Int
    k::VolterraKernel
    β::Vector{Float64}
    H::Matrix{Float64}
    Q::Vector{Float64}
end

VolterraModel(M,N,k=1) = VolterraModel(M,k,zeros(N),zeros(M,N),zeros(N))

"""
Fitting a Volterra Series Model simply requires inversion of the kernel matrix.
"""
function StatsBase.fit(M::VolterraModel,H::Matrix{Float64},Q::Vector{Float64})
    VolterraModel(M.M,M.k,kernel_matrix(M.k,H)\Q,H,Q)
end

function StatsBase.fit!(M::VolterraModel,H::Matrix{Float64},Q::Vector{Float64})
    M.β = kernel_matrix(M.k,H)\Q
    M.H = H
    M.Q = Q
    M
end

StatsBase.coef(M::VolterraModel) = M.β
StatsBase.nobs(M::VolterraModel) = length(M.Q)
StatsBase.model_response(M::VolterraModel) = M.Q
function StatsBase.predict(M::VolterraModel,H)
    vec(M.β'kernel_matrix(M.k,M.H,H))
end
StatsBase.predict(M::VolterraModel) = predict(M,M.H)
StatsBase.residuals(M::VolterraModel) = M.Q-predict(M)
StatsBase.residuals(M::VolterraModel,H,Q) = Q-predict(M,H)

type RegularizedVolterraModel<: DischargeModel
    M::Int
    k::VolterraKernel
    λ::Float64
    R::AbstractMatrix
    β::Vector{Float64}
    H::Matrix{Float64}
    Q::Vector{Float64}
end

RegularizedVolterraModel(M,N,k=1,λ=0.0) = RegularizedVolterraModel(M,InhomogeneousPolyKernel(k),λ,eye(N-M+1,N-M+1),zeros(N),zeros(M,N),zeros(N))

function StatsBase.fit(M::RegularizedVolterraModel,H::Matrix{Float64},Q::Vector{Float64})
    RegularizedVolterraModel(M.M,
                             M.k,
                             M.λ,
                             M.R,
                             (kernel_matrix(M.k,H)+M.λ*M.R)\Q,
                             H,
                             Q)
end

function StatsBase.fit!(M::RegularizedVolterraModel,H::Matrix{Float64},Q::Vector{Float64})
    M.β = (kernel_matrix(M.k,H)+M.λ*M.R)\Q
    M.H = H
    M.Q = Q
    M
end

StatsBase.coef(M::RegularizedVolterraModel) = M.β
StatsBase.nobs(M::RegularizedVolterraModel) = length(M.Q)
StatsBase.model_response(M::RegularizedVolterraModel) = M.Q
function StatsBase.predict(M::RegularizedVolterraModel,H)
    vec(M.β'kernel_matrix(M.k,M.H,H))
end
StatsBase.predict(M::RegularizedVolterraModel) = predict(M,M.H)
StatsBase.residuals(M::RegularizedVolterraModel) = M.Q-predict(M)
StatsBase.residuals(M::RegularizedVolterraModel,H,Q) = Q-predict(M,H)

"""
To get the Volterra operator, we have to calculate a design matrix.

This is Φn = [ϕn(x_1),ϕn(x_2),...]

where ϕn(x) collects all monomials of order n of the entries of x
"""
function ϕ(x,n)
    out = ones(ntuple(y->length(x),n))
    for I in CartesianRange(size(out))
        for i in 1:length(I)
            out[I]*=x[I[i]]
        end
    end
    vec(out)
end
                
function designmatrix(H,n)
    a,b = size(H)
    Φ = zeros(a^n,b)
    for i in 1:b
        Φ[:,i] = ϕ(H[:,i],n)
    end
    Φ
end

"""
Derive the Volterra operator of order n from a model
"""
operator(M::VolterraModel,n) = weights(M.k,n).*designmatrix(M.H,n)*M.β
operator(M::RegularizedVolterraModel,n) = weights(M.k,n).*designmatrix(M.H,n)*M.β
