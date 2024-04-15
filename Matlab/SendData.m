function txt = SendData(IPAddressSend,portSend,data,name, args)
%Sending data to the server
%
% IPAddressSend - server ip address
% portSend      - server port
% data          - data packet sent to the server
% name          - control information sent to the server
% args          - arguments related to control information
% returns the response from the server in xml format
  
%Preparing data for sending (xml format)
  txtOut = sprintf('<?xml version="1.0" encoding="utf-8"?>');
  txtOut = [txtOut sprintf('<Data xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">')];
  if isempty(args)
    txtOut = [txtOut sprintf('<%s>',name)];
  else  
    txtOut = [txtOut sprintf('<%s %s>',name, args)];
  end
  if ~isempty(data)
    txtOut = [txtOut, data];
  end
  txtOut = [txtOut sprintf('</%s>',name)];
  txtOut = [txtOut sprintf('</Data>\n')];
  
%Sending data to the server  
  tcpipClient = tcpclient(IPAddressSend,portSend);
  set(tcpipClient,'Timeout',30);
  writeline(tcpipClient,txtOut);
  pause(0.1);
    fid = fopen('tmpSend.xml','w');%MOJE
    bytes = fprintf(fid,'%s',txtOut);
    fclose(fid);

%Getting a response from the server
  txt = read(tcpipClient,100,'uint8');
  while tcpipClient.NumBytesAvailable >= 100
    txt = [txt read(tcpipClient,100,'uint8')];
  end
  if tcpipClient.NumBytesAvailable > 0
    txt = [txt read(tcpipClient,tcpipClient.NumBytesAvailable,'uint8')];    
  end
  clear tcpipClient;
  txt = char(txt);
  if exist('OCTAVE_VERSION', 'builtin') ~= 0
    txt = strrep(txt,'<?xml version="1.0" encoding="utf-16"?>','<?xml version="1.0"?>');
  else
    txt = replace(txt,'<?xml version="1.0" encoding="utf-16"?>','<?xml version="1.0"?>');
  end
  
      fid = fopen('tmpSend2.xml','w');%MOJE
    bytes = fprintf(fid,'%s',txt);
    fclose(fid);


end
