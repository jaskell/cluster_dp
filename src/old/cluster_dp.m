function cluster_dp(filename, percent)
    shapeset = load(filename);
    %shapeset = shapeset .* 100;
    %xmin = min(shapeset(:, 1));
    %ymin = min(shapeset(:, 2));
    %shapeset(:, 1) = shapeset(:, 1) + xmin + 1;
    %shapeset(:, 2) = shapeset(:, 2) + ymin + 2;
    showShapeSet(shapeset);
    distset = shapeset2distset(shapeset);
    dc = computeDc(distset, percent);
    %dc = 0.048;
    fprintf('average percentage of neighbours (hard coded): %5.6f\n', percent);
    fprintf('Computing Rho with gaussian kernel of radius: %12.6f\n', dc);
    rhos = getLocalDensity(distset, dc);
    
    %rho_delta = load('vc/rho_delta.txt');
    %rhos = rho_delta(:, 1)';
    [deltas, nneigh] = getDistanceToHigherDensity(distset, rhos);
    %deltas = rho_delta(:, 2)';
    
    showDeltas(rhos, deltas);
    [min_rho, min_delta] = selectRect();
    filter = (rhos > min_rho) & (deltas > min_delta);
    cluster_num = sum(filter);
    fprintf('rho: %f, delta: %f, number of clusters: %i \n', min_rho, min_delta, cluster_num);
    ords = find(filter);
    cluster = zeros(size(rhos));
    color = 1;
    for i = 1:size(ords, 2)
        cluster(ords(i)) = color;
        color = color + 1;
    end
    [sorted_rhos, rords] = sort(rhos, 'descend');
    for i = 1:size(rords, 2)
        if cluster(rords(i)) == 0
            neigh_cluster = cluster(nneigh(rords(i)));
            assert(neigh_cluster ~= 0, 'neigh_cluster has not assign!');
            cluster(rords(i)) = neigh_cluster;
        end
    end
    showColorShape(shapeset, cluster, cluster_num, ords);
end

function [min_rho, min_delta] = selectRect()
    subplot(2,2,2);
    rect = getrect;
    fprintf('rect(x:%i y:%i width:%i height:%i)\n', rect(1), rect(2), rect(3), rect(4));
    min_rho   = rect(1);
    min_delta = rect(2);
end

function showColorShape(shapeset, cluster, cluster_num, ords)
    subplot(2,2,3); 
    hold on;    
    cmap = colormap;
    for i = 0:cluster_num
        filter = (cluster == i);
        x = shapeset(:, 1)';
        y = shapeset(:, 2)';
        xx = x(filter);
        yy = y(filter);
        ic = int8(i * 32.0 / cluster_num) + 1;
        fprintf('i: %d, cluster_element: %d\n', i, size(xx, 2));
        tt=plot(xx, yy, 'o', 'MarkerSize', 3, 'MarkerFaceColor', cmap(ic,:), 'MarkerEdgeColor', cmap(ic,:));
    end
    for i = 1:size(ords, 2)
        color = cluster(ords(i));
        x = shapeset(ords(i), 1);
        y = shapeset(ords(i), 2);
        ic = int8(color * 64.0 / cluster_num);
        tt=plot([x], [y], 'o', 'MarkerSize', 10, 'MarkerFaceColor', cmap(ic,:), 'MarkerEdgeColor', cmap(ic,:));
    end    
    text = strcat('ColorShape: ', num2str(cluster_num));
    title (text, 'FontSize', 15.0);
    xlabel ('x');
    ylabel ('y');    
end

function showShapeSet(shapeset)
    scrsz = get(0,'ScreenSize');
    figure('Position', [6 72 scrsz(3)/2. scrsz(4)/1.3]);
    subplot(2,2,1); 
    tt = plot(shapeset(:, 1), shapeset(:, 2), 'o', 'MarkerSize', 3, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
    text = 'LoadShape';
    title (text, 'FontSize', 15.0);
    xlabel ('x');
    ylabel ('y');       
end

function showDeltas(rhos, deltas)
    subplot(2,2,2);
    tt = plot(rhos(:), deltas(:), 'o', 'MarkerSize', 3, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
    text = strcat('max rho: ', num2str(max(rhos)), ', delta: ', num2str(max(deltas)));
    title (text, 'FontSize', 15.0);
    xlabel ('rho');
    ylabel ('delta');
end
