%% Directory and auxiliary variables
cd '/Users/andre/Documents/GitHub/mouseTibiaData';
load('aux_variables.mat');
ABQresolution = ABQresolution/1.05;

%% Read 12 week data
load('thicknessCT_2.mat');

%% Read 22 week data
load('thicknessCT_22w_1.mat');

%% Plot data

% sideC
% B: Thickness change
% L: Left leg thickness
% R: Right leg thickness
sideC = 'B';

% strAnimal
% Mouse identifier
% 12 week: '_lem_12w' (paper data), '_2lem_12w', '_bem_12w', '_nem_12w', '_rem_12w'
% 22 week: '1_22w', '2_22w', '3_22w'
strAnimal = '_lem_12w'; circShift = 14;

surfaceS = 'peri';

figure

evalc(['tempCT = CTresolution*thickMean' strAnimal '_' surfaceS ';']);
Zlist = 0:0.005:1;

numBins = size(tempCT,2);
binAngles = linspace(-2*pi, 0, numBins+1);
binAngles2 = -(binAngles(1:end-1)+binAngles(2:end))/2;

tempCT = tempCT(:,[90:180 1:89]);
    
switch(sideC)
    case('B')
        pcontour(rad2deg(binAngles2), Zlist, tempCT(2:2:end,:)./tempCT(1:2:end,:));
        caxis([1 1.5]);
    case('L')
        
        pcontour(rad2deg(binAngles2), Zlist, tempCT(1:2:end,:));
        caxis([0 80*CTresolution])
    case('R')
        pcontour(rad2deg(binAngles2), Zlist, tempCT(2:2:end,:));
        caxis([0 80*CTresolution])
end



angleMarks = 0:45:360;
for i = angleMarks
    line([i i], [0 1],'color','w','LineStyle','--');
end
line([0 0], [0 1],'color','k','LineStyle','-', 'LineWidth', 2);
line([360 360], [0 1],'color','k','LineStyle','-', 'LineWidth', 2);
set(gca,'XTickLabel',angleMarks);
set(gca,'XTick', angleMarks)

xlim([-0.1 360])

set(gca, 'fontsize', 15, 'fontname', 'Times New Roman');
ylab = ylabel('Z', 'rot', 0, 'fontsize', 20, 'fontname', 'Times New Roman');
xlabel('\theta (º)', 'fontsize', 20, 'fontname', 'Times New Roman');
title(['f' strAnimal], 'Interpreter', 'none');
colorbar
set(gca, 'FontName', 'Palatino', 'FontSize', 20)
set(gcf, 'Position', [1551         -68         666         793])
set(ylab, 'Position', get(ylab, 'Position')-[6 0 0]);
set(gcf, 'PaperPositionMode', 'auto');
set(gca,'XTickLabel',angleMarks);
set(gca,'XTick', angleMarks)
