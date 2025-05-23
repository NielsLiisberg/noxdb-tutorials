**free
ctl-opt copyright('System & Method (C), 2025');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main); 
ctl-opt bndDir('NOXDB':'ICEUTILITY');

// -----------------------------------------------------------------------------
// Service . . . : Get rows from a table
// Author  . . . : Niels Liisberg 
// Company . . . : System & Method A/S
// 
// CRTICEPGM STMF('/prj/noxdb-tutorials/ntut02.rpgle') SVRID(NOXDBTUT)
// 
// run:
// http://my_ibm_i:60666/ntut02?employeeNumber=0001000 
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
// Note: the injection protection with strQuot() is needed here,
// ----------------------------------------------------------------------------- 
dcl-proc main;

	dcl-s pResponse		  pointer;		
	dcl-s employeeNumber  varchar(6);
  
	setContentType('application/json; charset=utf-8');

	employeeNumber = reqStr('employeeNumber');

	pResponse = json_sqlResultSet('-
		select *                   -
		from corpdata.employee     -
		where empno = ' + strQuot(employeeNumber) 
	);

	responseWriteJson(pResponse);
	json_delete(pResponse);


end-proc;
