%main file
% Octave use install instrument-control and run:
% pkg load instrument-control

clear all;
close all;
IPAddressSend = '127.0.0.1';
portSend = 55001;
SendData(IPAddressSend,portSend,'','Command','name="Restart"');
pause(1);

tilemap = [1 3 1 3 1 1 1 1 1 1 1 3 1 1 1 1;
           1 2 1 2 1 1 1 1 1 1 1 2 1 1 1 1;
           1 2 1 2 1 1 1 1 3 1 2 2 1 1 1 1;
           1 2 1 2 1 1 1 1 2 1 2 1 1 1 1 1;
           1 2 1 2 1 1 1 1 2 1 2 1 1 1 1 1;
           1 2 1 2 2 1 1 1 2 1 2 2 1 1 1 1;
           1 2 1 1 2 1 1 2 2 1 1 2 1 1 1 1;
           1 2 1 2 2 1 1 2 1 1 2 2 1 1 1 1;
           1 2 1 2 1 1 1 2 1 1 2 1 1 1 1 1;
           1 2 1 2 1 1 1 2 2 1 2 2 2 2 1 1;
           1 2 1 2 1 1 1 1 2 1 1 1 1 2 2 1;
           1 2 1 2 2 1 1 1 2 2 4 1 1 1 2 1;
           1 4 1 1 4 1 1 1 1 1 1 1 1 1 4 1;];
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

txt = SetTowers(-10,1000,1,1000,5,7,'Tower','Enemy');
SendData(IPAddressSend,portSend,txt,'Command','name="SetTowers"');


%Rounds of the game - read data from XML
dataTower = fileread('towers.xml');
dataTower = ParseXML(dataTower);

scoreArray = [];
tracksCost = 0;

