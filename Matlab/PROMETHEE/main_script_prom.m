%Variables used
%%NoOfCriteria - number of criteria
%%NoOfAlternatives - number of alternatives
%%E - decision matrix cell
%%Wf - fuzzy weights vector cell
%%PrefDirection - preference directions vector
%%PrefFun - preference functions vector
%%q - indifference thresholds vector
%%p - preference thresholds vector
%%s - Gaussian thresholds vector
clear all;
close all;
%Decision problem model
%%Decision-maker preference model
NoOfAlternatives=7;%Number of alternatives
NoOfCriteria=12;%Number of criteria
W=[0.165 0.165 0.11 0.055 0.055 0.075 0.075 0.1 0.03 0.07 0.06 0.04];%Weights of criteria
PrefDirection=[1 1 1 1 1 1 1 1 1 1 1 1];%Preference direction (1-max;2-min)
PrefFun=3*ones(1,12);%Preference functions
q=[1 1 1 0 1 0 1 1 0 2 1 1];%Indifference thresholds 
p=[2 3 3 1 3 1 2 2 1 4 3 2];%Preference thresholds
s=[0 0 0 0 0 0 0 0 0 0 0 0];%Gaussian thresholds
%%Alternative performance model
[E,names,~]=xlsread('alternatives.xlsx','values','A3:M9');%read data from file
names=names(:,1);%define alternative names
%PROMETHEE computations
[Phi,PhiPlus,PhiMinus,Pi,W,P,d]=PROMETHEE(NoOfCriteria,NoOfAlternatives,E,W,PrefDirection,PrefFun,q,p,s);
%Rank alternatives
rankPhi=genRanking(round(Phi,8));
rankPhiPlus=genRanking(round(PhiPlus,8));
rankPhiMinus=genRanking(1-round(PhiMinus,8));
%Print results
showResults(NoOfAlternatives,names,rankPhi',rankPhiPlus',rankPhiMinus',Phi,PhiPlus,PhiMinus);
plotResults(NoOfAlternatives,names,rankPhi',rankPhiPlus',rankPhiMinus',Phi,PhiPlus,PhiMinus);
plotPartialOrder(NoOfAlternatives,names,rankPhiPlus',rankPhiMinus');

%GAIA
PROMGaiaC(NoOfCriteria,NoOfAlternatives,E,W,PrefDirection,PrefFun,q,p,s)