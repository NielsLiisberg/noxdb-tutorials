**free
ctl-opt copyright('System & Method (C), 2025');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main); 
ctl-opt bndDir('NOXDB':'ICEUTILITY');

// -----------------------------------------------------------------------------
// Service . . . : Get exchangereate from the danish national bank  
//                 and make a conversion rate between USD to EUR
// Author  . . . : Niels Liisberg 
// Company . . . : System & Method A/S
// 
// CRTICEPGM STMF('/prj/noxdb-tutorials/ntut04b.rpgle') SVRID(NOXDBTUT)
// 
// run:
// http://my_ibm_i:60666/ntut04b 
// 
// 
// By     Date       PTF     Description
// ------ ---------- ------- ---------------------------------------------------
// NLI    10.05.2025         New program
// ----------------------------------------------------------------------------- 
 /include qrpgleref,noxdb
 /include qrpgleref,iceutility
 
// ----------------------------------------------------------------------------- 
// Main line:
// http://my_ibm_i:60666/ntut04b
//
//
// make a httprequest to the  Danish National Bank at this URL:
// https://www.nationalbanken.dk/api/currencyratesxml          
// and get the USD rate 
// ----------------------------------------------------------------------------- 
dcl-proc main;

    dcl-s pNationalBank pointer;
    dcl-s rateUSD       packed(23:19);
    dcl-s rateEUR       packed(23:19);
    dcl-s rateUSD2EUR   packed(23:19);
    dcl-s pRateUSD      pointer;
    dcl-s pRateEUR      pointer;
    dcl-s pRates        pointer;    
		
	setContentType('application/json; charset=utf-8');


    // Use YUM to install curl, which is the tool used by httpRequest
    pNationalBank = xml_httpRequest ('https://www.nationalbanken.dk/api/currencyratesxml');

    // Just serialize the reult 
    xml_WriteXmlStmf(pNationalBank:'/prj/noxdb-tutorials/testout/nationalbanken.xml':1208:*ON);
    
	
	// In the next example we will use the rate from the noxDb graph..
    pRateUSD = xml_locate (pNationalBank: 'exchangerates/dailyrates/currency[@code=USD]');
    pRateEUR = xml_locate (pNationalBank: 'exchangerates/dailyrates/currency[@code=EUR]');
    rateUSD = xml_getNum (pRateUSD: '@rate' );
    rateEUR = xml_getNum (pRateEUR: '@rate' );
    rateUSD2EUR = rateUSD / rateEUR;    
    
    // Write to joblog:
    xml_joblog('USD -> DKR rate: ' + %char(rateUSD / 100.0));
    xml_joblog('EUR -> DKR rate: ' + %char(rateEUR / 100.0));
    xml_joblog('USD -> EUR rate: ' + %char(rateUSD2EUR));
    
    // Build response object in json format 
    pRates = json_newObject();
    json_setNum(pRates: 'usd2dkk' : rateUSD / 100.0); 
    json_setNum(pRates: 'eur2dkk' : rateEUR / 100.0); 
    json_setNum(pRates: 'usd2eur' : rateUSD2EUR);    
    responseWriteJson(pRates);

on-exit;    
    json_delete(pRates);    
	xml_delete(pNationalBank);

end-proc;

