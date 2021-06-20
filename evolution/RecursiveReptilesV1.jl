
function find_recur_parent(db, reptile)
    #returns the ID of the first reptile in a recursive family tree

    #initialize
    ID = reptile[1,:ID]
    recurparents = reptile[reptile[:classfromparents][1] .== "Recursive", :parents] #IDs of recusive parents

    while length(recurparents) == 1 #not empty tree
        
        if length(recurparents[1]) > 1 #check for multiple parents
            error("Multiple recursive parents.")
        end

        ID = recurparents[1][1] #store parent ID
        reptile = getrep(db, recurparents[1][1]) #update reptile to parent
        recurparents = reptile[reptile[:classfromparents][1] .== "Recursive", :parents]
    end
    
    return ID #length == 0  means no parents, first in tree
end

function recurcheck(db, reptile)
    #creates a recursive child of `reptile` and saves it in `db`

    #get new reptile
    newrotate, newreflect, newtranslate = recurreptile(db, reptile) 
    reptile[1,:childcheck][1] = true

    #save new reptile
    newID = savereptile(db, reptile[:n][1], length(newreflect), reptile[:ID][1], reptile[:sides][1],
        reptile[:angles][1], reptile[:points][1], newrotate, newreflect, newtranslate,
    ["Recursive"], reptile[:ID], fill(false, 6), NA, NA, "", "", false)

    #update original reptile
    push!(db[db[:ID] .== reptile[:ID],:][:childrensclass][1], "Recursive")
    push!(db[db[:ID] .== reptile[:ID],:][:children][1], newID)
    
    return newID
end     

function recurreptile(db, reptile)
    #replaces every tile with a smaller copy of the parent recursive reptile

    #init
    parent = getrep(db, find_recur_parent(db, reptile))
    mparent = parent[1,:m] #parent m
    mreptile = reptile[1,:m] #tile m
    mchild = mparent * mreptile
    newrotate = zeros(mchild)
    newreflect = fill(false, mchild)
    newtranslate = zeros(mchild,2)

    for i = 1:mreptile
        #new reptile values      
        s = (parent[1,:reflect] .- 0.5) / -0.5 #sign of rotation

        newrotate[(i-1)*mparent+1:i*mparent] = map(mod2pi, parent[1,:rotate] .+ s .* reptile[1,:rotate][i]) #sum of rotations
        newreflect[(i-1)*mparent+1:i*mparent] = map(x -> x $ reptile[1,:reflect][i], parent[1,:reflect]) #xor of reflections
        
        rot = [cos(reptile[1,:rotate][i]) sin(reptile[1,:rotate][i]);
            -sin(reptile[1,:rotate][i]) cos(reptile[1,:rotate][i])] #rotation matrix (transposed)  
        newtranslate[(i-1)*mparent+1:i*mparent,:] = parent[1,:translate] / sqrt(mreptile) * rot #rotate and scale to tile size

        if reptile[1,:reflect][i] == true
            newtranslate[(i-1)*mparent+1:i*mparent,1] *= -1 #reflect
        end

        newtranslate[(i-1)*mparent+1:i*mparent,:] .+= reptile[1,:translate][i,:] #translate

    end

    return newrotate, newreflect, newtranslate
end

function recurloop(db, reptile, mmax)
    #generates recursive reptiles until m > mmax
    
    for i = 1:floor(Int, log(reptile[1,:m], mmax)) - 1
        newID = recurcheck(db, reptile)
        reptile = getrep(db, newID)
    end
end
