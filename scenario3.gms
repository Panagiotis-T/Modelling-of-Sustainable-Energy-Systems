option optcr = 0.01
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
*ep    Electricity Price(Fixed)/0.002/

Parameters


d(t)     standardised demand
*/t1 0,t2 0,t3 0,t4 0,t5 0,t6 0,t7 1715,t8 3920,t9 210,t10 105,t11 210,t12 315,t13 0,t14 105,t15 105,t16 105,t17 0,t18 315,t19 105,t20 735,t21 3710,t22 0,t23 0,t24 0/

/
$ondelim
$include demandyear3.csv
$offdelim
/

Parameters

ta(t)    air temperature
*/t1 3, t2 3, t3 4, t4 4, t5 4, t6 5, t7 5, t8 6, t9 5, t10 5,t11 4, t12 3, t13 3, t14 3, t15 3, t16 2, t17 2, t18 2, t19 2, t20 3, t21 3, t22 3, t23 3, t24 3/

/
$ondelim
$include airtempyear3.csv
$offdelim
/

Parameters

ep(t) electricity prices

/
$ondelim
$include eprices.csv
$offdelim
/


Parameters

u_init(t) Initial online status
d_init(t) Initial demand
s_init(t) Initial heat stored in tank
s_fillup(t) Final heat fillup
l_init(t) Initial heat losses
q_init(t) Initial heat transfered to tank
u_fillup(t) Final fillup
;
u_init(t) = 0 ;
u_fillup(t) = 1;
d_init(t) = 0 ;
s_init(t) = 9918 ;
s_fillup(t) = 9918;
l_init(t) = 71.5;
q_init(t) = 0

Parameters

q(t) heat provided to tank
;
q(t) = 1472-10.85*twlow+42.66*ta(t)
;

Parameters
w(t) power consumption
;
w(t) = 206+4.06*twlow+1.76*ta(t)
;

Parameters

COP(t) Coefficient of Performance;
COP(t) = q(t)/w(t)
;

Free variables
z Minimum cost
;

Positive variables
s(t) Heat stored in the tank
l(t) Heat loss from the tank
p(t) Power conusmed for running heat pump
heatprod(t) Heat supplied by heat pump when turned on
;

Binary variable
u(t) online status
v(t) startup status
;

Equations
Total_Cost cost minimization
Power_consumption(t) Power consumed by heat pump every hour
Heat_production(t) Heat produced by heat pump every hour
Heat_Loss(t) Heat Losses
Heat_flow1(t) Heat Flow equation at t=1
Heat_flow2(t) heat balancing at t>1
Heat_flow3(t) heat at fill up at t=672

*dem(t) demand
stmax(t) maximum storage
st1(t) startup constraint at t=1
st2(t) another startup at t>1
st3(t) fillup at t=672
;

Total_Cost..z =e= sum((t)$subt(t),ep(t)*(p(t)+50*v(t)));

Power_consumption(t)$subt(t).. p(t) =e= w(t)*u(t) ;

Heat_production(t)$subt(t)..  heatprod(t) =e= q(t)*u(t)  ;

Heat_Loss(t)$subt(t).. l(t) =e= (s(t)/s_max)*1.3*twtop;

Heat_flow1(t)$subinit(t)..s(t) =e= s_init(t)+heatprod(t)-l(t)-d(t) ;

Heat_flow2(t)$sub2(t)..s(t) =e=  s(t-1)+heatprod(t)-l(t)-d(t)  ;
Heat_flow3(t)$sub3(t)..s(t) =e= s_fillup(t)-heatprod(t)+l(t)+d(t);

stmax(t)$subt(t)..s(t) =l= s_max ;

st1(t)$subinit(t).. u(t)-u_init(t) =l= v(t);

st2(t)$sub2(t).. u(t)-u(t-1) =l= v(t);
st3(t)$sub3(t).. u_fillup(t)-u(t-1) =l= v(t);





Model uc/all/ ;

Solve uc using MIP minimising z ;

display z.l,COP,s.l
