
/*

%let dsTest=D01;
%let dsTest=D03;
%let dsTest=D04;

*/


%let root=/cas/data/caslibs/casuserlibraries/itamrz/ddc_editpro;

libname in "&root/dat/in";


%let intab     =&dsTest._ddc_data_serie_01_edit;
%let inrepTab  =&dsTest._ddc_data_serie_01_rep;

%let castab     =ddc_serie_edit;
%let casrepTab  =ddc_serie_trend;


cas; caslib _all_ assign;

proc delete data=casuser.&castab; run;

data casuser.&castab (promote=yes);
set in.&intab;
run;

proc casutil incaslib="casuser" outcaslib="casuser";
save casdata="&castab"   replace;
run;



proc delete data=casuser.&casrepTab; run;

data casuser.&casrepTab (promote=yes);
set in.&inrepTab;
run;

proc casutil incaslib="casuser" outcaslib="casuser";
save casdata="&casrepTab"   replace;
run;

data _null_;
file _webout;
put '{ "esito": "OK" }';
run;
 
