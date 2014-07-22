clear;
close all
disp('The only input needed is a distance matrix file')
disp('The format of this file should be: ')
disp('Column 1: id of element i')
disp('Column 2: id of element j')
disp('Column 3: dist(i,j)')

if(0)
    % mdist=input('name of the distance matrix file (with single quotes)?\n'
);
    mdist = 'example_distances.dat';
   
    disp('Reading input distance matrix')
    xx=load(mdist);
   
    N=size(xx,1);
   
    ND=max(xx(:,2));
    NL=max(xx(:,1));
   
    if(NL>ND)
      ND=NL;
    end
   
    dist = zeros(ND, ND);
    % for i=1:ND
    %   for j=1:ND
    %     dist(i,j)=0;
    %   end
    % end
   
    for i=1:N
      ii=xx(i,1);
      jj=xx(i,2);
      dist(ii,jj)=xx(i,3);
      dist(jj,ii)=xx(i,3);
    end

    percent=2.0;
    fprintf('average percentage of neighbours (hard coded): %5.6f\n',
percent);
   
    position=round(N*percent/100);
    sda=sort(xx(:,3));
    dc=sda(position);
   
    clear xx;
   
    save('PeakCluData.mat');
    return;
   
else
    load('PeakCluData.mat');
end;

dc = dc * 3;

dc = 0.1;

% rhomin = 20;
% deltamin = 0.1;

rhomin = 10;
deltamin = 0.15;

percent=2.0;
fprintf('average percentage of neighbours (hard coded): %5.6f\n', percent);
fprintf('Computing Rho with gaussian kernel of radius: %12.6f\n', dc);

rho = zeros(1, ND);
% for i=1:ND
%   rho(i)=0.;
% end

% %
% % Gaussian kernel
% %
% for i=1:ND-1
%   for j=i+1:ND
%      rho(i)=rho(i)+exp(-(dist(i,j)/dc)*(dist(i,j)/dc));
%      rho(j)=rho(j)+exp(-(dist(i,j)/dc)*(dist(i,j)/dc));
%   end
% end

% Kernel distance
k_dist = exp(-dist.^2/dc^2);
rho = sum(k_dist) - 1;

% %
% % "Cut off" kernel
% %
% for i=1:ND-1
%  for j=i+1:ND
%    if (dist(i,j)<dc)
%       rho(i)=rho(i)+1.;
%       rho(j)=rho(j)+1.;
%    end
%  end
% end

maxd=max(max(dist));

% [rho_sorted,ordrho]=sort(rho,'descend');

[rho_sorted,ordrho]=sort(-rho);
rho_sorted = -rho_sorted;

delta(ordrho(1))=-1.;
nneigh(ordrho(1))=0;

% Find local peak among neighbors; mark the clustering trace
for ii=2:ND
   delta(ordrho(ii))=maxd;
   for jj=1:ii-1
     if(dist(ordrho(ii),ordrho(jj))<delta(ordrho(ii)))
        delta(ordrho(ii))=dist(ordrho(ii),ordrho(jj));
        nneigh(ordrho(ii))=ordrho(jj);
     end
   end
end
delta(ordrho(1))=max(delta(:));
disp('Generated file:DECISION GRAPH')
disp('column 1:Density')
disp('column 2:Delta')

fid = fopen('DECISION_GRAPH', 'w');
for i=1:ND
   fprintf(fid, '%6.2f %6.2f\n', rho(i),delta(i));
end

disp('Select a rectangle enclosing cluster centers')
scrsz = get(0,'ScreenSize');
%figure('Position',[6 72 scrsz(3)/4. scrsz(4)/1.3]);
figure('Position',[scrsz(3)/4 scrsz(4)/4 scrsz(3)/2. scrsz(4)/2]);
for i=1:ND
  ind(i)=i;
  gamma(i)=rho(i)*delta(i);
