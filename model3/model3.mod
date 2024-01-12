/*********************************************
 * OPL 20.1.0.0 Model
 * Author: MCA
 * Creation Date: Mar 5, 2021 at 5:55:56 PM
 *********************************************/
 
// indices

int m =...;
int n =...;
int T =...;
int V1 =...;
int V2 =...;
int PC= 0;

// parameters
range prodcenter = 0..PC;
range retailers = 1..m;
range customers = 1..n;
range time = 0..T;
range time1 = 1..T;
range vehicle1 = 1..V1;
range vehicle2 = 1..V2;

float costofarc1[retailers][retailers]=...;
float costofarc2[retailers][customers]=...;
float costofarc0[prodcenter][retailers]=...;
float costofarc3[customers][customers]=...;
float costofarc4[prodcenter][customers] = ...;
float distance0[prodcenter][retailers]=...;
float distance1[retailers][retailers]=...;
float distance2[retailers][customers]=...;
float distance3[customers][customers]=...;
float distance4[prodcenter][customers] = ...;

int demand[time1][customers]=...;

float invcapacity = 1500;
float holdcost = 0.1;
float capvec1 = 8750;
float capvec2 = 1500;
float capretailer = 3900;
float DC = 14;
float FC = 25000;  /*12500 x timeperiod*/
int M = 9999;
float costofcarry = 2.5;
float maxdistance1 = 2800;
float maxdistance2 = 300;
float availabledays = 5;   /*Haftanin 5 gunu*/

// dec variables

dvar int x [time1][prodcenter][retailers][vehicle1] in 0..M ;
dvar int y [time1][retailers][customers][vehicle2] in 0..M; //rc arasi product flow
dvar int z [time1][retailers][retailers][vehicle1] in 0..M;
dvar int w[time1][customers][customers][vehicle2] in 0..M;  // cc arasi product flow
dvar int q[time1][prodcenter][customers][vehicle2] in 0..M;
dvar boolean r0 [time1][prodcenter][customers][vehicle2];
dvar boolean r1 [time1][prodcenter][retailers][vehicle1];
dvar boolean r2 [time1][retailers][customers][vehicle2]; //rc
dvar boolean r3 [time1][retailers][retailers][vehicle1];
dvar boolean r4 [time1][customers][retailers][vehicle2]; //cr
dvar boolean r5 [time1][retailers][prodcenter][vehicle1];
dvar boolean r6 [time1][customers][customers][vehicle2]; //cc
dvar boolean r7 [time1][customers][prodcenter][vehicle2];
dvar int I [time][retailers] in 0..M; 
dvar boolean a [retailers];
dvar int ds[time1][customers] in 0..M;

dexpr float cost = sum(t in time1, i in retailers, j in customers, l in vehicle2) y[t][i][j][l] * costofcarry +  sum(t in time1, j in customers, l in vehicle2) r0[t][0][j][l] * costofarc4 [0][j] + sum(t in time1, j in customers, l in vehicle2) r7[t][j][0][l] * costofarc4 [0][j]  + sum(t in time1,  i in customers, j in customers, l in vehicle2) r6[t][i][j][l] * costofarc3 [i][j] + sum(t in time1,  i in retailers ,  v in vehicle1, p in prodcenter) r1[t][p][i][v] * costofarc0 [p][i] + sum ( t in time1,  i in retailers , k in retailers,  v in vehicle1)r3 [t][k][i][v] * costofarc1 [k][i] + sum ( t in time1,  i in retailers ,  v in vehicle1, p in prodcenter) r5 [t][i][p][v] * costofarc0 [p][i] + sum ( t in time1, i in retailers , j in customers, l in vehicle2) r2 [t][i][j][l] * costofarc2 [i][j] + sum(t in time1, j in customers, i in retailers, l in vehicle2) r4[t][j][i][l] * costofarc2[i][j] + sum ( t in time1,  i in retailers ) I [t][i] * holdcost + sum ( t in time1, j in customers ) ds[t][j] * DC + sum ( i in retailers ) FC * a [i];

