% Results GAMS CASE 30 IEEE, STHS 
clc ;clear all;
clear figure; close all;
format shortG


% STUDY CASES PATH
% Add the path to the study case files
% addpath('Path to files')

%run Case_1.m   % Case 30IEEE, Unoptimized case
%run Case_2.m   % Case 30IEEE, Optimized base case
run Case_3.m   % Case 30IEEE, Optimized with Load Shedding Cut (LSH)


if exist ('LMP_P') == 1                                              
disp('Lowest Local Marginal Price $/MWh') 
MinPML=min(min(abs(LMP_P)))
disp('Highest Local Marginal Price $/MWh')
MaxPML=max(max(abs(LMP_P)))
end    
%Total Costs by Technology
if exist ('Potencias_totales') == 1 
    if length(Potencias_totales)== 8 && exist ('Potencias_totales') == 1  %hay perdidas
    PtTerm = Potencias_totales(1); PtEol = Potencias_totales(2); PtSol = Potencias_totales(3); PtPchr = Potencias_totales(4);
    PtPdis = Potencias_totales(5); PtPlsh = Potencias_totales(6); PtPloss = Potencias_totales(7); PtPload = Potencias_totales(8);
    disp('       PtTerm       PtEol        PtSol        PtPchr        PtPdis       PtPlsh       PtPloss    PtPload');
    disp(Potencias_totales)
    elseif length(Potencias_totales)== 9 && exist ('Potencias_totales') == 1  %hay perdidas e HIDROS
    PtTerm = Potencias_totales(1); Pth = Potencias_totales(2); PtEol = Potencias_totales(3); PtSol = Potencias_totales(4); PtPchr = Potencias_totales(5);
    PtPdis = Potencias_totales(6); PtPlsh = Potencias_totales(7); PtPloss = Potencias_totales(8); PtPload = Potencias_totales(9);
    disp('       PtTerm         PtH         PtEol       PtSol         PtPchr      PtPdis       PtPlsh       PtPloss    PtPload');
    disp(Potencias_totales)
    else
    PtTerm = Potencias_totales(1); PtEol = Potencias_totales(2); PtSol = Potencias_totales(3); PtPchr = Potencias_totales(4);
    PtPdis = Potencias_totales(5); PtPlsh = Potencias_totales(6); PtPload = Potencias_totales(7);  
    disp('       PtTerm       PtEol        PtSol        PtPchr        PtPdis       PtPlsh       PtPload');
    disp(Potencias_totales)
    end   

    if length(Costos_totales)== 8 && exist ('Costos_totales') == 1  
    PtTerm = Costos_totales(1); PtEol = Costos_totales(2); PtSol = Costos_totales(3); PtPchr = Costos_totales(4);
    PtPdis = Costos_totales(5); PtPlsh = Costos_totales(6); PtPloss = Costos_totales(7); PtPload = Costos_totales(8);
    disp('       C(Term)     Cvar(Term)    C(Eol)       C(Sol)        C(Pchr)        C(Pdis)   C(Plsh)      Ctotal');
    disp(Costos_totales)
    elseif length(Costos_totales)== 9 && exist ('Costos_totales') == 1  
    PtTerm = Costos_totales(1);   
    PtEol = Costos_totales(2);
    PtH = Costos_totales(3); PtSol = Costos_totales(4); PtPchr = Costos_totales(5);
    PtPdis = Costos_totales(6); PtPlsh = Costos_totales(7); PtPloss = Costos_totales(8); PtPload = Costos_totales(9);
    disp('       C(Term)     Cvar(Term)  C(Hidros)    C(Eol)       C(Sol)        C(Pchr)        C(Pdis)   C(Plsh)      Ctotal');
    disp(Costos_totales)
    end   
end 

%i=j = nodes, t = TIME INTERVALS, t: vector, tt = time intervals
if exist ('LMP_P') == 1                                                     
[i,tt]=size(LMP_P);
else
[i,tt]=size(P_Load);
end
j=i;
t=1:1:tt;


