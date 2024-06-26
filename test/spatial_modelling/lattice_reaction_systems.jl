### Preparations ###

# Fetch packages.
using Catalyst, Graphs, Test
using Symbolics: BasicSymbolic, unwrap
t = default_t()

# Pre declares a grid.
grid = Graphs.grid([2, 2])


### Tests LatticeReactionSystem Getters Correctness ###

# Test case 1.
let 
    rs = @reaction_network begin
        (p, 1), 0 <--> X
    end
    tr = @transport_reaction d X    
    lrs = LatticeReactionSystem(rs, [tr], grid)

    @unpack X, p = rs
    d = edge_parameters(lrs)[1]
    @test issetequal(species(lrs), [X])  
    @test issetequal(spatial_species(lrs), [X])   
    @test issetequal(parameters(lrs), [p, d])   
    @test issetequal(vertex_parameters(lrs), [p])  
    @test issetequal(edge_parameters(lrs), [d])      
end

# Test case 2.
let 
    rs = @reaction_network begin
        @parameters p1 p2 [edgeparameter=true]
    end
    @unpack p1, p2 = rs

    @test !isedgeparameter(p1)
    @test isedgeparameter(p2)
end

# Test case 3.
let 
    rs = @reaction_network begin
        @parameters pX pY dX [edgeparameter=true] dY
        (pX, 1), 0 <--> X
        (pY, 1), 0 <--> Y
    end
    tr_1 = @transport_reaction dX X  
    tr_2 = @transport_reaction dY Y    
    lrs = LatticeReactionSystem(rs, [tr_1, tr_2], grid)

    @unpack X, Y, pX, pY, dX, dY = rs
    @test issetequal(species(lrs), [X, Y])
    @test issetequal(spatial_species(lrs), [X, Y])
    @test issetequal(parameters(lrs), [pX, pY, dX, dY])
    @test issetequal(vertex_parameters(lrs), [pX, pY, dY])
    @test issetequal(edge_parameters(lrs), [dX])
end

# Test case 4.
let 
    rs = @reaction_network begin
        @parameters dX p
        (pX, 1), 0 <--> X
        (pY, 1), 0 <--> Y
    end
    tr_1 = @transport_reaction dX X   
    lrs = LatticeReactionSystem(rs, [tr_1], grid)

    @unpack dX, p, X, Y, pX, pY = rs
    @test issetequal(species(lrs), [X, Y])
    @test issetequal(spatial_species(lrs), [X])
    @test issetequal(parameters(lrs), [dX, p, pX, pY])
    @test issetequal(vertex_parameters(lrs), [dX, p, pX, pY])
    @test issetequal(edge_parameters(lrs), [])
end

# Test case 5.
let 
    rs = @reaction_network begin
        @species W(t)
        @parameters pX pY dX [edgeparameter=true] dY
        (pX, 1), 0 <--> X
        (pY, 1), 0 <--> Y
        (pZ, 1), 0 <--> Z
        (pV, 1), 0 <--> V
    end
    @unpack dX, X, V = rs
    @parameters dV dW
    @species W(t)
    tr_1 = TransportReaction(dX, X)  
    tr_2 = @transport_reaction dY Y    
    tr_3 = @transport_reaction dZ Z 
    tr_4 = TransportReaction(dV, V)  
    tr_5 = TransportReaction(dW, W)     
    lrs = LatticeReactionSystem(rs, [tr_1, tr_2, tr_3, tr_4, tr_5], grid)

    @unpack pX, pY, pZ, pV, dX, dY, X, Y, Z, V = rs
    dZ, dV, dW = edge_parameters(lrs)[2:end]
    @test issetequal(species(lrs), [W, X, Y, Z, V])
    @test issetequal(spatial_species(lrs), [X, Y, Z, V, W])
    @test issetequal(parameters(lrs), [pX, pY, dX, dY, pZ, pV, dZ, dV, dW])
    @test issetequal(vertex_parameters(lrs), [pX, pY, dY, pZ, pV])
    @test issetequal(edge_parameters(lrs), [dX, dZ, dV, dW])
end

# Test case 6.
let 
    rs = @reaction_network customname begin
        (p, 1), 0 <--> X
    end
    tr = @transport_reaction d X    
    lrs = LatticeReactionSystem(rs, [tr], grid)

    @test nameof(lrs) == :customname
end

### Tests Spatial Reactions Getters Correctness ###

