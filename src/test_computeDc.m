distset = [0 1 2 3 4; 1 0 5 6 7; 2 5 0 8 9; 3 6 8 0 10; 4 7 9 10 0];
percent = 30.0;
fprintf('average percentage of neighbours (hard coded): %5.6f\n', percent);
dc = computeDc(distset, percent);
fprintf('Computing Rho with gaussian kernel of radius: %12.6f\n', dc);
