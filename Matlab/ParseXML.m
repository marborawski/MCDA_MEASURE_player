function result = ParseXML(data)
%Parses text containing xml
%
% data - a text array containing data in xml format
% returns an array of structures whose structure reflects the structure of the XML data, the field names are the names of the XML elements
  result = [];
% Definition of the machine's transition table specifying what state it should go to when a specific character appears
  t = zeros(11,24);
  t(1,1) = 1;t(2,1) = 17;t(3,1) = 2;t(4,1) = 8;t(5,1) = 12;t(6,1) = 4;t(8,1) = 6;t(9,1) = 15;t(10,1) = 22;
  t(:,2) = 3;t(5,2) = 10;t(10,2) = 20;
  t(1,4) = 5;t(2,4) = 5;t(4,4) = 5;t(5,4) = 5;t(6,4) = 4;t(7,4) = 4;t(9,4) = 5;
  t(:,6) = 6;t(8,6) = 7;
  t(:,7) = 19;
  t(:,8) = 9;
  t(:,10) = 11;
  t(4,12) = 13;
  t(:,13) = 14;
  t(:,15) = 16;
  t(:,17) = 18;
  t(:,20) = 21;
  t(4,22) = 23;
  t(:,23) = 24;
% Starting the machine
  data = Machine(data,t);
% Analysis of extracted text elements containing data in XML format. The analysis uses five states:
% state = 1 - start
% state = 2 - creating a new level
% state = 3 - level analysis
% state = 4 - char =
% state = 5 - ending the level
  nStack = 0;
  lastLevelName = [];
  state = 1;
  for ii = 1:length(data)
    switch data(ii).state
      case 3
        state = 2;
      case 5
        switch state
          case 2
            levelName = data(ii).txt;
            txt = [levelName '.txt=[];'];
            eval(txt);
            state = 3;
          case 3
            varName = data(ii).txt;
        case 5
          endLevelName = data(ii).txt;
        end
      case 9
        if state ~= 1
          if state ~= 5
            if ~isempty(lastLevelName)
              nStack = nStack + 1;
              stack{nStack} = lastLevelName;
            end
            lastLevelName = levelName;
          else
            if nStack > 0
              txt = ['a=isfield(' stack{nStack} ',' char(39) lastLevelName  char(39) ');'];
              eval(txt);
              if a == 0
                txt = [stack{nStack} '.' lastLevelName '{1}=' lastLevelName ';'];
                eval(txt);
              else
                txt = [stack{nStack} '.' lastLevelName '{end+1}=' lastLevelName ';'];
                eval(txt);
              end
              txt = ['clear ' lastLevelName ';'];
              eval(txt);
              lastLevelName = stack{nStack};
              nStack = nStack - 1;
            else
              txt = ['result.' lastLevelName '=' lastLevelName ';'];
              eval(txt);
              break;
            end
          end
        end
      case 11
        if state ~= 1
          state = 5;
        end
      case 14
        if state ~= 1
          txt = ['a=isfield(' lastLevelName ',' char(39) levelName  char(39) ');'];
          eval(txt);
          if a == 0
            txt = [lastLevelName '.' levelName '{1}=' levelName ';'];
            eval(txt);
          else
             txt = [lastLevelName '.' levelName '{end + 1}=' levelName ';'];
             eval(txt);
          end
          txt = ['clear ' levelName ';'];
          eval(txt);
        end
      case 16
        switch state
          case 3
            state = 4;
        end
      case 19
        switch state
          case 4
            d = data(ii).txt;
            if isnan(str2double(d))
              d = [char(39) d char(39)];
            end
            txt = [levelName '.' varName '=' d ';'];
            eval(txt);
            state = 3;
        end
    end
  end
end
