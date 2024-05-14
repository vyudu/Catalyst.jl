# Catalyst.jl

[![Join the chat at https://julialang.zulipchat.com #sciml-bridged](https://img.shields.io/static/v1?label=Zulip&message=chat&color=9558b2&labelColor=389826)](https://julialang.zulipchat.com/#narrow/stream/279055-sciml-bridged)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://docs.sciml.ai/Catalyst/stable/)
[![API Stable](https://img.shields.io/badge/API-stable-blue.svg)](https://docs.sciml.ai/Catalyst/stable/api/catalyst_api/)
<!---  [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://docs.sciml.ai/Catalyst/dev/)
[![API Dev](https://img.shields.io/badge/API-dev-blue.svg)](https://docs.sciml.ai/Catalyst/dev/api/catalyst_api/) -->

[![Build Status](https://github.com/SciML/Catalyst.jl/workflows/CI/badge.svg)](https://github.com/SciML/Catalyst.jl/actions?query=workflow%3ACI)
[![codecov.io](https://codecov.io/gh/SciML/Catalyst.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/SciML/Catalyst.jl)
[![Coverage Status](https://coveralls.io/repos/github/SciML/Catalyst.jl/badge.svg?branch=master)](https://coveralls.io/github/SciML/Catalyst.jl?branch=master)

[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)
[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)

Catalyst.jl is a symbolic modeling package for analysis and high performance
simulation of chemical reaction networks. Catalyst defines symbolic
[`ReactionSystem`](https://docs.sciml.ai/Catalyst/stable/catalyst_functionality/programmatic_CRN_construction/)s,
which can be created programmatically or easily
specified using Catalyst's domain specific language (DSL). Leveraging
[ModelingToolkit](https://github.com/SciML/ModelingToolkit.jl) and
[Symbolics.jl](https://github.com/JuliaSymbolics/Symbolics.jl), Catalyst enables
large-scale simulations through auto-vectorization and parallelism. Symbolic
`ReactionSystem`s can be used to generate ModelingToolkit-based models, allowing
the easy simulation and parameter estimation of mass action ODE models, Chemical
Langevin SDE models, stochastic chemical kinetics jump process models, and more.
Generated models can be used with solvers throughout the broader
[SciML](https://sciml.ai) ecosystem, including higher level SciML packages (e.g.
for sensitivity analysis, parameter estimation, machine learning applications,
etc).

## Breaking changes and new features

**NOTE:** version 14 is a breaking release, prompted by the release of ModelingToolkit.jl version 9. This caused several breaking changes in how Catalyst models are represented and interfaced with.

Breaking changes and new functionality are summarized in the
[HISTORY.md](HISTORY.md) file.

## Tutorials and documentation

The latest tutorials and information on using the package are available in the [stable
documentation](https://docs.sciml.ai/Catalyst/stable/). The [in-development
documentation](https://docs.sciml.ai/Catalyst/dev/) describes unreleased features in
the current master branch.

Several Youtube video tutorials and overviews are also available, but note these use older 
Catalyst versions with slightly different notation (for example, in building reaction networks):
- From JuliaCon 2023: A short 15 minute overview of Catalyst as of version 13 is
available in the talk [Catalyst.jl, Modeling Chemical Reaction Networks](https://www.youtube.com/watch?v=yreW94n98eM&ab_channel=TheJuliaProgrammingLanguage).
- From JuliaCon 2022: A three hour tutorial workshop overviewing how to use
  Catalyst and its more advanced features as of version 12.1. [Workshop
  video](https://youtu.be/tVfxT09AtWQ), [Workshop Pluto.jl
  Notebooks](https://github.com/SciML/JuliaCon2022_Catalyst_Workshop). 
- From SIAM CSE 2021: A short 15 minute overview of Catalyst as of version 6 is
available in the talk [Modeling Biochemical Systems with
Catalyst.jl](https://www.youtube.com/watch?v=5p1PJE5A5Jw).
- From JuliaCon 2018: A short 13 minute overview of Catalyst when it was known
  as DiffEqBiological in older versions is available in the talk [Efficient
  Modelling of Biochemical Reaction
  Networks](https://www.youtube.com/watch?v=s1e72k5XD6s)

Finally, an overview of the package and its features (as of version 13) can also be found in its corresponding research paper, [Catalyst: Fast and flexible modeling of reaction networks](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1011530).

## Features

- A DSL provides a simple and readable format for manually specifying chemical
  reactions.
- Catalyst `ReactionSystem`s provide a symbolic representation of reaction networks,
  built on [ModelingToolkit.jl](https://docs.sciml.ai/ModelingToolkit/stable/) and
  [Symbolics.jl](https://docs.sciml.ai/Symbolics/stable/).
- Non-integer (e.g. `Float64`) stoichiometric coefficients are supported for generating
  ODE models, and symbolic expressions for stoichiometric coefficients are supported for
  all system types.
- The [Catalyst.jl API](http://docs.sciml.ai/Catalyst/stable/api/catalyst_api) provides functionality for extending networks,
  building networks programmatically, network analysis, and for composing multiple
  networks together.
- `ReactionSystem`s generated by the DSL can be converted to a variety of
  `ModelingToolkit.AbstractSystem`s, including symbolic ODE, SDE and jump process
  representations.
- Coupled differential and algebraic constraint equations can be included in
  Catalyst models, and are incorporated during conversion to ODEs or steady
  state equations.
- Conservation laws can be detected and applied to reduce system sizes, and generate
  non-singular Jacobians, during conversion to ODEs, SDEs, and steady state equations.
- By leveraging ModelingToolkit, users have a variety of options for generating
  optimized system representations to use in solvers. These include construction
  of dense or sparse Jacobians, multithreading or parallelization of generated
  derivative functions, automatic classification of reactions into optimized
  jump types for Gillespie type simulations, automatic construction of
  dependency graphs for jump systems, and more.
- Generated systems can be solved using any
  [DifferentialEquations.jl](https://docs.sciml.ai/DiffEqDocs/stable/)
  ODE/SDE/jump solver, and can be used within `EnsembleProblem`s for carrying
  out parallelized parameter sweeps and statistical sampling. Plot recipes
  are available for visualizing the solutions.
- [Symbolics.jl](https://github.com/JuliaSymbolics/Symbolics.jl) symbolic
  expressions and Julia `Expr`s can be obtained for all rate laws and functions
  determining the deterministic and stochastic terms within resulting ODE, SDE
  or jump models.
- [Latexify](https://korsbo.github.io/Latexify.jl/stable/) can be used to generate
  LaTeX expressions corresponding to generated mathematical models or the
  underlying set of reactions.
- [Graphviz](https://graphviz.org/) can be used to generate and visualize
  reaction network graphs. (Reusing the Graphviz interface created in
  [Catlab.jl](https://algebraicjulia.github.io/Catlab.jl/stable/).)

## Packages supporting Catalyst
- Catalyst [`ReactionSystem`](@ref)s can be imported from SBML files via
  [SBMLToolkit.jl](https://github.com/SciML/SBMLToolkit.jl), and from BioNetGen .net
  files and various stoichiometric matrix network representations using
  [ReactionNetworkImporters.jl](https://github.com/SciML/ReactionNetworkImporters.jl).
- [MomentClosure.jl](https://github.com/augustinas1/MomentClosure.jl) allows
  generation of symbolic ModelingToolkit `ODESystem`s, representing moment
  closure approximations to moments of the Chemical Master Equation, from
  reaction networks defined in Catalyst.
- [FiniteStateProjection.jl](https://github.com/kaandocal/FiniteStateProjection.jl)
  allows the construction and numerical solution of Chemical Master Equation
  models from reaction networks defined in Catalyst.
- [DelaySSAToolkit.jl](https://github.com/palmtree2013/DelaySSAToolkit.jl) can
  augment Catalyst reaction network models with delays, and can simulate the
  resulting stochastic chemical kinetics with delays models.
- [BondGraphs.jl](https://github.com/jedforrest/BondGraphs.jl) a package for
  constructing and analyzing bond graphs models, which can take Catalyst models as input.
- [PEtab.jl](https://github.com/sebapersson/PEtab.jl) a package that implements the PEtab format for fitting reaction network ODEs to data. Input can be provided either as SBML files or as Catalyst `ReactionSystem`s.


## Illustrative examples
#### Gillespie simulations of Michaelis-Menten enzyme kinetics

```julia
using Catalyst, Plots, JumpProcesses
rs = @reaction_network begin
  c1, S + E --> SE
  c2, SE --> S + E
  c3, SE --> P + E
end
p  = (:c1 => 0.00166, :c2 => 0.0001, :c3 => 0.1)
tspan = (0., 100.)
u0 = [:S => 301, :E => 100, :SE => 0, :P => 0]

# solve JumpProblem
dprob = DiscreteProblem(rs, u0, tspan, p)
jprob = JumpProblem(rs, dprob, Direct())
jsol = solve(jprob, SSAStepper())
plot(jsol; lw = 2, title = "Gillespie: Michaelis-Menten Enzyme Kinetics")
```

![](https://user-images.githubusercontent.com/1814174/87864114-3bf9dd00-c932-11ea-83a0-58f38aee8bfb.png)

#### Adaptive time stepping SDEs for a birth-death process

```julia
using Catalyst, Plots, StochasticDiffEq
rs = @reaction_network begin
  c1, X --> 2X
  c2, X --> 0
  c3, 0 --> X
end
p     = (:c1 => 1.0, :c2 => 2.0, :c3 => 50.)
tspan = (0.,10.)
u0    = [:X => 5.]
sprob = SDEProblem(rs, u0, tspan, p)
ssol  = solve(sprob, LambaEM(), reltol=1e-3)
plot(ssol; lw = 2, title = "Adaptive SDE: Birth-Death Process")
```

![](https://user-images.githubusercontent.com/1814174/87864113-3bf9dd00-c932-11ea-8275-f903eef90b91.png)

## Getting help
Catalyst developers are active on the [Julia
Discourse](https://discourse.julialang.org/), the [Julia Slack](https://julialang.slack.com) channels \#sciml-bridged and \#sciml-sysbio, and the [Julia Zulip sciml-bridged channel](https://julialang.zulipchat.com/#narrow/stream/279055-sciml-bridged).
For bugs or feature requests [open an issue](https://github.com/SciML/Catalyst.jl/issues).


## Supporting and citing Catalyst.jl
The software in this ecosystem was developed as part of academic research. If you would like to help support it,
please star the repository as such metrics may help us secure funding in the future. If you use Catalyst as part
of your research, teaching, or other activities, we would be grateful if you could cite our work:
```
@article{CatalystPLOSCompBio2023,
    doi = {10.1371/journal.pcbi.1011530},
    author = {Loman, Torkel E. AND Ma, Yingbo AND Ilin, Vasily AND Gowda, Shashi AND Korsbo, Niklas AND Yewale, Nikhil AND Rackauckas, Chris AND Isaacson, Samuel A.},
    journal = {PLOS Computational Biology},
    publisher = {Public Library of Science},
    title = {Catalyst: Fast and flexible modeling of reaction networks},
    year = {2023},
    month = {10},
    volume = {19},
    url = {https://doi.org/10.1371/journal.pcbi.1011530},
    pages = {1-19},
    number = {10},
}
```
