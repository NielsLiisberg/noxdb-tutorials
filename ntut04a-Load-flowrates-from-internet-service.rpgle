**free
ctl-opt copyright('System & Method (C), 2025');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main); 
ctl-opt bndDir('NOXDB':'ICEUTILITY');

// -----------------------------------------------------------------------------
// Service . . . : Get exchangereate from flowrates
// Author  . . . : Niels Liisberg 
// Company . . . : System & Method A/S
// 
// CRTICEPGM STMF('/prj/noxdb-tutorials/ntut04a.rpgle') SVRID(NOXDBTUT)
// 
// run:
// http://my_ibm_i:60666/ntut04a
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
// http://my_ibm_i:60666/ntut04a
//
//
// make a httprequest at the floatrates service at this URL
// http://www.floatrates.com/daily/usd.json       
// and get the USD rate 
//
// Under the covers noxDb are using cUrl, so you have to installed that first:
// From the ssh / shell prompt:
// PATH=/QOpenSys/pkgs/bin:$PATH
// yum install curl
// ----------------------------------------------------------------------------- 
dcl-proc main;

    dcl-s pFlorate      pointer;
    dcl-s rate          packed(23:19);
		
	setContentType('application/json; charset=utf-8');

    // Use YUM to install curl, which is the tool used by httpRequest
    pFlorate = json_httpRequest ('http://www.floatrates.com/daily/usd.json');
    responseWriteJson(pFlorate);
    
    // Just serialize the reult
    json_WriteJsonStmf(pFlorate:'/prj/noxdb-tutorials/testout/floarates.json':1208);

	
	// In the next example we will use the rate from the noxDb graph..
	// for now we just put it in the console 
    rate = json_getNum (pFlorate: 'eur.rate' );
    consoleLog(%char(rate));
    json_joblog('EUR rate: ' + %char(rate));

on-exit;
	json_delete(pFlorate);

end-proc;

