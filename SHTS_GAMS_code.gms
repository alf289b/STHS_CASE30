$title Short-Term Day-Ahead Hydrothermal Scheduling with Energy Renewables Variable, Storage, Load Shedding
$onText
Case 30 IEEE 
6 thermal generators
3 wind, 3 solar
41 lines
With load shedding
With 1 ESS
4 hydro units in cascade with 40 MW installed capacity
$offText
option  nlp=CONOPT4;

*It is strongly recommended to import as much data as possible for Sets and Tables using a GDX file
*From MATLAB or Excel to GAMS and not insert them manually in GAMS for better information control.



Set

   i                'number of buses'               / 1*30 /     
   t                'time intervals 1-24'           / 1*24 /                
   NG               'number of thermal generators'  / 1*6 /         
   GenEol           'number of wind generators'     / 1*3 /
   H                'number of hydro generators'    / 1*4 / 
   S                'solar plants'                  / 1*3 /
   ESS              'energy storage systems'        / 1 /;
   
Alias (i,j);
*if we want to refer to i differently, j has the same sets as i
 
  
*BEGIN FORMAT FILE GDX MATLAB TO GAMS
*Parameter  Poner todos los parametros aqui (Paramameter 1, t)... (ParameterN,t) del archivo GDX ;
*$if not set gdxin $set gdxin NAME_GDX_FILE (Call Matlab file previously on the path of the GAMS FILE)
*$GDXIN  %gdxin%
*$LOAD Set 1, Table 1...... Set N Table N
*$LOAD GenEolData  EolPredict S TitleGenDataSol GenSolData  SolPredict  PloadPos  ESS TitleGenDataESS ESSData
$GDXIN
*END FORMAT FILE GDX MATLAB TO GAMS


Scalar
   Sbase      'MVA base'          / 100 /
   VOLL 'Value Of Loss of Load'  /10000/

*penalty costs for load shedding.
 

*CONNECTIVITY OF CASCADE HYDROS
Alias (H,Hcascade);
*Indicates that Hcascade has the same sets as H
set upstream(H,Hcascade);
upstream( '3' ,Hcascade)$(ord(Hcascade)<3)=yes ;
*h1 and h2 link to h3
upstream('4' , '3 ')=yes ;
*h3 link to h4

parameter PerfilCarga(t) From ANN
/
1   0.7978 
2   0.7510 
3   0.7224 
4   0.7151 
5   0.7282 
6   0.7571 
7   0.7957 
8   0.8377 
9   0.8782 
10  0.9142
11  0.9441 
12  0.9673 
13  0.9841 
14  0.9948 
15  1.0000 
16  1.0000 
17  0.9952 
18  0.9859 
19  0.9724 
20  0.9553 
21  0.9356 
22  0.9142 
23  0.8926 
24  0.8721
/;

   
Parameter PLpos(i)
/
1  0
2  21.7
3  2.4
4  7.6
5  0
6  0
7  22.8
8  30
9  0
10 5.8
11 0
12 11.2
13 0
14 6.2
15 8.2
16 3.5
17 9
18 3.2
19 9.5
20 2.2
21 17.5
22 0
23 3.2
24 8.7
25 0
26 3.5
27 0
28 0
29 2.4
30 10.6
/
;


Parameter PL(i)
/
1  0
2  21.7
3  2.4
4  7.6
5  0
6  0
7  22.8
8  30
9  0
10 5.8
11 0
12 11.2
13 0
14 6.2
15 8.2
16 3.5
17 9
18 3.2
19 9.5
20 2.2
21 17.5
22 0
23 3.2
24 8.7
25 0
26 3.5
27 0
28 0
29 2.4
30 10.6
/
;

Parameter QL(i)
/
1  0
2  12.7
3  1.2
4  1.6
5  0
6  0
7  10.9
8  30
9  0
10 2
11 0
12 7.5
13 0
14 1.6
15 2.5
16 1.8
17 5.8
18 0.9
19 3.4
20 0.7
21 11.2
22 0
23 1.6
24 6.7
25 0
26 2.3
27 0
28 0
29 0.9
30 1.9/;