%Start rounds
noOfRounds=length(dataTower.Answer.TowerCoordinates{1}.Element);
for roundNo=1:noOfRounds
        
    %Placing tower on the tilemap
    x=dataTower.Answer.TowerCoordinates{1}.Element{roundNo}.x;
    y=dataTower.Answer.TowerCoordinates{1}.Element{roundNo}.y;
    if x>=0 && y>=0
        txt = AddTower(0,x,y);
        errorAddTower = SendData(IPAddressSend,portSend,txt,'Command','name="AddTower"');
        choiceOfPathData = SendData(IPAddressSend,portSend,[],'Command','name="GetChoiceOfPathData"');    
    end

    %Reading alternative statistics
    levelData = SendData(IPAddressSend,portSend,[],'Command','name="LevelData"');
    data = ParseXML(levelData);

    %Preparation of decision matrix based on the read statistics
    NoOfAlternatives=length(data.Answer.LevelPath{1}.Path);
    
    %Criterion 1 - cost - Path length (number of tiles)
    E=[GetVectorFromCell(data.Answer.LevelPath{1}.Path,'cost')]';
    
    %Criterion 2 - shotAtTiles - Number of fired tiles on the path
    E=[E [GetVectorFromCell(data.Answer.LevelPath{1}.Path,'shotAtTiles')]'];
    
    %Criterion 3 - towers - Number of towers on the path
    E=[E [GetVectorFromCell(data.Answer.LevelPath{1}.Path,'towers')]'];
    
    %Criterion 4 - min([sumTowerPlace TowerNumsCashCost]) - How many towers can be placed (free tiles and money)
    sumTowerPlace=[GetVectorFromCell(data.Answer.LevelPath{1}.Path,'sumTowerPlace')]';
    numberOfTowers=[GetVectorFromCell(data.Answer.LevelPath{1}.Path,'towers')]';
    if exist('OCTAVE_VERSION', 'builtin') ~= 0;
      TowerNumsCashCost=round(data.Answer.LevelPath{1}.Towers{1}.cash/data.Answer.LevelPath{1}.Tower{1}.cost);
    else
      TowerNumsCashCost=round(data.Answer.LevelPath{1}.Towers{1}.cash/data.Answer.LevelPath{1}.Tower{1}.cost,TieBreaker="minusinf"); 
    end
    TowerNumsCashCost=ones(NoOfAlternatives,1)*TowerNumsCashCost;
    E=[E min([sumTowerPlace-numberOfTowers TowerNumsCashCost],[],2)];%C4
    %Criterion 5 - EndBeginRatio for Enemy - How many % enemies reached the end of path
    %Criterion 6 - EndStartHealthRatio for Enemy - How many % of life the opponents have left on average after reaching the end
    EndBeginRatio=[];
    EndStartHealthRatio=[];
    for j=1:NoOfAlternatives
        EndBeginRatio=[EndBeginRatio;[GetVectorFromCell(data.Answer.LevelPath{1}.Path{j}.End{1}.Enemy,'enemies')]./[GetVectorFromCell(data.Answer.LevelPath{1}.Path{j}.Begin{1}.Enemy,'enemies')]];
        EndStartHealthRatio=[EndStartHealthRatio;[GetVectorFromCell(data.Answer.LevelPath{1}.Path{j}.End{1}.Enemy,'endMeanHealth')]./[GetVectorFromCell(data.Answer.LevelPath{1}.Enemy,'startHealth')]];
        if isnan(EndBeginRatio(j,2)) %If the enemy hasn't taken this path yet, put 1
            EndBeginRatio(j,2)=1;
        end
        if EndStartHealthRatio(j,2)==0 %If the enemy hasn't taken this path yet, put 1
            EndStartHealthRatio(j,2)=1;
        end
    end
    E=[E EndBeginRatio(:,2) EndStartHealthRatio(:,2)];%C5 C6
    E(isnan(E))=0;

	%MCDA method calling
    %Vector of criteria weights
    W=[2 10 8 1 20 10];
    %Vector of criteria preference directions: 1-max, 2-min
    PrefDirection=[2 2 2 2 1 1];
    [E,W,PrefDirection,ind] = RemoveCriteria(E,W,PrefDirection);
    fh=@TOPSIS;
    %fh=@VIKOR;
    Score=fh(E,W,PrefDirection,2);%call function for TOPSIS method
    %Score=fh(E,W,PrefDirection,0.5);%call function for VIKOR method
    funName=func2str(fh);
    [~,rank1]=sort(Score,'descend');%The number in rank1 indicates the path
    rank2=GenerateRanking(Score)';%The number in the rank2 means the position in the ranking
    roundNo
    ind
    E
    Score
    rank2
     
    %launching the enemy
    trackNumber=rank1(1)-1;
    txt = StartEnemy(trackNumber,trackNumber);
    errorStartEnemy = SendData(IPAddressSend,portSend,txt,'Command','name="StartEnemy"');
    
    %scores
    scoreArray = [scoreArray;Score];
    cost=GetVectorFromCell(data.Answer.LevelPath{1}.Path,'cost');
    tracksCost=tracksCost+cost(trackNumber+1);

    pause(10);
    %pause();
    roundNo=roundNo+1;
end

%Reading and calculating the game result for the MCDA method
levelData = SendData(IPAddressSend,portSend,[],'Command','name="LevelData"');
data = ParseXML(levelData);
EndEnemies=[];
BeginEnemies=[];
EndHealth=[];
for j=1:NoOfAlternatives
    EndEnemies=[EndEnemies;[GetVectorFromCell(data.Answer.LevelPath{1}.Path{j}.End{1}.Enemy,'enemies')]];
    BeginEnemies=[BeginEnemies;[GetVectorFromCell(data.Answer.LevelPath{1}.Path{j}.Begin{1}.Enemy,'enemies')]];
    EndHealth=[EndHealth;[GetVectorFromCell(data.Answer.LevelPath{1}.Path{j}.End{1}.Enemy,'endMeanHealth')]];
    if isnan(EndEnemies(j,2)) %If the enemy hasn't taken this path, put 0
        EndEnemies(j,2)=0;
    end
    if isnan(BeginEnemies(j,2)) %If the enemy hasn't taken this path, put 0
        BeginEnemies(j,2)=0;
    end
    if BeginEnemies(j,2)==0 %If the enemy hasn't taken this path, put 1
        EndHealth(j,2)=1;
    end
end
StartHealth=GetVectorFromCell(data.Answer.LevelPath{1}.Enemy,'startHealth');

EnemiesToEnd=sum(EndEnemies(:,2))
EnemiesMeanHealthRatio=mean(EndHealth(:,2))/StartHealth
tracksCost
PngName=['../Latex/' funName 'scoreRounds.png'];
HtmlName=['../Latex/' funName 'scoreRounds.html'];
GenerateReport(PngName,HtmlName,scoreArray,funName,EnemiesToEnd,EnemiesMeanHealthRatio,tracksCost);