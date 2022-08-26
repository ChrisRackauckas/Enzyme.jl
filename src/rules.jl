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

f(x) = x^2

function fip(x)
   x[1] *= x[1]
   return nothing
end

g(x, y) = x * y

function EnzymeRules.forward(::Type{Tuple{typeof(f), Float64}}, RT, Args)
    @assert Args[1] <: Const
    if RT <: DuplicatedNoNeed && Args[2] <: Duplicated
        tmp1(func, x) = 10+2*x.val*x.dval
        return tmp1
    end
    if RT <: Enzyme.BatchDuplicatedNoNeed && Args[2] <: Enzyme.BatchDuplicated
        function tmp1b(func, x)
            @show x
            flush(stdout)
            @show Base.pointer_from_objref(x)
            flush(stdout)
            # @show x.dval
            # flush(stdout)
            @show x.val
            flush(stdout)
            throw(AssertionError("WAt"))
            r = tuple(1000+2*x.val*dv for dv in x.dval)
            @show r
            return r
        end
        return tmp1b
    end
    if RT <: Duplicated && Args[2] <: Duplicated
        tmp2(func, x) = Enzyme.Duplicated(func.val(x.val), 100+2*x.val*x.dval)
        return tmp2
    end
    return nothing
end

function EnzymeRules.forward(::Type{Tuple{typeof(fip), T}}, RT, Args) where {T}
    @show Args, RT
    @assert Args[1] <: Const
    @assert RT <: Const
    if Args[2] <: Duplicated
        function tmp1(func, x)
            ld = x.val[1]
            x.val[1] *= ld
            x.dval[1] *= 2 * ld + 10
            nothing
        end
        return tmp1
    end
    return nothing
end

EnzymeRules.augmented_primal(::typeof(f), ::Type{Active{T}}, x::Active{T}) where {T} = (Active(f(x.val)), nothing)
EnzymeRules.augmented_primal(::typeof(f), ::Type{Const{T}}, x::Const{T}) where {T} = (Const(f(x.val)), nothing)

EnzymeRules.reverse(::typeof(f), ::Type{Active{T}}, x::Active{T}, dret::T, tape) where {T} = (2*x.val*dret,)
EnzymeRules.reverse(::typeof(f), ::Type{Const{T}}, x::Const{T}, tape) where {T} = ()


EnzymeRules.forward(::typeof(g), ::Type{Duplicated{T}}, x::Duplicated{T}, y::Duplicated{T}) where {T} = Duplicated(g(x.val, y.val), x.val*y.dval+y.val*x.dval)

EnzymeRules.augmented_primal(::typeof(g), ::Type{Active{T}}, x, y) where {T} = (Active(g(x.val, y.val)), nothing)

EnzymeRules.reverse(::typeof(g), ::Type{Active{T}}, x::Active{T}, y::Active{T}, dret::T, tape) where {T} = (y*dret,x*dret)
EnzymeRules.reverse(::typeof(g), ::Type{Active{T}}, x::Active{T}, y::Const{T}, dret::T, tape) where {T} = (y*dret,)
EnzymeRules.reverse(::typeof(g), ::Type{Active{T}}, x::Const{T}, y::Active{T}, dret::T, tape) where {T} = (x*dret,)

# TODO:
# - Duplicated?
# - NoTangent() vs nothing
# - Combinatorial explosion
# - activity dispatch doesn't quite work yet

end