Table GenData(NG,*) 'Thermal units characteristics'
        Pmax   Pmin  a             b      c       Qmax    Qmin     Vg     RU    RD    Pg        Qg 
*        MW     MW   ax^2           bx     c       mvar   mvar   Vactual  mw/h   mh/h   Pact  Qact
   1    80.00  0     0.02          2.0    0        150    -20     1.06   40     40    41.5421  -5.43643 
   2    80.0   0     0.0175        1.75   0         60    -20     1.045  40     40    55.4019   1.67476 
   3    50.0   0     0.0625        1.0    0         62.5  -15     1.01   25     25    22.74033  4.1971 
   4    55.0   0     0.00834       3.25   0         48.7  -15     1.01   27.5   27.5  39.909    31.7544  
   5    30.0   0     0.025         3.0    0         40    -10     1.082  15     15    16.267    6.95985  
   6    40.0   0     0.025         3.0    0         44.7  -15     1.071  20     20    16.2002   35.9303 ;


set GBconect (i,NG)  Index of connectivity of thermal generating units
/   1.1
    2.2
    22.3
    27.4
    23.5
    13.6 /;
 

*Hydro Data
set Hidroconect(i,H) Connectivity index of hydro buses (node h) all to bus 4
/4.1 
 4.2 
 4.3 
 4.4 /;

table HidroData (H,*)
   c1      c2    c3    c4   c5   c6   Volmin    Volmax   Volini   Volfin     qaudmin    qaudmax      Phmin   Phmax        Delay      CH    LossCofH  
**                                                                                                                 $/MWh
1 -0.0042 -0.42 0.030 0.90 10.0 -50    80       130      100      80          0.001     0.5          0       10            2        0.0    0.000012
2 -0.0040 -0.30 0.015 1.14  9.5 -70    30       130      100      40          0.001     0.4          0       10            1        0.0    0.000010
3 -0.0016 -0.30 0.014 0.55  5.5 -40    50       120      100      50          0.001     0.5          0       10            4        0.0    0.000008
4 -0.0030 -0.31 0.027 1.44 14.0 -90    40        75       60      50          0.001     0.4          0       10            0        0.0    0.000006;


Table inflow ( t ,H)
    1      2       3        4
1  10      8       8.1      2.8
2   9      8       8.2      2.4
3   8      9       4        1.6
4   7      9       2        0      
5   6      8       3        0
6   7      7       4        0
7   8      6       3        0
8   9      7       2        0
9  10      8       1        0
10 11      9       1        0
11 12      9       1        0
12 10      8       2        0
13 11      8       4        0
14 12      9       3        0
15 11      9       3        0
16 10      8       2        0
17  9      7       2        0
18  8      6       2        0 
19  7      7       1        0
20  6      8       1        0
21  7      9       2        0
22  8      9       2        0
23  9      8       1        0
24 10      8       0        0;

 
Table LN(i,j,*) 'transmission network technical characteristics'
             r       x       b       limit         
