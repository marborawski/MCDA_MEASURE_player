function GenerateReport(fileNamePlot,fileNameTab,scoreArray,funName,EnemiesToEnd,EnemiesMeanHealthRatio,TracksCost);
%Generating a report with the results of the tested MCDA method
%
% fileNamePlot              - name of the file to which the plot will be saved
% fileNameTab               - name of the file to which the table will be saved
% scoreArray                - scores (assessments) ot paths
% funName                   - name of the MCDA method
% EnemiesToEnd              - main score of the MCDA method
% EnemiesMeanHealthRatio    - additional score of MCDA method
% TracksCost				- second additional score of MCDA method

%File reports - plot
noOfRounds=size(scoreArray,1);
for i = 1:size(scoreArray,2)
  legendDescription{i} = ['Path no ' num2str(i)];
end
fig=figure;
fig.Position(3:4) = [720 400];
hold on;
title(funName,' - Score dependence on iteration');
xlim([0.5 noOfRounds+0.5]);
xticks([1:noOfRounds]);
ylim([min(min(scoreArray))-0.1 max(max(scoreArray))+0.1]);
yticks([round(min(min(scoreArray)),1):(round(max(max(scoreArray)),1)-round(min(min(scoreArray)),1))/10:round(max(max(scoreArray)),1)]);
grid on;
xlabel('Iteration (Round)');
ylabel('Score');
leg=plot(scoreArray);
legend([leg],legendDescription,'Location','eastoutside','Orientation','vertical');
saveas(fig,fileNamePlot,'png');

%File reports - table html
scoreArray=[[1:size(scoreArray,1)]' scoreArray];
fid=fopen(fileNameTab,'w'); 
fprintf(fid,'<html>\n<body>\n');
fprintf(fid,'<p>MCDA Method: %s</p>\n<p>Enemies to end: %i</p>\n<p>Enemies mean health: %f</p>\n<p>Tracks cost: %i</p>\n<table>\n',funName,EnemiesToEnd,EnemiesMeanHealthRatio,TracksCost);
fprintf(fid,'<tr>\n<th>No.</th>');
for i = 1:size(scoreArray,2)-1  
    fprintf(fid,'<th>Path %i</th>',i);
end
fprintf(fid,'\n</tr>\n');
for i = 1:size(scoreArray,1)
    fprintf(fid,'<tr>\n');
    fprintf(fid,'<td>%i</td>',scoreArray(i,1));
    for j = 2:size(scoreArray,2)
        fprintf(fid,'<td>%.4f</td>',scoreArray(i,j));
    end
    fprintf(fid,'\n</tr>\n');
end
fprintf(fid,'</table>\n<style>\ntable {border: 1px solid; border-collapse: collapse;}\nth {border: 1px solid; padding-left: 10px; padding-right: 10px;}\ntd {border: 1px solid; padding-left: 10px; padding-right: 10px;}\n</style>\n</body>\n</html>');
fclose('all');