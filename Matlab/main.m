%main file
% Octave use install instrument-control and run:
% pkg load instrument-control

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

txt = SetEnemies(-1,2,20,2,30,30,40,'Paper','Enemy');
SendData(IPAddressSend,portSend,txt,'Command','name="SetEnemies"');

txt = SetTowers(-10,1000,1,1000,5,10,'Tower','Enemy');
SendData(IPAddressSend,portSend,txt,'Command','name="SetTowers"');


%Rounds of the game - read data from XML
dataTower = fileread('towers.xml');
dataTower = ParseXML(dataTower);

scoreArray = [];
%Start rounds
NoOfRounds=length(dataTower.Answer.TowerCoordinates{1}.Element);
for i=1:NoOfRounds
    %Placing tower on the board
    x=dataTower.Answer.TowerCoordinates{1}.Element{i}.x;
    y=dataTower.Answer.TowerCoordinates{1}.Element{i}.y;
    no=dataTower.Answer.TowerCoordinates{1}.Element{i}.no;
    txt = AddTower(0,x,y);
    errorAddTower = SendData(IPAddressSend,portSend,txt,'Command','name="AddTower"');
    choiceOfPathData = SendData(IPAddressSend,portSend,[],'Command','name="GetChoiceOfPathData"');    
    
    %Reading alternative statistics
    levelData = SendData(IPAddressSend,portSend,[],'Command','name="LevelData"');
    data = ParseXML(levelData);

    %Preparation of decision matrix based on the read statistics
    NoOfAlternatives=length(data.Answer.LevelPath{1}.Path);
    %Criterion 1
    E=[GetVectorFromCell(data.Answer.LevelPath{1}.Path,'cost')]';
    %Criterion 2
    E=[E [GetVectorFromCell(data.Answer.LevelPath{1}.Path,'shotAtTiles')]'];
    %Criterion 3
    E=[E [GetVectorFromCell(data.Answer.LevelPath{1}.Path,'towers')]'];
    %Criterion 4
    sumTowerPlace=[GetVectorFromCell(data.Answer.LevelPath{1}.Path,'sumTowerPlace')]';
    if exist('OCTAVE_VERSION', 'builtin') ~= 0;
      TowerNumsCashCost=round(data.Answer.LevelPath{1}.Towers{1}.cash/data.Answer.LevelPath{1}.Tower{1}.cost);
    else
      TowerNumsCashCost=round(data.Answer.LevelPath{1}.Towers{1}.cash/data.Answer.LevelPath{1}.Tower{1}.cost,TieBreaker="minusinf"); 
    end
    TowerNumsCashCost=ones(NoOfAlternatives,1)*TowerNumsCashCost;
    E=[E min([sumTowerPlace TowerNumsCashCost],[],2)];
    %Criteria 5-8
    EndBeginRatio=[];%jeżeli nie ma przejścia to wstaw 1
    EndStartHealthRatio=[];
    for j=1:NoOfAlternatives
        EndBeginRatio=[EndBeginRatio;[GetVectorFromCell(data.Answer.LevelPath{1}.Path{j}.End{1}.Enemy,'enemies')]./[GetVectorFromCell(data.Answer.LevelPath{1}.Path{j}.Begin{1}.Enemy,'enemies')]];
        EndStartHealthRatio=[EndStartHealthRatio;[GetVectorFromCell(data.Answer.LevelPath{1}.Path{j}.End{1}.Enemy,'endMeanHealth')]./[GetVectorFromCell(data.Answer.LevelPath{1}.Enemy,'startHealth')]];
        if isnan(EndBeginRatio(j,1))
            EndBeginRatio(j,1)=1;
        end
        if EndStartHealthRatio(j,1)==0
            EndStartHealthRatio(j,1)=1;
        end
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
    %[E,W,PrefDirection] = RemoveCriteria(E,W,PrefDirection);
    [Score]=PROMETHEE(E,W,PrefDirection);
%    [Score]=TOPSIS(E,W,PrefDirection,2);%Im wyższa wartość tym lepiej
%    [Score]=VIKOR(E,W,PrefDirection,0.5);%Im wyższa wartość tym lepiej
%    [Score]=VMCM(E,W,PrefDirection);%Im wyższa wartość tym lepiej
%     [Score]=AHP(E,W,PrefDirection,10);%Im wyższa wartość tym lepiej
    [~,rank]=sort(Score,'descend');%numer oznacza ścieżkę
    ranking=GenerateRanking(Score);%numer oznacza pozycję w rankingu
    i
    E
    Score
    ranking'
     
    %launching the enemy
    trackNumber=rank(1)-1;
    txt = StartEnemy(trackNumber,trackNumber);
    errorStartEnemy = SendData(IPAddressSend,portSend,txt,'Command','name="StartEnemy"');
    
    scoreArray = [scoreArray;Score];
    pause;
    i=i+1;
end

columnDescriptions{1} = 'Nr.';
for ii = 1:size(scoreArray,2)
  columnDescriptions{ii + 1} = ['Path no ' num2str(ii)];
end
for ii = 1:size(scoreArray,1)
  rowDescriptions{ii} = num2str(ii);
end
GenerateTabular('../Latex/Table/Score.tex',scoreArray,columnDescriptions,rowDescriptions,0,3)

columnDescriptions{1} = 'Nr.';
for ii = 1:size(scoreArray,2)
  columnDescriptions{ii + 1} = ['Path' num2str(ii)];
end
GenerateTikzData('../Latex/Fig/Score.dat',[[1:size(scoreArray,1)]' scoreArray],columnDescriptions)