*         pu       pu          pu         MW
1 .2         0.02   0.06    0.03    130
1 .3         0.05   0.19    0.02    130
2 .4         0.06   0.17    0.02    65
3 .4         0.01   0.04    0       130
2 .5         0.05   0.2     0.02    130
2 .6         0.06   0.18    0.02    65
4 .6         0.01   0.04    0       90
5 .7         0.05   0.12    0.01    70
6 .7         0.03   0.08    0.01    130
6 .8         0.01   0.04    0       32
6 .9         0      0.21    0       65
6 .10        0      0.56    0       32
9 .11        0      0.21    0       65
9 .10        0      0.11    0       65
4 .12        0      0.26    0       65
12.13        0      0.14    0       65
12.14        0.12   0.26    0       32
12.15        0.07   0.13    0       32
12.16        0.09   0.2     0       32
14.15        0.22   0.2     0       16
16.17        0.08   0.19    0       16
15.18        0.11   0.22    0       16
18.19        0.06   0.13    0       16
19.20        0.03   0.07    0       32
10.20        0.09   0.21    0       32
10.17        0.03   0.08    0       32
10.21        0.03   0.07    0       32
10.22        0.07   0.15    0       32
21.22        0.01   0.02    0       32
15.23        0.1    0.2     0       16
22.24        0.12   0.18    0       16
23.24        0.13   0.27    0       16
24.25        0.19   0.33    0       16
25.26        0.25   0.38    0       16
25.27        0.11   0.21    0       16
28.27        0      0.4     0       65
27.29        0.22   0.42    0       16
27.30        0.32   0.6     0       16
29.30        0.24   0.45    0       16
8 .28        0.06   0.2     0.02    32
6 .28        0.02   0.06    0.01    32;                              
*----------------------------------------- 


table GenEolData (GenEol,*) 'Wind Generator Data'
  RUeol RDeol   CG  Pwmax   Pwmin
1 7.875  7.875  0.1 19.5417 0
2 9      9      0.1 22.3333 0
3 10.125 10.125 0.1 25.125  0;
*******************************************************************   
set GBEolconect (i,GenEol)  Connectivity index of wind generating units
/     1.1  
     13.2
     22.3 /;
     
Table EolPredict(GenEol,t) 'Wind generation forecast data over time'
  1        2        3        4        5        6        7        8        9        10       11       12       13       14       15       16   17       18       19       20       21       22       23       24
1 0.348592 0.385871 0.456674 0.511105 0.511001 0.460428 0.406257 0.406882 0.464025 0.520959 0.527685 0.480918 0.413973 0.371376 0.360167 0.65 0.625391 0.580396 0.541606 0.5244   0.229718 0.236027 0.242649 0.249218
2 0.402222 0.445235 0.526931 0.589737 0.589617 0.531263 0.468758 0.469479 0.535413 0.601107 0.608867 0.554905 0.477661 0.428511 0.415577 0.75 0.721605 0.669688 0.62493  0.605077 0.26506  0.272339 0.279979 0.287559
3 0.455851 0.5046   0.597189 0.668368 0.668232 0.602098 0.531259 0.532077 0.606802 0.681255 0.69005  0.628892 0.541349 0.485646 0.470987 0.85 0.817819 0.75898  0.708254 0.685754 0.300401 0.308651 0.31731  0.3259;


*******************   One Storage at node 7
*P discharge MAX = P charge Max = 20% Storage capacity
table ESSData (ESS,*) 'ESS Data' 
  PUB  EeUB nch  ndis Cdis Cchr
1 26.8 134  0.95 0.9  0.2  0.1 ;
    
    set ESSconect (i,ESS)  Index of ESS storage connectivity
/      7.1  /;

   Parameter ESS0(ESS);
* Initial state 20% due to ESS constraint
 ESS0(ESS) =0.2*ESSData(ESS,'EeUB')/sbase;

****************************************************
 
table GenSolData (S,*) 'Solar plants data'
  CS  PSmax   Psmin
1 0.1 22.3333 0
2 0.1 22.3333 0
3 0.1 22.3333 0;

*******************************************************************   
set GBSolconect (i,S)  Connectivity index of solar units
/     3.1
      4.2
      6.3 /;
 
Table SolPredict(S,t) 'Forecast data for solar units by time'     
    1    2   3   4   5   6   7    8         9        10       11       12       13       14  15       16       17       18      19       20        21   22   23   24
1   0    0   0   0   0   0   0    0.014949  0.29619  0.73628  0.90466  0.97589  0.99047  1   0.99865  0.93823  0.87768  0.7301  0.36529  0.056011  0    0    0    0
2   0    0   0   0   0   0   0    0.0119592 0.236952 0.589024 0.723728 0.780712 0.792376 0.8 0.79892  0.750584 0.702144 0.58408 0.292232 0.0448088 0    0    0    0
3   0    0   0   0   0   0   0    0.0134541 0.266571 0.662652 0.814194 0.878301 0.891423 0.9 0.898785 0.844407 0.789912 0.65709 0.328761 0.0504099 0    0    0    0  ;

