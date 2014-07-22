function dc = computeDc(distset, percent)
    casenum = size(distset, 1);
    filter = logical(triu(ones(casenum, casenum),1)); % 得到上三角布尔矩阵
    crossnum = sum(sum(filter));
    pos = round(crossnum * percent / 100);
    sda = sort(distset(filter)); % 取对称矩阵distset的上三角数据进行排序
    dc = sda(pos);
end
