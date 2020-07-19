# Catalyst.jl

[![Join the chat at https://gitter.im/JuliaDiffEq/Lobby](https://badges.gitter.im/JuliaDiffEq/Lobby.svg)](https://gitter.im/JuliaDiffEq/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.com/SciML/Catalyst.jl.svg?branch=master)](https://travis-ci.com/SciML/Catalyst.jl)
[![Coverage Status](https://coveralls.io/repos/github/SciML/Catalyst.jl/badge.svg?branch=master)](https://coveralls.io/github/SciML/Catalyst.jl?branch=master)
[![codecov.io](https://codecov.io/gh/SciML/Catalyst.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/SciML/Catalyst.jl)

<!--- [![Build status](https://ci.appveyor.com/api/projects/status/github/SciML/Catalyst.jl?branch=master&svg=true)](https://ci.appveyor.com/project/ChrisRackauckas/Catalyst-jl/branch/master) --->
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://catalyst.sciml.ai/stable/)
[![API Stable](https://img.shields.io/badge/API-stable-blue.svg)](https://catalyst.sciml.ai/stable/api/catalyst_api/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://catalyst.sciml.ai/dev/)
[![API Dev](https://img.shields.io/badge/API-dev-blue.svg)](https://catalyst.sciml.ai/dev/api/catalyst_api/)

**Note for pre-version 5 users**: *Version 5 is a breaking release, with the DSL
now generating `ModelingToolkit.ReactionSystem`s and DiffEqBiological being
renamed to Catalyst.  As such, the `@reaction_network` macro no longer allows
the generation of custom types. Please see the updated documentation to
understand changes to the API and functionality. In particular, the earlier
bifurcation functionality has not yet been updated to the new system. If you
rely on this functionality please do not update at this time, or consider using
[BifurcationKit.jl](https://github.com/rveltz/BifurcationKit.jl).*

Catalyst.jl is a domain specific language (DSL) for high performance
simulation and model of chemical reaction networks. Catalyst utilizes
[ModelingToolkit](https://github.com/SciML/ModelingToolkit.jl)
`ReactionSystem`s for auto-vectorization and parallelism in the
generated networks to scale large-scale simulations. This system
can generate ModelingToolkit-based systems of ODEs, SDEs, jump processes
and more. This allows for the easy simulation and parameter estimation
on mass action ODE models, Chemical Langevin SDE models,
stochastic chemical kinetics jump process models, and more.
The generated models can then be used with solvers throughout the broader
[SciML](https://sciml.ai) ecosystem, including higher level SciML
packages (e.g. for sensitivity analysis, parameter estimation,
machine learning applications, etc).

## Gillespie Simulations of Michaelis-Menten Enzyme Kinetics

```julia
rs = @reaction_network begin
  c1, S + E --> SE
  c2, SE --> S + E
  c3, SE --> P + E
end c1 c2 c3
p = (0.00166,0.0001,0.1)   # [c1,c2,c3]
tspan = (0., 100.)
u0 = [301., 100., 0., 0.]  # [S,E,SE,P]

# solve JumpProblem
dprob = DiscreteProblem(rs, u0, tspan, p)
jprob = JumpProblem(rs, dprob, Direct())
jsol = solve(jprob, SSAStepper())
plot(jsol,lw=2,title="Gillespie: Michaelis-Menten Enzyme Kinetics")
```

![](https://user-images.githubusercontent.com/1814174/87864114-3bf9dd00-c932-11ea-83a0-58f38aee8bfb.png)

## Adaptive SDEs for A Birth-Death Process

```julia
using Catalyst, Plots, StochasticDiffEq, DiffEqJump
rs = @reaction_network begin
  c1, X --> 2X
  c2, X --> 0
  c3, 0 --> X
end c1 c2 c3
p = (1.0,2.0,50.) # [c1,c2,c3]
tspan = (0.,10.)
u0 = [5.]         # [X]
sprob = SDEProblem(rs, u0, tspan, p)
ssol  = solve(sprob, LambaEM(), reltol=1e-3)
plot(ssol,lw=2,title="Adaptive SDE: Birth-Death Process")
```

![](https://user-images.githubusercontent.com/1814174/87864113-3bf9dd00-c932-11ea-8275-f903eef90b91.png)
