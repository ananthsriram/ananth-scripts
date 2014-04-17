#!/bin/ksh

SCRIPT_DIR=$(cd $(dirname $0) && pwd)
count=0

OS=`uname`
case $OS in
"Linux" ) ECHO_="echo -e"
          ;;
*       ) ECHO_="echo"
esac

clear
printf "\n \n"
echo "*************************************************************************************************************************"
echo "* Parameters "
echo "* ============"
$ECHO_ "${e}* Please enter the Source Env parameters file or Connection String (like sa/sa@telst01) : \c"
read src
if [[ "X"$src = "X" ]]
then
        $ECHO_ "===================> Source Env Parameter File name or Connection String cannot be empty."
        exit 1
fi
$ECHO_ "${e}* Please enter the Target Env parameters file or Connection String (like sa/sa@telst02) : \c"
read trg
if [[ "X"$trg = "X" ]]
then
        $ECHO_ "===================> Target Env Parameter File name or Connection String cannot be empty."
        exit 1
fi
$ECHO_ "${e}* Do you wish to provide a file with list of parameters that can be ignored (Y or N ): \c"
read ignr_opt
if [[ "X"$ignr_opt = "X" ]]
then
        $ECHO_ "===================> Option cannot be left empty. You should provide Y or N."
        exit 1
fi
if [[ $ignr_opt = "Y" || $ignr_opt = "y" ]]
then
        $ECHO_ "${e}* Please provide the file name : \c"
        read ignore_file
        if [[ "X"$ignore_file = "X" ]]
        then
                $ECHO_ "===================> File name cannot be empty."
                exit 1
        fi
        cp $ignore_file ${SCRIPT_DIR}/ignore.txt
else
echo "control_files
audit_file_dest
background_dump_dest
core_dump_dest
diagnostic_dest
dispatchers
local_listener
log_archive_dest
log_archive_dest_1
log_archive_format
user_dump_dest
event
rdbms_server_dn
service_names
dg_broker_config_file1
dg_broker_config_file2
db_file_name_convert
db_recovery_file_dest
db_recovery_file_dest_size
log_file_name_convert
spfile
db_create_file_dest
remote_listener
db_name
instance_name" > ${SCRIPT_DIR}/ignore.txt
fi

echo "*************************************************************************************************************************"

if [[ `echo ${src} | grep "/" | grep "@" | wc -l` -eq 1 ]]
then
        sqlplus -s ${src} <<  *eof* >>/dev/null 2>&1
        spool ${SCRIPT_DIR}/source_init.txt
        set head off echo off trimspool on feedback off verify off pages 1000 lines 250 serveroutput on
        select name||'^'||value from v\$parameter order by 1;
        spool off
*eof*
else
        cp $src ${SCRIPT_DIR}/source_init.txt
fi

if [[ `echo ${trg} | grep "/" | grep "@" | wc -l` -eq 1 ]]
then
        sqlplus -s ${trg} <<  *eof* >>/dev/null 2>&1
        spool ${SCRIPT_DIR}/target_init.txt
        set head off echo off trimspool on feedback off verify off pages 1000 lines 250 serveroutput on
        select name||'^'||value from v\$parameter order by 1;
        spool off
*eof*
else
        cp $trg ${SCRIPT_DIR}/target_init.txt
fi

source_env=`grep db_unique_name ${SCRIPT_DIR}/source_init.txt | cut -d '^' -f2`
target_env=`grep db_unique_name ${SCRIPT_DIR}/target_init.txt | cut -d '^' -f2`
perl -p -i -e "s: :+:g" ${SCRIPT_DIR}/source_init.txt
perl -p -i -e "s: :+:g" ${SCRIPT_DIR}/target_init.txt


printf "\n \n"
echo "|-------------------------------------------------------------|---------------------------------------------|---------------------------------------------|"
printf "|%-61s| %-44s| %-44s|\n"  "Parameter" "${source_env} DB" "${target_env} DB"
echo "|-------------------------------------------------------------|---------------------------------------------|---------------------------------------------|"
echo "Following Parameters are set in ${source_env} DB but not in ${target_env} DB:" > ${SCRIPT_DIR}/missing_params.txt
echo "Parameter,${source_env},${target_env}" > ${SCRIPT_DIR}/difference.csv
for i in `cat ${SCRIPT_DIR}/source_init.txt`
do
        name=`echo $i | cut -d '^' -f1`
        value=`echo $i | cut -d '^' -f2`
        count=0
        j=`grep "^${name}^" ${SCRIPT_DIR}/target_init.txt`
        #for j in `cat ${SCRIPT_DIR}/target_init.txt`
        #do
                name1=`echo $j | cut -d '^' -f1`
                value1=`echo $j | cut -d '^' -f2`
                if [[ $name = $name1 ]]
                then
                        count=`expr $count + 1`
                        if [[ $value != $value1 ]]
                        then
                                if [[ `grep "^${name}$" ${SCRIPT_DIR}/ignore.txt | wc -l` -eq 0 ]]
                                then
                                        printf "|%-61s| %-44s| %-44s|\n"  "$name" "$value" "$value1"
                                        echo "$name,$value,$value1" >> ${SCRIPT_DIR}/difference.csv
                                fi
                        fi
                fi
        #done
        if [[ $count -eq 0 ]]
        then
                echo "$name parameter is not set in ${target_env} DB" >> ${SCRIPT_DIR}/missing_params.txt
        fi
done
echo "|-------------------------------------------------------------|---------------------------------------------|---------------------------------------------|"
if [[ `cat ${SCRIPT_DIR}/missing_params.txt | wc -l` -gt 1 ]]
then
        cat ${SCRIPT_DIR}/missing_params.txt
fi

rm -f ${SCRIPT_DIR}/source_init.txt ${SCRIPT_DIR}/target_init.txt ${SCRIPT_DIR}/ignore.txt ${SCRIPT_DIR}/missing_params.txt
