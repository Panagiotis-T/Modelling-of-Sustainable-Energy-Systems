

option optcr = 0.013
Sets

t time periods /t1*t672/

subt(t) /t1*t672/
subInit(t)/t1/
Sub2(t)/t2*t671/
sub3(t) /t672/
;



Scalar
twlow Temperature at the bottom of the tank in degree C /55/
twtop Temperature at the top of the tank in degree C /55/
s_max  Maximum heat storage in the tank in W /9918/
elp    Electricity Price(Fixed)/0.002/

Parameters


d(t)     standardised demand

/
$ondelim
$include demandyear.csv
$offdelim
/

Parameters

ta(t)    air temperature

/
$ondelim
$include airtempyear.csv
$offdelim
/

Parameters

qh(t) heat by solar

/
$ondelim
$include qheatsolarnew.csv
$offdelim
/

Parameters

u_init(t) Initial online status
s_init(t) Initial heat stored in tank
s_fillup(t) Final heat fillup
u_fillup(t) Final fillup
;
u_init(t) = 0 ;
u_fillup(t) = 1;
s_init(t) = 9918 ;
s_fillup(t) = 9918;


Parameters

q(t) heat capacity provided to tank
;
q(t) = 1472-10.85*twlow+42.66*ta(t)
;

Parameters
w(t) power consumption of heat pump
;
w(t) = 206+4.06*twlow+1.76*ta(t)
;

Parameters

COP(t) Coefficient of Performance;
COP(t) = q(t)/w(t)
;

Free variables
z Cost
;

Positive variables
s(t) Heat stored in the tank
l(t) Heat loss from the tank
p(t) Power conusmed by heat pump
hp(t) Heat supplied by heat pump
;

Binary variables
u(t) online status
v(t) startup status
;

Equations
Total_Cost cost minimization
Power_consumption(t) Power consumed by heat pump
Heat_production(t) Heat produced by heat pump
Heat_Loss(t) Heat Losses
Heat_stor1(t) Storage level equation at t=1
Heat_stor2(t) Storage level equation at t>1
Heat_stor3(t) Storage level equation at t=168



stmax(t) maximum storage constraint
st1(t) startup constraint at t=1
st2(t) operation constraint at t>1
st3(t) fillup constraint at t=168
;

Total_Cost..z =e= sum((t)$subt(t),elp*(p(t)+50*v(t)));

Power_consumption(t)$subt(t).. p(t) =e= w(t)*u(t) ;

Heat_production(t)$subt(t)..  hp(t) =e= q(t)*u(t)  ;


Heat_Loss(t)$subt(t).. l(t) =e= (s(t)/s_max)*1.3*twtop;

Heat_stor1(t)$subinit(t)..s(t) =e= s_init(t)+hp(t)+qh(t)-l(t)-d(t) ;

Heat_stor2(t)$sub2(t)..s(t) =e=  s(t-1)+hp(t)+qh(t)-l(t)-d(t)  ;
Heat_stor3(t)$sub3(t)..s(t) =e= s_fillup(t)-hp(t)+qh(t)+l(t)+d(t);

stmax(t)$subt(t)..s(t) =l= s_max ;

st1(t)$subinit(t).. u(t)-u_init(t) =l= v(t);

st2(t)$sub2(t).. u(t)-u(t-1) =l= v(t);
st3(t)$sub3(t).. u_fillup(t)-u(t-1) =l= v(t);





Model uc/all/ ;

Solve uc using MIP minimising z ;

display z.l,COP,s.l,p.l,hp.l,u.l,l.l

execute_unload "resultsscenario5.gdx" z.l,COP,s.l,p.l,hp.l,u.l,l.l

execute 'gdxxrw.exe resultsscenario5.gdx var=z.l,COP,s.l,p.l,heatprod.l,u.l'
execute '=gdx2xls resultsscenario5.gdx'
execute '=shellExecute resultsscenario5.xlsx';
