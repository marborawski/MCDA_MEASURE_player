%pkg load instrument-control

clear all;
close all;
IPAddressSend = '127.0.0.1';
portSend = 55001;
SendData(IPAddressSend,portSend,'','Command','name="Restart"');
pause(1);

%x=cols=16 y=rows=13 -tilemap is rotated 90 degree-left
tilemap = [1	1	1	1	1	1	1	1	1	1	1	1	1;
           4	2	2	2	2	2	2	2	2	2	2	2	3;
           1	1	1	1	1	1	1	1	1	1	1	1	1;
           1	2	2	2	2	2	1	2	2	2	2	2	3;
           4	2	1	1	1	2	2	2	1	1	1	1	1;
           1	1	1	1	1	1	1	1	1	1	1	1	1;
           1	1	1	1	1	1	1	1	1	1	1	1	1;
           1	1	1	2	2	2	2	1	1	1	1	1	1;
           1	2	2	2	1	1	2	2	2	2	3	1	1;
           1	2	1	1	1	1	1	1	1	1	1	1	1;
           1	4	1	2	2	2	1	2	2	2	2	1	1;
           1	1	1	2	1	2	2	2	1	1	2	2	3;
           1	1	1	2	1	1	1	1	1	1	1	1	1;
           1	1	2	2	1	1	1	1	1	1	1	1	1;
           4	2	2	1	1	1	1	1	1	1	1	1	1;
           1	1	1	1	1	1	1	1	1	1	1	1	1;];
              
names{1} = 'Ground';
names{2} = 'Water';
names{3} = 'Begin';
names{4} = 'End';

tilemapNames = NumberToName(tilemap,names);
tilemapNames = ChangeBeginEnd(tilemapNames);

txt = TilemapToXML(tilemapNames);
%SaveTilemapToXML(filename,txt); 
SendData(IPAddressSend,portSend,txt,'Tilemap',[]);

txt = SetEnemies(1,-1,2,20,2,30,30,40,'Paper','Enemy');%0 to butelka, 1 to papier
SendData(IPAddressSend,portSend,txt,'Command','name="SetEnemies"');

%txt = SetTowers(0,-2,550,1,1010,5,40,'Tower','Enemy');
txt = SetTowers(0,-10,1000,1,1000,5,10,'Tower','Enemy');
SendData(IPAddressSend,portSend,txt,'Command','name="SetTowers"');


%od tego miejsca tury
if exist('OCTAVE_VERSION', 'builtin') ~= 0;
  load dataTower;
else
  dataTower=readstruct('towers.xml');
