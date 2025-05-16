**free
ctl-opt copyright('System & Method (C), 2025');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main); 
ctl-opt bndDir('NOXDB':'ICEUTILITY':'QC2LE');

/* -----------------------------------------------------------------------------
   Service . . . : Get rows from a table
   Author  . . . : Niels Liisberg 
   Company . . . : System & Method A/S
  
   CRTICEPGM STMF('/prj/noxdb-tutorial/noxdbtut02.rpgle') SVRID(NOXDBTUT)

   run:
   http://my_ibm_i:60666/noxdbtut02?prodKey=110


   By     Date       PTF     Description
   ------ ---------- ------- ---------------------------------------------------
   NLI    10.05.2025         New program
   ----------------------------------------------------------------------------- */
 /include qrpgleref,jsonparser
 /include qrpgleref,iceutility
 
// --------------------------------------------------------------------
// Main line:
// --------------------------------------------------------------------
dcl-proc main;

	dcl-s pResponse		pointer;		
	dcl-s prodKey     int(10);
  
	SetContentType('application/json; charset=utf-8');

  prodKey = reqNum('prodKey');

  pResponse = json_sqlResultSet('-
		select *         -
		from icproduct    -
    where prodKey = ' + %char(prodKey) 
  );

	responseWriteJson(pResponse);
	json_delete(pResponse);


end-proc;
