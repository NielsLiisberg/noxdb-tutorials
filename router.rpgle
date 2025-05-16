<%@ language="RPGLE"%>
<%
ctl-opt copyright('System & Method (C), 2025');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main); 
ctl-opt bndDir('NOXDB':'ICEUTILITY':'QC2LE');

/* -----------------------------------------------------------------------------
   Service . . . : microservice router
   Author  . . . : Niels Liisberg 
   Company . . . : System & Method A/S
  
   CRTICEPGM STMF('/www/IceBreak-Samples/router.rpgle') SVRID(samples)


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

	dcl-s pPayload       pointer;
	dcl-s pResponse		pointer;		

	pPayload  = unpackParms();
	pResponse = runService (pPayload);
	if (pResponse = *NULL);
		responseWrite('null');
	else;
		responseWriteJson(pResponse);
		if json_getstr(pResponse : 'success') = 'false';
			setStatus ('500 ' + json_getstr(pResponse: 'message'));
			consoleLogjson(pResponse);
		endif;
		json_delete(pResponse);
	endif;
    json_delete(pPayload);

end-proc;
/* -------------------------------------------------------------------- *\ 
   	run a a microservice call
\* -------------------------------------------------------------------- */
dcl-proc runService export;	

	dcl-pi *n pointer;
		pPayload pointer value;
	end-pi;

	dcl-pr ActionProc pointer extproc(pProc);
		payload pointer value;
	end-pr;
	
	dcl-s url 		varchar(128);
	dcl-s pgmName 		char(10);
	dcl-s procName 		varchar(128);
	dcl-s pProc			pointer (*PROC) static;
	dcl-s pResponse		pointer;		
	dcl-s errText  		char(128);
	dcl-s errPgm   		char(64);
	dcl-s errList 		char(4096);
    dcl-s urlParms 			int(10);


    url = strUpper(getServerVar('REQUEST_FULL_PATH'));
    urlParms = words(url:'/');
    pgmName  = word (url:urlParms-1:'/');
    procName = word (url:urlParms:'/');

	//if  URL <> prevAction;
	//	prevAction = URL;
	pProc = loadServiceProgramProc ('*LIBL': pgmName : procName);
	//endif;

	if (pProc = *NULL);
		pResponse= FormatError (
			'Invalid URL: ' + url + ' or service not found'
		);
	else;
		monitor;

		pResponse = ActionProc(pPayload);

		on-error;                                     
			soap_Fault(errText:errPgm:errList);    
			pResponse =  FormatError (
				'Error in service ' + url + ', ' + errText
			);
		endmon;                                       	

	endif;

	return pResponse; 

end-proc;
/* -------------------------------------------------------------------- *\  
   get data form request
\* -------------------------------------------------------------------- */
dcl-proc unpackParms;

	dcl-pi *n pointer;
	end-pi;

	dcl-s pPayload 		pointer;
	dcl-s msg     		varchar(4096);


	SetContentType('application/json; charset=utf-8');
	SetEncodingType('*JSON');
	json_sqlSetOptions('{'             + // use dfault connection
		'upperCaseColname: false,   '  + // set option for uppcase of columns names
		'autoParseContent: true,    '  + // auto parse columns predicted to have JSON or XML contents
		'sqlNaming       : false    '  + // use the SQL naming for database.table  or database/table
	'}');


	if reqStr('payload') > '';
		pPayload = json_ParseString(reqStr('payload'));
	else;
		pPayload = json_ParseRequest();
		if pPayload = *NULL;
			pPayload = json_newObject(); // just an empty object;
		endif;
	endif;

	//if pPayload = *NULL;
	//	msg = json_message(pPayload);
	//	%>{ "text": "Microservices. Ready for transactions. Please POST payload in JSON", "desc": "<%= msg %>"}<%
	//	return *NULL;
	//endif;

	return pPayload;


end-proc;
/* -------------------------------------------------------------------- *\ 
   JSON error monitor 
\* -------------------------------------------------------------------- */
dcl-proc FormatError export;

	dcl-pi *n pointer;
		description  varchar(256) const options(*VARSIZE);
	end-pi;                     

	dcl-s msg 					varchar(4096);
	dcl-s pMsg 					pointer;

	msg = json_message(*NULL);
	pMsg = json_parseString (' -
		{ -
			"success": false, - 
			"description":"' + description + '", -
			"message": "' + msg + '"-
		} -
	');

	consoleLog(msg);
	return pMsg;


end-proc;
/* -------------------------------------------------------------------- *\ 
   JSON error monitor 
\* -------------------------------------------------------------------- */
dcl-proc successTrue export;

	dcl-pi *n pointer;
	end-pi;                     

	return json_parseString ('{"success": true}');

end-proc;