%Sum of generation from all thermal generators over time t in MW
GenT=length(PTermos); %number of thermal generators
[Pterm]=zeros(1,tt);
for n=1:1:tt
Pterm(n)=sum(PTermos((1:end),(n))) ;
end
Pterm;
if exist('QTermos')==1
%Sum of Q from all thermal generators per time t in MVAR
[Qterm]=zeros(1,tt);
for n=1:1:tt
Qterm(n)=sum(QTermos((1:end),(n))) ;
end
Qterm;
end
%Sum of LOAD SHEDDING (LOAD SHEDDING) if there is any in each time interval 
% of time t in MW
[Plshh]=zeros(1,tt);
for n=1:1:tt
Plshh(n)=sum(Plsh((1:end),(n))) ;
end
Plshh;

%Sum of generation from all hydraulic generators per time t in MW

GenH=length(PHidros); %number of hydraulic generators
[PH]=zeros(1,tt);
for n=1:1:tt
PH(n)=sum(PHidros((1:end),(n))) ;
end
PH;

%Sum of generation from all wind generators per time t in MW
GenE=length(Pwind); %number of wind generators
[Peol]=zeros(1,tt);
for n=1:1:tt
Peol(n)=sum(Pwind((1:end),(n))) ;
end
Peol;

%Sum of generation from all solar generators per time t in MW
GenPV=length(Psolar); %number of solar generators
[Ppv]=zeros(1,tt);
for n=1:1:tt
Ppv(n)=sum(Psolar((1:end),(n))) ;
end
Ppv;

%Sum of storage per time t in MW
%HOMOLOGATE
if exist ('Storage_Ec') == 1   

ESS=length(Storage_Ec); %number of storages
[SOCt]=zeros(1,tt);
for n=1:1:tt
SOCt(n)=sum(Storage_Ec((1:end),(n))) ;  %TOTAL STORAGE STATE OF CHARGE
end
SOCt;
%Sum of storage load power per time t in MW;
for n=1:1:tt
Pcargaesst(n)=sum(PCarga_Storage((1:end),(n))) ;
end
Pcargaesst;
%Sum of storage discharge power per time t in MW
[Pdisess]=zeros(1,tt);
for n=1:1:tt
Pdisesst(n)=sum(PDescarga_Storage((1:end),(n))) ;
end
Pdisesst;
end



%%%%Total generation sums to obtain losses
%%Plsh is not considered as electrical losses, if there is load shedding it is summed and graphed separately
[PgenTOTALt]=zeros(1,tt);
for n=1:1:tt
if exist ('PHidros') == 1    
PgenTOTALt(n)=sum(Pterm((1:end),(n)))+  sum(PH((1:end),(n)))+ sum(Peol((1:end),(n)))+  sum(Ppv((1:end),(n)))+sum(Pdisesst((1:end),(n)));
else
PgenTOTALt(n)=sum(Pterm((1:end),(n))) + sum(Peol((1:end),(n)))+  sum(Ppv((1:end),(n)))+sum(Pdisess((1:end),(n)));   
end

end
PgenTOTALt;
%Sum of total load P per time t in MW
[Pload]=zeros(1,tt);
for n=1:1:tt
Pload(n)=sum(P_Load((1:end),(n))) ;
end
Pload;

if exist('QTermos')==1
%%%%Total generation sums to obtain losses
[QgenTOTALt]=zeros(1,tt);
for n=1:1:tt
QgenTOTALt(n)=sum(Qterm((1:end),(n)));
end
QgenTOTALt;

%Sum of total load Q per time t in Mvar
[Qload]=zeros(1,tt);
for n=1:1:tt
Qload(n)=sum(Q_Load((1:end),(n))) ;
end
Qload;
end
%Total losses P per time t in MW
[Plosses]=zeros(1,tt);
for n=1:1:tt
Plosses(n)=abs(sum(PgenTOTALt((1:end),(n)))- sum(Pload((1:end),(n))) - sum(Pcargaesst((1:end),(n))) + sum(Plshh((1:end),(n))) )  ;
end
Plosses;


