**free
ctl-opt copyright('System & Method (C), 2025');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main); 
ctl-opt bndDir('NOXDB':'ICEUTILITY');

// -----------------------------------------------------------------------------
// Service . . . : Get rows from a table
// Author  . . . : Niels Liisberg 
// Company . . . : System & Method A/S
//  
// CRTICEPGM STMF('/prj/noxdb-tutorials/noxdbtut01.rpgle') SVRID(NOXDBTUT)
//
// Run:
// http://my_ibm_i:60666/noxdbtut01
//
//
// By     Date       PTF     Description
// ------ ---------- ------- ---------------------------------------------------
// NLI    10.05.2025         New program
// ----------------------------------------------------------------------------- 
 /include qrpgleref,jsonparser
 /include qrpgleref,iceutility
 
// ----------------------------------------------------------------------------- 
// Main line:
// ----------------------------------------------------------------------------- 
dcl-proc main;

	dcl-s pResponse		pointer;		
	
	SetContentType('application/json; charset=utf-8');

    pResponse = json_sqlResultSet('-
		select *                   -
		from corpdata.employee     -
	');

	responseWriteJson(pResponse);
	json_delete(pResponse);


end-proc;
