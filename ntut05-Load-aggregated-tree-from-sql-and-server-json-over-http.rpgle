**free
ctl-opt copyright('System & Method (C), 2025');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main); 
ctl-opt bndDir('NOXDB':'ICEUTILITY');

// -----------------------------------------------------------------------------
// Service . . . : Get rows from a table
// Author  . . . : Niels Liisberg 
// Company . . . : System & Method A/S
// 
// CRTICEPGM STMF('/prj/noxdb-tutorials/ntut05.rpgle') SVRID(NOXDBTUT)
// 
// run:
// http://my_ibm_i:60666/ntut05?employeeNumber=0001000 
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
// http://my_ibm_i:60666/ntut05?employeeNumber=000270
// ----------------------------------------------------------------------------- 
dcl-proc main;

	dcl-s pEmployee		  pointer;	
	dcl-s pResult 		  pointer;	
		
	dcl-s employeeNumber  varchar(6);
  
	setContentType('application/json; charset=utf-8');

	employeeNumber = reqStr('employeeNumber');

	pResult = json_sqlResultRow(empProjSql(employeeNumber)); 
	pEmployee = json_locate(pResult: 'rows[0]');
	convertBonusUsd2Euro(pEmployee);        
	responseWriteJson(pEmployee);

on-exit;    
	json_delete(pResult);

end-proc;

// -----------------------------------------------------------------------------
// Convert the bonus from USD to Euro
//
// This is done by calling the floatrates.com service
// and using the rate for USD to Euro.
// -----------------------------------------------------------------------------
dcl-proc convertBonusUsd2Euro;       
    dcl-pi *N;
        pEmployee pointer value;
    end-pi;


    dcl-s bonus         packed(13:2);    
    dcl-s bonuseuro     packed(13:2);    
    dcl-s url  	        varchar(1024);
    dcl-s pFlorate      pointer;
    dcl-s rate          packed(13:9);

    url = 'http://www.floatrates.com/daily/usd.json';

    pFlorate = json_httpRequest (url);
    rate = json_getNum (pFlorate: 'eur.rate' );

    bonus = json_getNum (pEmployee: 'bonus' );
    bonusEuro = bonus * rate;
    json_setNum (pEmployee: 'bonusEuro' : bonusEuro);

on-exit;    
    json_delete(pFlorate);

end-proc;

// -----------------------------------------------------------------------------
// SQL statement to get the employee and project data as JSON 
// Note: the injection protection with strQuot() is needed here
// because the employeeNumber is passed in from the URL.
// note2: We are using IceBreak string template to format the SQL statement.
// -----------------------------------------------------------------------------
dcl-proc empProjSql; 

	dcl-pi *N varchar(5000);
		employeeNumber varchar(6) value;
	end-pi; 

	return 
    `select json_array(
        (
            select json_object(
                'employeeNumber' : int(empno),
                'Name' :  rtrim(firstnme) || (' ' || midinit || ' ') || rtrim (lastname),  
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
            where empno = ${ strQuot(employeeNumber) }
        ) format json                       
	) rows 
    from sysibm.sysdummy1`;
end-proc;




