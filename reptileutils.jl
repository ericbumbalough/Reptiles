## Angle type definition and elementary functions
type Angle
  #type for angles. of form o + p * pi where p is rational
  o::Rational{Int64}
  p::Rational{Int64}
end

Base.show(io::IO, a::Angle) = print(io, a.o, "+", a.p, "π")

function Base.:+(a::Angle, b::Angle)
  return Angle(a.o + b.o, a.p + b.p)
end

function Base.:-(a::Angle)
  return Angle(-a.o, -a.p)
end

function Base.:-(a::Angle, b::Angle)
  return a + -b
end

function Base.:*(a::Angle, b::Angle)
  if a.p == 0//1 || b.p == 0//1 #only one nonzero pi coefficient => closed under multiplication
    return Angle(a.o * b.o, (a.o * b.p + b.o * a.p)) #pi^2 squared coefficient (a.p*b.p) is always zero
  end
  error("Cannot multiply. Must have at least one zero p term for type stability")
end

function Base.:*(a::Angle, b::Rational)
  return Angle(a.o * b, a.p * b)
end

function Base.:*(a::Rational, b::Angle)
  return b*a
end

function Base.:*(a::Array{Angle,1}, b::Angle)
  return b.*a
end

function Base.:*(a::Angle, b::Array{Angle,1})
  return b*a
end