******************************************************************

*ij = ji
LN(i,j,'x')$(LN(i,j,'x')=0) = LN(j,i,'x');
LN(i,j,'r')$(LN(i,j,'r')=0) = LN(j,i,'r');
LN(i,j,'b')$(LN(i,j,'b')=0) = LN(j,i,'b');
LN(i,j,'Limit')$(LN(i,j,'Limit')=0) =   LN(j,i,'Limit');
*Forming Zbus
*The conditional with the limit is to prevent zero values and handle the different cases of arctan.
LN(i,j,'bij')$LN(i,j,'Limit')       = 1/LN(i,j,'x');
*sqr is square for raising to the power of 2, it is not the same as sqrt.
LN(i,j,'z')$LN(i,j,'Limit') = sqrt(sqr(LN(i,j,'x')) + sqr(LN(i,j,'r')));
LN(j,i,'z')$(LN(i,j,'z')=0) = LN(i,j,'z');
LN(i,j,'th')$(LN(i,j,'Limit') and LN(i,j,'x') and LN(i,j,'r'))   = arctan(LN(i,j,'x')/(LN(i,j,'r')));
LN(i,j,'th')$(LN(i,j,'Limit') and LN(i,j,'x') and LN(i,j,'r')=0) = pi/2;
LN(i,j,'th')$(LN(i,j,'Limit') and LN(i,j,'r') and LN(i,j,'x')=0) = 0;
LN(j,i,'th')$LN(i,j,'Limit') = LN(i,j,'th');

*conect Bus connectivity matrix
Parameter conect(i,j);
conect(i,j)$(LN(i,j,'limit') and LN(j,i,'limit')) = 1;
conect(i,j)$(conect(j,i)) = 1;


Variables
OF           Objective function
Pij(i,j,t)   Active power Pij
Qij(i,j,t)   Reactive power Qij
Pg(NG,t)     Active power generated
Qg(NG,t)     Reactive power generated
Va(i,t)      Voltage angle of the bus
V(i,t)       Voltage of the bus
Pw(genEol,t) Wind power at the bus
Vol(H,t)     Reservoir volume for hydro (H)
R(H,t)       Reservoir outflow (R) for cascade hydropower units or Q(Ph) or discharge D
Spill(H,t)   Spill at the reservoir exit for cascade hydro plants
Ph(H,t)      Hydro unit power
eESS(ESS,t)  Energy storage (ESS)
PdisEss(ESS,t) Energy discharge power from ESS
PchrEss(ESS,t) Energy charging power to ESS
Ps(S,t)      Solar power
Plsh(i,t)    Load shedding active power (load shedding)
costPg       Thermal generator costs
costH        Hydro costs
costW        Wind costs
costS        Solar costs
costPlshh    Load shedding costs
CPchr        Storage charging costs
CPdis        Storage discharging costs
costWc       Wind curtailment costs
costSc       Solar curtailment costs
HidroCost    Hydro costs
Qgen         Total generated reactive power of the system
Pgen         Total generated active power of the system
Phtotal      Total hydraulic power
OBJ          For solving system of equations without optimization ;

*****THERMAL GENERATION constraints****
Pg.lo(NG,t) = GenData(NG,'Pmin')/Sbase;
Pg.up(NG,t) = GenData(NG,'Pmax')/Sbase;
Pg.l(NG,t) =  1*GenData(NG,'Pg')/Sbase;
Qg.lo(NG,t) = GenData(NG,'Qmin')/Sbase;
Qg.up(NG,t) = GenData(NG,'Qmax')/Sbase;
Qg.l(NG,t) =  1*GenData(NG,'Qg')/Sbase;


