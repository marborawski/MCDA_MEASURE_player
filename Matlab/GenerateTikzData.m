function GenerateTikzData(fileName,data,columnDescriptions)

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