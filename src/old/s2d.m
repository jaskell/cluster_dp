function s2d()
    filename = 'data/fig2_panelC.txt';
    st = load(filename);
    dt = st2dt(st);
    dt1 = st2dt1(st);
    err = max(max(abs(dt - dt1)));
    fprintf('err: %12.6f\n', err);
end

function distset = st2dt(shapeset)
    distvar = pdist(shapeset(:, 1:2), 'euclidean');
    distset = squareform(distvar);
end

function distset = st2dt1(shapeset)
    casenum = size(shapeset, 1);
    distset = zeros(casenum, casenum);
    colnum = size(shapeset, 2);
    if colnum > 2
        last = colnum-1
    else
        last = 2
    end
    for i = 1:casenum-1
        case1 = shapeset(i, 1:last);
        for j = 2:casenum
            case2 = shapeset(j, 1:last);
            dist = sqrt((case1 - case2) * (case1 - case2)');
            distset(i, j) = dist;
            distset(j, i) = dist;
        end
    end
end