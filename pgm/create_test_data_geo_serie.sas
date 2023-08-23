
/*
crea una tabella denormalizzata per edit e normalizzata per report trend

prefisso:
%let dsTest=D01;
%let status=;

*/


%let root=/cas/data/caslibs/casuserlibraries/itamrz/ddc_editpro;

libname in "&root/dat/in";


%let tab     =&dsTest._ddc_data_serie_01_edit;
%let repTab  =&dsTest._ddc_data_serie_01_rep;
%let metaTab =&dsTest._ddc_data_serie_01_meta;

%let nVals=24;

%macro mkTabs;

data 
in.&tab ( drop=slice value edited_value )
in.&repTab ( drop= note_edit value_1-value_&nVals  
                  edited_value_1-edited_value_&nVals )
;
length
 key $100
 slice $4
 country $2
 category $20
 sub_category $20

 value_1-value_&nVals 8
 edited_value_1-edited_value_&nVals 8

 note_edit $300
;
label
 category ='Line'
 sub_category ='Product'

%do v=1 %to &nVals;
 value_&v ="Forecast &v"
 edited_value_&v = "Edited Forecast &v"
%end;

 note_edit = 'Notes'
;
retain k 1;


note_edit='';

do c=1 to 4;

if c=1 then country='IT';
if c=2 then country='ES';
if c=3 then country='FR';
if c=4 then country='DE';

 do i=1 to 10;
 category = 'Product Line '|| put(i,z2.);

  do j=1 to 50;
    sub_category = 'Product '|| put(j,z2.);

    key='key'||put(k,z6.);

     v=3;

%do v=1 %to &nVals;
       value_&v = v;
       edited_value_&v = value_&v;

       slice="P%sysfunc(putn(&v,z3.))";
       value= value_&v;
       edited_value=edited_value_&v;
       output in.&repTab;
%end;

      
       output in.&tab;
       k+1;     
     
  end;
 end;

end;

drop
c k i j v 
;

run;
%mend;
%mkTabs;

data in.&metaTab;
 id     ="&dsTest";
 tab    ="&tab";
 reptab ="&reptab";
 desc   ="Dati di test - set dati id=&dsTest";
 createdBy ="&sysuserid";
 createdTime =put(datetime(), datetime18.);

length 
status $30
editedBy  editedTime  approvedBy approvedTime $20
;

 status   ="&status";

 editedBy ="";
 editedTime ="";

 approvedBy ="";
 approvedTime ="";

if "&status"='S01' then do;
   status='Initial forecast';
end;
if "&status"='S02' then do;
   status='Approval pending';
 editedBy ="pm 1";
 editedTime =put(datetime(), datetime18.);
end;
if "&status"='S03' then do;
   status='Approved';
 editedBy ="pm 1";
 editedTime =put(datetime(), datetime18.);
 approvedBy ="admin";
 approvedTime =put(datetime(), datetime18.);;
end;
if "&status"='S04' then do;
   status='Approval rejected';
 approvedBy ="admin";
 approvedTime =put(datetime(), datetime18.);;
end;

run;

/* 

cas; caslib _all_ assign;

proc delete data=casuser.&tab; run;

data casuser.&tab (promote=yes);
set &tab;
run;

proc casutil incaslib="casuser" outcaslib="casuser";
save casdata="&tab"   replace;
run;


%let repTrendTab=ddc_report_trend_01;
proc delete data=casuser.&repTrendTab; run;

data casuser.&repTrendTab (promote=yes);
set &repTab;
run;

proc casutil incaslib="casuser" outcaslib="casuser";
save casdata="&repTrendTab"   replace;
run;
 
*/
