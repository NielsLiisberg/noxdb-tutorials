**free
ctl-opt copyright('System & Method (C), 2025');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main); 
ctl-opt bndDir('NOXDB');

// -----------------------------------------------------------------------------
// Service . . . : Get rows from a table
// Author  . . . : Niels Liisberg 
// Company . . . : System & Method A/S
//  
// CRTICEPGM STMF('/prj/noxdb-tutorials/ntut00.rpgle') SVRID(NOXDBTUT)
//
// Run:
// call noxdbtut/ntut00
//
// By     Date       PTF     Description
// ------ ---------- ------- ---------------------------------------------------
// NLI    10.05.2025         New program
// ----------------------------------------------------------------------------- 
 /include qrpgleref,jsonparser
 
// ----------------------------------------------------------------------------- 
// Main line:
// STRDBG PGM(NOXDBTUT/ntut00) UPDPROD(*YES)             
// ----------------------------------------------------------------------------- 
dcl-proc main;

	dcl-s pResponse		pointer;		
	
    pResponse = json_sqlResultSet('-
		select *                   -
		from corpdata.employee     -
	');

	json_WriteJsonStmf(pResponse:'/prj/noxdb-tutorials/testout/employee.json':1208);

	json_delete(pResponse);


end-proc;
