cd(fileparts(mfilename('fullpath')));
clear all;
filename = 'data/example_distances.dat';
data = load(filename);
%data = [ randi([1,100],10,2), normrnd(0, 100,10,1) ];
distset = dat2distset(data);
%disp(distset);
