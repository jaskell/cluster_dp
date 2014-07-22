cd(fileparts(mfilename('fullpath')));
filename = 'rho_delta.txt';
rho_delta = load(filename);
figure;
scatter(rho_delta(:, 1), rho_delta(:, 2), 'r');
grid on;