*************WIND constraints***********
Pw.up(GenEol,t) =GenEolData(GenEol,'Pwmax')*1*EolPredict(GenEol,t)/Sbase;
Pw.lo(GenEol,t) =GenEolData(GenEol,'Pwmin')/Sbase;


*************SOLAR constraints***********
Ps.up(S,t) =GenSolData(S,'Psmax')*1*SolPredict(S,t)/Sbase;
Ps.lo(S,t) =GenSolData(S,'Psmin')/Sbase;

**************constraints STORAGE********************
eESS.up(ess,t)=1*(ESSData(ESS,'EeUB'))/Sbase;
eESS.lo(ess,t)=0;

*SOC_t24= SOCt_0 *
eESS.fx(ess,'24')=ESS0(ESS);
PdisEss.up(ess,t)=(ESSData(ESS,'PUB'))/Sbase;
PdisEss.lo(ess,t)=0;
PchrEss.up(ess,t)=(ESSData(ESS,'PUB'))/Sbase;
PchrEss.lo(ess,t)=0;


************** LOAD SHEDDING constraints**************
Plsh.up(i,t) =(PerfilCarga(t)*PLpos(i))/Sbase;
Plsh.lo(i,t) = 0;


*****LINES constraints*****
Pij.up(i,j,t)$((conect(i,j))) =+1*LN(i,j,'Limit')/Sbase;
Pij.lo(i,j,t)$((conect(i,j))) =-1*LN(i,j,'Limit')/Sbase;
Qij.up(i,j,t)$((conect(i,j))) = 1*LN(i,j,'Limit')/Sbase;
Qij.lo(i,j,t)$((conect(i,j))) =-1*LN(i,j,'Limit')/Sbase;

*****VOLTAGE constraints*****

V.lo(i,t)  = 0.95;
V.up(i,t)  = 1.05;
V.l(i,t)   = 1.0;

*****Angle constraints*****
*Va Voltage angle
*All initial angles are declared as 0
Va.up(i,t)     = 4*pi/8;
Va.lo(i,t)     =-4*pi/8;
Va.l(i,t)      =0;


************ HYDRO constraints**************
Vol.lo(H, t) =    1.0*HidroData(H, 'Volmin ' );
Vol.up(H, t ) =   1.0*HidroData(H, 'Volmax ' );
Ph.lo(H, t )=     HidroData(H, 'Phmin ' )/Sbase     ;
Ph.up (H, t )=    1*HidroData(H, 'Phmax ' )/Sbase    ;
R.lo(H,t ) =      1*HidroData(H,'qaudmin');
R.up(H, t ) =     1*HidroData (H, 'qaudmax ') ;
Spill.lo(H, t ) = 0; 
*Since there are no negative spills
  

Equations eq1, eq2, eq3, eq4, eq5, eq6, eq7, eq8, eq9,
         eq10, eq11,
         eq12,eq13,eq14
        costTermal,costHidro,costWind,costPV, costPlsh,costPchr,costPdis,costWcEc,costScEc,
        HidroCostec,Phidro,Phtotal_ec, Qqgen,dummy;
        
Qqgen(i,t)..
Qgen =e=  sum(NG$GBconect(i,NG), Qg(NG,t));

********************eq1 Pij*******************************
eq1(i,j,t)$conect(i,j)..
   Pij(i,j,t) =e= (V(i,t)*V(i,t)*cos(LN(j,i,'th')) - V(i,t)*V(j,t)*cos(Va(i,t) - Va(j,t) + LN(j,i,'th')))
                  /LN(j,i,'z');
                  
********************eq2 Qij*******************************
eq2(i,j,t)$conect(i,j)..
   Qij(i,j,t) =e= (V(i,t)*V(i,t)*sin(LN(j,i,'th')) - V(i,t)*V(j,t)*sin(Va(i,t) - Va(j,t) + LN(j,i,'th')))
                  /LN(j,i,'z')
                  - LN(j,i,'b')*V(i,t)*V(i,t)/2;
                  
