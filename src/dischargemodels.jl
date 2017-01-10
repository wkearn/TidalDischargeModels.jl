# Generic code for discharge modeling

"""
DischargeModel is a subtype of StatsBase's RegressionModel.

Each should thus attempt to implement the following methods:

- coef(model)
- coeftable(model)
- confint(model,prob)
- deviance(model)
- fit(Type{Model},X,y,params...)
- fit(Type{Model},X,params...) :: fit using a concatenated data-response matrix
- loglikelihood(model)
- stderr(model)
- vcov(model)
- nobs(model)
- model_response(model)
- predict(model)
- predict(model,H) :: using the new design matrix H, predict the fitted values
- residuals(model)
- residuals(model,H,Q) :: using the new design matrix H, predict fitted values and 
calculate the residuals from the new values

Some models will not be able to implement all of these easily.

We implement two helper functions

- `estfun(model,H,Q,range)` which fits a model to a stage and discharge record over 
the range given
- `evalfun(model,H,Q,range)` which evaluates a model's performance over the range given
"""
abstract DischargeModel <: RegressionModel

function estfun!(model::DischargeModel,H::Matrix{Nullable{Float64}},Q::Vector{Float64},range)
    Ht = validate(H,range,model.M)
    Qt = validate(Q,range,model.M)
    fit!(model,Ht,Qt)
end

estfun!(model::DischargeModel,H::Matrix{Nullable{Float64}},Q::Vector{Float64}) = estfun!(model,H,Q,1:length(Q))

function estfun(model::DischargeModel,H::Matrix{Nullable{Float64}},Q::Vector{Float64},range)
    Ht = validate(H,range,model.M)
    Qt = validate(Q,range,model.M)
    fit(model,Ht,Qt)
end

estfun(model::DischargeModel,H::Matrix{Nullable{Float64}},Q::Vector{Float64}) = estfun(model,H,Q,1:length(Q))

function evalfun(model::DischargeModel,H::Matrix{Nullable{Float64}},Q::Vector{Float64},range)
    Ht = validate(H,range,model.M)   
    Qt = validate(Q,range,model.M)
    sumabs2(residuals(model,Ht,Qt))
end

evalfun(model::DischargeModel,H::Matrix{Nullable{Float64}},Q::Vector{Float64}) = evalfun(model,H,Q,1:length(Q))

function evalmodel(model::DischargeModel,H::Matrix{Nullable{Float64}},range)
    Ht = validate(H,range,model.M)
    predict(model,Ht)
end

evalmodel(model::DischargeModel,H::Matrix{Nullable{Float64}},Q::Vector{Float64}) = evalmodel(model,H,Q,1:length(Q))

"""
This is  the one argument form of fitting a discharge model
"""
StatsBase.fit(M::DischargeModel, Y::Matrix{Float64}) = fit(M,Y[1:end-1,:],vec(Y[end,:]))

StatsBase.fit!(M::DischargeModel,Y::Matrix{Float64}) = fit!(M,Y[1:end-1,:],vec(Y[end,:]))

# Functions for fitting from a DischargeData type

estfun!(M::DischargeModel,dd::DischargeData,range) = estfun!(M,makelagmatrix(dd),dd.Q,range)
estfun!(M::DischargeModel,dd::DischargeData) = estfun!(M,makelagmatrix(dd),dd.Q,1:length(dd.Q))

estfun(M::DischargeModel,dd::DischargeData,range) = estfun(M,makelagmatrix(dd),dd.Q,range)
estfun(M::DischargeModel,dd::DischargeData) = estfun(M,makelagmatrix(dd),dd.Q,1:length(dd.Q))

evalfun(M::DischargeModel,dd::DischargeData,range) = evalfun(M,makelagmatrix(dd),dd.Q,range)
evalfun(M::DischargeModel,dd::DischargeData) = evalfun(M,makelagmatrix(dd),dd.Q,1:length(dd.Q))

evalmodel(M::DischargeModel,dd::DischargeData,range) = evalmodel(M,makelagmatrix(dd),range)
evalmodel(M::DischargeModel,dd::DischargeData) = evalmodel(M,makelagmatrix(dd),dd.Q,1:length(dd.Q))

# Add in all the possible models
const _models = ["lti",
                 "rlti",
                 "kmeans",
                 "volterra",
                 "threshold",
                 "boon"]
for m in _models
    include(joinpath("models",m*".jl"))
end