**free
ctl-opt copyright('System & Method (C), 2025');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main); 
ctl-opt bndDir('NOXDB':'ICEUTILITY');

// -----------------------------------------------------------------------------
// Service . . . : Get rows from a table
// Author  . . . : Niels Liisberg 
// Company . . . : System & Method A/S
// 
// CRTICEPGM STMF('/prj/noxdb-tutorials/ntut04.rpgle') SVRID(NOXDBTUT)
// 
// run:
// http://my_ibm_i:60666/ntut04?employeeNumber=0001000 
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
// http://my_ibm_i:60666/ntut04
//
//
// make a httprequest at the floatrates service        
// and get the USD rate 
// ----------------------------------------------------------------------------- 
dcl-proc main;

    dcl-s url  	        varchar(1024);
    dcl-s pFlorate      pointer;
    dcl-s rate          packed(23:19);
		
	SetContentType('application/json; charset=utf-8');

    url = 'http://www.floatrates.com/daily/usd.json';

    // Use YUM to install curl, which is the tool used by httpRequest
    pFlorate = json_httpRequest (url);
    responseWriteJson(pFlorate);
	
	// In the next example we will use the rate from the noxDb graph..
	// for now we just put it in the console 
    rate = json_getNum (pFlorate: 'eur.rate' );
    consoleLog(%char(rate));
    json_joblog('EUR rate: ' + %char(rate));
	json_delete(pFlorate);


end-proc;