figure(1)  %plot power vs time
plot(t,(Pload+PCarga_Storage),'k-o','LineWidth',2)
grid on
hold on
plot(t,(Pload),'m-s','LineWidth',2)
plot(t,Pterm,'r-o','LineWidth',2)
if exist ('PHidros') == 1  
plot(t,PH,'b-*','LineWidth',2)
end
plot(t,Peol,'g-s','LineWidth',2)
plot(t,Ppv,'y-o','LineWidth',2)
plot(t,PDescarga_Storage,'-o','LineWidth',2)
ylabel('MW','FontSize',13,'FontName','times')
xlabel('t','FontSize',13,'FontName','times')
title('Active power demand and generation by technology type','FontSize',15,'FontName','times')
if exist ('PHidros') == 1  
legend('Demand+PchrESS','Demand','Thermal','Hydro','Wind','Solar','PdisESS','LOCATION','BEST','FontName','times' )
else
legend('Demand+PchrESS','Demand','Thermal','Wind','Solar','PdisESS','LOCATION','BEST','FontName','times')
end

%to prevent appearing in exponential format
ax = gca;
ax.YAxis.Exponent = 0; 

%color = uisetcolor([1 1 1])  %this command allows us to choose a color in Matlab format
figure(2)
area(Pload+PCarga_Storage,'FaceColor','m','EdgeColor',[0.9216 0 0.5686]); hold on; 
area(Pload,'FaceColor','k'),area(Pterm,'FaceColor','r'),area(Peol,'FaceColor','g'), area (Ppv,'FaceColor','y'),area(PDescarga_Storage,'FaceColor','b')
ax2 = gca;
ax2.XGrid = 'on';
ylabel('MW','FontSize',13,'FontName','times')
xlabel('t ','FontSize',13,'FontName','times')
title('Active power demand and generation by technology type','FontSize',15,'FontName','times')
if exist ('PHidros') == 1  
legend('Demand+PchrESS','Demand','Thermal','Hydro','Wind','Solar','PdisESS','LOCATION','best','FontName','times' )
else
legend('Demand+PchrESS','Demand','Thermal','Wind','Solar','PdisESS','LOCATION','best','FontName','times')
end

PloadTotal= sum   (Pload);
PtermTotal= sum (Pterm);
if exist ('PHidros') == 1  
PHTotal= sum(PH);
end
PeolTotal= sum(Peol);
PpvTotal= sum(Ppv);
PcargaTotal= sum(Pcargaesst);
PdescargaTotal= sum(Pdisesst);

if exist ('PHidros') == 1  
YY=[PtermTotal;PHTotal;PeolTotal;PpvTotal;PdescargaTotal];
else
YY=[PtermTotal;PeolTotal;PpvTotal;PdescargaTotal];
end

figure (3)
piecolor=pie(YY);
title('Total active generation power as percentage','FontSize',15,'FontName','times')
if exist ('PHidros') == 1 
%legend('Thermal','Hydro','Wind','Solar','Pdischarge ESS','LOCATION','BEST','FontName','times')
labels = {'Thermal', 'Hydro', 'Wind', 'Solar', 'Pdischarge ESS'};
% Specific colors for each sector (Red, Blue, Green, Yellow, Brown)
colors = [1 0 0;  % Red
          0 0 1;  % Blue
          0 1 0;  % Green
          1 1 0;  % Yellow
          0.6 0.3 0];  % Brown
%  Assign colors
    for k = 1:length(piecolor)
        if mod(k, 2) == 1
        piecolor(k).FaceColor = colors((k+1)/2, :);
        end
    end
disp(piecolor);
legend(labels, 'LOCATION','BEST','FontName','times');
else
labels = {'Thermal', 'Wind', 'Solar', 'Pdischarge ESS'};
% Specific colors for each sector (Red, Green, Yellow, Brown)
colors = [1 0 0;  % Red
          0 1 0;  % Green
          1 1 0;  % Yellow
          0.6 0.3 0];  % Brown
% Assign colors
for k = 1:length(piecolor)
   if mod(k, 2) == 1
        piecolor(k).FaceColor = colors((k+1)/2, :);
   end