# Test case 1.
let 
    tr_1 = @transport_reaction dX X    
    tr_2 = @transport_reaction dY1*dY2 Y   

    # @test ModelingToolkit.getname.(species(tr_1)) == ModelingToolkit.getname.(spatial_species(tr_1)) == [:X] # species(::TransportReaction) currently not supported.
    # @test ModelingToolkit.getname.(species(tr_2)) == ModelingToolkit.getname.(spatial_species(tr_2)) == [:Y]
    @test ModelingToolkit.getname.(spatial_species(tr_1)) == [:X]
    @test ModelingToolkit.getname.(spatial_species(tr_2)) == [:Y]
    @test ModelingToolkit.getname.(parameters(tr_1)) == [:dX]
    @test ModelingToolkit.getname.(parameters(tr_2)) == [:dY1, :dY2]

    # @test issetequal(species(tr_1), [tr_1.species])
    # @test issetequal(species(tr_2), [tr_2.species])
    @test issetequal(spatial_species(tr_1), [tr_1.species])
    @test issetequal(spatial_species(tr_2), [tr_2.species])
end

# Test case 2.
let
    rs = @reaction_network begin
        @species X(t) Y(t)
        @parameters dX dY1 dY2
    end
    @unpack X, Y, dX, dY1, dY2 = rs
    tr_1 = TransportReaction(dX, X)
    tr_2 = TransportReaction(dY1*dY2, Y)
    # @test isequal(species(tr_1), [X])
    # @test isequal(species(tr_1), [X])
    @test issetequal(spatial_species(tr_2), [Y])
    @test issetequal(spatial_species(tr_2), [Y])
    @test issetequal(parameters(tr_1), [dX])
    @test issetequal(parameters(tr_2), [dY1, dY2])
end

### Tests Spatial Reactions Generation ###

# Tests TransportReaction with non-trivial rate.
let 
    rs = @reaction_network begin
        @parameters dV dE [edgeparameter=true] 
        (p,1), 0 <--> X
    end
    @unpack dV, dE, X = rs
    
    tr = TransportReaction(dV*dE, X)
    @test isequal(tr.rate, dV*dE)
end

# Tests transport_reactions function for creating TransportReactions.
let 
    rs = @reaction_network begin
        @parameters d
        (p,1), 0 <--> X
    end
    @unpack d, X = rs
    trs = TransportReactions([(d, X), (d, X)])
    @test isequal(trs[1], trs[2])
end

# Test reactions with constants in rate.
let 
    @species X(t) Y(t)
    
    tr_1 = TransportReaction(1.5, X)
    tr_1_macro = @transport_reaction 1.5 X
    @test isequal(tr_1.rate, tr_1_macro.rate)
    @test isequal(tr_1.species, tr_1_macro.species)
    
    tr_2 = TransportReaction(π, Y)
    tr_2_macro = @transport_reaction π Y
    @test isequal(tr_2.rate, tr_2_macro.rate)
    @test isequal(tr_2.species, tr_2_macro.species)
end

### Test Interpolation ###

# Does not currently work. The 3 tr_macro_ lines generate errors.
# Test case 1.
let
    rs = @reaction_network begin
        @species X(t) Y(t) Z(t)
        @parameters dX dY1 dY2 dZ
    end
    @unpack X, Y, Z, dX, dY1, dY2, dZ = rs
    rate1 = dX
    rate2 = dY1*dY2 
    species3 = Z
    tr_1 = TransportReaction(dX, X)
    tr_2 = TransportReaction(dY1*dY2, Y)
    tr_3 = TransportReaction(dZ, Z)
    tr_macro_1 = @transport_reaction $dX X
    tr_macro_2 = @transport_reaction $(rate2) Y
    # tr_macro_3 = @transport_reaction dZ $species3 # Currently does not work, something with meta programming.
    
    @test isequal(tr_1, tr_macro_1)
    @test isequal(tr_2, tr_macro_2) # Unsure why these fails, since for components equality hold: `isequal(tr_1.species, tr_macro_1.species)` and `isequal(tr_1.rate, tr_macro_1.rate)` are both true.
    # @test isequal(tr_3, tr_macro_3)
end

### Tests Error generation ###

# Test creation of TransportReaction with non-parameters in rate.
# Tests that it works even when rate is highly nested.
let 
    @species X(t) Y(t)
    @parameters D1 D2 D3
    @test_throws ErrorException TransportReaction(D1 + D2*(D3 + Y), X)
    @test_throws ErrorException TransportReaction(Y, X)
end

# Network where diffusion species is not declared in non-spatial network.
let 
    rs = @reaction_network begin
        (p, d), 0 <--> X
    end
    tr = @transport_reaction D Y    
    @test_throws ErrorException LatticeReactionSystem(rs, [tr], grid)
end

# Network where the rate depend on a species
let 
    rs = @reaction_network begin
        @species Y(t)
        (p, d), 0 <--> X
    end
    tr = @transport_reaction D*Y X
    @test_throws ErrorException LatticeReactionSystem(rs, [tr], grid)
end

# Network with edge parameter in non-spatial reaction rate.
let 
    rs = @reaction_network begin
        @parameters p [edgeparameter=true]
        (p, d), 0 <--> X
    end
    tr = @transport_reaction D X
    @test_throws ErrorException LatticeReactionSystem(rs, [tr], grid)
