module EnzymeRules

import ..Enzyme
import Enzyme: Const, Active, Duplicated, DuplicatedNoNeed, Annotation

function forward end

"""
	augmented_primal(::typeof(f), args...)

Return the primal computation value and a tape
"""
function augmented_primal end

"""
Takes gradient of derivative, activity annotation, and tape
"""
function reverse end

import Core.Compiler: argtypes_to_type
function has_frule(@nospecialize(TT), world=Base.get_world_counter())
    atype = Tuple{typeof(EnzymeRules.forward), Type{TT}, Type, Vector{Type}}
    res = ccall(:jl_gf_invoke_lookup, Any, (Any, UInt), atype, world) !== nothing
    return res
end

function has_rrule(@nospecialize(TT), world=Base.get_world_counter())
    atype = Tuple{typeof(EnzymeRules.reverse), Type{TT}, Type, Vector{Type}}
    res = ccall(:jl_gf_invoke_lookup, Any, (Any, UInt), atype, world) !== nothing
    return res
end

end
