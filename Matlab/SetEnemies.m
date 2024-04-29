function txt = SetEnemies(count,speed,startHealth,armour,cost,destroyCoins,coinsToEnd,type, tag)
% Creating information in the form of XML about a specific type of opponent
%
% count        - maximum number of opponents
% speed        - opponent's speed
% startHealth  - opponent's starting life value
% armour       - enemy's armor (bullet resistance) 
% cost         - the cost of creating and sending an enemy
% destroyCoins - profit for the tower manager for shooting down an enemy
% coinsToEnd   - gain for the opponent's manager if he reaches the end of the path
% type         - opponent type
% tag          - name of the object type
% returns information saved in xml format

    no = 0;
    txt = sprintf('\t<SetEnemies>');  
    txt = [txt, sprintf('\t\t<Enemy no="%d" count="%d" speed="%d" startHealth="%d" armour="%d" cost="%d" destroyCoins="%d" coinsToEnd="%d" type="%s" tag="%s">',no,count,speed,startHealth,armour,cost,destroyCoins,coinsToEnd,type, tag)];  
    txt = [txt, sprintf('\t\t</Enemy>')];
    txt = [txt, sprintf('\t</SetEnemies>')];
end