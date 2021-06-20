include("matrixgen.jl")
include("reptileutils.jl")

## Tools: functions for angles and sides
function findconstraints(A1, B1, n, digits = 12)
  #OBSOLTETE
  #returns a vector with ones in the locations where additional constraints would  fully constrain the system

  l = size(A)[2] #number of columns in A
  output = zeros(n)
  i = 0 #loop counter
  r = rank([A B])
  while r < n && i < n #underconstrained and not out of variables
    i += 1 #increment
    c = zeros(1, l) #new row
    c[i] = 1 #add constraint x_i = 0
    r1 = rank([A B; c 0]) #rank with new constraint x_i = 0
    if r == r1 #nothing changed
      continue #try next variable
    else #rank has increased. rank decrease should be impossible
      if size(A)[1] == l #sqaure. could be singular
        X = [A; zeros(1, l)] \ [B; 0.0] #add an empty row to trick the algorithm out of square matrix, and solve
      else
        X = A \ B #solve
      end
      if floateq(A * X, B, digits) == false #solution failed
        continue #try next variable
      end
      #new constraint is valid
      A = [A; c] #add new constraint
      B = [B; 0]
      r = rank([A B])
      output[i] = 1.0 #save this as a good constraint
    end
  end
  return output #return good constraints, or all zeros if it cannot be constrained
end

function buildanglesys(matint)
  #returns A and B of the equation AX=B for the given angle matrix
  mat = convert(Array{Angle, 2}, matint) #convert
  n = size(mat)[1]
  a = mat[:,2:end] - eye(Angle, n, n) #move lhs over
  A = [a; ones(Angle, 1, n)] # sum(theta) = pi*(n-2) constraint
  B = [-mat[:,1] * Angle(0//1, 1//1); Angle(0//1, 1//1) * (n-2)//1] #straight angle conditions; pi*(n-2 constraint)
  return A, B, n
end

function buildsidesys(matint::Array{Int, 2}, m::Int)
  #returns A and B of the equation AX=B for the given side matrix with s1 = 1
  mat = convert(Array{Side, 2}, matint, m)
  n = size(mat)[1]
  a = mat - sideeye(Side, n, m) * Side(0//1, 1//1, m)
  A = [one(Side, m) zeros(Side, (1, n-1), mvalue = m)
    zeros(Side, (n, 1), mvalue = m) a[:, 2:end]]::Array{Side, 2} #with fake first row and col forcing s1=1
  B = [one(Side, m); -a[:, 1]] #with fake first row forcing s1=1
  return A, B, n
end

function isvalidsol(angles::Array{Angle,1})
    #checks if the `angles` vector of polygon angles are valid
    #only checking the p-component since that should be all that is possible

  for i in angles
    if i.p <= 0//1 #negative angles (can't be changed because the system has no d.o.f.)
        return false
    end
    if i.p >= 2//1 #angle over 2pi (can't be changed because the system has no d.o.f.)
        return false
    end
    if i.p == 1//1 #there is a straight angle
        return false
    end
  end

  return true #all tests pass
end

function isvalidsol(sides::Array{Side,1})
    #tests whether the vector of side lengths `s` are valid
    m = findm(sides)

    if minimum(sides) <= zero(Side, m) #minimum individual side lenth
        return false
    end
    #longest side is more than the sum of the other sides (s1 is length 1)
    if 2//1 * maximum(sides) >= sum(sides)  #max side >= all sides - max side
        return false
    end
    return true #all test pass
end

function solvemat(mat, m::Int, isangle::Bool)
  #solves the given angle matrix if possible
  #returns rref form of the solution matrix
  #returns marix of zeros and rank = n+1 if there is no solution
  #returns rank as 2nd argument

  if isangle #angle matrix
    A, B, n = buildanglesys(mat) #matrices for A*X=B
  else #side matrix
    A, B, n = buildsidesys(mat, m) #matrices for A*X=B
  end

  rrefmat = rref([A B]) #row reduce

  if isangle
    rank = countnz(sum(rrefmat, 2)) #rank of matrix
  else #side
    #ifferent because of special side zero functions
    rank = countnz(sum(rrefmat .!= zero(Side, m), 2)) #rank of matrix
  end



  if rank < n #underconstrained.
    return rrefmat[1:n, :], rank
  end

  if rank == n #fully constrained
    if isvalidsol(rrefmat[1:n,end]) #last column is solutions
      return rrefmat[1:n, :], rank
    end
  end

  return zeros(rrefmat[1:n, :]), n+1 #overconstrained or invalid solutions
end
