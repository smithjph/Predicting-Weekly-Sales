/*section01 starter.sas*/
ods rtf style = journal2;
ods graphics on; 
options nodate nonumber linesize=80 formdlim='-';
/* reads in data set*/
data walmart;
infile "R:\STAT\gabrosek\sta321\section01.csv" DSD delimiter=','  firstobs=2;
input Store	Date Temperature	Fuel_Price	MarkDown1	MarkDown2	MarkDown3	MarkDown4	MarkDown5	
CPI	Unemployment	IsHoliday $	Dept	Weekly_Sales	Type $	Size;
run;
/* dataset size and variable types info*/
proc contents data=walmart  position; 
run;
/* ADD YOUR CODE BEGINNING HERE*/
data walmart2;
set walmart;

/* create dummy variables for Type, IsHoliday, and Dept */
data walmart2;
set walmart2;
If Type = "A" then Z1 = 1;
If Type = "B" or Type = "C" then Z1 = 0;
If Type = "B" then Z2 = 1;
If Type = "A" or Type = "C" then Z2 = 0;
If IsHoliday = "TRUE" then Z3 = 1;
If IsHoliday = "FALSE" then Z3 = 0;
If Dept = 2 then Z4 = 1;
else z4= 0;
If Dept = 5 then Z5 = 1;
else Z5 = 0;
If Dept = 30 then Z6 = 1;
else Z6 = 0;
If Dept = 33 then Z7 = 1;
else Z7 = 0;
If Dept = 38 then Z8 = 1;
else Z8 = 0;
If Dept = 49 then Z9 = 1;
else Z9 = 0;
If Dept = 67  then Z10 = 1;
else Z10 = 0;
If Dept = 72 then Z11 = 1;
else z11 = 0;
If Dept = 79 then Z12 = 1;
else Z12 = 0;
run;


/* Scatterplots of data 
proc sgplot data = walmart2;
scatter y= Weekly_Sales X = store;
run;
proc sgplot data = walmart2;
scatter y= Weekly_Sales X = Date;
run;
proc sgplot data = walmart2;
scatter y= Weekly_Sales X = Fuel_Price;
run;
proc sgplot data = walmart2;
scatter y= Weekly_Sales X = temperature;
run;
proc sgplot data = walmart2;
scatter y= Weekly_Sales X = CPI;
run;
proc sgplot data = walmart2;
scatter y= Weekly_Sales X = unemployment;
run;
proc sgplot data = walmart2;
scatter y= Weekly_Sales X = dept;
run;
proc sgplot data = walmart2;
scatter y= Weekly_Sales X = type;
run;
proc sgplot data = walmart2;
scatter y= Weekly_Sales X = size;
run;
*/



/* create Ischristmas, Z14 (not used), and the square root of Weekly_Sales variables */
data walmart3;
set walmart2;
if Date=40508 or Date=40515 or Date=40522 or Date=40529 or Date=40536 or Date=40872 or Date=40879 or Date=40886 or Date=40893 or Date=40900 or Date=40907 then Ischristmas=1;
else Ischristmas=0;
if CPI >= 180 then Z14=1;
else Z14=0;
rootsales = sqrt(Weekly_Sales);




/* final model statement */
proc reg data=walmart3;
model rootsales = Temperature Ischristmas Z1 Z2 Z3 Z4 Z5 Z6 Z7 Z8 Z9 Z10 Z11 Z12 Size / vif /*r influence*/ selection=stepwise;
output out=resids rstudent=jknf p=predicted;
ods output OutputStatistics = ourdfbetas;
run;



/* check for homoscedasticity, can use either one */
proc sgscatter data=resids;
plot jknf*predicted;
run;
proc sgplot data=resids;
scatter x=predicted y=jknf;
lineparm x=20 y=0 slope=0;
run;
quit;

/* check normality */
proc univariate data=resids normal;
histogram jknf/nmidpoints=10 normal;
qqplot jknf / normal(mu=0 sigma=1);
run;

/* check independence assumption */
proc sgplot data=resids;
scatter x=date y=jknf;
lineparm x=20 y=0 slope=0;
run;
quit;


/* overall F-test */
proc reg data=walmart3;
model rootsales = Temperature Ischristmas Z1 Z2 Z3 Z4 Z5 Z6 Z7 Z8 Z9 Z10 Z11 Z12 Size / pcorr1 pcorr2;
output out=multiple p=yhat;
run;

/* find the signs of the partial correlation coefficients */
proc reg data=walmart3;
model rootsales = Temperature Ischristmas Z1 Z2 Z3 Z4 Z5 Z6 Z7 Z8 Z9 Z10 Z11 Z12 Size;
run;


 /* overall F-test and multiple partial F-tests */
proc glm data=walmart3;
model rootsales = Temperature Ischristmas Z1 Z2 Z3 Z4 Z5 Z6 Z7 Z8 Z9 Z10 Z11 Z12 Size;
run;
quit;



/* this data set contains 699 points, or 3.84% of the 18226 original points */
data points;
set ourdfbetas;
if rstudent < -2.5 or rstudent > 2.5 or dffits < -0.05 or dffits > 0.05;
proc print data=points;
run;


proc means data = walmart3 n nmiss;
  var _numeric_;
run;

data negative;
set walmart;
if Weekly_Sales < 0;
proc print data=negative;
run;

ods graphics off;
ods rtf close;



