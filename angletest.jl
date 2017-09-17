function angletest(n, m)
  j=0
  for i in anglemat(n,m)
    mat, rank = solvemat(i, m, true)
    if rank <= n
      #@show i
      #@show rank
      #@show mat
    end
    j+=1
  end
  return j
end

function sidetest(n, m)
  j=0
  for i::Array{Int64,2} in sidemat(n,m)
    #@show i
    mat::Array{Side, 2}, rank::Int64 = solvemat(i, m, false)
    #@show typeof(mat)
    if rank <= n
      #@show i
      #@show rank
      #@show mat[:,end]
      j+=1
    end

  end
  return j
end

function bigtest(n)
  for i in 5:n
    @show i
    @show sidetest(i,i)
    @show angletest(i,i)
  end
end
