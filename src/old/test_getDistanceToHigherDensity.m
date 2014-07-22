distset = [0 1 2 3 4; 1 0 5 6 7; 2 5 0 8 9; 3 6 8 0 10; 4 7 9 10 0]
rhos = [1.0 2.0 1.5 2.5 3.0]
[deltas, nneigh] = getDistanceToHigherDensity(distset, rhos)
