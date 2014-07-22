function data = load_file(filename)
    srcdata = load(filename);
    num = size(srcdata, 1);
    data = zeros(num, num);
    for i = 1:num
        x1 = srcdata(i, 1);
        y1 = srcdata(i, 2);
        for j = 2:num-1
            x2 = srcdata(j, 1);
            y2 = srcdata(j, 2);
            dist = ((x1 - x2) ^ 2 + (y1 - y2) ^ 2) ^ 0.5;
            data(i, j) = dist;
            data(j, i) = dist;
        end
    end
end
