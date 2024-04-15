function txt = AddTower(noTower,x,y)
%Adding a tower
%
% noTower - tower number
% x       - x coordinate of the tower
% y       - y coordinate of the tower
% returns information saved in xml format

    txt = sprintf('\t<AddTower no="%d" x="%d" y="%d">',noTower,x,y);  
    txt = [txt, sprintf('\t</AddTower>')];
end