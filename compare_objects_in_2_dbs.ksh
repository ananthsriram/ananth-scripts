#!/bin/ksh

#===================================================================================================
# NAME:          DB_COMPARE.sh
#
# DESCRIPTION:   This is a script to compare the object/grants etc on two different DB instances
#                one should be source env and other one is target env, and comparison will be done in both ways
#                a) Prerequisite is to have the DATABASE LINK between the two DB instances 
#                b) CSV files will be created as per the differences, 1 for full report and other one for specific diffrences
#                
#                If you want full DB report:-
#                "Usage : $0 <PUT DB STRING HERE USER/PWD@INSTANCE> <PUT DATABASE LINK NAME> <F>"
#                If you want  specific comparison:-
#                "Usage : $0 <PUT DB STRING HERE USER/PWD@INSTANCE> <PUT DATABASE LINK NAME>"
#
#====================================================================================================

if [ $# -lt 1 ]
then
	echo "if you want full DB report"
        echo "Usage : $0 <PUT DB STRING HERE USER/PWD@INSTANCE> <PUT DATABASE LINK NAME> <F>"
       
	echo "if you want  specific comparison"
        echo "Usage : $0 <PUT DB STRING HERE USER/PWD@INSTANCE> <PUT DATABASE LINK NAME>"
	
        exit 1
fi

DATABASE=$1
DATABASE_LINK=$2
CHOICE=$3

if [[ $CHOICE != 'F' ]] then

clear
echo " please press one of the choices as below as per the number assigned to it"

echo "-----------------------------------------------------------------------------------------------------------"
echo "|1.INDEX             |         11.CLUSTER         |	    21.WINDOW        | 31.UNDEFINED		|" 
echo "-----------------------------------------------------------------------------------------------------------"
echo "|2.VIEW              |         12.CONSUMER GROUP  |           22.LOB           | 32.DIRECTORY		|"
echo "-----------------------------------------------------------------------------------------------------------"
echo "|3.TRIGGER           |         13.INDEX PARTITION |           23.LIBRARY       | 33.DIMENSION		|" 
echo "-----------------------------------------------------------------------------------------------------------"
echo "|4.FUNCTION          |         14.QUEUE           |           24.RULE SET      | 34.MATERIALIZED VIEW	|"	 
echo "-----------------------------------------------------------------------------------------------------------"
echo "|5.PROCEDURE         |         15.SCHEDULE        |           25.PROGRAM       | 35.WINDOW GROUP	|"
echo "-----------------------------------------------------------------------------------------------------------"
echo "|6.PACKAGE           |         16.TABLE PARTITION |           26.TYPE BODY     | 36.JAVA CLASS		|"
echo "-----------------------------------------------------------------------------------------------------------"
echo "|7.PACKAGE BODY      |         17.RULE            |           27.CONTEXT       | 37.INDEXTYPE		|"
echo "-----------------------------------------------------------------------------------------------------------"
echo "|8.SEQUENCE          |         18.JAVA DATA       |           28.JAVA RESOURCE | 38.TYPE		|"
echo "-----------------------------------------------------------------------------------------------------------"
echo "|9.SYNONYM           |         19.OPERATOR        |           29.XML SCHEMA    | 39.RESOURCE PLAN	|"
echo "-----------------------------------------------------------------------------------------------------------"
echo "|10.DATABASE LINK    |         20.LOB PARTITION   |           30.JOB CLASS     | 40.EVALUATION CONTEXT	|"
echo "-----------------------------------------------------------------------------------------------------------"
echo "|41.JOB		   											|"
echo "-----------------------------------------------------------------------------------------------------------"

read ANSWER

fi


if [[ $CHOICE == 'F' ]] then 

sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM 	v\$instance;
--Spool DB_Role_&&_\${DATABASE}_&&_today..csv
spool DB_comparion_&&_host_instance._&&_today..csv


Prompt ====================================================================
select 'DATABASE Name is :- &&_host_instance' from DUAL;
select 'Report Date is:- '|| to_char(sysdate, 'Dy DD-Mon-YYYY HH24:MI:SS') from dual;
Prompt ====================================================================
prompt ***** Objects in $DATABASE instance which differs from $DATABASE_LINK****** 
Prompt ====================================================================

prompt User Name,Role Name

select 'owner,Tables,Indexes,Views,Triggers,Functions,Procedures,Packages,Package_Body,Sequences,Synonyms,Dblinks,Clusters,Consumer_Group,Indexe_Partition,Queues,Schedules,Table_Partitions,Rules,Java_Data,Operators,Lob_Partitions,Window,Lobs,Library,Rule_Set,Program,Type_Body,Context,JAVA_RESOURCE,XML_SCHEMA,JOB_CLASS,UNDEFINED,DIRECTORY,DIMENSION,MATERIALIZED_VIEW,WINDOW_GROUP,JAVA_CLASS,INDEXTYPE,TYPE,RESOURCE_PLAN,EVALUATION_CONTEXT,JOB'
from dual;

select owner || ',' || sum(decode(object_type, 'TABLE', 1, 0))  || ',' ||
sum(decode(object_type, 'INDEX', 1, 0))  || ',' ||
sum(decode(object_type, 'VIEW', 1, 0))  || ',' ||
sum(decode(object_type, 'TRIGGER', 1, 0))  || ',' ||
sum(decode(object_type, 'FUNCTION', 1, 0))  || ',' ||
sum(decode(object_type, 'PROCEDURE', 1, 0))  || ',' ||
sum(decode(object_type, 'PACKAGE', 1, 0))  || ',' ||
sum(decode(object_type, 'PACKAGE BODY', 1, 0))  || ',' ||
sum(decode(object_type, 'SEQUENCE', 1, 0))  || ',' ||
sum(decode(object_type, 'SYNONYM', 1, 0))  || ',' ||
sum(decode(object_type, 'DATABASE LINK', 1, 0))  || ',' ||
sum(decode(object_type, 'CLUSTER', 1, 0))  || ',' ||
sum(decode(object_type, 'CONSUMER GROUP', 1, 0))  || ',' ||
sum(decode(object_type, 'INDEX PARTITION', 1, 0))  || ',' ||
sum(decode(object_type, 'QUEUE', 1, 0))  || ',' ||
sum(decode(object_type, 'SCHEDULE', 1, 0))  || ',' ||
sum(decode(object_type, 'TABLE PARTITION', 1, 0))  || ',' ||
sum(decode(object_type, 'RULE', 1, 0))  || ',' ||
sum(decode(object_type, 'JAVA DATA', 1, 0))  || ',' ||
sum(decode(object_type, 'OPERATOR', 1, 0))  || ',' ||
sum(decode(object_type, 'LOB PARTITION', 1, 0))  || ',' ||
sum(decode(object_type, 'WINDOW', 1, 0))  || ',' ||
sum(decode(object_type, 'LOB', 1, 0))  || ',' ||
sum(decode(object_type, 'LIBRARY', 1, 0))  || ',' ||
sum(decode(object_type, 'RULE SET', 1, 0))  || ',' ||
sum(decode(object_type, 'PROGRAM', 1, 0))  || ',' ||
sum(decode(object_type, 'TYPE BODY', 1, 0))  || ',' ||
sum(decode(object_type, 'CONTEXT', 1, 0))  || ',' ||
sum(decode(object_type, 'JAVA RESOURCE', 1, 0))  || ',' ||
sum(decode(object_type, 'XML SCHEMA', 1, 0))  || ',' ||
sum(decode(object_type, 'JOB CLASS', 1, 0))  || ',' ||
sum(decode(object_type, 'UNDEFINED', 1, 0))  || ',' ||
sum(decode(object_type, 'DIRECTORY', 1, 0))  || ',' ||
sum(decode(object_type, 'DIMENSION', 1, 0))  || ',' ||
sum(decode(object_type, 'MATERIALIZED VIEW', 1, 0))  || ',' ||
sum(decode(object_type, 'WINDOW GROUP', 1, 0))  || ',' ||
sum(decode(object_type, 'JAVA CLASS', 1, 0))  || ',' ||
sum(decode(object_type, 'INDEXTYPE', 1, 0))  || ',' ||
sum(decode(object_type, 'TYPE', 1, 0))  || ',' ||
sum(decode(object_type, 'RESOURCE PLAN', 1, 0))  || ',' ||
sum(decode(object_type, 'EVALUATION CONTEXT', 1, 0))  || ',' ||
sum(decode(object_type, 'JOB', 1, 0))  
from dba_objects
where owner in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
GROUP BY owner
MINUS
select owner || ',' || sum(decode(object_type, 'TABLE', 1, 0))  || ',' ||
sum(decode(object_type, 'INDEX', 1, 0))  || ',' ||
sum(decode(object_type, 'VIEW', 1, 0))  || ',' ||
sum(decode(object_type, 'TRIGGER', 1, 0))  || ',' ||
sum(decode(object_type, 'FUNCTION', 1, 0))  || ',' ||
sum(decode(object_type, 'PROCEDURE', 1, 0))  || ',' ||
sum(decode(object_type, 'PACKAGE', 1, 0))  || ',' ||
sum(decode(object_type, 'PACKAGE BODY', 1, 0))  || ',' ||
sum(decode(object_type, 'SEQUENCE', 1, 0))  || ',' ||
sum(decode(object_type, 'SYNONYM', 1, 0))  || ',' ||
sum(decode(object_type, 'DATABASE LINK', 1, 0))  || ',' ||
sum(decode(object_type, 'CLUSTER', 1, 0))  || ',' ||
sum(decode(object_type, 'CONSUMER GROUP', 1, 0))  || ',' ||
sum(decode(object_type, 'INDEX PARTITION', 1, 0))  || ',' ||
sum(decode(object_type, 'QUEUE', 1, 0))  || ',' ||
sum(decode(object_type, 'SCHEDULE', 1, 0))  || ',' ||
sum(decode(object_type, 'TABLE PARTITION', 1, 0))  || ',' ||
sum(decode(object_type, 'RULE', 1, 0))  || ',' ||
sum(decode(object_type, 'JAVA DATA', 1, 0))  || ',' ||
sum(decode(object_type, 'OPERATOR', 1, 0))  || ',' ||
sum(decode(object_type, 'LOB PARTITION', 1, 0))  || ',' ||
sum(decode(object_type, 'WINDOW', 1, 0))  || ',' ||
sum(decode(object_type, 'LOB', 1, 0))  || ',' ||
sum(decode(object_type, 'LIBRARY', 1, 0))  || ',' ||
sum(decode(object_type, 'RULE SET', 1, 0))  || ',' ||
sum(decode(object_type, 'PROGRAM', 1, 0))  || ',' ||
sum(decode(object_type, 'TYPE BODY', 1, 0))  || ',' ||
sum(decode(object_type, 'CONTEXT', 1, 0))  || ',' ||
sum(decode(object_type, 'JAVA RESOURCE', 1, 0))  || ',' ||
sum(decode(object_type, 'XML SCHEMA', 1, 0))  || ',' ||
sum(decode(object_type, 'JOB CLASS', 1, 0))  || ',' ||
sum(decode(object_type, 'UNDEFINED', 1, 0))  || ',' ||
sum(decode(object_type, 'DIRECTORY', 1, 0))  || ',' ||
sum(decode(object_type, 'DIMENSION', 1, 0))  || ',' ||
sum(decode(object_type, 'MATERIALIZED VIEW', 1, 0))  || ',' ||
sum(decode(object_type, 'WINDOW GROUP', 1, 0))  || ',' ||
sum(decode(object_type, 'JAVA CLASS', 1, 0))  || ',' ||
sum(decode(object_type, 'INDEXTYPE', 1, 0))  || ',' ||
sum(decode(object_type, 'TYPE', 1, 0))  || ',' ||
sum(decode(object_type, 'RESOURCE PLAN', 1, 0))  || ',' ||
sum(decode(object_type, 'EVALUATION CONTEXT', 1, 0))  || ',' ||
sum(decode(object_type, 'JOB', 1, 0))  
from dba_objects@$DATABASE_LINK
where owner in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
GROUP BY owner;

Prompt ====================================================================
prompt ***** Differnece in Objects in $DATABASE_LINK instance which differs from $DATABSE ***** 
Prompt ====================================================================

select 'owner,Tables,Indexes,Views,Triggers,Functions,Procedures,Packages,Package_Body,Sequences,Synonyms,Dblinks,Clusters,Consumer_Group,Indexe_Partition,Queues,Schedules,Table_Partitions,Rules,Java_Data,Operators,Lob_Partitions,Window,Lobs,Library,Rule_Set,Program,Type_Body,Context,JAVA_RESOURCE,XML_SCHEMA,JOB_CLASS,UNDEFINED,DIRECTORY,DIMENSION,MATERIALIZED_VIEW,WINDOW_GROUP,JAVA_CLASS,INDEXTYPE,TYPE,RESOURCE_PLAN,EVALUATION_CONTEXT,JOB'
from dual;

select owner || ',' || sum(decode(object_type, 'TABLE', 1, 0))  || ',' ||
sum(decode(object_type, 'INDEX', 1, 0))  || ',' ||
sum(decode(object_type, 'VIEW', 1, 0))  || ',' ||
sum(decode(object_type, 'TRIGGER', 1, 0))  || ',' ||
sum(decode(object_type, 'FUNCTION', 1, 0))  || ',' ||
sum(decode(object_type, 'PROCEDURE', 1, 0))  || ',' ||
sum(decode(object_type, 'PACKAGE', 1, 0))  || ',' ||
sum(decode(object_type, 'PACKAGE BODY', 1, 0))  || ',' ||
sum(decode(object_type, 'SEQUENCE', 1, 0))  || ',' ||
sum(decode(object_type, 'SYNONYM', 1, 0))  || ',' ||
sum(decode(object_type, 'DATABASE LINK', 1, 0))  || ',' ||
sum(decode(object_type, 'CLUSTER', 1, 0))  || ',' ||
sum(decode(object_type, 'CONSUMER GROUP', 1, 0))  || ',' ||
sum(decode(object_type, 'INDEX PARTITION', 1, 0))  || ',' ||
sum(decode(object_type, 'QUEUE', 1, 0))  || ',' ||
sum(decode(object_type, 'SCHEDULE', 1, 0))  || ',' ||
sum(decode(object_type, 'TABLE PARTITION', 1, 0))  || ',' ||
sum(decode(object_type, 'RULE', 1, 0))  || ',' ||
sum(decode(object_type, 'JAVA DATA', 1, 0))  || ',' ||
sum(decode(object_type, 'OPERATOR', 1, 0))  || ',' ||
sum(decode(object_type, 'LOB PARTITION', 1, 0))  || ',' ||
sum(decode(object_type, 'WINDOW', 1, 0))  || ',' ||
sum(decode(object_type, 'LOB', 1, 0))  || ',' ||
sum(decode(object_type, 'LIBRARY', 1, 0))  || ',' ||
sum(decode(object_type, 'RULE SET', 1, 0))  || ',' ||
sum(decode(object_type, 'PROGRAM', 1, 0))  || ',' ||
sum(decode(object_type, 'TYPE BODY', 1, 0))  || ',' ||
sum(decode(object_type, 'CONTEXT', 1, 0))  || ',' ||
sum(decode(object_type, 'JAVA RESOURCE', 1, 0))  || ',' ||
sum(decode(object_type, 'XML SCHEMA', 1, 0))  || ',' ||
sum(decode(object_type, 'JOB CLASS', 1, 0))  || ',' ||
sum(decode(object_type, 'UNDEFINED', 1, 0))  || ',' ||
sum(decode(object_type, 'DIRECTORY', 1, 0))  || ',' ||
sum(decode(object_type, 'DIMENSION', 1, 0))  || ',' ||
sum(decode(object_type, 'MATERIALIZED VIEW', 1, 0))  || ',' ||
sum(decode(object_type, 'WINDOW GROUP', 1, 0))  || ',' ||
sum(decode(object_type, 'JAVA CLASS', 1, 0))  || ',' ||
sum(decode(object_type, 'INDEXTYPE', 1, 0))  || ',' ||
sum(decode(object_type, 'TYPE', 1, 0))  || ',' ||
sum(decode(object_type, 'RESOURCE PLAN', 1, 0))  || ',' ||
sum(decode(object_type, 'EVALUATION CONTEXT', 1, 0))  || ',' ||
sum(decode(object_type, 'JOB', 1, 0))  
from dba_objects@$DATABASE_LINK
where owner in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
GROUP BY owner
MINUS
select owner || ',' || sum(decode(object_type, 'TABLE', 1, 0))  || ',' ||
sum(decode(object_type, 'INDEX', 1, 0))  || ',' ||
sum(decode(object_type, 'VIEW', 1, 0))  || ',' ||
sum(decode(object_type, 'TRIGGER', 1, 0))  || ',' ||
sum(decode(object_type, 'FUNCTION', 1, 0))  || ',' ||
sum(decode(object_type, 'PROCEDURE', 1, 0))  || ',' ||
sum(decode(object_type, 'PACKAGE', 1, 0))  || ',' ||
sum(decode(object_type, 'PACKAGE BODY', 1, 0))  || ',' ||
sum(decode(object_type, 'SEQUENCE', 1, 0))  || ',' ||
sum(decode(object_type, 'SYNONYM', 1, 0))  || ',' ||
sum(decode(object_type, 'DATABASE LINK', 1, 0))  || ',' ||
sum(decode(object_type, 'CLUSTER', 1, 0))  || ',' ||
sum(decode(object_type, 'CONSUMER GROUP', 1, 0))  || ',' ||
sum(decode(object_type, 'INDEX PARTITION', 1, 0))  || ',' ||
sum(decode(object_type, 'QUEUE', 1, 0))  || ',' ||
sum(decode(object_type, 'SCHEDULE', 1, 0))  || ',' ||
sum(decode(object_type, 'TABLE PARTITION', 1, 0))  || ',' ||
sum(decode(object_type, 'RULE', 1, 0))  || ',' ||
sum(decode(object_type, 'JAVA DATA', 1, 0))  || ',' ||
sum(decode(object_type, 'OPERATOR', 1, 0))  || ',' ||
sum(decode(object_type, 'LOB PARTITION', 1, 0))  || ',' ||
sum(decode(object_type, 'WINDOW', 1, 0))  || ',' ||
sum(decode(object_type, 'LOB', 1, 0))  || ',' ||
sum(decode(object_type, 'LIBRARY', 1, 0))  || ',' ||
sum(decode(object_type, 'RULE SET', 1, 0))  || ',' ||
sum(decode(object_type, 'PROGRAM', 1, 0))  || ',' ||
sum(decode(object_type, 'TYPE BODY', 1, 0))  || ',' ||
sum(decode(object_type, 'CONTEXT', 1, 0))  || ',' ||
sum(decode(object_type, 'JAVA RESOURCE', 1, 0))  || ',' ||
sum(decode(object_type, 'XML SCHEMA', 1, 0))  || ',' ||
sum(decode(object_type, 'JOB CLASS', 1, 0))  || ',' ||
sum(decode(object_type, 'UNDEFINED', 1, 0))  || ',' ||
sum(decode(object_type, 'DIRECTORY', 1, 0))  || ',' ||
sum(decode(object_type, 'DIMENSION', 1, 0))  || ',' ||
sum(decode(object_type, 'MATERIALIZED VIEW', 1, 0))  || ',' ||
sum(decode(object_type, 'WINDOW GROUP', 1, 0))  || ',' ||
sum(decode(object_type, 'JAVA CLASS', 1, 0))  || ',' ||
sum(decode(object_type, 'INDEXTYPE', 1, 0))  || ',' ||
sum(decode(object_type, 'TYPE', 1, 0))  || ',' ||
sum(decode(object_type, 'RESOURCE PLAN', 1, 0))  || ',' ||
sum(decode(object_type, 'EVALUATION CONTEXT', 1, 0))  || ',' ||
sum(decode(object_type, 'JOB', 1, 0)) 
from dba_objects
where owner in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
GROUP BY owner;


Prompt ======= End of FULL Report =======



Prompt ======= Comparing Grants=======

Prompt ====================================================================
prompt *****differneces of  GRANTEE,GRANTED_ROLE in $DATABASE instance in comparison to $DATABASE_LINK *******
Prompt ====================================================================

select 'GRANTEE,GRANTED_ROLE' from dual;

prompt ***** Count of Extra GRANTEE,GRANTED_ROLE in $DATABASE instance in comparison to $DATABASE_LINK *******

select count(GRANTEE || ',' || GRANTED_ROLE)
from dba_role_privs
where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS','MDNE','OFA','NSA')
MINUS
select count(GRANTEE || ',' || GRANTED_ROLE)
from dba_role_privs@$DATABASE_LINK
where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS','MDNE','OFA','NSA')
order by 1;

prompt ***** Exact names of Extra GRANTEE,GRANTED_ROLE in $DATABASE instance in comparison to $DATABASE_LINK *******

select GRANTEE || ',' || GRANTED_ROLE
from dba_role_privs
where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS','MDNE','OFA','NSA')
MINUS
select GRANTEE || ',' || GRANTED_ROLE
from dba_role_privs@$DATABASE_LINK
where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS','MDNE','OFA','NSA')
order by 1;

Prompt ====================================================================
prompt *****differneces of GRANTEE,GRANTED_ROLE in $DATABASE_LINK instance in comparison to $DATABASE *******
Prompt ====================================================================

select 'GRANTEE,GRANTED_ROLE' from dual;

prompt ***** Count of Extra  GRANTEE,GRANTED_ROLE in $DATABASE_LINK instance in comparison to $DATABASE *******

select count(GRANTEE  || ',' || GRANTED_ROLE)
from dba_role_privs@$DATABASE_LINK
where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS','MDNE','OFA','NSA')
minus
select count(GRANTEE  || ',' || GRANTED_ROLE)
from dba_role_privs
where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
order by 1;

prompt ***** Exact names of  GRANTEE,GRANTED_ROLE in $DATABASE_LINK instance in comparison to $DATABASE *******

select GRANTEE  || ',' || GRANTED_ROLE
from dba_role_privs@$DATABASE_LINK
where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS','MDNE','OFA','NSA')
minus
select GRANTEE  || ',' || GRANTED_ROLE
from dba_role_privs
where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
order by 1;

Prompt ======= End of Report Comparing Grants=======


Prompt ====================================================================
prompt ***** Privilege given to users in  $DATABASE instance in comparison to $DATABASE_LINK *******
Prompt ====================================================================

prompt User Name,Privilege Name

select 'GRANTEE,PRIVILEGE' from dual;

prompt ***** Count of Extra  Privilege given to users in $DATABASE instance in comparison to $DATABASE_LINK *******

select count(GRANTEE || ',' ||PRIVILEGE)
from dba_sys_privs 
where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
MINUS
select count(GRANTEE || ',' ||PRIVILEGE)
from dba_sys_privs@$DATABASE_LINK
where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
order by 1;


prompt *****Exact names of  Privilege given to users in $DATABASE instance in comparison to $DATABASE_LINK *******

select GRANTEE || ',' ||PRIVILEGE 
from dba_sys_privs 
where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
MINUS
select GRANTEE || ',' ||PRIVILEGE 
from dba_sys_privs@$DATABASE_LINK
where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
order by 1;

Prompt ====================================================================
prompt ***** Privilege given to users in  $DATABASE_LINK instance in comparison to $DATABASE *******
Prompt ====================================================================


select 'GRANTEE,PRIVILEGE' from dual;

prompt ***** Count of Extra  Privilege given to users in $DATABASE_LINK instance in comparison to $DATABASE *******

select count(GRANTEE || ',' ||PRIVILEGE)
from dba_sys_privs@$DATABASE_LINK
where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
MINUS
select count(GRANTEE || ',' ||PRIVILEGE) 
from dba_sys_privs 
where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
order by 1;


select 'GRANTEE,PRIVILEGE' from dual;

prompt ***** Actual difference Privilege given to users in $DATABASE_LINK instance in comparison to $DATABASE *******

select GRANTEE || ',' ||PRIVILEGE 
from dba_sys_privs@$DATABASE_LINK
where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
MINUS
select GRANTEE || ',' ||PRIVILEGE 
from dba_sys_privs 
where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
order by 1;

Prompt ======= End of Report =======

Prompt ====================================================================
prompt ***** Privileges given to Roles in  $DATABASE instance in comparison to $DATABASE_LINK *******
Prompt ====================================================================


prompt Role Name,Privilege Name


select 'ROLE,PRIVILEGE' from dual;

prompt ***** Count of Extra  Privileges given to Roles in $DATABASE instance in comparison to $DATABASE_LINK *******

SELECT count(Role  || ',' || Privilege)
FROM ROLE_SYS_PRIVS 
WHERE ROLE IN ( select UNIQUE GRANTED_ROLE 
		from dba_role_privs 
		where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA') ) 
MINUS
SELECT count(Role  || ',' || Privilege)
FROM ROLE_SYS_PRIVS@$DATABASE_LINK 
WHERE ROLE IN ( select UNIQUE GRANTED_ROLE 
		from dba_role_privs@$DATABASE_LINK 
		where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA') ) 
order by 1;

prompt ***** Actual difference of Privileges given to Roles in $DATABASE instance in comparison to $DATABASE_LINK *******

SELECT Role  || ',' || Privilege
FROM ROLE_SYS_PRIVS
WHERE ROLE IN ( select UNIQUE GRANTED_ROLE
                from dba_role_privs
                where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA') )
MINUS
SELECT Role  || ',' || Privilege
FROM ROLE_SYS_PRIVS@$DATABASE_LINK
WHERE ROLE IN ( select UNIQUE GRANTED_ROLE
                from dba_role_privs@$DATABASE_LINK
                where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA') )
order by 1;

Prompt ====================================================================
prompt ***** Privileges given to Roles in  $DATABASE_LINK instance in comparison to $DATABASE *******
Prompt ====================================================================

select 'ROLE,PRIVILEGE' from dual;

prompt ***** Count of Extra  Privileges given to Roles in $DATABASE_LINK instance in comparison to $DATABASE *******

SELECT count(Role  || ',' || Privilege)  
FROM ROLE_SYS_PRIVS@$DATABASE_LINK
WHERE ROLE IN ( select UNIQUE GRANTED_ROLE 
		from dba_role_privs@$DATABASE_LINK
		where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA') ) 
MINUS
SELECT count(Role  || ',' || Privilege)
FROM ROLE_SYS_PRIVS
WHERE ROLE IN ( select UNIQUE GRANTED_ROLE 
		from dba_role_privs
		where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA') ) 
order by 1;

prompt ***** Exact names of  Privileges given to Roles in $DATABASE_LINK instance in comparison to $DATABASE *******

SELECT Role  || ',' || Privilege
FROM ROLE_SYS_PRIVS@$DATABASE_LINK
WHERE ROLE IN ( select UNIQUE GRANTED_ROLE
                from dba_role_privs@$DATABASE_LINK
                where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA') )
MINUS
SELECT Role  || ',' || Privilege
FROM ROLE_SYS_PRIVS
WHERE ROLE IN ( select UNIQUE GRANTED_ROLE
                from dba_role_privs
                where GRANTEE in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA') )
order by 1;

Prompt ======= End of Report =======


Prompt ====================================================================
prompt ***** INVALID DATABASE Object Status in  $DATABASE instance in comparison to $DATABASE_LINK ***** 
Prompt ====================================================================

prompt User Name, Object_name, Object_type, Status

prompt ***** Count of Extra  INVALID DATABASE Object in $DATABASE instance in comparison to $DATABASE_LINK *******

select 'User Name,Object_name,Object_type,Status' from dual;

select count(Owner || ',' || Object_name || ',' || object_type|| ',' ||  status)
from dba_objects 
where owner in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
and STATUS like 'INVALID'
MINUS
select count(Owner || ',' || Object_name || ',' || object_type|| ',' ||  status)
from dba_objects@$DATABASE_LINK
where owner in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
and STATUS like 'INVALID'
order by 1;

prompt *****Exact names of  INVALID DATABASE Object in $DATABASE instance in comparison to $DATABASE_LINK *******

select 'User Name,Object_name,Object_type,Status' from dual;

select Owner || ',' || Object_name || ',' || object_type|| ',' ||  status
from dba_objects
where owner in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
and STATUS like 'INVALID'
MINUS
select Owner || ',' || Object_name || ',' || object_type|| ',' ||  status
from dba_objects@$DATABASE_LINK
where owner in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
and STATUS like 'INVALID'
order by 1;

Prompt ====================================================================
prompt ***** INVALID DATABASE Object Status in $DATABASE_LINK instance in comparison to $DATABASE *****
Prompt ====================================================================

prompt ***** Count of Extra  GRANTEE,GRANTED_ROLE in $DATABASE_LINK instance in comparison to $DATABASE *******

select 'User Name,Object_name,Object_type,Status' from dual;

select count(Owner || ',' || Object_name || ',' || object_type|| ',' ||  status)
from dba_objects@$DATABASE_LINK 
where owner in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
and STATUS like 'INVALID'
MINUS
select count(Owner || ',' || Object_name || ',' || object_type|| ',' ||  status)
from dba_objects
where owner in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
and STATUS like 'INVALID'
order by 1;

prompt *****Exact names of  GRANTEE,GRANTED_ROLE in $DATABASE_LINK instance in comparison to $DATABASE *******

select 'User Name,Object_name,Object_type,Status' from dual;

select Owner || ',' || Object_name || ',' || object_type|| ',' ||  status
from dba_objects@$DATABASE_LINK
where owner in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
and STATUS like 'INVALID'
MINUS
select Owner || ',' || Object_name || ',' || object_type|| ',' ||  status
from dba_objects
where owner in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
and STATUS like 'INVALID'
order by 1;

Prompt ======= End of Report =======


Prompt ====================================================================
prompt ***** DATABASE table privilege in $DATABASE instance in comparison to $DATABASE_LINK***** 
Prompt ====================================================================

prompt User Name, Table_name, Grantee, Grantor, Privilege, Grantable, Hierarchy

prompt *****Count of Extra  DATABASE table privilege in $DATABASE instance in comparison to $DATABASE_LINK *******

select 'PROMPT USER NAME, TABLE_NAME, GRANTEE, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY' from dual;

SELECT count(owner||','||table_name||','||grantee||','||grantor||','||privilege||','||grantable||','||hierarchy)
FROM dba_tab_privs 
WHERE owner in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
MINUS
SELECT count(owner||','||table_name||','||grantee||','||grantor||','||privilege||','||grantable||','||hierarchy)
FROM dba_tab_privs@$DATABASE_LINK 
WHERE owner in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
ORDER BY 1;

prompt *****Exact names of DATABASE table privilege in $DATABASE instance in comparison to $DATABASE_LINK *******

select 'PROMPT USER NAME, TABLE_NAME, GRANTEE, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY' from dual;

SELECT owner||','||table_name||','||grantee||','||grantor||','||privilege||','||grantable||','||hierarchy
FROM dba_tab_privs
WHERE owner in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
MINUS
SELECT owner||','||table_name||','||grantee||','||grantor||','||privilege||','||grantable||','||hierarchy
FROM dba_tab_privs@$DATABASE_LINK
WHERE owner in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
ORDER BY 1;

prompt ====================================================================
prompt ***** DATABASE table privilege in $DATABASE_LINK instance in comparison to $DATABASE ***** 
Prompt ====================================================================

prompt *****Count of Extra  DATABASE table privilege in $DATABASE_LINK instance in comparison to $DATABASE *******

select 'PROMPT USER NAME, TABLE_NAME, GRANTEE, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY' from dual;

SELECT count(owner||','||table_name||','||grantee||','||grantor||','||privilege||','||grantable||','||hierarchy)
FROM dba_tab_privs@$DATABASE_LINK WHERE owner in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
MINUS
SELECT count(owner||','||table_name||','||grantee||','||grantor||','||privilege||','||grantable||','||hierarchy)
FROM dba_tab_privs  WHERE owner in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
ORDER BY 1;

prompt *****Exact names of DATABASE table privilege in $DATABASE_LINK instance in comparison to $DATABASE *******

select 'PROMPT USER NAME, TABLE_NAME, GRANTEE, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY' from dual;

SELECT owner||','||table_name||','||grantee||','||grantor||','||privilege||','||grantable||','||hierarchy
FROM dba_tab_privs@$DATABASE_LINK WHERE owner in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
MINUS
SELECT owner||','||table_name||','||grantee||','||grantor||','||privilege||','||grantable||','||hierarchy
FROM dba_tab_privs  WHERE owner in ('SA','HR','SYS','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS''MDNE','OFA','NSA')
ORDER BY 1;

Prompt ======= End of Report =======

SPOOL OFF;

exit;
EOF

else

case $ANSWER in
1)

sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_Index_&&_host_instance._&&_today..csv


prompt====================================================================================================================== 
prompt Exact name of  Indexes which are in $DATABASE but not in $DATABASE_LINK instance 
prompt====================================================================================================================== 

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='INDEX' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='INDEX' and object_name not like 'SYS%';


prompt====================================================================================================================== 
prompt Exact name of  Indexes which are in $DATABASE_LINK but not in $DATABASE instance 
prompt====================================================================================================================== 

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='INDEX' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='INDEX' and object_name not like 'SYS%';

SPOOL OFF;
exit;
EOF
;;

2)

sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_view_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  VIEW which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='VIEW' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='VIEW' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of VIEW which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='VIEW' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='VIEW' and object_name not like 'SYS%';

SPOOL OFF;
EOF
exit;
;;
3)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_triggers_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  TRIGGER which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='TRIGGER' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='TRIGGER' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  TRIGGER which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='TRIGGER' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='TRIGGER' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
4)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_Functions_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  FUNCTION which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='FUNCTION' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='FUNCTION' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of FUNCTION which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='FUNCTION' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='FUNCTION' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
5)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_procedure_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of PROCEDURE which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='PROCEDURE' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='PROCEDURE' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  PROCEDURE which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='PROCEDURE' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='PROCEDURE' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
6)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_PACKAGE_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  PACKAGE which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='PACKAGE' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='PACKAGE' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  PACKAGE which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='PACKAGE' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='PACKAGE' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
7)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_PACKAGEBODY_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  PACKAGE BODY which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='PACKAGE BODY' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='PACKAGE BODY' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  PACKAGE BODY which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='PACKAGE BODY' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='PACKAGE BODY' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
8)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_SEQUENCE_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  SEQUENCE which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='SEQUENCE' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='SEQUENCE' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  SEQUENCE which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='SEQUENCE' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='SEQUENCE' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
9)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_SYNONYM_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  SYNONYM which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='SYNONYM' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='SYNONYM' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  SYNONYM which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='SYNONYM' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='SYNONYM' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
10)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_DATABASELINK_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  DATABASE LINK which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='DATABASE LINK' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='DATABASE LINK' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  DATABASE LINK which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='DATABASE LINK' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='DATABASE LINK' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
11)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_CLUSTER_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  CLUSTER which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='CLUSTER' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='CLUSTER' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  Indexes which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='CLUSTER' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='CLUSTER' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
12)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_CONSUMERGROUP_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  CONSUMER GROUP which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='CONSUMER GROUP' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='CONSUMER GROUP' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  CONSUMER GROUP which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='CONSUMER GROUP' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='CONSUMER GROUP' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
13)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_INDEXPARTITION_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  INDEX PARTITION which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='INDEX PARTITION' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='INDEX PARTITION' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  INDEX PARTITION which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='INDEX PARTITION' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='INDEX PARTITION' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
14)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_QUEUE_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  QUEUE which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='QUEUE' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='QUEUE' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  QUEUE which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='QUEUE' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='QUEUE' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
15)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_SCHEDULE_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  SCHEDULE which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='SCHEDULE' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='SCHEDULE' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  SCHEDULE  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='SCHEDULE' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='SCHEDULE' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
16)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_TABLEPARTITION_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  TABLE PARTITION which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='TABLE PARTITION' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='TABLE PARTITION' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  TABLE PARTITION  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='TABLE PARTITION' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='TABLE PARTITION' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
17)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_RULE_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  RULE which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='RULE' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='RULE' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  RULE  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='RULE' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='RULE' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
18) 
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_JAVADATA_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  JAVA DATA which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='JAVA DATA' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='JAVA DATA' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  JAVA DATA  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='JAVA DATA' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='JAVA DATA' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
19)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_OPERATOR_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  OPERATOR which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='OPERATOR' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='OPERATOR' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  OPERATOR  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='OPERATOR' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='OPERATOR' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
20)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_LOBPARTITION_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  LOB PARTITION which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='LOB PARTITION' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='LOB PARTITION' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  LOB PARTITION  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='LOB PARTITION' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='LOB PARTITION' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
21)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_WINDOW_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  WINDOW which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='WINDOW' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='WINDOW' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  WINDOW  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='WINDOW' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='WINDOW' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
22)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_LOB_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  LOB which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='LOB' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='LOB' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  LOB  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='LOB' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='LOB' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
23)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_LIBRARY_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  LIBRARY which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='LIBRARY' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='LIBRARY' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  LIBRARY  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='LIBRARY' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='LIBRARY' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
24)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_RULESET_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  RULE SET which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='RULE SET' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='RULE SET' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  RULE SET  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='RULE SET' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='RULE SET' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
25)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_PROGRAM_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  PROGRAM which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='PROGRAM' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='PROGRAM' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  PROGRAM  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='PROGRAM' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='PROGRAM' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
26)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_TYPEBODY_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  TYPE BODY which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='TYPE BODY' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='TYPE BODY' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  TYPE BODY  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='TYPE BODY' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='TYPE BODY' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
27)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_CONTEXT_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  CONTEXT which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='CONTEXT' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='CONTEXT' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  CONTEXT  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='CONTEXT' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='CONTEXT' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
28)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_JAVARESOURCE_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  JAVA RESOURCE which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='JAVA RESOURCE' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='JAVA RESOURCE' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  JAVA RESOURCE  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='JAVA RESOURCE' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='JAVA RESOURCE' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
29)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_XMLSCHEMA_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  XML SCHEMA which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='XML SCHEMA' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='XML SCHEMA' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  XML SCHEMA  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='XML SCHEMA' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='XML SCHEMA' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
30)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_JOBCLASS_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  JOB CLASS which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='JOB CLASS' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='JOB CLASS' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  JOB CLASS  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='JOB CLASS' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='JOB CLASS' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
31)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_UNDEFINED_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  UNDEFINED which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='UNDEFINED' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='UNDEFINED' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  UNDEFINED  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='UNDEFINED' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='UNDEFINED' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
32)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_DIRECTORY_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  DIRECTORY which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='DIRECTORY' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='DIRECTORY' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  DIRECTORY  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='DIRECTORY' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIRECTORY','CRAMERSSO','REPORTS')
and OBJECT_TYPE='DIRECTORY' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
33)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_DIMENSION_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  DIMENSION which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIMENSION','CRAMERSSO','REPORTS')
and OBJECT_TYPE='DIMENSION' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIMENSION','CRAMERSSO','REPORTS')
and OBJECT_TYPE='DIMENSION' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  DIMENSION  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIMENSION','CRAMERSSO','REPORTS')
and OBJECT_TYPE='DIMENSION' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERDIMENSION','CRAMERSSO','REPORTS')
and OBJECT_TYPE='DIMENSION' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
34)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_MATERIALIZEDVIEW_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  MATERIALIZED VIEW which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERMATERIALIZED VIEW','CRAMERSSO','REPORTS')
and OBJECT_TYPE='MATERIALIZED VIEW' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERMATERIALIZED VIEW','CRAMERSSO','REPORTS')
and OBJECT_TYPE='MATERIALIZED VIEW' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  MATERIALIZED VIEW  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERMATERIALIZED VIEW','CRAMERSSO','REPORTS')
and OBJECT_TYPE='MATERIALIZED VIEW' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERMATERIALIZED VIEW','CRAMERSSO','REPORTS')
and OBJECT_TYPE='MATERIALIZED VIEW' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
35)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_WINDOWGROUP_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  WINDOW GROUP which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERWINDOW GROUP','CRAMERSSO','REPORTS')
and OBJECT_TYPE='WINDOW GROUP' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERWINDOW GROUP','CRAMERSSO','REPORTS')
and OBJECT_TYPE='WINDOW GROUP' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  WINDOW GROUP  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERWINDOW GROUP','CRAMERSSO','REPORTS')
and OBJECT_TYPE='WINDOW GROUP' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERWINDOW GROUP','CRAMERSSO','REPORTS')
and OBJECT_TYPE='WINDOW GROUP' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
36)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_JAVACLASS_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  JAVA CLASS which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERJAVA CLASS','CRAMERSSO','REPORTS')
and OBJECT_TYPE='JAVA CLASS' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERJAVA CLASS','CRAMERSSO','REPORTS')
and OBJECT_TYPE='JAVA CLASS' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  JAVA CLASS  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERJAVA CLASS','CRAMERSSO','REPORTS')
and OBJECT_TYPE='JAVA CLASS' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERJAVA CLASS','CRAMERSSO','REPORTS')
and OBJECT_TYPE='JAVA CLASS' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
37x)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_INDEX TYPE_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  INDEX TYPE which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERINDEX TYPE','CRAMERSSO','REPORTS')
and OBJECT_TYPE='INDEX TYPE' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERINDEX TYPE','CRAMERSSO','REPORTS')
and OBJECT_TYPE='INDEX TYPE' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  INDEX TYPE  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERINDEX TYPE','CRAMERSSO','REPORTS')
and OBJECT_TYPE='INDEX TYPE' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERINDEX TYPE','CRAMERSSO','REPORTS')
and OBJECT_TYPE='INDEX TYPE' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
38)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_TYPE_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  TYPE which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERTYPE','CRAMERSSO','REPORTS')
and OBJECT_TYPE='TYPE' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERTYPE','CRAMERSSO','REPORTS')
and OBJECT_TYPE='TYPE' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  TYPE  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERTYPE','CRAMERSSO','REPORTS')
and OBJECT_TYPE='TYPE' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERTYPE','CRAMERSSO','REPORTS')
and OBJECT_TYPE='TYPE' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
39)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_RESOURCEPLAN_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  RESOURCE PLAN which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERRESOURCE PLAN','CRAMERSSO','REPORTS')
and OBJECT_TYPE='RESOURCE PLAN' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERRESOURCE PLAN','CRAMERSSO','REPORTS')
and OBJECT_TYPE='RESOURCE PLAN' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  RESOURCE PLAN  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERRESOURCE PLAN','CRAMERSSO','REPORTS')
and OBJECT_TYPE='RESOURCE PLAN' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERRESOURCE PLAN','CRAMERSSO','REPORTS')
and OBJECT_TYPE='RESOURCE PLAN' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
40)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_EVALUATIONCONTEXT_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  EVALUATION CONTEXT which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMEREVALUATION CONTEXT','CRAMERSSO','REPORTS')
and OBJECT_TYPE='EVALUATION CONTEXT' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMEREVALUATION CONTEXT','CRAMERSSO','REPORTS')
and OBJECT_TYPE='EVALUATION CONTEXT' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  EVALUATION CONTEXT  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMEREVALUATION CONTEXT','CRAMERSSO','REPORTS')
and OBJECT_TYPE='EVALUATION CONTEXT' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMEREVALUATION CONTEXT','CRAMERSSO','REPORTS')
and OBJECT_TYPE='EVALUATION CONTEXT' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
41)
sqlplus -s $DATABASE << EOF

