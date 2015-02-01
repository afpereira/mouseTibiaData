%% Directory and auxiliary variables
cd '/Users/andre/Documents/GitHub/mouseTibiaData';
load('aux_variables.mat');
ABQresolution = ABQresolution/1.05;

%% Read 12 week data
load('thicknessCT_2.mat');
slicesI = 1:200;
flim = [184 78];


%% Read Simulation data
load('thicknessInSilico_FLVEL.mat')

%% Plot simulation vs CT

strAnimal = '_lem_12w';
surfaceS = 'peri';

showContours = 1;
thicknessQ = 1;
separateFigs = 0;
positionQ = 0;
scale0Q = 1;

lastQ = 1;



stimulus = 'FLVEL';
jobs = [68 81 82 85 86]; % selection
lastA = [7 15 13 13 12]; % driver 2
psiJ = [68 1.0E-3; 81 1.0E-1; 82 7.0E-2;
        85 3.0E-2; 86 6.0E-2];


psiVal = zeros(size(jobs));
for j = jobs
    psiVal(j == jobs) = psiJ(j == psiJ(:,1),2);
end
[~,sortPsi] = sort(psiVal);


if thicknessQ
    ctVarName = 'thickMean';
    silicoVarName = 'thick';
    caLimits = [1 1.5];
    if scale0Q
        caLimits = caLimits - 1;
    end
else    
    ctVarName = 'endoDistMean';
    silicoVarName = 'endoD';
    caLimits = [1 1.2];
end

zI = (slicesI-flim(1))/(flim(2)-flim(1));
Zlist = [0:0.005:1];



evalc(['tempCT = CTresolution*' ctVarName strAnimal '_' surfaceS ';']);

tempCT = tempCT(:,[90:180 1:89]);


if separateFigs
    figH = round(rand*100);
else
    figure
end

numBins = size(tempCT,2);
ctAngles = linspace(-2*pi, 0, size(tempCT,2)+1);
ctAngles2 = -(ctAngles(1:end-1)+ctAngles(2:end))/2;



if separateFigs
    figure(figH+1);
else
    subplot(1,2,2);
end

if scale0Q
    pcontour(rad2deg(ctAngles2), Zlist, tempCT(2:2:end,:)./tempCT(1:2:end,:)-1)
else
    pcontour(rad2deg(ctAngles2), Zlist, tempCT(2:2:end,:)./tempCT(1:2:end,:))
end
caxis(caLimits)

for angle = [0:45:360]
    line([angle angle], [0 1],'color','w','LineStyle','--')
end
%colorbar
colormap jet;
ylab = ylabel('Z', 'rot', 0, 'fontsize', 20, 'fontname', 'Times New Roman');
xlabel('\theta (º)', 'fontsize', 20, 'fontname', 'Times New Roman');
colorbar
set(gca, 'FontName', 'Palatino', 'FontSize', 20)


jCtr = 1;

errorVal = zeros(size(jobs))+Inf;

tauVal = zeros(size(jobs));
rhoVal = zeros(size(jobs));

errorI = zeros(size(jobs));
maxTh = zeros(20,length(jobs));

firstCycleQ = 1;

for j = jobs(sortPsi)
    evalc(sprintf('tempSilico = ABQresolution*%s%2.2d_%s;',silicoVarName,j, surfaceS));
    
    silicoAngles = linspace(0, 2*pi , size(tempSilico,1)+1);
    silicoAngles2 = (silicoAngles(1:end-1)+silicoAngles(2:end))/2;
    
    tempSilico = tempSilico([90:180 1:89],:,:);
    
    psiVal(j == jobs) = psiJ(j == psiJ(:,1),2);
    
    if lastQ
        a_range = lastA(jobs == j);
    else
        a_range = 2:size(tempSilico,3);
    end
    
    for a = a_range
        if separateFigs
            figure(figH);
        else
            subplot(1,2,1);
        end
        
        silicoMat = (tempSilico(:,78:184,a)./tempSilico(:,78:184,1))';
        if scale0Q
            silicoMat = silicoMat - 1;
        end
        
        if showContours
            pcontour(rad2deg(silicoAngles2), zI(78:184), silicoMat)
        end
        ylim([0 1]);
        caxis(caLimits);
        
        fprintf('Psi_A = %8.2E, Iteration %d\n', psiVal(jobs==j), a);
        
        for angle = [0:45:360]
            line([angle angle], [0 1],'color','w','LineStyle','--')
        end
        
        if firstCycleQ
            colorbar
            set(gca, 'FontName', 'Palatino', 'FontSize', 20)
            firstCycleQ = 0;
        end
        colormap jet;
         
        maxTh(a,j==jobs) = max(max(max((tempSilico(111:end,99:142,a)-tempSilico(111:end,99:142,1))./tempSilico(111:end,99:142,1))));
        
        %ylab = ylabel('Z', 'rot', 0, 'fontsize', 20, 'fontname', 'Times New Roman');
        xlabel('\theta (º)', 'fontsize', 20, 'fontname', 'Times New Roman');
        
        ctMat = tempCT(2:2:end,:)./tempCT(1:2:end,:);
        silicoMat = (tempSilico(:,78:184,a)./tempSilico(:,78:184,1))';
        
        ctMat = ctMat(round(1:201/107:201), end:-1:1);
        silicoMat = silicoMat(end:-1:1,:);
        
        errorTemp = sum(sum((ctMat(20:100,37:180)-silicoMat(20:100,37:180)).^2));
        if errorVal(j==jobs) > errorTemp
            errorVal(j==jobs) = errorTemp;
            errorI(j==jobs) = a;
        end
        
        corr_R = corr2(silicoMat(40:100,50:180), ctMat(40:100,50:180));
        x2 = silicoMat(40:100,50:180);
        x2 = x2(:);
        y2 = ctMat(40:100,50:180);
        y2 = y2(:);
        corr_KT = corr(x2, y2, 'type', 'kendall');
        fprintf('Kendall''s tau = %4.3d\n\n', corr_KT);
        
        tauVal(j==jobs) = corr_KT;
        rhoVal(j==jobs) = corr_R;
        
        if showContours
            fprintf('Press any key\n\n');
            pause
        end
    end
    jCtr = jCtr + 1;
end
