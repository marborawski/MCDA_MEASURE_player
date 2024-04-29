function txt = StartEnemy(beginNo,endNo)
% Creating an opponent and sending him out along a selected path
%
% beginNo - starting point number
% endNo   - endpoint number
% returns information saved in xml format
    noEnemy = 0;
    txt = sprintf('\t<StartEnemy no="%d">',noEnemy);  
    txt = [txt, sprintf('\t\t<Begin no="%d">',beginNo)];  
    txt = [txt, sprintf('\t\t</Begin>')];
    txt = [txt, sprintf('\t\t<End no="%d">',endNo)];  
    txt = [txt, sprintf('\t\t</End>')];
    txt = [txt, sprintf('\t</StartEnemy>')];
end