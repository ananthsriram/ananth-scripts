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
#       Name                  History             Date
#     --------             ------------         --------
#   Ananth Sriram             Created          23-JUNE-2013
#
#
#====================================================================================================

if [ $# -lt 1 ]
then
	#echo "if you want full DB report"
        echo "Usage : $0 <F>"
       
	#echo "if you want  specific comparison"
        #echo "Usage : $0 <PUT DB STRING HERE USER/PWD@INSTANCE> <PUT DATABASE LINK NAME>"
	
        exit 1
fi

export ORACLE_HOME=/oravl01/ora11g/112_RAC
export PATH=/oravl01/ora11g/112_RAC/bin:$PATH:$ORACLE_HOME/OPatch
export ORACLE_BASE=/oravl01/ora11g/app
export ORACLE_SID=CRAMPRD1
export LD_LIBRARY_PATH=/oravl01/ora11g/11.2_RAC/lib:/usr/lib

#${ORACLE_HOME}/bin/sqlplus -s "/ as sysdba" <<STOP >> ${SCRIPT_DIR}/${ORACLE_SID}_Schema_Objects_Details_${DATE}.txt

DATABASE=CRAMPRD
DATABASE_LINK=IMSPROD_TEST
CHOICE=$1

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
echo "|5.PROCEDURE         |         15.SCHEDULE        |           25.PROGRAM       | 35.WINDOW GROUP		|"
echo "-----------------------------------------------------------------------------------------------------------"
echo "|6.PACKAGE           |         16.TABLE PARTITION |           26.TYPE BODY     | 36.JAVA CLASS		|"
echo "-----------------------------------------------------------------------------------------------------------"
echo "|7.PACKAGE BODY      |         17.RULE            |           27.CONTEXT       | 37.INDEXTYPE		|"
echo "-----------------------------------------------------------------------------------------------------------"
echo "|8.SEQUENCE          |         18.JAVA DATA       |           28.JAVA RESOURCE | 38.TYPE			|"
echo "-----------------------------------------------------------------------------------------------------------"
echo "|9.SYNONYM           |         19.OPERATOR        |           29.XML SCHEMA    | 39.RESOURCE PLAN		|"
echo "-----------------------------------------------------------------------------------------------------------"
echo "|10.DATABASE LINK    |         20.LOB PARTITION   |           30.JOB CLASS     | 40.EVALUATION CONTEXT	|"
echo "-----------------------------------------------------------------------------------------------------------"
echo "|41.JOB		   											|"
echo "-----------------------------------------------------------------------------------------------------------"

read ANSWER

fi


if [[ $CHOICE == 'F' ]] then 

sqlplus -s "/ as sysdba" << EOF

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
where OWNER NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
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
where OWNER NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
GROUP BY owner;

Prompt ====================================================================
prompt ***** Difference in Objects in $DATABASE_LINK instance which differs from $DATABSE ***** 
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
where OWNER NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
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
where OWNER NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
GROUP BY owner;


Prompt ======= End of FULL Report =======



Prompt ======= Comparing Grants=======

Prompt ====================================================================
prompt *****differences of  GRANTEE,GRANTED_ROLE in $DATABASE instance in comparison to $DATABASE_LINK *******
Prompt ====================================================================

select 'GRANTEE,GRANTED_ROLE' from dual;

prompt ***** Count of Extra GRANTEE,GRANTED_ROLE in $DATABASE instance in comparison to $DATABASE_LINK *******

select count(GRANTEE || ',' || GRANTED_ROLE)
from dba_role_privs
where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
MINUS
select count(GRANTEE || ',' || GRANTED_ROLE)
from dba_role_privs@$DATABASE_LINK
where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
order by 1;

prompt ***** Exact names of Extra GRANTEE,GRANTED_ROLE in $DATABASE instance in comparison to $DATABASE_LINK *******

select GRANTEE || ',' || GRANTED_ROLE
from dba_role_privs
where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
MINUS
select GRANTEE || ',' || GRANTED_ROLE
from dba_role_privs@$DATABASE_LINK
where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
order by 1;

Prompt ====================================================================
prompt *****differences of GRANTEE,GRANTED_ROLE in $DATABASE_LINK instance in comparison to $DATABASE *******
Prompt ====================================================================

select 'GRANTEE,GRANTED_ROLE' from dual;

prompt ***** Count of Extra  GRANTEE,GRANTED_ROLE in $DATABASE_LINK instance in comparison to $DATABASE *******

select count(GRANTEE  || ',' || GRANTED_ROLE)
from dba_role_privs@$DATABASE_LINK
where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
minus
select count(GRANTEE  || ',' || GRANTED_ROLE)
from dba_role_privs
where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
order by 1;

prompt ***** Exact names of  GRANTEE,GRANTED_ROLE in $DATABASE_LINK instance in comparison to $DATABASE *******

select GRANTEE  || ',' || GRANTED_ROLE
from dba_role_privs@$DATABASE_LINK
where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
minus
select GRANTEE  || ',' || GRANTED_ROLE
from dba_role_privs
where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
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
where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
MINUS
select count(GRANTEE || ',' ||PRIVILEGE)
from dba_sys_privs@$DATABASE_LINK
where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
order by 1;


prompt *****Exact names of  Privilege given to users in $DATABASE instance in comparison to $DATABASE_LINK *******

select GRANTEE || ',' ||PRIVILEGE 
from dba_sys_privs 
where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
MINUS
select GRANTEE || ',' ||PRIVILEGE 
from dba_sys_privs@$DATABASE_LINK
where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
order by 1;

Prompt ====================================================================
prompt ***** Privilege given to users in  $DATABASE_LINK instance in comparison to $DATABASE *******
Prompt ====================================================================


select 'GRANTEE,PRIVILEGE' from dual;

prompt ***** Count of Extra  Privilege given to users in $DATABASE_LINK instance in comparison to $DATABASE *******

select count(GRANTEE || ',' ||PRIVILEGE)
from dba_sys_privs@$DATABASE_LINK
where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
MINUS
select count(GRANTEE || ',' ||PRIVILEGE) 
from dba_sys_privs 
where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
order by 1;


select 'GRANTEE,PRIVILEGE' from dual;

prompt ***** Actual difference Privilege given to users in $DATABASE_LINK instance in comparison to $DATABASE *******

select GRANTEE || ',' ||PRIVILEGE 
from dba_sys_privs@$DATABASE_LINK
where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
MINUS
select GRANTEE || ',' ||PRIVILEGE 
from dba_sys_privs 
where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
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
		where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN'))
MINUS
SELECT count(Role  || ',' || Privilege)
FROM ROLE_SYS_PRIVS@$DATABASE_LINK 
WHERE ROLE IN ( select UNIQUE GRANTED_ROLE 
		from dba_role_privs@$DATABASE_LINK 
		where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN'))
order by 1;

prompt ***** Actual difference of Privileges given to Roles in $DATABASE instance in comparison to $DATABASE_LINK *******

SELECT Role  || ',' || Privilege
FROM ROLE_SYS_PRIVS
WHERE ROLE IN ( select UNIQUE GRANTED_ROLE
                from dba_role_privs
                where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN'))
MINUS
SELECT Role  || ',' || Privilege
FROM ROLE_SYS_PRIVS@$DATABASE_LINK
WHERE ROLE IN ( select UNIQUE GRANTED_ROLE
                from dba_role_privs@$DATABASE_LINK
                where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN'))
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
		where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN'))
MINUS
SELECT count(Role  || ',' || Privilege)
FROM ROLE_SYS_PRIVS
WHERE ROLE IN ( select UNIQUE GRANTED_ROLE 
		from dba_role_privs
		where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN') ) 
order by 1;

prompt ***** Exact names of  Privileges given to Roles in $DATABASE_LINK instance in comparison to $DATABASE *******

SELECT Role  || ',' || Privilege
FROM ROLE_SYS_PRIVS@$DATABASE_LINK
WHERE ROLE IN ( select UNIQUE GRANTED_ROLE
                from dba_role_privs@$DATABASE_LINK
                where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN'))
MINUS
SELECT Role  || ',' || Privilege
FROM ROLE_SYS_PRIVS
WHERE ROLE IN ( select UNIQUE GRANTED_ROLE
                from dba_role_privs
                where GRANTEE NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN') )
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
where owner NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
and STATUS like 'INVALID'
MINUS
select count(Owner || ',' || Object_name || ',' || object_type|| ',' ||  status)
from dba_objects@$DATABASE_LINK
where owner NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
and STATUS like 'INVALID'
order by 1;

prompt *****Exact names of  INVALID DATABASE Object in $DATABASE instance in comparison to $DATABASE_LINK *******

select 'User Name,Object_name,Object_type,Status' from dual;

select Owner || ',' || Object_name || ',' || object_type|| ',' ||  status
from dba_objects
where owner NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
and STATUS like 'INVALID'
MINUS
select Owner || ',' || Object_name || ',' || object_type|| ',' ||  status
from dba_objects@$DATABASE_LINK
where owner NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
and STATUS like 'INVALID'
order by 1;

Prompt ====================================================================
prompt ***** INVALID DATABASE Object Status in $DATABASE_LINK instance in comparison to $DATABASE *****
Prompt ====================================================================

prompt ***** Count of Extra  GRANTEE,GRANTED_ROLE in $DATABASE_LINK instance in comparison to $DATABASE *******

select 'User Name,Object_name,Object_type,Status' from dual;

select count(Owner || ',' || Object_name || ',' || object_type|| ',' ||  status)
from dba_objects@$DATABASE_LINK 
where owner NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
and STATUS like 'INVALID'
MINUS
select count(Owner || ',' || Object_name || ',' || object_type|| ',' ||  status)
from dba_objects
where owner NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
and STATUS like 'INVALID'
order by 1;

prompt *****Exact names of  GRANTEE,GRANTED_ROLE in $DATABASE_LINK instance in comparison to $DATABASE *******

select 'User Name,Object_name,Object_type,Status' from dual;

select Owner || ',' || Object_name || ',' || object_type|| ',' ||  status
from dba_objects@$DATABASE_LINK
where owner NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
and STATUS like 'INVALID'
MINUS
select Owner || ',' || Object_name || ',' || object_type|| ',' ||  status
from dba_objects
where owner NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
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
WHERE owner NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
MINUS
SELECT count(owner||','||table_name||','||grantee||','||grantor||','||privilege||','||grantable||','||hierarchy)
FROM dba_tab_privs@$DATABASE_LINK 
WHERE owner NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
ORDER BY 1;

prompt *****Exact names of DATABASE table privilege in $DATABASE instance in comparison to $DATABASE_LINK *******

select 'PROMPT USER NAME, TABLE_NAME, GRANTEE, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY' from dual;

SELECT owner||','||table_name||','||grantee||','||grantor||','||privilege||','||grantable||','||hierarchy
FROM dba_tab_privs
WHERE owner NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
MINUS
SELECT owner||','||table_name||','||grantee||','||grantor||','||privilege||','||grantable||','||hierarchy
FROM dba_tab_privs@$DATABASE_LINK
WHERE owner NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
ORDER BY 1;

prompt ====================================================================
prompt ***** DATABASE table privilege in $DATABASE_LINK instance in comparison to $DATABASE ***** 
Prompt ====================================================================

prompt *****Count of Extra  DATABASE table privilege in $DATABASE_LINK instance in comparison to $DATABASE *******

select 'PROMPT USER NAME, TABLE_NAME, GRANTEE, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY' from dual;

SELECT count(owner||','||table_name||','||grantee||','||grantor||','||privilege||','||grantable||','||hierarchy)
FROM dba_tab_privs@$DATABASE_LINK WHERE owner NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
MINUS
SELECT count(owner||','||table_name||','||grantee||','||grantor||','||privilege||','||grantable||','||hierarchy)
FROM dba_tab_privs  WHERE owner NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
ORDER BY 1;

prompt *****Exact names of DATABASE table privilege in $DATABASE_LINK instance in comparison to $DATABASE *******

select 'PROMPT USER NAME, TABLE_NAME, GRANTEE, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY' from dual;

SELECT owner||','||table_name||','||grantee||','||grantor||','||privilege||','||grantable||','||hierarchy
FROM dba_tab_privs@$DATABASE_LINK WHERE owner NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
MINUS
SELECT owner||','||table_name||','||grantee||','||grantor||','||privilege||','||grantable||','||hierarchy
FROM dba_tab_privs  WHERE owner NOT IN ('ANONYMOUS','AIM_DBA','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','BI','BM_BASIC','CRADBA','CRAMERRP','CTXSYS','DBSNMP','DIP','DMSYS','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS','MDDATA','MDSYS','MGMT_VIEW','MSPAK','ODM','ODM_MTR','OPS$ORACLE','OE','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','PM','PUBLIC','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','OWBSYS','OWBSYS_AUDIT','WEBSYS','WK_PROXY','WKSYS','WK_TEST','WMSYS','XDB','RMAN')
ORDER BY 1;

Prompt ======= End of Report =======

SPOOL OFF;

exit;
EOF
fi

