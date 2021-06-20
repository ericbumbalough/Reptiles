# Reptiles
## Definition
Rep-m-tiles are polygons that can be tiled with identical smaller copies of themselves.
![Rep-m-tiles examples](https://upload.wikimedia.org/wikipedia/commons/7/70/A_selection_of_rep-tiles.gif)
Examples from MagistraMundi, CC BY-SA 3.0 <https://creativecommons.org/licenses/by-sa/3.0>, via Wikimedia Commons
## Personal Narrative
After completing my line-based fractal project, I wanted to explore polygon based fractals such as Sierpinski's triangle. However, only very special polygons are reptiles and finding them can be difficult.

This project was abandoned when I relocated to Indiana.
## Code Overview
This project is partially Jupyter notebooks and partially raw Julia files because it spans the transition of the "official" IDE of Julia from Jupyter to Atom.

### Discovery
Discover new fundamental reptiles that cannot be generated as children of other reptieles.

The completed codes create matricies that describe a valid combination of sides or angles and solves them to find the angle and side values. Custom data types were implemented to give exact solutions because angle and side measurements are guaranteed to have a single possible form built from rational numbers.

The next step would have been a algorithm to attempt to build a reptile from the valid side and angle combinations.

I'm not sure if the solution started here would have been practically computable. I wasn't able to put a tight upper bound on the number of possible angle and side combniations.
#### [matrixgen.jl](https://github.com/ericbumbalough/Reptiles/blob/master/discovery/matrixgen.jl)
Build iterators for matricies describing possible side or angle combinations. Matricies are built in pieces and combined with iterator functions.
#### [matrixsol.jl](https://github.com/ericbumbalough/Reptiles/blob/master/discovery/matrixsol.jl)
Build system of linear equations from matricies and solve them.
#### [reptileutils.jl](https://github.com/ericbumbalough/Reptiles/blob/master/discovery/reptileutils.jl)
Contains custom datatypes for sides and angles and elementary functions for these types. 

### Evolution
Given a parent reptile, generate new child reptiles.

#### [Expansion Reptile Generation V0.ipynb](https://github.com/ericbumbalough/Reptiles/blob/master/evolution/Expansion%20Reptile%20Generation%20V0.ipynb)
Generate simple rectangular and triangular reptiles.

#### [Recurive Reptiles V1.ipynb](https://github.com/ericbumbalough/Reptiles/blob/master/evolution/Recursive%20Reptiles%20V1.ipynb)
Replace each polygon in the reptile with the original reptile.

#### [Reflected Reptiles V0.ipynb](https://github.com/ericbumbalough/Reptiles/blob/master/evolution/Reflected%20Reptiles%20V0.ipynb)
Generate a new child reptile by reflecting the parent over its own side.
