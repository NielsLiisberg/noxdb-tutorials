-- First build the sample schema:

call qsys.create_sql_sample('CORPDATA');

-- We can then play with these;
select * 
from systables 
where table_schema= 'CORPDATA'
and   table_name not like 'SYS%' 
and   table_type in ('T');

select * from corpdata.act;
select * from corpdata.cl_sched;
select * from corpdata.department;
select * from corpdata.emp_photo;
select * from corpdata.emp_resume;
select * from corpdata.employee;
select * from corpdata.empprojact;
select * from corpdata.in_tray;
select * from corpdata.org;
select * from corpdata.projact;
select * from corpdata.sales;
select * from corpdata.staff 
order by 4, 5;

