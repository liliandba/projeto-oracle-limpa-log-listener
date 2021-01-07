#!/bin/bash

# script oracle_limpa_log_listener_tradional.sh 
# script criado em 07-01-2021 por Lilian Barroso Yamaguti
# Objetivo: limpeza dos logs tradicionais dos listeneres (listener.log) com mais de 1 semana. 
# Motivo: o ADRCI não faz limpeza destes arquivos de forma automatica.


export MYDATE=$(date "+%Y%m%d%H%M")

O_HOMES=( $( cat /etc/oratab|grep -v "^#"|cut -f2 -d: -s | sort |uniq) );

for(( VFOR=0 ; $VFOR <  ${#O_HOMES[@]} ; VFOR++ ))
{
    export ORACLE_HOME=${O_HOMES[$VFOR]}
    
    # abaixo, colocado em laço for pq em alguns ambientes pode ter mais de um listener no servidor (ex: ambientes RAC) 
    for LISTENER_DIAG_HOME in `$ORACLE_HOME/bin/adrci exec="show homes"|grep listener`; do
    	
    	export ORACLE_BASE=`$ORACLE_HOME/bin/adrci exec="show base" | awk  --field-separator="\""  '{ print $2 }'`
    	export LISTENER_LOG=${ORACLE_BASE}/${LISTENER_DIAG_HOME}/trace/listener.log 
		    	
    	#abaixo, para log de informacoes: status do diretorio de alert do listener ANTES do procedimento 
    	TAMANHO=`du -sh  $ORACLE_BASE/$LISTENER_DIAG_HOME | awk '{ print $1 }'`
    	QTD=`wc -l ${LISTENER_LOG} | awk '{ print $1 }'`
    	echo ' '
    	echo inicio do procedimento
    	echo Tamanho do diretório de log do listener antes: ${TAMANHO}
    	echo Quantia de linhas do listener.log antes: $QTD
    	echo ' ' 
    	 	
    	#abaixo, procedimento de limpeza  do listener.log atual e de arquivos antigos (mais de 7 dias) 
    	find ${ORACLE_BASE}/${LISTENER_DIAG_HOME}/old/ -mtime +7 -exec rm -rf {} \;
    	${ORACLE_HOME}/bin/lsnrctl set log_status off
    	cp ${LISTENER_LOG} ${ORACLE_BASE}/${LISTENER_DIAG_HOME}/old/listener_${MYDATE}.log 
    	gzip ${ORACLE_BASE}/${LISTENER_DIAG_HOME}/old/listener_${MYDATE}.log
	> ${LISTENER_LOG}
	${ORACLE_HOME}/bin/lsnrctl set log_status on
	
	      	  
    	# abaixo, para log de informacoes: status do listener log DEPOIS do procedimento 
  	TAMANHO=`du -sh  $ORACLE_BASE/$LISTENER_DIAG_HOME | awk '{ print $1 }'`
  	QTD=`wc -l ${LISTENER_LOG} | awk '{ print $1 }'`
  	echo ''
    	echo finalizada a limpeza do arquivo ${LISTENER_LOG}
    	echo Tamanho do diretório de log do listener DEPOIS: ${TAMANHO}
    	echo qtd de linhas DEPOIS da limpeza: $QTD
    	echo arquivo de log do listener antigo esta em: ${ORACLE_BASE}/${LISTENER_DIAG_HOME}/old/
    	echo abaixo, listagem de arquivos presentes no diretorio: 
    	ls -1 ${ORACLE_BASE}/${LISTENER_DIAG_HOME}/old/
    	echo ''
    	
    done
}



 
	
