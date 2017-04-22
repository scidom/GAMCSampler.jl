CURRENTDIR, CURRENTFILE = splitdir(@__FILE__)
ROOTDIR = splitdir(splitdir(CURRENTDIR)[1])[1]
SRCDIR = joinpath(ROOTDIR, "src")
DATADIR = joinpath(ROOTDIR, "data")

include(joinpath(SRCDIR, "rv_model.jl"))
include(joinpath(SRCDIR, "utils_ex.jl"))

using RvModelKeplerian

srand(314159)

param_true = make_param_true_ex2()

# Make true values and one set of simulated data with noise
num_obs = 50
observation_timespan = 2*365.25
times = observation_timespan*sort(rand(num_obs));
model_true = map(t->calc_model_rv(param_true, t),times);
sigma_obs_scalar = 2.0
sigma_obs = sigma_obs_scalar*ones(num_obs);
jitter = RvModelKeplerian.num_jitters >=1 ? extract_jitter(param_true) : 0.
sigma_eff = sqrt(sigma_obs_scalar^2+jitter^2)

set_times(times);
set_obs( model_true .+ sigma_eff .* randn(length(times)) );
set_sigma_obs(sigma_obs);

writedlm(
  joinpath(DATADIR, "two_planets.csv"),
  zip(RvModelKeplerian.times,RvModelKeplerian.obs,RvModelKeplerian.sigma_obs),
  ','
)

# # Test
#
# using ForwardDiff
#
# function test_rv_example2()
#   plogtarget(param_true)
#   ForwardDiff.gradient(plogtarget,param_true)
#   ForwardDiff.hessian(plogtarget,param_true)
#   result = HessianResult(param_true)
#   ForwardDiff.hessian!(result, plogtarget, param_true);
# end
