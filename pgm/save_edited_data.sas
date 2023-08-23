


%let castab     =ddc_serie_edit;
%let casrepTab  =ddc_serie_trend;

/* ------------------------------------- */

* Reference the uploaded JSON data;

filename indata filesrvc "&_WEBIN_FILEURI";

/*
normal:  _WEBIN_CONTENT_LENGTH=989
normal:  _WEBIN_CONTENT_TYPE=application/json
normal:  _WEBIN_FILE_COUNT=1
normal:  _WEBIN_FILEEXT= 
normal:  _WEBIN_FILENAME=blob
normal:  _WEBIN_FILEURI=/files/files/f944d533-243d-453b-b413-f9ff3771a409
normal:  _WEBIN_NAME=myjsonfile
*/

* Use the JSON engine to provide read-only sequential access to JSON data;

libname indata json;

libname x "$HOME";

/*

{"key000051":{"editedValues":[3,3,3,....],"values":[4,4,4,4,...],"notes":"(missing)"},"key000052":{

*/


data x.jDataLev2 x.jDataLev3 ;
set indata.alldata ;
if p=2 and p2='notes' then output x.jDataLev2;
if p=3 and p2='editedValues' then output x.jDataLev3;
run;

proc sort data=x.jDataLev2; by p1; run;
proc sort data=x.jDataLev3; by p1; run;

data _null_; 
set x.jDataLev3 (obs=1);
call symput ('dummyKey', p1);
run;
proc sql noprint;
select count(*) into: numCols
from x.jDataLev3
where p1=trim(left("&dummyKey"));
quit;
%let numCols=%sysfunc(compress(&numCols));
%put numCols=&numCols;

%macro TranCols;
data x.cols;
set x.jDataLev3 ;
by p1;

length 
key $100
edited_value_1-edited_value_&numCols 8
note_edit $300;

retain key edited_value_1-edited_value_&numCols 
;

key=p1;

%do e=1 %to &numCols;
if p3="editedValues&e" then edited_value_&e=input(value,best.);
%end;

if last.p1 then output;

keep key edited_value_1-edited_value_&numCols ;

run;
%mend;
%TranCols

data x.notes;
set x.jDataLev2 ;
by p1;

length 
key $100
note_edit $300;

retain key note_edit 
;

key=p1;

if p2='notes' then note_edit=value;

if last.p1 then output;

keep key note_edit;

run;

  



/* es salvataggio in cas - per demo */

cas; caslib _all_ assign;


data &castab;
set casuser.&castab;
run;

proc sort data=&castab; by  key ; run;

data x.up;
merge &castab x.cols x.notes;
by key;
run;



proc delete data=casuser.&castab; run;

data casuser.&castab (promote=yes);
set x.up;
run;

proc casutil incaslib="casuser" outcaslib="casuser";
save casdata="&castab"  /* compress */ replace;
run;






/*** report ***/

data x.jData;
set indata.alldata;
run;

data editedValues  (keep=key slice edited_value)
;

length 
key $100
slice $4
edited_value    8
;

set x.jData (rename=( value=cvalue ));
if p=3;

key=p1;

if p2='editedValues' then do;
   edited_value=input(cvalue,best.);
   prg = input ( tranwrd( p3, 'editedValues','' ), best.) ;
   slice='P' || put( prg,  z3.);
   output editedValues ;
end;

run;

proc sort data=editedValues ; by key slice;run;


data &casrepTab;
set casuser.&casrepTab;
run;
proc sort data=&casrepTab ; by key slice;run;


proc sql;
create table x.reportTrend as select
rt.key,
rt.country,
rt.category,
rt.sub_category,
rt.slice,
rt.value,
case when e.edited_value ne . then e.edited_value else  rt.edited_value end  as edited_value 
from 
&casrepTab rt left join editedValues e
on
rt.key=e.key
and
rt.slice=e.slice
;
quit;


proc delete data=casuser.&casrepTab; run;

data casuser.&casrepTab (promote=yes);
set x.reportTrend;
run;

proc casutil incaslib="casuser" outcaslib="casuser";
save casdata="&casrepTab"  /* compress */ replace;
run;





data _null_;
file _webout;
put '{ "esito": "OK" }';
run;
