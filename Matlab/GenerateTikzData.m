function GenerateTikzData(fileName,data,columnDescriptions)
%Generating data files for tikz charts
%
% fileName           - name of the file to which the array will be saved
% data               - saved array
% columnDescriptions - column descriptions

  fid = fopen(fileName,'w');
  for ii = 1:length(columnDescriptions)
    fprintf(fid,'%s ',columnDescriptions{ii});
  end
  fprintf(fid,'\n');
  for ii = 1:size(data,1)
    for jj = 1:size(data,2)
      fprintf(fid,'%d ',data(ii,jj));
    end
    fprintf(fid,'\n');
  end
  fclose(fid);
end