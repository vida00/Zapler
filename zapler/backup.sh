#!/bin/env bash

source conf.sh
#<-------------------------------->
# <-> Variavéis  <->
#<-------------------------------->
DATA=`date "+%d_%m_%Y-%H_%M_%S"`
DIR="Backups"

#<-------------------------------->
# <-> Tratamento de Erros  <->
#<-------------------------------->
[ ! -d "$DIR" ] && mkdir "$DIR"

#<-------------------------------->
# <-> Backup  <->
#<-------------------------------->
mysqldump --host="localhost" --port="3306" --user="root" --password="root" "$DB" > "$DIR"/backup_"$DATA".sql

#<-------------------------------->
# <-> CronTab  <->
#<-------------------------------->
# m h dom mon dow command
# 30 10 * * * /path/backup.sh -> Linha X
# Executara o backup todo dia as 10:30 a.m
# Adicionar Linha X no final do crontab
