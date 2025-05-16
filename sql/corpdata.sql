-- First build the sample schema:

call qsys.create_sql_sample('CORPDATA');

-- We can then play with these;
select * from systables where table_schema= 'CORPDATA';
 
select * from corpdata.employee;