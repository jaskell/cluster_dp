function fast_cluster_dp(filename)
    srcdata = load(filename);
    %showSrcData(srcdata);
    dists = src2dists(srcdata);
    dc = getDc(dists, 2.0);
    rhos = getLocalDensity(dists, dc);    
    deltas = getDistanceToHigherDensity(dists, rhos);
    %save rhos_deltas.mat rhos deltas;
    showFigure(rhos, deltas);    
subplot(2,1,1)
rect = getrect(1);
rhomin=rect(1);
deltamin=rect(4);
NCLUST=0;
ND = size(dists, 1);
for i=1:ND
  cl(i)=-1;
end
for i=1:ND
  if ( (rhos(i)>rhomin) && (deltas(i)>deltamin))
     NCLUST=NCLUST+1;
     cl(i)=NCLUST;
     icl(NCLUST)=i;
  end
end
fprintf('NUMBER OF CLUSTERS: %i \n', NCLUST);
disp('Performing assignation')    
end

function dists = src2dists(srcdata)
    num = size(srcdata, 1);
    dists = zeros(num, num);
    for i = 1:num
        dot1 = srcdata(i, 1:end-1);
        for j = 2:num-1
            dot2 = srcdata(j, 1:end-1);
            dist = sqrt((dot1-dot2)*(dot1-dot2)');
            dists(i, j) = dist;
            dists(j, i) = dist;
        end
    end
end

function dc = getDc(dists, percent)
    fprintf('average percentage of neighbours (hard coded): %5.6f\n', percent);
    num = size(dists, 1);
    pos = round(num * percent / 100);
    filter = logical(triu(ones(num, num),1)); % filter = triu(ones(num, num) == 1,1);
    sda = sort(dists(filter));
    dc=sda(pos);
    fprintf('Computing Rho with gaussian kernel of radius: %12.6f\n', dc);
end

function rhos = getLocalDensity1(dists, dc)
    marks = (dists < dc) & (dists > 0);
    rhos = sum(marks, 1);
end

function rhos = getLocalDensity(dists, dc)
    num = size(dists, 1);
    rhos = zeros(1, num);
    % Gaussian kernel
    for i = 1:num-1
        for j = i+1:num
            gk = exp(-(dists(i,j) / dc) * (dists(i,j) / dc));
            rhos(i) = rhos(i) + gk;
            rhos(j) = rhos(j) + gk;
        end
    end
end

function deltas = getDistanceToHigherDensity(dists, rhos)
    max_rho = max(rhos);
    deltas = zeros(size(rhos));
    for i = 1:size(rhos, 2)
        disti = dists(i, :);
        if rhos(i) == max_rho
            deltas(i) = max(disti);
        else
            deltas(i) = min(disti(rhos > rhos(i)));
        end
    end
end

function showSrcData(srcdata)
    x = srcdata(:, 1);
    y = srcdata(:, 2);
    scrsz = get(0,'ScreenSize');
    figure('Position', [6 72 scrsz(3)/4. scrsz(4)/1.3]);
    subplot(2,1,1);
    tt=plot(x(:), y(:), 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
    title ('Decision Graph','FontSize',15.0);
    xlabel ('x');
    ylabel ('y');
end

function showFigure(x, y)
    scrsz = get(0,'ScreenSize');
    figure('Position', [6 72 scrsz(3)/4. scrsz(4)/1.3]);
    subplot(2,1,1);
    tt=plot(x(:), y(:), 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
    title ('Decision Graph','FontSize',15.0);
    xlabel ('\rho');
    ylabel ('\delta');
end
