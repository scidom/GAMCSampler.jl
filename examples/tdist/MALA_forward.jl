using Distributions
using Lora
using PGUManifoldMC

function C(n::Int, c::Float64)
  X = eye(n)
  [(j <= n-i) ? X[i+j, i] = X[i, i+j] = c^j : nothing for i = 1:(n-1), j = 1:(n-1)]
  X
end

n = 5
Σ = C(n, 0.5)
ν = 30.

plogtarget(p::Vector, v::Vector) = logpdf(MvTDist(ν, zeros(n), (ν-2)*Σ/ν), p)

p = BasicContMuvParameter(
  :p,
  logtarget=plogtarget,
  nkeys=1,
  autodiff=:forward,
  order=1
)

model = likelihood_model([p], isindexed=false)

# Simulation 01

sampler = MALA(1.)

mcrange = BasicMCRange(nsteps=11000, burnin=1000)

v0 = Dict(:p=>[-4., 2., 3., 1., 2.4])

outopts = Dict{Symbol, Any}(:monitor=>[:value, :logtarget, :gradlogtarget], :diagnostics=>[:accept])

job = BasicMCJob(
  model,
  sampler,
  mcrange,
  v0,
  tuner=AcceptanceRateMCTuner(0.6, score=x -> logistic_rate_score(x, 3.), verbose=false),
  outopts=outopts
)

tic()
run(job)
runtime = toc()

chain = output(job)

ppostmean = mean(chain)

ess(chain, vtype=:bm)

ess(chain, vtype=:bm)/runtime

acceptance(chain)