end

# Network where metadata has been added in rs (which is not seen in transport reaction).
let 
    rs = @reaction_network begin
        @species X(t) [description="Species with added metadata"]
        (p, d), 0 <--> X
    end
    tr = @transport_reaction D X
    @test_throws ErrorException LatticeReactionSystem(rs, [tr], grid)

    rs = @reaction_network begin
        @parameters D [description="Parameter with added metadata"]
        (p, d), 0 <--> X
    end
    tr = @transport_reaction D X
    @test_throws ErrorException LatticeReactionSystem(rs, [tr], grid)
end


### Test Designation of Parameter Types ###
# Currently not supported. Won't be until the LatticeReactionSystem internal update is merged.

# Checks that parameter types designated in the non-spatial `ReactionSystem` is handled correctly.
# Broken lattice tests have local branches that fixes them.
@test_broken let
    # Declares LatticeReactionSystem with designated parameter types.
    rs = @reaction_network begin
        @parameters begin
            k1
            l1
            k2::Float64 = 2.0
            l2::Float64
            k3::Int64 = 2, [description="A parameter"]
            l3::Int64
            k4::Float32, [description="Another parameter"]
            l4::Float32
            k5::Rational{Int64}
            l5::Rational{Int64}
            D1::Float32
            D2, [edgeparameter=true]
            D3::Rational{Int64}, [edgeparameter=true]
        end
        (k1,l1), X1 <--> Y1
        (k2,l2), X2 <--> Y2
        (k3,l3), X3 <--> Y3
        (k4,l4), X4 <--> Y4
        (k5,l5), X5 <--> Y5
    end
    tr1 = @transport_reaction $(rs.D1) X1 
    tr2 = @transport_reaction $(rs.D2) X2 
    tr3 = @transport_reaction $(rs.D3) X3    
    lrs = LatticeReactionSystem(rs, [tr1, tr2, tr3], grid)
    
    # Loops through all parameters, ensuring that they have the correct type
    p_types = Dict([ModelingToolkit.nameof(p) => typeof(unwrap(p)) for p in parameters(lrs)])
    @test p_types[:k1] == BasicSymbolic{Real}
    @test p_types[:l1] == BasicSymbolic{Real}
    @test p_types[:k2] == BasicSymbolic{Float64}
    @test p_types[:l2] == BasicSymbolic{Float64}
    @test p_types[:k3] == BasicSymbolic{Int64}
    @test p_types[:l3] == BasicSymbolic{Int64}
    @test p_types[:k4] == BasicSymbolic{Float32}
    @test p_types[:l4] == BasicSymbolic{Float32}
    @test p_types[:k5] == BasicSymbolic{Rational{Int64}}
    @test p_types[:l5] == BasicSymbolic{Rational{Int64}}
    @test p_types[:D1] == BasicSymbolic{Float32}
    @test p_types[:D2] == BasicSymbolic{Real}
    @test p_types[:D3] == BasicSymbolic{Rational{Int64}}
end

# Checks that programmatically declared parameters (with types) can be used in `TransportReaction`s.
# Checks that LatticeReactionSystem with non-default parameter types can be simulated.
@test_broken let
    rs = @reaction_network begin
        @parameters p::Float32
        (p,d), 0 <--> X
    end
    @parameters D::Rational{Int64}
    tr = TransportReaction(D, rs.X)  
    lrs = LatticeReactionSystem(rs, [tr], grid)
    
    p_types = Dict([ModelingToolkit.nameof(p) => typeof(unwrap(p)) for p in parameters(lrs)])
    @test p_types[:p] == BasicSymbolic{Float32}
    @test p_types[:d] == BasicSymbolic{Real}
    @test p_types[:D] == BasicSymbolic{Rational{Int64}}

    u0 = [:X => [0.25, 0.5, 2.0, 4.0]]
    ps = [rs.p => 2.0, rs.d => 1.0, D => 1//2]

    # Currently broken. This requires some non-trivial reworking of internals.
    # However, spatial internals have already been reworked (and greatly improved) in an unmerged PR.
    # This will be sorted out once that has finished.
    @test_broken false 
    # oprob = ODEProblem(lrs, u0, (0.0, 10.0), ps)
    # sol = solve(oprob, Tsit5())
    # @test sol[end] == [1.0, 1.0, 1.0, 1.0]
end

# Tests that LatticeReactionSystem cannot be generated where transport reactions depend on parameters
# that have a type designated in the non-spatial `ReactionSystem`.
@test_broken false
# let
#     rs = @reaction_network begin
#         @parameters D::Int64
#         (p,d), 0 <--> X
#     end
#     tr = @transport_reaction D X 
#     @test_throws Exception LatticeReactionSystem(rs, tr, grid)
# end