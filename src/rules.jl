module EnzymeRules

import ..Enzyme
import Enzyme: Const, Active, Duplicated, DuplicatedNoNeed

function has_rule end

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

f(x) = x^2

EnzymeRules.forward(::typeof(f), ::Type{Duplicated{T}}, x::Duplicated{T}) where {T} = Duplicated(f(x.val), 2*x.val*x.dval)

EnzymeRules.augmented_primal(::typeof(f), ::Type{Active{T}}, x::Active{T}) where {T} = (Active(f(x.val)), nothing)
EnzymeRules.augmented_primal(::typeof(f), ::Type{Const{T}}, x::Const{T}) where {T} = (Const(f(x.val)), nothing)

EnzymeRules.reverse(::typeof(f), ::Type{Active{T}}, x::Active{T}, dret::T, tape) where {T} = (2*x.val*dret,)
EnzymeRules.reverse(::typeof(f), ::Type{Const{T}}, x::Const{T}, tape) where {T} = ()

g(x, y) = x * y

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
