**free
ctl-opt copyright('System & Method (C), 2025');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main); 
ctl-opt bndDir('NOXDB':'ICEUTILITY');

// -----------------------------------------------------------------------------
// Service . . . : Get rows from a table
// Author  . . . : Niels Liisberg 
// Company . . . : System & Method A/S
// 
// CRTICEPGM STMF('/prj/noxdb-tutorials/ntut06.rpgle') SVRID(NOXDBTUT)
// 
// run:
// http://my_ibm_i:60666/ntut06 
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
// http://my_ibm_i:60666/ntut06
// 
// Demonstrates: 
// 1) noxDb - moving JSON into the graph using SQL
// 2) noxDb iterators 
// 3) noxDb - httpRequest ( with simple cache)  
// 4) pressent the result as a JSON service 
// ----------------------------------------------------------------------------- 
dcl-proc main;

	dcl-s  pEmployees	    pointer;	
	dcl-DS employeeList     likeds(json_iterator);
		
	setContentType('application/json; charset=utf-8');

	pEmployees = getEmplyeesAndProjects();

    // For each employee we caclulate the bonus in Euro
    // we use a noxDb iterator to loop through the employees
    employeeList = json_setIterator(pEmployees);
    dow json_ForEach(employeeList);
        convertBonusUsd2Euro(employeeList.this);
    enddo;

	responseWriteJson(pEmployees);

on-exit;    
	json_delete(pEmployees);

end-proc;


// -----------------------------------------------------------------------------
// Convert the bonus from USD to Euro
// -----------------------------------------------------------------------------
dcl-proc convertBonusUsd2Euro;       
    dcl-pi *N;
        pEmployee pointer value;
    end-pi;

    dcl-s bonus         packed(13:2);    
    dcl-s bonuseuro     packed(13:2);    

    bonus = json_getNum (pEmployee: 'bonus' );
    bonusEuro = bonus * getConversionRateUSD2Euro();
    json_setNum (pEmployee: 'bonusEuro' : bonusEuro);

end-proc;

// -----------------------------------------------------------------------------
// get conversion rate from USD to Euro
//
// This is done by calling the floatrates.com service
// and using the rate for USD to Euro.
// We cache the value, since rate will not change during the  
// http session
// -----------------------------------------------------------------------------
dcl-proc getConversionRateUSD2Euro;       

    dcl-pi *N packed(13:9);
    end-pi;


    dcl-s bonus         packed(13:2);    
    dcl-s bonuseuro     packed(13:2);    
    dcl-s url  	        varchar(1024);
    dcl-s pFlorate      pointer;
    dcl-s rate          packed(13:9) static inz(0);

    // already calculate? use the cached value! note it is delared static     
    if rate <> 0;
        return rate;
    endif;

    url = 'http://www.floatrates.com/daily/usd.json';

    pFlorate = json_httpRequest (url);
    rate = json_getNum (pFlorate: 'eur.rate' );
    json_delete(pFlorate);
    
    return rate; 

end-proc;

// -----------------------------------------------------------------------------
// A "tighter version" where we only return the employees array 
// and cleanup the envelope object it was created in 
// -----------------------------------------------------------------------------
dcl-proc getEmplyeesAndProjects;

    dcl-pi *n pointer;
    end-pi;

	dcl-s pEmployees		  pointer;	
	dcl-s pResult 		      pointer;	

	pResult = json_sqlResultRow(
        `select json_array(
            (
                select json_object(
                    'employeeNumber' : int(empno),
                    'Name'           :  rtrim(firstnme) || (' ' || midinit || ' ') || rtrim (lastname),  
                    'workDepartment' : workdept,
                    'phoneNumber'    : phoneno,
                    'hireDate'       : hiredate,
                    'jobTitle'       : job,
                    'educationLevel' : edlevel,
                    'sex'            : case when sex='M' then 'Male' when sex='F' then 'Female' else 'Other' end ,
                    'birthDate'      : birthdate,
                    'salary'         : salary,
                    'bonus'          : bonus,
                    'commission'     : comm,
                    'projects'       : json_array(                          
                        (
                            select json_object(
                                'projNumber'   : project.projno,
                                'projName' : projname,
                                'actNumber'    : actno,
                                'empTime'  : emptime,
                                'emstDate' : emstdate,
                                'emenDate' : emendate,
                                'deptNumber'   : deptno,
                                'respEmployee'  : respemp,
                                'prstaff'  : prstaff,
                                'prstDate' : prstdate,
                                'prenDate' : prendate,
                                'majProj'  : majproj
                            )   
                            from corpdata.empprojact
                            left join corpdata.PROJECT  on empprojact.projno = PROJECT.projno
                            where empprojact.empno = employee.empno
                        ) format json
                    )
                )
                from corpdata.employee
                order by empno 
            ) format json                       
        ) rows 
        from sysibm.sysdummy1`
    );

    // Note - here we are returning the employees array
    // that exists in the result set as "rows"
    // so we need to unlink "separate" it from the result set
	pEmployees = json_locate(pResult: 'rows');
    json_nodeUnlink(pEmployees);
    return pEmployees;

on-exit;    
    json_delete(pResult);

end-proc;