// obj fnc
minimize cost;
// constraints

  subject to  {
    
      forall(j in customers, t in time1)
      kendisindencikipkendisinegidemezcustomer:
      sum(v in vehicle2) r6[t][j][j][v] == 0;
    
      forall(i in retailers, t in time1, j in customers, l in vehicle2)
      egeroaracoarcikullaniyorsaurunusadeceoaractasiyabilir:
      y[t][i][j][l] <= M*r2[t][i][j][l];
    
      forall(i in customers, j in customers, t in time1, l in vehicle2)
      egeroaracoarcikullaniyorsaurunusadeceoaractasiyabilircc:
      w[t][i][j][l] <= M* r6[t][i][j][l];
      
      forall(i in prodcenter, j in customers, t in time1, l in vehicle2)
      egeroaracoarcikullaniyorsaurunusadeceoaractasiyabilirpc:
      q[t][i][j][l] <= M* r0[t][i][j][l];
      
      forall ( t in time1, k in customers, l in vehicle2) 
      vec2check:
      r0[t][0][k][l] + sum(i in retailers) r2 [t][i][k][l] + sum(j in customers) r6[t][j][k][l] == sum(i in retailers) r4 [t][k][i][l] + sum(j in customers) r6[t][k][j][l] + r7[t][k][0][l];
      
      forall(t in time1, k in customers)  
      sum(i in retailers, l in vehicle2) r2[t][i][k][l] + sum(j in customers, l in vehicle2) r6[t][j][k][l] + sum(l in vehicle2) r0[t][0][k][l] <= 1;
       
      forall ( t in time1, l in vehicle2)  
      vehicle2_capacity:
      sum(i in retailers, j in customers) y[t][i][j][l] <= capvec2;
      
      forall( t in time1, l in vehicle2) 
      vehicle23_capacity:
      sum(j in customers) q[t][0][j][l] <= capvec2;
      
      forall(j in customers, t in time1) 
      flow2constraint:
      sum(l in vehicle2) q[t][0][j][l] + sum(i in retailers, l in vehicle2) y[t][i][j][l] + sum(k in customers, l in vehicle2) w[t][k][j][l] - demand[t][j] + ds[t][j]  == sum(k in customers, l in vehicle2) w[t][j][k][l];
      
      forall(t in time1, i in retailers, l in vehicle2)
      basladigiretaileradonmeli:
      sum(j in customers) r2[t][i][j][l] == sum(j in customers) r4[t][j][i][l]; 
      
      forall(t in time1, l in vehicle2)
      prodcenterdanciktiysaprodadonmeli:
      sum(j in customers) r0[t][0][j][l] == sum(j in customers) r7[t][j][0][l]; 
      
      forall(t in time1, l in vehicle2)
      biraracsadecebirdagitantarafindankullanilabiliroperiyotta:
      sum(i in retailers, j in customers) r2[t][i][j][l] + sum(j in customers) r0[t][0][j][l] <= 1;
      
      forall(t in time1,i in retailers)
      birretailerperiyottamakscapretailerkadarurundagitabilir:
      sum(j in customers, l in vehicle2) y[t][i][j][l] <= capretailer;
      
      forall(t in time1)
      prodcenterperiyottamakscapretailerkadarurundagitabilir:
      sum(j in customers, l in vehicle2) q[t][0][j][l] <= capretailer;
      
      forall(t in time1, i in retailers)
      availabledaystoroute:
      sum(j in customers, l in vehicle2) r2[t][i][j][l] <= availabledays;
      
      forall(t in time1)
      availabledaystoroute1:
      sum(j in customers, l in vehicle2) r0[t][0][j][l] <= availabledays;
      
      forall(t in time1, v in vehicle1) 
      birinciseviyedebiraracinyapabilecegimaksimummesafe:
      sum (i in retailers) r1[t][0][i][v] * distance0[0][i] + sum(i, j in retailers) r3[t][i][j][v] * distance1[i][j] + sum(j in retailers) r5[t][j][0][v] * distance0[0][j] <= maxdistance1;
      
      forall(t in time1, l in vehicle2)
      ikinciseviyedebiraracinyapabilecegimaksimummesafe:
      sum(j in customers) r0[t][0][j][l] * distance4[0][j] + sum(j in customers) r7[t][j][0][l] * distance4[0][j] + sum (i in retailers, j in customers) r2[t][i][j][l] * distance2[i][j] + sum(i, j in customers) r6[t][i][j][l] * distance3[i][j] + sum(i in retailers,j in customers) r4[t][j][i][l] * distance2[i][j] <= maxdistance2;
                  
  	  forall(v in vehicle1, t in time1) 
      birinciseviyedekivehicleproddancikipsadecebirretaileragidebilir:
      sum(i in retailers) r1[t][0][i][v] <= 1;
    
      forall(i in retailers, t in time1) 
      kendisindencikipkendisinegidemez:
      sum(v in vehicle1) r3[t][i][i][v] ==0;
      
      forall ( i in retailers ) 
      inventory_capacity:
      I[0][i] == 0;
   
   	  forall ( i in retailers ) 
      inventory_capacity1:
      I[T][i] == 0;
	        
      forall(i,k in retailers, t in time1, v in vehicle1) 
      egeroaracoarcibirinciseviyekullaniyorsasadeceoaracuruntasiyabilir:
      z[t][k][i][v] <=  M*r3[t][k][i][v];
     
      forall(i in retailers, t in time1, v in vehicle1)
      egeroaracoarcibirinciseviyekullaniyorsasadeceoaracuruntasiyabilir1:
	  x[t][0][i][v] <=  M*r1[t][0][i][v]; 
  
      forall(t in time1, i in retailers, p in prodcenter, v in vehicle1)
      girencikanaracesitligi:
   	  r1[t][p][i][v] + sum(k in retailers)r3[t][k][i][v]  == sum(k in retailers)r3[t][i][k][v] + r5[t][i][p][v]; 
   	 
      forall (t in time1, i in retailers)
      retailerorprodcenteryadahic:
      sum (k in retailers, v in vehicle1) r3[t][k][i][v] + sum(v in vehicle1)r1[t][0][i][v] <= 1;
   	
      forall (t in time1, i in retailers, p in prodcenter)
      inventory_flow_balance:
      sum ( v in vehicle1 )  x [t][p][i][v] + I [t-1][i] + sum ( k in retailers, v in vehicle1) z [t][k][i][v] == sum ( k in retailers, v in vehicle1) z [t][i][k][v] + sum ( j in customers, l in vehicle2 ) y [t][i][j][l] + I [t][i];

      forall ( t in time1, v in vehicle1 )
      vehicle1_capacity:
      sum(i in retailers) x[t][0][i][v]  <= capvec1;
    
      forall ( t in time1, i in retailers )
      retailer_capacity:
      I [t][i] <= invcapacity;    
            
      forall ( i in retailers, p in prodcenter )
      recieveprodcheck:
      sum ( t in time1 , v in vehicle1 ) r1 [t][p][i][v] + sum (t in time1 , v in vehicle1, k in retailers) r3 [t][k][i][v] <= M * a [i]  ;                              
                                                                                   
 }