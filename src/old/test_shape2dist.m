cd(fileparts(mfilename('fullpath')));
filename = 'data/jain.txt';
filename = 'data/spiral.txt';
filename = 'data/flame.txt';
filename = 'data/Aggregation.txt';
filename = 'data/fig2_panelB.txt';
%filename = 'data/fig2_panelC.txt';
%filename = 'data/example.txt';
inputfile = filename;
[pathstr,name,ext] = fileparts(filename);
outputfile = strcat('data/', name, '.dat');
shape2dist(inputfile, outputfile);
