function distset = dat2distset(data)
    ND = max(data(:, 2));
    NL = max(data(:, 1));
    if (NL > ND)
        ND=NL;
    end
    N = size(data, 1);
    %distset = zeros(ND, ND);
    for i=1:ND
        for j=1:ND
            distset(i,j)=0;
        end
    end    
    for i = 1:N
        x = data(i,1);
        y = data(i,2);
        dist = data(i, 3);
        distset(x, y) = dist;
        distset(y, x) = dist;
    end
end

