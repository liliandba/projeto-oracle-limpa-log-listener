# script oracle_limpa_log_listener_xml.sh 
# script criado em 05-01-2021 por Lilian Barroso Yamaguti
# Objetivo: limpeza dos logs xml dos listeneres (log.xml) com mais de 1 semana
# Motivo: o ADRCI não faz limpeza destes arquivos de forma automatica.


#!/bin/bash
O_HOMES=( $( cat /etc/oratab|grep -v "^#"|cut -f2 -d: -s | sort |uniq) );
for(( VFOR=0 ; $VFOR <  ${#O_HOMES[@]} ; VFOR++ ))
{
    export ORACLE_HOME=${O_HOMES[$VFOR]}
    
    # abaixo, colocado em laço for pq em alguns ambientes pode ter mais de um listener no servidor (ex: ambientes RAC) 
    for LISTENER_DIAG_HOME in `$ORACLE_HOME/bin/adrci exec="show homes"|grep listener`; do
    	
    	# abaixo, para troubleshooting, caso necessario 
    	#echo "$ORACLE_HOME/bin/adrci exec=\"set home $LISTENER_DIAG_HOME;purge\"" 
    	export ORACLE_BASE=`$ORACLE_HOME/bin/adrci exec="show base" | awk  --field-separator="\""  '{ print $2 }'`
	export LISTENER_LOG_XML=${ORACLE_BASE}/${LISTENER_DIAG_HOME}/alert/log.xml
	    	
    	#abaixo, para log de informacoes: status do diretorio de alert do listener ANTES do procedimento 
    	TAMANHO=`du -sh  $ORACLE_BASE/$LISTENER_DIAG_HOME | awk '{ print $1 }'`
    	echo Tamanho do diretório de log do listener antes: ${TAMANHO}
    	QTD=`wc -l ${LISTENER_LOG_XML} | awk '{ print $1 }'`
    	echo Quantia de linhas do log.xml antes: $QTD
    	
    	#abaixo, comando que faz a limpeza efetivamente dos xml files 
    	echo ${ORACLE_HOME}/bin/adrci exec='"set home' ${LISTENER_DIAG_HOME}';purge -age 168 -type alert"'
    	${ORACLE_HOME}/bin/adrci exec="set home ${LISTENER_DIAG_HOME};purge -age 168 -type alert"
    	
    	#abaixo, para log de informacoes: status do diretorio de alert do listener DEPOIS do procedimento 
    	TAMANHO=`du -sh  $ORACLE_BASE/$LISTENER_DIAG_HOME | awk '{ print $1 }'`
    	echo Tamanho do diretório de log do listener depois: ${TAMANHO}
    	QTD=`wc -l ${LISTENER_LOG_XML} | awk '{ print $1 }'`
    	echo Quantia de linhas do log.xml DEPOIS: $QTD
    	
    	
    	##########  descomentar abaixo caso necessario limpar o log do listener tradicional ########## 
    	## abaixo, comando para limpar o log do listener tradicional
    	## pode ser melhorado fazendo logrotate
    	# export LISTENER_LOG=${ORACLE_BASE}/${LISTENER_DIAG_HOME}/alert/listener*.log` 
    	# echo '' > ${LISTENER_LOG} 
    	# QTD=`wc -l ${LISTENER_LOG} | awk '{ print $1 }'`
    	# echo qtd de linhas antes da limpeza: $QTD
    	## abaixo, para log de informacoes: status do listener log DEPOIS do procedimento 
    	# echo Tamanho do log do listener DEPOIS: `du -sh  $LISTENER_LOG`
    	# QTD=`wc -l $LISTENER_LOG | awk '{ print $1 }'`
    	# echo qtd de linhas DEPOIS da limpeza: $QTD	
    	
    done
}











# abaixo, faz a limpeza dos xml via adrci.
# Mantem 7 dias de log dos listeneres
for i in `$ORACLE_HOME/bin/adrci exec="show homes"|grep listener`;do

# abaixo, purge dos XML files

echo "$ORACLE_HOME/bin/adrci exec=\"set home $i;purge\""

$ORACLE_HOME/bin/adrci exec="set home $i;purge -age 168 -type alert";

# abaixo, faz a limpeza full dos listenres*.log

export listenerlog=`ls $ORACLE_BASE/$i/trace/listener*.log`

echo antes: `du -sh  $listenerlog`

> $listenerlog

# abaixo, lista os arquivos alterados e insere em arquivo para posterior consulta

echo ls -lh ${listenerlog} >> $RESULT_LOG/limpeza_listenerlog.sh

done

 

#abaixo, limpeza do log do listener do asm (.log e xml)

for i in `$ORACLE_HOME/bin/adrci exec="show homes"|grep asmnet1lsnr`;do

export asmlistenerlog=`ls $ORACLE_BASE/$i/trace/asmnet1lsnr_asm.log`

$ORACLE_HOME/bin/adrci exec="set home $i;purge -age 168 -type alert";

echo antes: `du -sh  $asmlistenerlog`

cat /dev/null > ${asmlistenerlog}

# abaixo, lista o arquivo alterado e insere em arquivo para posterior consulta

echo ls -lh ${asmlistenerlog} >> $RESULT_LOG/limpeza_listenerlog.sh

done


 
	