***********************eq3 Active power balance *********** 
eq3(i,t)..
Plsh(i,t)$(PerfilCarga(t)*PLpos(i))+
 sum(ESS,(EssConect(i,ESS))*(PdisEss(Ess,t)-PchrEss(Ess,t))) +
 sum(S$GBSolconect(i,S), Ps(S,t))+
 sum(GenEol$GBEolconect(i,GenEol), Pw(GenEol,t))+
 sum(H$Hidroconect(i,H), Ph(H,t))+
 sum(NG$GBconect(i,NG), Pg(NG,t)) - (PerfilCarga(t)*PL(i))/Sbase =e= sum(j$conect(j,i), Pij(i,j,t)); 

***********************eq4 Reactive power balance ***********
eq4(i,t)..
sum(NG$GBconect(i,NG), Qg(NG,t)) - (PerfilCarga(t)*QL(i))/Sbase =e= sum(j$conect(j,i), Qij(i,j,t));

***********************eq5  OBJECTIVE FUNCTION *******
eq5..
     OF =E=  sum((NG,t),Pg(NG,t)*GenData(NG,'b')*Sbase$GenData(NG,'Pmax'))
           + sum((NG,t),(Pg(NG,t)*Sbase$GenData(NG,'Pmax'))*(Pg(NG,t)*Sbase$GenData(NG,'Pmax'))*GenData(NG,'a'))
           + sum((NG,t), GenData(NG,'c'))
           + sum((genEol,t),Pw(genEol,t)*GenEolData(genEol,'CG')*Sbase$GenEolData(genEol,'Pwmax')) 
           + sum((H,t),Ph(H, t )*HidroData(H,'CH')*Sbase$HidroData(H,'Phmax'))
           + sum((S,t),Ps(S,t)*GenSolData(S,'CS')*Sbase$GenSolData(S,'Psmax'))
           + sum((ess,t),PChrEss(ess,t)*EssData(Ess,'Cchr')*Sbase$EssData(ess,'PUB'))
           + sum((ess,t),PDisEss(ess,t)*EssData(Ess,'Cdis')*Sbase$EssData(ess,'PUB'))
           + sum((i,t),VOLL*Plsh(i,t)*Sbase$(PerfilCarga(t)*PLpos(i)) );
           
****************Costs in independent variables for display***********
costTermal..
costPg    =e=  sum((NG,t),Pg(NG,t)*GenData(NG,'b')*Sbase$GenData(NG,'Pmax')
           + (Pg(NG,t)*Sbase$GenData(NG,'Pmax'))*(Pg(NG,t)*Sbase$GenData(NG,'Pmax'))*GenData(NG,'a')
           + GenData(NG,'c'));
costHidro..
costH     =e= sum((H,t),ph(H, t )*HidroData(H,'CH')*Sbase);

costWind..
costW     =e= sum((genEol,t),Pw(genEol,t)*GenEolData(genEol,'CG')*Sbase$GenEolData(genEol,'Pwmax'));

costPV.. 
CostS      =e= sum((S,t),Ps(S,t)*GenSolData(S,'CS')*Sbase$GenSolData(S,'Psmax'));

costPlsh..
costPlshh  =e= sum((i,t),VOLL*Plsh(i,t)*Sbase$(PerfilCarga(t)*PLpos(i)));

costPchr..
cPchr  =e=    sum((ess,t),PChrEss(ess,t)*EssData(Ess,'Cchr')*Sbase$EssData(ess,'PUB'));
                    
costPdis..
cPdis  =e=    sum((ess,t),PDisEss(ess,t)*EssData(Ess,'Cdis')*Sbase$EssData(ess,'PUB'));


***********************eq6  Ramp up thermal generators*********************
eq6(NG,t)$(GenData(NG,'Pmax') and ord(t)>1)..
   Pg(NG,t) - Pg(NG,t-1) =l= GenData(NG,'RU')/Sbase;
