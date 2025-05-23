**free
ctl-opt copyright('System & Method (C), 2025');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main); 
ctl-opt bndDir('NOXDB':'ICEUTILITY');

// -----------------------------------------------------------------------------
// Service . . . : Get rows from a table
// Author  . . . : Niels Liisberg 
// Company . . . : System & Method A/S
//  
// CRTICEPGM STMF('/prj/noxdb-tutorials/ntut20.rpgle') SVRID(NOXDBTUT)
//
// Run:
// http://my_ibm_i:60666/ntut20
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

	dcl-s  pStaff		 pointer;		
	dcl-DS staffList     likeds(json_iterator);
	
	SetContentType('application/json; charset=utf-8');

    pStaff = json_sqlResultSet('-
		select *                -
		from corpdata.staff     -
	');
		
    // For each employee we caclulate the bonus in Euro
    // we use a noxDb iterator to loop through the employees
    staffList = json_setIterator(pStaff);
    dow json_ForEach(staffList);
        calculateDefaultSalary (staffList.this);
    enddo;

	responseWriteJson(pStaff);

on-exit;
	json_delete(pStaff);

end-proc;

// -----------------------------------------------------------------------------	
// Calculate the default salary for each employee
// Note we are using the json_CallProgram to call a classic RPG program
// The classic RPG program is compiled with pgminfo(*PCML:*MODULE)
// This way you can implement - dynamic call to a classic RPG program using
// PCML   
// ----------------------------------------------------------------------------
dcl-proc calculateDefaultSalary;
	dcl-pi *n;
		pStaff pointer 	value;
	end-pi;
	dcl-s defaultSalary 	packed(7:2);	
	dcl-s pCalculatorInput 	pointer ;	
	dcl-s pCalculatorOutput pointer ;	

	pCalculatorInput = json_newObject();
	json_copyValue (pCalculatorInput: 'years' : pStaff: 'years');	
	json_copyValue (pCalculatorInput: 'job'   : pStaff: 'job'  );	

	pCalculatorOutput = json_CallProgram  ( '*LIBL':'NTUT99' : pCalculatorInput);

	// Get the default salary from the staff object
	defaultSalary = json_getNum(pCalculatorOutput: 'salary');
	
	// Set the default salary to 0.0
	json_setNum(pStaff: 'defaultSalary': defaultSalary);
	
on-exit;
	json_delete(pCalculatorOutput);
	json_delete(pCalculatorInput);
end-proc;