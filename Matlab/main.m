%main file

clear all;
close all;
IPAddressSend = '127.0.0.1';
portSend = 55001;
SendData(IPAddressSend,portSend,'','Command','name="Restart"');
pause(1);

%x=cols=16 y=rows=13 -tilemap is rotated 90 degree-left
tilemap = [1	3	1	3	1	1	1	1	1	1	1	3	1	1	1 1;
           1	2	1	2	1	1	1	1	1	1	1	2	1	1	1 1;
           1	2	1	2	1	1	1	1	3	1	2	2	1	1	1 1;
           1	2	1	2	1	1	1	1	2	1	2	1	1	1	1 1;
           1	2	1	2	1	1	1	1	2	1	2	1	1	1	1 1;
           1	2	1	2	2	1	1	1	2	1	2	2	1	1	1 1;
           1	2	1	1	2	1	1	2	2	1	1	2	1	1	1 1;
           1	2	1	2	2	1	1	2	1	1	2	2	1	1	1 1;
           1	2	1	2	1	1	1	2	1	1	2	1	1	1	1 1;
           1	2	1	2	1	1	1	2	2	1	2	2	2	2	1 1;
           1	2	1	2	1	1	1	1	2	1	1	1	1	2	2 1;
           1	2	1	2	2	1	1	1	2	2	4	1	1	1	2 1;
           1	4	1	1	4	1	1	1	1	1	1	1	1	1	4 1;];
names{1} = 'Ground';
names{2} = 'Water';
names{3} = 'Begin';
names{4} = 'End';
tilemap = rot90(rot90(rot90(tilemap)));

tilemapNames = NumberToName(tilemap,names);
tilemapNames = ChangeBeginEnd(tilemapNames);

txt = TilemapToXML(tilemapNames);
SendData(IPAddressSend,portSend,txt,'Tilemap',[]);

txt = SetEnemies(1,-1,2,20,2,30,30,40,'Paper','Enemy');
SendData(IPAddressSend,portSend,txt,'Command','name="SetEnemies"');

txt = SetTowers(0,-10,1000,1,1000,5,10,'Tower','Enemy');
SendData(IPAddressSend,portSend,txt,'Command','name="SetTowers"');


%Rounds of the game - read data from XML
if exist('OCTAVE_VERSION', 'builtin') ~= 0;
  load dataTower;
else
  dataTower=readstruct('towers.xml');
end

%Start rounds
NoOfRounds=sum(~cellfun(@isempty,{dataTower.TowerCoordinates.Element.noAttribute}));
for i=1:NoOfRounds
    %Placing tower on the board
    x=dataTower.TowerCoordinates.Element(i).xAttribute;
    y=dataTower.TowerCoordinates.Element(i).yAttribute;
    no=dataTower.TowerCoordinates.Element(i).noAttribute;
    txt = AddTower(0,x,y);
    errorAddTower = SendData(IPAddressSend,portSend,txt,'Command','name="AddTower"');
    choiceOfPathData = SendData(IPAddressSend,portSend,[],'Command','name="GetChoiceOfPathData"');    
    
    %Reading alternative statistics
    levelData = SendData(IPAddressSend,portSend,[],'Command','name="LevelData"');
    if exist('OCTAVE_VERSION', 'builtin') ~= 0;
      load data;
    else
      fid = fopen('tmp.xml','w');
      bytes = fprintf(fid,'%s',levelData);
      fclose(fid);
      data=readstruct('tmp.xml');
    end

    %Preparation of decision matrix based on the read statistics
    NoOfAlternatives=sum(~cellfun(@isempty,{data.LevelPath.Path.costAttribute}));
    %Criterion 1
    E=[data.LevelPath.Path.costAttribute]';
    %Criterion 2
    E=[E [data.LevelPath.Path.shotAtTilesAttribute]'];
    %Criterion 3
    E=[E [data.LevelPath.Path.towersAttribute]'];
    %Criterion 4
    sumTowerPlace=[data.LevelPath.Path.sumTowerPlaceAttribute]';
    if exist('OCTAVE_VERSION', 'builtin') ~= 0;
      TowerNumsCashCost=round(data.LevelPath.Towers.cashAttribute/data.LevelPath.Tower.costAttribute);
    else
      TowerNumsCashCost=round(data.LevelPath.Towers.cashAttribute/data.LevelPath.Tower.costAttribute,TieBreaker="minusinf"); 
    end
    TowerNumsCashCost=ones(NoOfAlternatives,1)*TowerNumsCashCost;
    E=[E min([sumTowerPlace TowerNumsCashCost],[],2)];
    %Criteria 5-8
    EndBeginRatio=[];%jeżeli nie ma przejścia to wstaw 1
    EndStartHealthRatio=[];
    for j=1:NoOfAlternatives
        EndBeginRatio=[EndBeginRatio;[data.LevelPath.Path(j).End.Enemy.enemiesAttribute]./[data.LevelPath.Path(j).Begin.Enemy.enemiesAttribute]];
        EndStartHealthRatio=[EndStartHealthRatio;[data.LevelPath.Path(j).End.Enemy.endMeanHealthAttribute]./[data.LevelPath.Enemy.startHealthAttribute]];
    end
    E=[E EndBeginRatio EndStartHealthRatio];%C5-C6 C7-C8
    E(isnan(E))=0;

    %Criteria Preference direction (1-max;2-min):
    %C1 - Cost - min - dlugosc sciezki
    %C2 - shotAtTiles - min - liczba ostrzeliwanych pol
    %C3 - towers - min - liczba wiez na sciezce
    %C4 - min([sumTowerPlace TowerNumsCashCost]) - min - ile wiez mozna
    %postawic (wolne pola i kasa)
    %C5 - EndBeginRatio for Bottle Enemy - max - ile butelek dotarło do konca
    %C6 - EndBeginRatio for Paper Enemy - max - ile papierow dotarło do konca 
    %C7 - EndStartHealthRatio for Bottle - max - ile % zycia zostalo srednio
    %butelkom
    %C8 - EndStartHealthRatio for Paper - max - ile % zycia zostalo srednio
    %papierom
	
	%MCDA method calling
    %vector of criteria weights
    W=[1 8 10 2 9 0 8 0];
    %vector of criteria preference directions: 1-max, 2-min
    PrefDirection=[2 2 2 2 1 1 1 1];
    [E,W,PrefDirection] = RemoveCriteria(E,W,PrefDirection);
%    [Score]=PROMETHEE(E,W,PrefDirection);
%    [Score]=TOPSIS(E,W,PrefDirection,2);%Im wyższa wartość tym lepiej
    [Score]=VIKOR(E,W,PrefDirection,0.5);%Im wyższa wartość tym lepiej
%    [Score]=VMCM(E,W,PrefDirection);%Im wyższa wartość tym lepiej
%     [Score]=AHP(E,W,PrefDirection,10);%Im wyższa wartość tym lepiej
    [~,rank]=sort(Score,'descend');
    i
    E
    Score
    rank
     
    %launching the enemy
    trackNumber=rank(1)-1;
    txt = StartEnemy(1,trackNumber,trackNumber);
    errorStartEnemy = SendData(IPAddressSend,portSend,txt,'Command','name="StartEnemy"');
    pause;
    i=i+1;
end