***********************eq7  Ramp down thermal generators*********************
eq7(NG,t)$(GenData(NG,'Pmax') and ord(t)<card(t))..
   Pg(NG,t) - Pg(NG,t+1) =l= GenData(NG,'RD')/Sbase;

eq10(H, t +1)..
Vol(H, t +1) =e= HidroData (H, 'Volini' )$(ord(t)=1)+
                 Vol(H,t)$(ord(t)>1)+ 1.0*inflow(t+1,H)-R(H,t+1)-Spill (H,t+1)+
                 0.9*sum( Hcascade$upstream(H, Hcascade ) ,R(Hcascade,t-HidroData(H,'Delay') )
                 + Spill(Hcascade , t-HidroData(H,'Delay')));
                 
****************** eq 11 Ph Hydroelectric power**********************
eq11(H, t ) ..
        Ph(H,t) =e= HidroData(H,'c1')*Vol(H,t)*Vol(H,t )+HidroData(H,'c2')*R(H,t)*R(H,t)
                +HidroData(H, 'c3' )*Vol(H, t )*R(H, t )
                +HidroData (H,'c4' )*Vol(H, t )+ HidroData (H, 'c5' )*R(H, t)+ HidroData (H,'c6');

**************************************** eq12 storage******************************
eq12(ESS,t)$(1*(ESSData(ESS,'EeUB')))..
eESS(ESS,t) =e= ESS0(ESS)$(ord(t)=1)
                + eESS(ESS,t-1)$(ord(t)>1) + PchrEss(ESS,t)*ESSData(ESS,'nchr')
                - PdisEss(ESS,t)*( 1/ESSData(ESS,'ndis'));

***  For the non-optimized case, change the objective function to dummy.
dummy.. OBJ=E=1;

   
Model OPF / eq1, eq2, eq3, eq4, eq5, eq6, eq7,eq12,
          eq10,eq11,costHidro,
          costTermal,costWind,costPV, costPlsh,costPchr,costPdis,dummy/;
solve OPF minimizing OF  using nlp;
*solve OPF maximizing OBJ using NLP;


*$ontext
Parameter report(t,i,*), Termos(NG,t,*), Eolicas(genEol,t,*), Hidros(H,t,*), Solar(S,t,*), 
          Congestioncost, Pij_(i,j,t),Qij_(i,j,t),lmp(i,t),Storage(t,ess,*),reportHidro(t,H,*),VarCost,
          PloadData2(i,t),Preport,Creport,TotalLosses;
          
VarCost= sum((NG,t),GenData(NG,'b')*Pg.l(NG,t)*Sbase + GenData(NG,'a')*Pg.l(NG,t)*Sbase*Pg.l(NG,t)*Sbase);
PloadData2(i,t) =PerfilCarga(t)*PL(i)/sbase ;
TotalLosses =    SUM((NG,t),Pg.l(NG,t)*Sbase)
                +sum((genEol,t),Pw.l(genEol,t)*Sbase)
                +sum((S,t),Ps.l(S,t)*Sbase)
                -sum((ess,t),PChrEss.l(ess,t)*Sbase)
                +sum((ess,t),PDisEss.l(ess,t)*Sbase)
                +sum((i,t),Plsh.l(i,t)*Sbase)
                +sum((H,t),Ph.l(H,t)*Sbase)
                - sum((i,t),PloadData2(i,t)*Sbase);

                          
Preport('Pt_Thermal') = SUM((NG,t),Pg.l(NG,t)*Sbase);
Preport('Pt_Eol')= sum((genEol,t),Pw.l(genEol,t)*Sbase);
Preport('Pt_Sol')= sum((S,t),Ps.l(S,t)*Sbase);
Preport('Pt_Pchr') = sum((ess,t),PChrEss.l(ess,t)*Sbase);
Preport('Pt_Pdish')= sum((ess,t),PDisEss.l(ess,t)*Sbase);
Preport('Pt_lsh')= sum((i,t),Plsh.l(i,t)*Sbase); 
Preport('Pt_loss')= TotalLosses;
Preport('Pt_load')= sum((i,t),PloadData2(i,t)*Sbase);
Preport('Pt_Hydros') = sum((H,t),Ph.l(H,t)*Sbase);