end
subplot(1,2,1)
tt=plot(rho(:),delta(:),'o','MarkerSize',5,'MarkerFaceColor','k','
MarkerEdgeColor','k');
title(sprintf('Decision Graph: dc = %.3f', dc));
xlabel ('\rho')
ylabel ('\delta')

subplot(1,2,1)

% Read the threshold set manually
% rect = getrect(1);
% rhomin=rect(1);
% deltamin=rect(4);

disp(sprintf('rhomin = %f, deltamin = %f', rhomin, deltamin));

NCLUST=0;
for i=1:ND
  cl(i)=-1;
end
for i=1:ND
  if ( (rho(i)>rhomin) && (delta(i)>deltamin))
     NCLUST=NCLUST+1;
     cl(i)=NCLUST;
     icl(NCLUST)=i;
  end
end
fprintf('NUMBER OF CLUSTERS: %i \n', NCLUST);
disp('Performing assignation')

%assignation
for i=1:ND
  if (cl(ordrho(i))==-1)
    cl(ordrho(i))=cl(nneigh(ordrho(i)));
  end
end

%halo

% for i=1:ND
%   halo(i)=cl(i);
% end
halo = cl;

if (NCLUST>1)
%   for i=1:NCLUST
%     bord_rho(i)=0.;
%   end
  bord_rho = zeros(1, NCLUST);

  % For each cluster, calculate the average rho of border points
  for i=1:ND-1
    for j=i+1:ND
      if ((cl(i)~=cl(j))&& (dist(i,j)<=dc))
        rho_aver=(rho(i)+rho(j))/2.;
        if (rho_aver>bord_rho(cl(i)))
          bord_rho(cl(i))=rho_aver;
        end
        if (rho_aver>bord_rho(cl(j)))
          bord_rho(cl(j))=rho_aver;
        end
      end
    end
  end
 
  % Points whose rho is less than the average border rho will be considered
  % as noise
  for i=1:ND
    if (rho(i)<bord_rho(cl(i)))
      halo(i)=0;
    end
  end
end
for i=1:NCLUST
  nc=0;
  nh=0;
  for j=1:ND
    if (cl(j)==i)
      nc=nc+1;
    end
    if (halo(j)==i)
      nh=nh+1;
    end
  end
  fprintf('CLUSTER: %i CENTER: %i ELEMENTS: %i CORE: %i HALO: %i \n', i,icl(
i),nc,nh,nc-nh);
end

cmap=colormap;
for i=1:NCLUST
   ic=int8((i*64.)/(NCLUST*1.));
   subplot(1,2,1)
   hold on
   plot(rho(icl(i)),delta(icl(i)),'o','MarkerSize',8,'MarkerFaceColor',cmap(
ic,:),'MarkerEdgeColor',cmap(ic,:));
end
subplot(1,2,2)
disp('Performing 2D nonclassical multidimensional scaling')
Y1 = mdscale(dist, 2, 'criterion','metricstress');
plot(Y1(:,1),Y1(:,2),'o','MarkerSize',2,'MarkerFaceColor','k','
MarkerEdgeColor','k');
%title ('2D Nonclassical multidimensional scaling','FontSize',15.0)
title (['Clu result: \rho_{min} = ', sprintf('%.2f', rhomin) ', \delta_{min}
= ' sprintf('%.2f', deltamin) ]);
xlabel ('X')
ylabel ('Y')
axis equal;
for i=1:ND
A(i,1)=0.;
A(i,2)=0.;
end
for i=1:NCLUST
  nn=0;
  ic=int8((i*64.)/(NCLUST*1.));
  for j=1:ND
    if (halo(j)==i)
      nn=nn+1;
      A(nn,1)=Y1(j,1);
      A(nn,2)=Y1(j,2);
    end
  end
  hold on
  plot(A(1:nn,1),A(1:nn,2),'o','MarkerSize',2,'MarkerFaceColor',cmap(ic,:),'
MarkerEdgeColor',cmap(ic,:));
end

%for i=1:ND
%   if (halo(i)>0)
%      ic=int8((halo(i)*64.)/(NCLUST*1.));
%      hold on
%      plot(Y1(i,1),Y1(i,2),'o','MarkerSize',2,'MarkerFaceColor',cmap(ic,:),
'MarkerEdgeColor',cmap(ic,:));
%   end
%end
faa = fopen('CLUSTER_ASSIGNATION', 'w');
disp('Generated file:CLUSTER_ASSIGNATION')
disp('column 1:element id')
disp('column 2:cluster assignation without halo control')
disp('column 3:cluster assignation with halo control')
for i=1:ND
   fprintf(faa, '%i %i %i\n',i,cl(i),halo(i));
end

im = getframe(gcf);
imwrite(im.cdata, 'PeakCluRes.png');
