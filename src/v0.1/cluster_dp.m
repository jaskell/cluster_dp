function cluster_dp(filename)
    %xydist = read_xydist(filename, 1000);
    xydist = load(filename);
    data   = xydist_to_matrix(xydist);
    dc     = getDc(data, 1.5, 2.0);
    rhos   = getLocalDensity(data, dc);
    deltas = getDistanceToHigherDensity(data, rhos);
    save rhos_deltas.mat rhos deltas;
    showFigure(rhos, deltas);
end

function xydata = read_xydist(filename, readnum)
    xydata = dlmread(filename, ' ', [0 0 readnum-1 2]);
end

function showFigure(rhos, deltas)
    scrsz = get(0,'ScreenSize');
    figure('Position', [6 72 scrsz(3)/4. scrsz(4)/1.3]);
    subplot(2,1,1);
    tt=plot(rhos(:), deltas(:), 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
    title ('Decision Graph','FontSize',15.0);
    xlabel ('\rho');
    ylabel ('\delta');
end

function [dc] = getDc(data, lowpercent, highpercent)
    num  = nnz(data) / 2;
    low  = lowpercent / 100. * num;
    high = highpercent / 100. * num;
    dc   = min(nonzeros(data)) + 0.001;
    step = dc / 10.0;
    dc   = hasNeighbors(data, low, high, dc, step);
end

function [dc] = hasNeighbors(data, low, high, dc, step)
    i = 1;
    n = size(data, 1);
    while i < n
        neighbors = full(sum(data(i, :) <= dc));
        if neighbors > high || neighbors < low
            fprintf('i: %d, neighbors: %f, dc: %f\n', i, neighbors, dc);
            dc = dc + step;
            i = 1;
            continue;
        end
        i = i + 1;
    end
end

function [deltas] = getDistanceToHigherDensity(data, rhos)
    max_rho = max(rhos);
    deltas = zeros(size(rhos));
    for i = 1:size(rhos, 2)
        disti = data(i, :);
        if rhos(i) == max_rho
            deltas(i) = max(disti);
        else
            deltas(i) = min(disti(rhos > rhos(i)));
        end
    end
end

function [rhos] = getLocalDensity(data, dc)
    marks = (data < dc) & (data > 0);
    rhos = sum(marks, 1);
end

function [data] = xydist_to_matrix(xydist)
    n = max(max(xydist(:, 1)), max(xydist(:, 2)));
    data = sparse(n, n);
    numSamples = size(xydist, 1);
    for i = 1:numSamples
        x = xydist(i, 1);
        y = xydist(i, 2);
        dist = xydist(i, 3);
        data(x, y) = dist;
        data(y, x) = dist;
    end
end