Creport('CTerm') = SUM((NG,t),GenData(NG,'c')) + SUM( (NG,t),GenData(NG,'b')*Pg.l(NG,t)*Sbase ) + SUM( (NG,t),GenData(NG,'a')*Pg.l(NG,t)*Sbase*Pg.l(NG,t)*Sbase ) ;
Creport('CTerm_var') = VarCost;
Creport('CEoli')= sum((genEol,t),Pw.l(genEol,t)*GenEolData(genEol,'CG')*Sbase);
Creport('CSola')= sum((S,t),Ps.l(S,t)*GenSolData(S,'CS')*Sbase);
Creport('CPchr') = sum((ess,t),PChrEss.l(ess,t)*EssData(Ess,'Cchr')*Sbase);
Creport('CPdischr')= sum((ess,t),PDisEss.l(ess,t)*EssData(Ess,'Cdis')*Sbase);
Creport('CPlsh')= sum((i,t),VOLL*Plsh.l(i,t)*Sbase);
Creport('CTotal')= OF.l;
Creport('CHydros')= sum((H,t),ph.l(H, t )*HidroData(H,'CH')*Sbase);

report(t,i,'V')     = V.l(i,t);
report(t,i,'Angle') = Va.l(i,t)*180/pi;
report(t,i,'P LSH')        = Plsh.l(i,t)*sbase ;
report(t,i,'LMP_P') = eq3.m(i,t)/Sbase;
report(t,i,'LMP_Q') = eq4.m(i,t)/Sbase;
Termos(NG,t,'Pg')        = Pg.l(NG,t)*Sbase;
Termos(NG,t,'Qg')        = Qg.l(NG,t)*Sbase;
Eolicas(geneol,t,'Pw')        = Pw.l(geneol,t)*Sbase;
Hidros(H,t,'Ph')        = Ph.l(H,t)*Sbase;

reportHidro(t,H,'Ph')=Ph.l(H,t)*Sbase;
reportHidro(t,H,'Reservour Volume ')=Vol.l(H,t);
reportHidro(t,H,'Flow')= R.l(H,t);
reportHidro(t,H,'Spills')= Spill.l(H,t);

Solar(S,t,'Ps')        = Ps.l(S,t)*Sbase;
Storage(t,ess,'ESS')    =     EEss.l(ess,t)*Sbase;
Storage(t,ess,'PchrESS')    = PChrEss.l(ess,t)*Sbase;
Storage(t,ess,'PdischrESS')    = PdisEss.l(ess,t)*Sbase;
Congestioncost = sum((i,j,t)$conect(i,j), Pij.l(i,j,t)*(-eq3.m(i,t) + eq3.m(j,t)))/2;
Pij_(i,j,t)=Pij.l(i,j,t)*Sbase;
Qij_(i,j,t)=Qij.l(i,j,t)*Sbase;

display VarCost,TotalLosses,Preport,Creport,Congestioncost,Termos, Eolicas,Solar,Storage,report,Pij_ ,Qij_,PloadData2
      reportHidro;
      

*Exporting variables to a .m file for MATLAB
*file RESULTADO /Case30AC_HIDROS_curvas_costo_cuadraticas_PRUEBA.m/;
*file RESULTS  PATH/NAME_matlab_file.m/;


*put RESULTADO
*put 'clc', put /;
*put 'clear all', put /, put /;
*put '% Results Case 30', put /;

*Set interest variables with put
*put 'variable1 = ' / variable1.tl:0:8 / ';' /;
* Write variable1 to the .m file
*put 'variable2 = ' / variable2.tl:0:8 / ';' /;
* Write variable2 to the .m file

*