end
NoOfRounds=sum(~cellfun(@isempty,{dataTower.TowerCoordinates.Element.noAttribute}));
for i=1:NoOfRounds
    %x to y
    x=dataTower.TowerCoordinates.Element(i).xAttribute;
    y=dataTower.TowerCoordinates.Element(i).yAttribute;
    no=dataTower.TowerCoordinates.Element(i).noAttribute;
    txt = AddTower(0,x,y);
    errorAddTower = SendData(IPAddressSend,portSend,txt,'Command','name="AddTower"');

    %tu był startEnemy i pause

    choiceOfPathData = SendData(IPAddressSend,portSend,[],'Command','name="GetChoiceOfPathData"');
    levelData = SendData(IPAddressSend,portSend,[],'Command','name="LevelData"');

    %MOJE
    fid = fopen('tmp.xml','w');%MOJE
    bytes = fprintf(fid,'%s',levelData);
    fclose(fid);

    
    if exist('OCTAVE_VERSION', 'builtin') ~= 0;
      load data;
    else
      data=readstruct('tmp.xml');
    end
    
    NoOfAlternatives=sum(~cellfun(@isempty,{data.LevelPath.Path.costAttribute}));
    NoOfCriteria=8;
    E=[data.LevelPath.Path.costAttribute]';%C1
    E=[E [data.LevelPath.Path.shotAtTilesAttribute]'];%C2
    E=[E [data.LevelPath.Path.towersAttribute]'];%C3
    sumTowerPlace=[data.LevelPath.Path.sumTowerPlaceAttribute]';
    if exist('OCTAVE_VERSION', 'builtin') ~= 0;
       TowerNumsCashCost=round(data.LevelPath.Towers.cashAttribute/data.LevelPath.Tower.costAttribute);
    else
      TowerNumsCashCost=round(data.LevelPath.Towers.cashAttribute/data.LevelPath.Tower.costAttribute,TieBreaker="minusinf"); 
    end
     TowerNumsCashCost=ones(NoOfAlternatives,1)*TowerNumsCashCost;
    E=[E min([sumTowerPlace TowerNumsCashCost],[],2)];%C4
    EndBeginRatio=[];
    EndStartHealthRatio=[];
    for i=1:NoOfAlternatives
        EndBeginRatio=[EndBeginRatio;[data.LevelPath.Path(i).End.Enemy.enemiesAttribute]./[data.LevelPath.Path(i).Begin.Enemy.enemiesAttribute]];
        if data.LevelPath.Path(i).End.Enemy(1).enemiesAttribute==0
            EndStartHealthRatio=[EndStartHealthRatio;1 0];
        else
            EndStartHealthRatio=[EndStartHealthRatio;[data.LevelPath.Path(i).End.Enemy.endMeanHealthAttribute]./[data.LevelPath.Enemy.startHealthAttribute]];
        end
        %EndBeginRatio(isnan(EndBeginRatio))=1;
        %EndStartHealthRatio(isnan(EndStartHealthRatio))=1;
    end
    EndBeginRatio;
    EndStartHealthRatio;
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
	
	%Wejście metody wielokryterialnej
    %W=ones(NoOfCriteria,1)';
    W=[1 8 10 2 9 0 8 0];
    PrefDirection=[2 2 2 2 1 1 1 1];%2-min 1-max
    PrefFun=ones(NoOfCriteria,1)*3;
    for j=1:NoOfCriteria
        stdDev(j)=std(E(:,j));
    end
    q=ones(NoOfCriteria,1)'*0;
    p=2*stdDev;
    s=stdDev;
    E
    [E,W,PrefDirection] = RemoveCriteria(E,W,PrefDirection);
%    [Phi,PhiPlus,PhiMinus,Pi,W,P,d]=PROMETHEE(NoOfCriteria,NoOfAlternatives,E,W,PrefDirection,PrefFun,q,p,s);
%    [Phi]=TOPSIS(E,W,PrefDirection,2);%Im wyższa wartość tym lepiej
%    [Phi]=VIKOR(E,W,PrefDirection,0.5);%Im wyższa wartość tym lepiej
%    [Phi]=VMCM(E,W,PrefDirection);%Im wyższa wartość tym lepiej
    [Phi]=AHP(E,W,PrefDirection,10);%Im wyższa wartość tym lepiej
    Phi'
    rankPhi=genRanking(Phi);
    rankPhi'
    [~,rank]=sort(Phi,'descend');
    rank'
	%Koniec metody wielokryterialnej
     
    %puszczanie ludka
    trackNumber=rank(1)-1;
    txt = StartEnemy(1,trackNumber,trackNumber);
    %txt = StartEnemy(0,2,2);
    errorStartEnemy = SendData(IPAddressSend,portSend,txt,'Command','name="StartEnemy"');
    pause;
    i=i+1;
end





function SaveTilemapToXML(filename, txt)
  txtOut = sprintf('<?xml version="1.0" encoding="utf-8"?>\n');
  txtOut = [txtOut sprintf('<Tilemap xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">\n')];
  txtOut = [txtOut, txt];
  txtOut = [txtOut sprintf('</Tilemap>\n')];
  fid=fopen(filename,'wt','n','UTF-8');
  fprintf(fid,'%s',txtOut);

  fclose(fid);
end






