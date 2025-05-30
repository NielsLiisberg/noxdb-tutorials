**free
ctl-opt copyright('System & Method (C), 2025');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main); 
ctl-opt bndDir('NOXDB':'ICEUTILITY');

// -----------------------------------------------------------------------------
// Service . . . : Get rows from a table
// Author  . . . : Niels Liisberg 
// Company . . . : System & Method A/S
//  
// CRTICEPGM STMF('/prj/noxdb-tutorials/ntut01.rpgle') SVRID(NOXDBTUT)
//
// Run:
// http://my_ibm_i:60666/ntut01
//
//
// By     Date       PTF     Description
// ------ ---------- ------- ---------------------------------------------------
// NLI    10.05.2025         New program
// ----------------------------------------------------------------------------- 
 /include qrpgleref,jsonparser
 
// ----------------------------------------------------------------------------- 
// Main line:
// ----------------------------------------------------------------------------- 
dcl-proc main;

	dcl-s pResponse		pointer;		
	
	setContentType('application/json; charset=utf-8');

    pResponse = json_sqlResultSet('-
		select *                   -
		from corpdata.employee     -
	');

	responseWriteJson(pResponse);
	json_delete(pResponse);


end-proc;
