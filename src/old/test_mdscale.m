cd(fileparts(mfilename('fullpath')));
clear all;
filename = 'data/example_distances.dat';
d = load(filename);
e = squareform(d);
[f, g] = cmdscale(e);
h = pdist(f, 'euclidean');
err1 = max(max(h - e));
fprintf('err1: %12.6f\n', err1);