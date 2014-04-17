#!/bin/ksh

SCRIPT_DIR=$(cd $(dirname $0) && pwd)

OS=`uname`
case $OS in
"Linux" ) ECHO_="echo -e"
          ;;
*       ) ECHO_="echo"
esac
clear
echo "Logs present at current working directory are :"
ls -lart *.log
echo "*************************************************************************************************************************"
echo "* Parameters "
echo "* ============"
$ECHO_ "${e}* Please enter the expdp logfile name : \c"
read src_file
if [[ "X"$src_file = "X" ]]
then
        $ECHO_ "===================> expdp logfile name cannot be empty."
        exit 1
fi
cat $src_file | sed 's:"::g' > ${SCRIPT_DIR}/temp_src.txt
$ECHO_ "${e}* Please enter the impdp logfile name : \c"
read trg_file
if [[ "X"$trg_file = "X" ]]
then
        $ECHO_ "===================> impdp logfile name cannot be empty."
        exit 1
fi

cat $trg_file | sed 's:"::g' > ${SCRIPT_DIR}/temp_trg.txt
echo "*************************************************************************************************************************"

echo "Table_Name,Export_Log,Import_Log,Difference" > ${SCRIPT_DIR}/difference.csv
cp /dev/null ${SCRIPT_DIR}/source.txt
################ This can be used if export is having a non-partitioned table and import is having partitioned table #############
#for i in `grep "\. \. exported" ${SCRIPT_DIR}/temp_src.txt| grep ':' | awk '{print $4}' | cut -d ':' -f1 | sort -u | sed 's:"::g'`
#do
#        row_count=`grep "\. \. exported" ${SCRIPT_DIR}/temp_src.txt | grep "${i}:" | awk 'BEGIN {} {s += $7}  END  {print s}'`
#        table_name=`echo $i | cut -d '.' -f2`
#        echo "${table_name}+${row_count}" >> ${SCRIPT_DIR}/source.txt
#done
##################################################################################################################################

for i in `grep "\. \. exported" ${SCRIPT_DIR}/temp_src.txt| grep ':' | awk '{print $4}' | sort -u | sed 's:"::g'`
do
        row_count=`grep "\. \. exported" ${SCRIPT_DIR}/temp_src.txt | grep "${i} " | awk '{print $7}'`
        table_name=`echo $i | cut -d '.' -f2`
        sub_partition=`echo $i | cut -d '.' -f3`
        schema_name=`echo $i | cut -d '.' -f1`
        echo "${schema_name}+${table_name}+${sub_partition}+${row_count}" >> ${SCRIPT_DIR}/source.txt
done

for i in `grep "\. \. exported" ${SCRIPT_DIR}/temp_src.txt | grep -v ':' | awk '{print $4}' | sort -u | sed 's:"::g'`
do
        row_count=`grep "\. \. exported" ${SCRIPT_DIR}/temp_src.txt | grep "${i} " | awk '{print $7}'`
        table_name=`echo $i | cut -d '.' -f2`
        sub_partition=`echo $i | cut -d '.' -f3`
        schema_name=`echo $i | cut -d '.' -f1`
        echo "${schema_name}+${table_name}+${sub_partition}+${row_count}" >> ${SCRIPT_DIR}/source.txt
done

cp /dev/null ${SCRIPT_DIR}/target.txt
################ This can be used if export is having a non-partitioned table and import is having partitioned table #############
#for i in `grep "\. \. imported" ${SCRIPT_DIR}/temp_trg.txt | grep ':' | awk '{print $4}' | cut -d ':' -f1 | sort -u | sed 's:"::g'`
#do
#        row_count=`grep "\. \. imported" ${SCRIPT_DIR}/temp_trg.txt | grep "${i}:" | awk 'BEGIN {} {s += $7}  END  {print s}'`
#        table_name=`echo $i | cut -d '.' -f2`
#        echo "${table_name}+${row_count}" >> ${SCRIPT_DIR}/target.txt
#done
##################################################################################################################################

