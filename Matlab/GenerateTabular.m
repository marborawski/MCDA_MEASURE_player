function GenerateTabular(fileName,data,columnDescriptions,rowDescriptions,rowsBold,decimalPlaces)
%Automatic generation of a tabular table
%
% fileName           - name of the file to which the array will be saved
% data               - saved array
% columnDescriptions - column descriptions
% rowDescriptions    - row descriptions, empty array([]) means no descriptions
% rowsBold           - 0 means line descriptions are bold and 1 means bold
% decimalPlaces      - number of decimal places

  fid = fopen(fileName,'w');
  fprintf(fid,'\\begin{tabular}{|');
  for ii = 1:length(columnDescriptions)
    fprintf(fid,'r|');
  end
  fprintf(fid,'}\n');
  fprintf(fid,'  \\hline\n');
  for ii = 1:length(columnDescriptions)
    if ii > 1
        fprintf(fid,'&');
    end
    fprintf(fid,'  \\textbf{%s}',columnDescriptions{ii});
  end
  fprintf(fid,'\\\\\n');
  fprintf(fid,'  \\hline\n');
  n = length(rowDescriptions);
  if n == 0 || n > size(data,1)
    n = size(data,1);
  end
  txt = ['& %.' num2str(decimalPlaces) 'f'];
  for ii = 1:n
    if ~isempty(rowDescriptions)
      if rowsBold == 1
        fprintf(fid,'  \\textbf{%s}',rowDescriptions{ii});
      else
        fprintf(fid,'  %s',rowDescriptions{ii});
      end
    end
    for jj = 1:size(data,2)
      if jj == 1 && isempty(rowDescriptions)
        fprintf(fid,txt(2:end),data(ii,jj));
      else
        fprintf(fid,txt,data(ii,jj));
      end
    end
    fprintf(fid,'\\\\\n');
    fprintf(fid,'  \\hline\n');
  end
  fprintf(fid,'\\end{tabular}\n');

  fclose(fid);
end