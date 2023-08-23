
%let root=/cas/data/caslibs/casuserlibraries/itamrz/ddc_editpro;

libname in "&root/dat/in";

/*
libname in (work);
*/

data tables;
set sashelp.vtable (where=( libname='IN' ));
if index (memname, '_META') then do;
   output;
end;
run;

proc sql noprint;
select compress(libname||'.'||memname) into: metaTabs separated by '  ' from tables;
quit;
%put &metaTabs;


data _null_;
file _webout;

set &metaTabs end=last;

if _n_=1 then put '[';

put '{';
put '  "id": "' id +(-1) '"   ' ;
put ',';
put '  "desc": "' desc +(-1) '"   ' ;
put ',';
put '  "createdBy": "' createdBy +(-1) '"   ' ;
put ',';
put '  "createdTime": "' createdTime  +(-1) '"   ' ;
put ',';
put '  "status": "' status +(-1) '"   ' ;
put ',';
put '  "editedBy": "' editedBy +(-1) '"   ' ;
put ',';
put '  "editedTime": "' editedTime  +(-1) '"   ' ;
put ',';
put '  "approvedBy": "' approvedBy +(-1) '"   ' ;
put ',';
put '  "approvedTime": "' approvedTime  +(-1) '"   ' ;

put '}';

if not last then put ',';

if last then put ']';

run;