end
disp(piecolor);
legend(labels, 'LOCATION','BEST','FontName','times');
end

figure(4)  %individual storage behavior
plot(t,Storage_Ec(1,:),'k-o','LineWidth',2)
hold on; grid on
plot(t,PCarga_Storage(1,:),'g-*','LineWidth',2)
plot(t,PDescarga_Storage(1,:),'r-s','LineWidth',2)
legend('SOC(MWh)','MW Charge','MW Discharge','LOCATION','BEST','FontName','times' )
title('Energy Storage System Dispatch','FontSize',15,'FontName','times')
%title('ESS at bus 7')
ylabel('MW','FontSize',13,'FontName','times')
xlabel('t','FontSize',13,'FontName','times')

if exist ('LMP_P') == 1   

    figure(5)
    [ss pp]=size(LMP_P);
    for n=1:ss
        plot(t,LMP_P(n,:),'-o','LineWidth',1.5); hold on; grid on;
    end  
    grid on
    title('Local Marginal Price (LMP) of P ','FontSize',15,'FontName','times')
    ylabel('$/MWh','FontSize',13,'FontName','times')
    xlabel('t','FontSize',13,'FontName','times')
    labels=(1:length(LMP_P));
    labels=num2str(labels');
    legend(labels,'LOCATION','best','FontName','times')
    ax = gca;
    ax.YAxis.Exponent = 0;

end

figure(7)
[a , b]=size(PTermos);
for n=1:a
    plot(t,PTermos(n,:),'-o','LineWidth',2); hold on; grid on;
end 
grid on
title('Active Power Dispatch, Thermal Units','FontSize',15,'FontName','times')
ylabel('MW','FontSize',13,'FontName','times')
xlabel('t','FontSize',13,'FontName','times')
labels=(1:length(PTermos));
labels=num2str(labels');
legend(labels,'LOCATION','best','FontName','times')


if exist('QTermos')==1
figure(8)
[c , d]=size(QTermos);
for n=1:c
    plot(t,QTermos(n,:),'-s','LineWidth',2); hold on; grid on;
end 
title('Reactive Power Dispatch, Thermal Units','FontSize',15,'FontName','times')
ylabel('Q(MVAr)','FontSize',13,'FontName','times')
xlabel('t','FontSize',13,'FontName','times')
legend('G1','G2','G3','G4','G5','G6','LOCATION','NE','FontName','times')
end

figure(9)
[e f]=size(Plsh);
for n=1:e
    plot(t,Plsh(n,:),'-o','LineWidth',2); hold on; grid on;
end  
title('Nodal load shedding','FontSize',15,'FontName','times')
ylabel('Plsh','FontSize',13,'FontName','times')
xlabel('t','FontSize',13,'FontName','times')
labels=(1:length(Plsh));
labels=num2str(labels');
legend(labels,'LOCATION','best','FontName','times');



figure(10)
[ss pp]=size(Pwind);
for n=1:ss
    plot(t,Pwind(n,:),'-s','LineWidth',2); hold on; grid on;
end    
title('Active Power Dispatch, Wind Units','FontSize',15,'FontName','times')
ylabel('MW','FontSize',13,'FontName','times')
xlabel('t','FontSize',13,'FontName','times')
%labels=(1:length(Pwind));
%labels=num2str(labels');
legend('Wind Gen 1, Wind Gen 2, Wind Gen 3','LOCATION','BEST','FontName','times')

figure(11)
[ss pp]=size(Psolar);
for n=1:ss
    plot(t,Psolar(n,:),'-x','LineWidth',2); hold on; grid on;
end    
title('Active Power Dispatch, Solar Units','FontSize',15,'FontName','times')
ylabel('MW','FontSize',13,'FontName','times')
xlabel('t','FontSize',13,'FontName','times')
%labels=(1:length(Pwind));
%labels=num2str(labels');
legend(' PV Plant 1','PV Plant 2','PV Plant 3','LOCATION','NE')

if exist ('Voltaje_nodal') == 1 
figure(12)
[ss pp]=size(Voltaje_nodal);
for n=1:ss
    plot(t,Voltaje_nodal(n,:),'-o','LineWidth',2); hold on; grid on;
end    
title('Nodal Voltage in p.u.','FontSize',15,'FontName','times')
ylabel('Voltage in p.u.','FontSize',13,'FontName','times')
xlabel('t','FontSize',13,'FontName','times')
labels=(1:length(Voltaje_nodal));
labels=num2str(labels');
axis([1 tt 0.94 1.06])
legend(labels,'LOCATION','best','FontName','times')
end

%optional
% if exist ('Angulo_nodal') == 1 
% figure(13)
% [ss pp]=size(Angulo_nodal);
% for n=1:ss
%     plot(t,Angulo_nodal(n,:),'-o','LineWidth',2); hold on; grid on;
% end    
% title('Nodal Angle','FontSize',15,'FontName','times')
% ylabel('Degrees(º).','FontSize',12,'FontName','times')
% xlabel('t ','FontSize',12,'FontName','times')
% labels=(1:length(Angulo_nodal));
% labels=num2str(labels');
% legend(labels,'LOCATION','best','FontName','times')
% end

% if exist ('Angulo_Theta') == 1 
% figure(13)
% [ss pp]=size(Angulo_Theta);
% for n=1:ss
%     plot(t,Angulo_Theta(n,:),'-o','LineWidth',2); hold on; grid on;
% end    
% title('Nodal Angle','FontSize',15,'FontName','times')
% ylabel('Degrees(º).','FontSize',12,'FontName','times')
% xlabel('t ','FontSize',12,'FontName','times')
% labels=(1:length(Angulo_Theta));
% labels=num2str(labels');
% legend(labels,'LOCATION','best','FontName','times')
% end


if exist ('PHidros') == 1 
figure(14)
[gg hh]=size(PHidros);
for n=1:gg
    plot(t,PHidros(n,:),'-v','LineWidth',2); hold on; grid on;
end    
title('Active Power Dispatch, Hydroelectric Units')
ylabel('MW','FontSize',12,'FontName','times')
xlabel('t','FontSize',12,'FontName','times')
labels=(1:length(PHidros));
labels=num2str(labels');
legend(labels,'LOCATION','best','FontName','times')

figure(15)
title('Reservoir Hydraulic Variables')
[ii jj]=size(Volumen_embalse);
for n=1:ii
  subplot(3,1,1)  
    plot(t,Volumen_embalse(n,:),'-+','LineWidth',2); hold on; grid on;
end   
    title('Reservoir volume per hour','FontSize',15,'FontName','times')
    ylabel('Vol(m^3)','FontSize',12,'FontName','times')
    xlabel('t (','FontSize',12,'FontName','times')
legend('Reservoir 1','Reservoir 2','Reservoir 3','Reservoir 4','LOCATION','best','FontName','times')
for n=1:ii
  subplot(3,1,2)  
    plot(t,Caudal_hidros(n,:),'-s','LineWidth',2); hold on; grid on;
end    
    title('Flow rate','FontSize',15,'FontName','times')
    ylabel('Flow rate(m^3/s)','FontSize',12,'FontName','times')
    xlabel('t','FontSize',12,'FontName','times')
legend('Reservoir 1','Reservoir 2','Reservoir 3','Reservoir 4','LOCATION','best','FontName','times')
for n=1:ii
  subplot(3,1,3)  
    plot(t,Derrame_hidros(n,:),'-<','LineWidth',2); hold on; grid on;
end    
    title('Spills','FontSize',15,'FontName','times')
    ylabel('(m^3)','FontSize',12,'FontName','times')
    xlabel('t','FontSize',12,'FontName','times')
legend('Reservoir 1','Reservoir 2','Reservoir 3','Reservoir 4','LOCATION','best','FontName','times')
end


figure(16)  %Losses
plot(t,(Plosses),'k-o','LineWidth',2)
grid on
hold on
ylabel('MW','FontSize',13,'FontName','times')
xlabel('t','FontSize',13,'FontName','times')
title('Total Losses per time','FontSize',15,'FontName','times')
legend('Losses per time','LOCATION','best','FontName','times')

