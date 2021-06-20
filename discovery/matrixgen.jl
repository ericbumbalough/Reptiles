using IterTools
using Combinatorics

## Tools: functions for multiple iterators
function comb2col(comb, n)
  #given a possible combination of 1:n, returns a matrix with 1 at the choosen values
  temp = zeros(Int, n, 1)
  temp[comb] = 1
  return temp
end

function matcheck(mat, m)
  #returns false if any row of the matrix is zero or any row or column has a sum greater than m
  a = sum(mat, 2) #sum of each row
  if minimum(a) == 0 #zero row
    return false
  end
  if maximum(a) > m #row with sum over m
    return false
  end
  if maximum(sum(mat,1)) > m #col with a sum over m
    return false
  end
  return true
end

## Angle matrix 1st row
function acol1(n)
  #returns an iterator for the first (straight edge) column of the angle matrix
  iter = [zeros(Int, n, 1)] #first element
  for i = 1:n-3 #loop through number of angles containing edge
    comb = combinations(1:n-3, i) #combinations 1:n, choose i
    temp = imap(x->comb2col(x .+ 3, n), comb) #convert to 1s and 0s. the .+3 shifts the combination to ensure that the first 3 elements are zero
    iter = chain(iter, temp) #build the chain
  end
  return iter
end

## Angle matrix top half
function rowpadzeros(comb, k, numzeros)
  #returns the combination with 1 at the choosen values, then padded with zeros
  rowbase = comb2col(comb, k)' #non-zero part of the rowbase. transposed to make a row
  return [zeros(Int, 1, numzeros) rowbase]
end

function aupperrow(n, k)
  #returns the iterator for a angle matrix row with total lenth n.
  #the first n-k elements are always zero
  iter1 = [zeros(Int, 1, n)] #first element
  comb = combinations(1:k, 1) #choose one of the last n-k rows
  iter = imap(x->rowpadzeros(x, k, n-k), comb)
  return chain(iter1, iter)
end

function aupper(n)
  #returns an iterator for the upper triangular half of the angle matrix
  allrows = (aupperrow(n, n-i+1) for i in 1:n) #each row
  a = product(allrows...)
  b = imap(x -> vcat(x...), a)
  return b
end

## Angle matrix bottom half
immutable AngRowGen
  #generates the possible row with sum less than m
  n::Int #total row length
  m::Int #row maximum sum
  l::Int #non-zero row length
end

function Base.start(a::AngRowGen)
  row = zeros(Int, 1, a.n)
  row[1] = -1 #so the first iteration gives all zeros
  return row
end

function Base.next(a::AngRowGen, row)
  for i in 1:a.l #iterate through element, starting with first non-zero element
    if sum(row) < a.m #still room in the raw
      row[i] += 1 #increment and return
      return row, row
    else #no room
      row[i] = 0
    end
  end
  return row, row
end

function Base.done(a::AngRowGen, row)
  return row[a.l] == a.m
end

function alower(n, m)
  #returns an iterator for the upper triangular half of the angle matrix
  allrows = (AngRowGen(n, m, i) for i in 1:n-1)
  a = product(allrows...)
  b = imap(x->vcat(zeros(Int, 1, n), x...), a) #build matrix with zero row on top
  return chain([zeros(Int, n, n)], b) #because product is removing the all zero option
end

## Build anlge matrix
function anglemat(n, m)
  #returns an iterator of the possible angle matrices
  a = product(aupper(n), alower(n, m)) #all upper and lower half combinations
  b = imap(x->x[1] + x[2], a) #add upper and lower half
  c = Iterators.filter(x->matcheck(x, m), b) #filter out zero rows and rows and columns summing over m
  d = product(acol1(n), c) #combine first column and rest of matrix
  f = imap(x->hcat(x...), d)
  return f
end

## Side matrix row
immutable SideRowGen
  #generates the possible row with sum less than m
  n::Int #total row length
  m::Int #row maximum sum
  l::Int #sum of elements from l to end is less than floor(Int, sqrt(m))
end

function Base.start(d::SideRowGen)
  row = zeros(Int, 1, d.n)
  return row
end

function Base.next(d::SideRowGen, row)
  flsqm = floor(Int, sqrt(d.m))
  for i in 1:d.n #iterate through each element
    #(still room in the row) and (element is in beginning of or there is room at the end)
    if (sum(row) < d.m) && ((i < d.l) || sum(row[d.l:end]) < flsqm)
      row[i] += 1
      return row, row
    else #no room
      row[i] = 0
    end
  end
  return row, row
end

function Base.done(d::SideRowGen, row)
  flsqm = floor(Int, sqrt(d.m))
  if row[end] == flsqm #last element at max
    if d.l == 1 #avoid looking for zero index
      return row[end] == flsqm #last unconstrained value + last value
    else
      return row[d.l-1] + row[end] == d.m #last unconstrained value + last value
    end
  end
  return false
end

## Build side matrix
function sidemat(n, m)
  #returns an iterator of the possible side matricies

  ###### correct version. unexpected behavior in product is skipping the first value
  #allrows = (SideRowGen(n, m, i) for i in 1:n) #build all row iterators
  #a = product(allrows...) #combine all row iterators
  ###### end correct version

  ###### begin workaround
  allrows = (SideRowGen(n, m, i) for i in 2:n) #build all row iterators
  firstrow = ([zeros(Int, 1, i) 1 zeros(Int, 1, n-i-1)] for i = 0:n-1)
  a = product(firstrow, allrows...) #combine all row iterators
  ###### end workaround

  b = imap(x->vcat(x...),a)
  c = Iterators.filter(x->matcheck(x,m), b) ##filter out zero rows and rows and columns summing over m
  #(zero rows are impossible, this could be sped up)
  return c
end