SET ECHO OFF
SET PAGES 0
SET LINES 1000
set pages 1000
SET TERM OFF
SET TTITLE OFF
SET FEEDBACK OFF
SET HEAD OFF
SET VERIFY OFF
SET TRIMSPOOL ON

COLUMN host_instance NEW_VALUE _host_instance;
COLUMN today NEW_VALUE _today

SELECT TO_CHAR(sysdate,'DDMONYYYY_HH24MI')||'Hrs' today FROM DUAL;

SELECT UPPER(instance_name)||'_'||DECODE(INSTR(host_name,'.'),0,host_name,SUBSTR(LOWER(host_name), 1, INSTR(host_name,'.')-1)) host_instance
FROM    v\$instance;
spool DB_comparion_JOB_&&_host_instance._&&_today..csv


prompt======================================================================================================================
prompt Exact name of  JOB which are in $DATABASE but not in $DATABASE_LINK instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERJOB','CRAMERSSO','REPORTS')
and OBJECT_JOB='JOB' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERJOB','CRAMERSSO','REPORTS')
and OBJECT_JOB='JOB' and object_name not like 'SYS%';


prompt======================================================================================================================
prompt Exact name of  JOB  which are in $DATABASE_LINK but not in $DATABASE instance
prompt======================================================================================================================

select OBJECT_NAME from dba_objects@$DATABASE_LINK where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERJOB','CRAMERSSO','REPORTS')
and OBJECT_JOB='JOB' and object_name not like 'SYS%'
MINUS
select OBJECT_NAME from dba_objects where OWNER in ('SA','HR','CRAMER','UASM','CRAMER_COMMON','CRAMER_SHARED','CRAMERJOB','CRAMERSSO','REPORTS')
and OBJECT_JOB='JOB' and object_name not like 'SYS%';
SPOOL OFF;
EOF
exit;
;;
esac
fi
