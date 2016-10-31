#!/usr/bin/env bash
WDAY=$(date +%u)
# куда архивируем
SAVEDIR=${SAVEDIR-'/srv/backup'}
[[ -d ${SAVEDIR} ]] || mkdir -p ${SAVEDIR}
# метка с датой и временем, используетя в именах:
FDATE=$(date +%F_%H-%M)
# файл с временной меткой последнего полного бекапа,
# время модификации этого файла Tar использует для инкрементального бэкапа:
LAST="${SAVEDIR}/lasttimebackup.log"
# путь к файлу со списком файлов/директорий, которые необходимо архивировать:
INTAR=${INTAR}
# путь к файлу со списком файлов/директорий, которые необходимо исключить из архива:
EXTAR=${EXTAR}

# условие которое проверяет какой день недели сегодня [в WDAY записан числовой эквиваленнт дня недели [1 -7], где 1 - понедельник],
# если WDAY != 7, то выполняется блок Then: в переменную TARPAR записываются опции для инкрементального бекапа Tar'ом по дате модификации файла LAST,
# если сегодня воскресенье, т.е. WDAY=7, то выполняется блок Else: в переменную TARPAR записываются опции для полного бекапа Tar'ом и обновляется время модификации файла LAST;
# также в обоих блоках генерируется имя бекапа и лог-файла для Tar'a в переменную SAVENAME.
if [[ "$WDAY" -ne 7 ]] && [[ -f ${LAST} ]]; then
    SAVENAME="${SAVEDIR}/backup_${FDATE}.SMALL"
    TARPAR="-N$LAST -X$EXTAR -T$INTAR"
# перестраховка, если случайно время модификации у контрольного файла было изменено [например открыли файл и нажали сохранить, хотя изменений и не вносили],
# получаем _из_ файла LAST штамп времени и устаналиваем его как время модификации _для_ этого же файла:
    touch -t $(cat ${LAST}) ${LAST}
else
    SAVENAME="${SAVEDIR}/backup_${FDATE}.FULL"
    TARPAR="-X$EXTAR -T$INTAR"
    echo $(date +%Y%m%d%H%M.%S) > ${LAST}
fi

# вывод в консоль полученных переменных, для мониторинга при ручном прогоне:
# echo "##### prefix-list in script: #####"
# echo "#day of week $WDAY #date $FDATE #last Full backup $(cat $LAST)"'\n'
# echo "#savename: ${SAVENAME}"'\n''\n'"#Tar's parameters: ${TARPAR}"'\n''########## end list ##########''\n'
# echo "$(date +'%R:%S'): beginning of filtration and packaging backup files .. wait a few moments .."'\n'

# тут всё просто, происходит архивирование, Tar получает опции из переменной TARPAR, а имя для архива и лога из SAVENAME:
nice -n 19 ionice -c2 -n7 tar czvf ${SAVENAME}.tar.gz ${TARPAR} > ${SAVENAME}.log 2>&1
# добавляем в лог Tar'a текущий временной штамп, себе для справки:
echo $(cat ${LAST}) >> ${SAVENAME}.log

#echo "$(date +'%R:%S'): packing is completed, all operations were successful."'\n''\n'"backup location >> ${SAVENAME}.tar.gz"'\n'
# завершение работы скрипта;

echo ${SAVENAME}.tar.gz
exit 0
