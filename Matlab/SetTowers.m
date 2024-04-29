function txt = SetTowers(count,speed,rateofFire,force,bulletStrength,cost,type, tag)
% Creating information in the form of XML about a specific type of tower
%
% count          - maximum number of towers
% speed          - the rotation speed of the towers
% rateofFire     - rate of fire towers
% force          - turret firing power (determines range)
% bulletStrength - turret projectile strength (affects the number of wounds dealt to the enemy)
% cost           - cost of creating a tower
% type           - tower type
% tag            - the type of object that the tower will attack
% returns information saved in xml format  
  
    no = 0;
    txt = sprintf('\t<SetTowers>');  
    txt = [txt, sprintf('\t\t<Tower no="%d" count="%d" speed="%d" rateofFire="%d" force="%d" bulletStrength="%d" cost="%d" type="%s" tag="%s">', no,count,speed,rateofFire,force,bulletStrength,cost,type, tag)];  
    txt = [txt, sprintf('\t\t</Tower>')];
    txt = [txt, sprintf('\t</SetTowers>')];
end