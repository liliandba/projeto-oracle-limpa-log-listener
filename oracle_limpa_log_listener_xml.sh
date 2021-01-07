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
    	
    done
}






 
	
