module CatalystOscarExtension

# Fetch packages.
using Catalyst
import Oscar 

# Creates and exports hc_steady_states function.
include("CatalystOscarExtension/oscar_extension.jl")

end
