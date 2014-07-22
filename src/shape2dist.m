function shape2dist(inputfile, outputfile)
    shapeset = load(inputfile);
    distset = shapeset2distset(shapeset);
    casenum = size(distset, 1);
    filter = logical(triu(ones(casenum, casenum),1)); % 得到上三角布尔矩阵
    distset(filter) = 0;
    [r, c, v] = find(distset);
    fp = fopen(outputfile, 'w');
    assert(fp ~= -1, 'Can not open output file!');
    for i = 1:size(r)
        fprintf(fp, '%d %d %12.6f\n', r(i), c(i), v(i));
    end
    fclose(fp);
end