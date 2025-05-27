**free
ctl-opt pgminfo(*PCML:*MODULE);
ctl-opt copyright('System & Method (C), 2025');
ctl-opt decEdit('0.') datEdit(*YMD.); 
ctl-opt debug(*yes);

// -----------------------------------------------------------------------------
// Service . . . : Salary calculator
// Author  . . . : Niels Liisberg 
// Company . . . : System & Method A/S
// 
// This example shows how traditional programs compiled with
//    ctl-opt pgminfo(*PCML:*MODULE);
// can be used with noxDb 
// CRTICEPGM STMF('/prj/noxdb-tutorials/ntut99.rpgle') SVRID(NOXDBTUT)
// 
// run:
// http://my_ibm_i:60666/ntut99
// 
// 
// By     Date       PTF     Description
// ------ ---------- ------- ---------------------------------------------------
// NLI    10.05.2025         New program
// ----------------------------------------------------------------------------- 
 
	dcl-pi *N;
		job    char (10)   const;
		years  packed(3:0) const ;
		salary packed(7:2) ; // Output parameter
	end-pi;

	dcl-s w_years  packed(3:0)  ;

	w_years = years; 
	if w_years <= 0;
		w_years = 1; 
	endif; 

	if w_years > 25;
		w_years = 25; 
	endif; 

	select; 
		when  job = 'Clerk'; 
			salary = 10988.25 + (( w_years - 1) * 1021.75);
		when  job = 'Mgr';
			salary = 10000.25 + (( w_years - 1) * 2792.50);
		when  job = 'Sales';
			salary =  9599.25 + (( w_years - 1) * 1512.50);
		other;    
			salary =  7234.33 + (( w_years - 1) * 1477.33);
	endsl; 
	*inrt = *ON; 