function Base.:/(a::Angle, b::Angle)
  if b.p == 0//1 #invertable
    return Angle(a.o / b.o, a.p / b.o)
  end
  if a.o == 0//1 && b.o == 0//1 #pi terms will cancel
    return Angle(a.p / b.p, 0//1)
  end
  warn("Answer not expressible as angle data typel.")
  return (a.o + a.p * pi)/(b.o + b.p * pi)
end

function Base.:/(a::Array{Angle,1}, b::Angle)
  return a ./ b
end

function Base.:/(a::Int, b::Angle)
  return Angle(a//1, 0//1)/b
end

function Base.inv(a::Angle)
  return 1/a
end

function Base.zero(::Type{Angle})
  return Angle(zero(Rational), zero(Rational))
end

function Base.zero(a::Angle)
  return zero(Angle)
end

function Base.one(::Type{Angle})
  return Angle(one(Rational), zero(Rational))
end

import Base.== #the other syntax was throwing errors
==(a::Angle, b::Angle) = a.o == b.o && a.p == b.p
==(a::Angle, n:: Int) = a.o == n && a.p == 0

function Base.transpose(a::Angle)
  return a
end

function Base.norm(a::Angle)
  return norm(a.o + a.p * pi)
end

function Base.convert(::Type{Angle}, a::Int)
  return Angle(a//1, 0//1)
end

## Side type definition and elementary functions
type Side
  #type for sides. of form q + r *sqrt(m)
  q::Rational{Int64}
  r::Rational{Int64}
  m::Int

  function Side(q, r, m)
    if !isnull(m) && issquare(m) != 0 #m is square
      new(q + r * issquare(m), 0//1, m) #simplify to rational
    else
      new(q, r, m)
    end
  end
end

Base.show(io::IO, a::Side) = print(io, a.q, "+", a.r, "√", a.m)

function issquare(m)
  #returns if m is a perfect square. m will always be small and > 2
  #returns 0 if not square and the square root if square
  i = 2 #m is always greater than 2
  while i^2 <= m
    if i^2 == m
      return i
    end
    i += 1
  end
  return 0
end

function mfix(a::Side, b::Side)
  #checks if the value for m is null
  if isnull(a.m)
    if isnull(b.m)
      error("No non-null values for m.")
    else
      a.m = b.m
    end
  else
    if isnull(b.m)
      b.m = a.m
    end
  end
    return a, b
end

function Base.:+(a::Side, b::Side)
  #could add error check if m is the same
  a, b = mfix(a, b)
  return Side(a.q + b.q, a.r + b.r, a.m)
end

function Base.:-(a::Side)
  return Side(-a.q, -a.r, a.m)
end

function Base.:-(a::Side, b::Side)
  return a + -b
end

function Base.:*(a::Side, b::Rational)
  return Side(a.q * b, a.r * b, a.m)
end

function Base.:*(a::Rational, b::Side)
  return b*a
end

function Base.:*(a::Side, b::Side)
  a, b = mfix(a, b)
  return Side(a.q * b.q + a.r * b.r * a.m, a.r * b.q + a.q * b.r, a.m)
end

function Base.:*(a::Array{Side,2}, b::Side)
  return a .* b
end

function Base.:/(a::Side, b::Side)
  a, b = mfix(a, b)
  return Side((a.q*b.q-a.r*b.r*a.m)/(b.q^2-a.m*b.r^2),
   -(a.q*b.r-a.r*b.q)/(b.q^2-a.m*b.r^2), a.m) #never divides by zero because m cannot be square
end

function Base.:/(a::Int, b::Side)
  return Side(a//1, 0, b.m) / b
end

function Base.:/(a::Array{Side,1}, b::Side)
  return a ./ b
end

function Base.isless(a::Side, b::Side)
  a, b = mfix(a, b)
  return (a.q + a.r * sqrt(a.m)) < (b.q + b.r * sqrt(b.m))
end

function Base.inv(a::Side)
  return 1/a
end

import Base.== #the other syntax was throwing errors
==(a::Side, b::Side) = a.q == b.q &&  a.r == b.r #does not check for m equality
==(a::Side, b::Int) = a.q == b && a.r == 0//1

function Base.convert(::Type{Side}, a::Int, m)
  return Side(a//1, 0//1, m)
end

function Base.convert(::Float64, a::Side)
  return (a.p + a.r * a.m)::Float64
end

function Base.convert(::Type{Array{Side,2}}, a::Array{Int64,2}, m::Int64)
  output = zeros(Side, size(a), mvalue=m)
  for i in 1:length(a)
    output[i] = convert(Side, a[i], m)
  end
  return output
end

function Base.zero(::Type{Side})
  return Side(zero(Rational), zero(Rational), Nullable{Int}())
end

function Base.zero(::Type{Side}, m::Int)
  return Side(zero(Rational), zero(Rational), m)
end

function Base.zero(a::Side)
  return zero(Side)
end

function Base.zeros(::Type{Side}, size; mvalue::Int=Nullable{Int64})
  return repmat([zero(Side, mvalue)], size...)
end

function Base.zeros(a::Array{Side})
  return zeros(Side, size(a), mvalue=findm(a))
  error("All m-values in matrix null.")
end

function Base.one(::Type{Side})
  return Side(one(Rational), zero(Rational), Nullable{Int}())
end

function Base.one(::Type{Side}, m::Int)
  return Side(one(Rational), zero(Rational), m)
end

function Base.transpose(a::Side)
  return a
end

function Base.norm(a::Side)
  return a.q + a.r * sqrt(a.m)
end

function findm(a::Array{Side})
 #finds the first non-null value for m in the matrix
  for i in a
    if !isnull(i.m)
      return i.m
    end
  end
end

function sideeye(::Type{Side}, n, m)
  #returns nxn identity matrix of size with m
  output = zeros(Side, (n,n), mvalue=m)
  for i in 1:n
    output[i,i] = one(Side, m)
  end
  return output
end

## rref
function rref(mat)
  #returns modified reduced row eschelon form of mat
  #probably could be improved further
  j, k = size(mat)
  for i in 1:min(j,k) #loop through rows
    if mat[i,:] != zeros(mat[i,:]) #non zero row.
      pivotind = findfirst(mat[i,:])
      mat[i,:] /= mat[i,pivotind] #normalize leading element
      minus = repmat(mat[i,:]', j, 1) #base to zero the other rows
      minus .*= mat[:,pivotind] #scale to zero elements below pivot
      minus[i,:] = zeros(minus[i,:]) #zero pivot row to avoid cancelling it
      mat -= minus
    end
  end
  return rrefsort(mat)

end

function rrefsort(mat)
  #sorts rows to their aligned pivot location
  output = zeros(mat) #storage for output
  j, k = size(mat)
  for i in 1:min(j, k) #loop through each row
   if mat[i,:] != zeros(mat[i,:]) #non zero row.
    output[findfirst(mat[i,:]),:] = mat[i,:]
   end
  end
  return output
end
