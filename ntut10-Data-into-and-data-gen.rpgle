**free
ctl-opt copyright('System & Method (C), 2025');
ctl-opt decEdit('0.') datEdit(*YMD.) main(main); 
ctl-opt bndDir('NOXDB':'ICEUTILITY');

// -----------------------------------------------------------------------------
// Service . . . : Get rows from a table
// Author  . . . : Niels Liisberg 
// Company . . . : System & Method A/S
// 
// CRTICEPGM STMF('/prj/noxdb-tutorials/ntut10.rpgle') SVRID(NOXDBTUT)
// 
// run:
// http://my_ibm_i:60666/ntut10 
// 
// 
// By     Date       PTF     Description
// ------ ---------- ------- ---------------------------------------------------
// NLI    10.05.2025         New program
// ----------------------------------------------------------------------------- 
 /include qrpgleref,jsonparser
 /include qrpgleref,iceutility 
 
dcl-ds employee_t    extname('CORPDATA/EMPLOYEE') qualified template end-ds;  	 
 
// ----------------------------------------------------------------------------- 
// Main line:
// http://my_ibm_i:60666/ntut10
// 
// Demonstrates: 
// 1) noxDb - load sql resultset into a graph 
// 2) store the noxDb graph into an array of structures - using data-into  
//  
// 3) load a new noxDb graph from an array of structures - using data-gen
// 4) serialize the graph over HTTP to the client
// ----------------------------------------------------------------------------- 
dcl-proc main;

	dcl-ds employee   likeds(employee_t) inz dim(100);
	dcl-s count       int(5);
	dcl-s pOutputRows pointer;
    
	setContentType('application/json; charset=utf-8');

	// Load an array with data structures;
	exampleDataInto (employee : count);

	// Respond an array with data structures;
	pOutputRows = exampleDataGen (employee : count);
	responseWriteJson(pOutputRows);
	json_delete(pOutputRows);

end-proc;
// ----------------------------------------------------------------------------- 
// Now the magic: the pInputRows object graph is send to the mapper
// Note the second parm of %data controls you mapping - look at:
// https://www.ibm.com/support/knowledgecenter/en/ssw_ibm_i_74/rzasd/dataintoopts.htm
// we set 'allowextra=yes allowmissing=yes' 
// However; Leave them out if You need a strict mapping
// The json_DataInto() function will populate the array of structures
// ----------------------------------------------------------------------------- 
dcl-proc exampleDataInto;

	dcl-pi *n;
		employee    likeds(employee_t) dim(100);
		count 		int(5);
	end-pi; 

	dcl-s pInputRows  pointer;

    // This is our array of objects:
    pInputRows = json_sqlResultSet(' -
		select *                -
		from corpdata.employee  -
		limit 100               -
	');

    // Keep track of number of rows:
    count = json_getLength(pInputRows); 

    data-into employee %data('':'allowextra=yes allowmissing=yes') %parser(json_DataInto(pInputRows));
    json_delete(pInputRows);

end-proc;
// ----------------------------------------------------------------------------- 
// Now the magic back: the pOutputRows pointer is send to the mapper and returns as an object graph
// the noxDb object graph is generated from the array of structures with the json_DataGen()
// ----------------------------------------------------------------------------- 
dcl-proc exampleDataGen;
    
	dcl-pi *n pointer;
		employee    likeds(employee_t) dim(100);
		count 		int(5);
	end-pi; 

	dcl-s pOutputRows pointer;
	dcl-s dummy       char(1);
	
    data-gen %subarr(employee : 1: count)  %data(dummy: '') %gen(json_DataGen(pOutputRows));
	return pOutputRows;

end-proc;