for i in `grep "\. \. imported" ${SCRIPT_DIR}/temp_trg.txt | grep ':' | awk '{print $4}' | sort -u | sed 's:"::g'`
do
        row_count=`grep "\. \. imported" ${SCRIPT_DIR}/temp_trg.txt | grep "${i} " | awk '{print $7}'`
        table_name=`echo $i | cut -d '.' -f2`
        sub_partition=`echo $i | cut -d '.' -f3`
        schema_name=`echo $i | cut -d '.' -f1`
        echo "${schema_name}+${table_name}+${sub_partition}+${row_count}" >> ${SCRIPT_DIR}/target.txt
done

for i in `grep "\. \. imported" ${SCRIPT_DIR}/temp_trg.txt | grep -v ':' | awk '{print $4}' | sort -u | sed 's:"::g'`
do
        row_count=`grep "\. \. imported" ${SCRIPT_DIR}/temp_trg.txt | grep "${i} " | awk '{print $7}'`
        table_name=`echo $i | cut -d '.' -f2`
        sub_partition=`echo $i | cut -d '.' -f3`
        schema_name=`echo $i | cut -d '.' -f1`
        echo "${schema_name}+${table_name}+${sub_partition}+${row_count}" >> ${SCRIPT_DIR}/target.txt
done

count=0
printf "\n \n"
echo "|------------------------------------------------------------|---------------------|---------------------|---------------------|"
echo "|Table Name                                                  | Export Log          | Import Log          | Difference          |"
echo "|------------------------------------------------------------|---------------------|---------------------|---------------------|"
for i in `cat ${SCRIPT_DIR}/source.txt`
do
        schema_name1=`echo $i | cut -d '+' -f1`
        table_name1=`echo $i | cut -d '+' -f2,3 | tr '+' '.'`
        count1=`echo $i | cut -d '+' -f4`
        sub_partition1=`echo $table_name1 | cut -d '.' -f2`
        if [[ "X"$sub_partition1 = "X" ]]
        then
                table_name1=`echo $table_name1 | sed 's:\.::g'`
        fi
        j=`grep "\. \. imported ${schema_name1}.${table_name1} " ${SCRIPT_DIR}/temp_trg.txt`
        if [[ "X"$j = "X" && $count1 > 0 ]]
        then
                echo "${schema_name1}.${table_name1},$count1,0,$count1" >> ${SCRIPT_DIR}/difference.csv
                printf "|%-60s| %-20s| %-20s| %-20s|\n"  "${schema_name1}.${table_name1}" "$count1" "0" "$count1"
        else
                temp_table=`echo $j | awk '{print $4}'`
                schema_name2=`echo $temp_table | cut -d '.' -f1`
                table_name2=`echo $temp_table | cut -d '.' -f2,3 | tr '+' '.'`
                count2=`echo $j | awk '{print $7}'`
                if [[ $schema_name1 = $schema_name2 ]]
                then
                        if [[ $table_name1 = $table_name2 ]]
                        then
                                if [[ $count1 != $count2 && $count1 > 0 ]]
                                then
                                        diffrnc=`expr $count1 - $count2`
                                        printf "|%-60s| %-20s| %-20s| %-20s|\n"  "${schema_name1}.${table_name1}" "$count1" "$count2" "$diffrnc"
                                        echo "${schema_name1}.${table_name1},$count1,$count2,$diffrnc" >> ${SCRIPT_DIR}/difference.csv
                                        count=1
                                fi
                        fi
                fi
        fi
done

echo "|------------------------------------------------------------|---------------------|---------------------|---------------------|"
if [[ ${count} = 0 ]]
then
        printf "\n"
        echo "+++++++++++++++++++++++       Number of rows exported and imported are same in all tables!!!      ++++++++++++++++++++++++++"
        printf "\n"
fi
echo "Export log Final Status : `tail -1 ${src_file}`"
printf "\n"
echo "Import log Final Status : `tail -1 ${trg_file}`"
printf "\n"

if [[ `cat ${SCRIPT_DIR}/difference.csv | wc -l` -lt 2 ]]
then
        rm -f ${SCRIPT_DIR}/difference.csv
fi

rm -f ${SCRIPT_DIR}/temp_src.txt ${SCRIPT_DIR}/temp_trg.txt ${SCRIPT_DIR}/source.txt ${SCRIPT_DIR}/target.txt
