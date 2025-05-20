**free
ctl-opt copyright('System & Method (C), 2025');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main); 
ctl-opt bndDir('NOXDB':'ICEUTILITY');

// -----------------------------------------------------------------------------
// Service . . . : Get rows from a table
// Author  . . . : Niels Liisberg 
// Company . . . : System & Method A/S
// 
// CRTICEPGM STMF('/prj/noxdb-tutorials/ntut03.rpgle') SVRID(NOXDBTUT)
// 
// run:
// http://my_ibm_i:60666/ntut03?employeeNumber=0001000 
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
// http://my_ibm_i:60666/ntut03?employeeNumber=000270
// Note: the injection protection with strQuot() is needed here,
// ----------------------------------------------------------------------------- 
dcl-proc main;

	dcl-s pResponse		  pointer;	
	dcl-s pResult 		  pointer;	
		
	dcl-s employeeNumber  varchar(6);
  
	SetContentType('application/json; charset=utf-8');

	employeeNumber = reqStr('employeeNumber');

	pResult = json_sqlResultRow(empProjSql(employeeNumber)); 
	pResponse = json_locate(pResult: 'rows[0]');
	responseWriteJson(pResponse);
	json_delete(pResult);


end-proc;

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
            where empno = ${strQuot(employeeNumber)}
        ) format json                       
	) rows 
    from sysibm.sysdummy1`;
end-proc;

