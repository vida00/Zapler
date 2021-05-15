#!/bin/env bash
#
#<--------------------------------------->
# Autor: Diego
# Versão: 0.1
# Discord: vida#6443
# GitHub: 
#<--------------------------------------->
# Funcionalidade:
# 	Gerenciamento de consultas e controle de usuários
#<------------------------------------------------->
source conf.sh 2>/dev/null
#
#<-------------------------------------------------------->
# <-> Variáveis/Constantes <->
#<-------------------------------------------------------->
function IFEXIT(){
	[ $? -ne 0 ] && main
}

trap Ctrl_C INT
function Ctrl_C(){ 
	clear ; exit 1
}

#<-------------------------------------------------------->
# <-> Tratamento de erros <->
#<-------------------------------------------------------->
function PERMEXIT(){
	if [ ! -r "$1" ];then
		dialog --title "Zapler - ERRO" --msgbox "[ERRO] - Impossível ler o arquivo $2, falta de permissão" 5 75 && clear && exit 1
	elif [ ! -w "$1" ];then
		dialog --title "Zapler - ERRO" --msgbox "[ERRO] - Impossível escrever no arquivo $2, falta de permissão" 5 80 && clear && exit 1
	else
		continue
	fi
}
if [ ! -x "$(which dialog)" ];then 
	dialog --title "Zapler - ERRO" --msgbox "[ERRO] - Dependência Encontrada: Dialog" 5 45 && clear && exit 1
elif [ ! -x "$(which mysql)" ];then
	dialog --title "Zapler - ERRO" --msgbox "[ERRO] - Dependência Encontrada: MySQL" 5 45 && clear && exit 1
elif [ ! -x "$(which mariadb)" ];then
	dialog --title "Zapler - ERRO" --msgbox "[ERRO] - Dependência Encontrada: MariaDB" 5 45 && clear && exit 1
elif [ ! -x conf.sh ];then 
	dialog --title "ERRO" --msgbox "[ERRO] - Impossível executar o arquivo conf.sh, falta de permissão" 5 70 && clear && exit 1
else
	continue
fi
[ ! -e ".tmp" ] && mkdir ".tmp"

#<-------------------------------------------------------->
# <-> Funções  <->
#<-------------------------------------------------------->
function listar(){
	local arqlist=".tmp/.listarq"

	mysql -e "SELECT id AS 'ID', user AS 'Usuário', pass AS 'Senha', cargo AS 'Cargo' FROM \`$DB\`.\`$TABLE\`" | column -t > "$arqlist"

	PERMEXIT "$arqlist" "$arqlist"

	list=$(dialog --title "Zapler - Listar Usuários" --stdout --textbox $arqlist 60 60 )
}

function adicionar(){
	user_add=$(dialog --title "Zapler - Adicionar Usuário" --stdout --inputbox "Usuário" 0 0) || IFEXIT

	mysql -e "SELECT * FROM \`$DB\`.\`$TABLE\` WHERE user=\"$user_add\"" | column -t | grep "$user_add"
	[ $? -ne 1 ] && {
		dialog --title "Sucesso" --msgbox "Usuário já existente" 5 35
		exit 1 
	}

	senha_add=$(dialog --title "Zapler - Adicionar Usuário" --stdout --inputbox "Senha" 0 0) || IFEXIT

	cargo_add=$(dialog --title "Zapler - Adicionar Usuário" --stdout --inputbox "Cargo" 0 0) || IFEXIT

	conf_add=$(dialog --title "Confirme" --stdout --yesno "Deseja adicionar $user_add ao sistema?" 0 0 ) || IFEXIT

	mysql -e "INSERT INTO \`$DB\`.\`$TABLE\` (user,pass,cargo)
    	  	VALUES (\"$user_add\", \"$senha_add\", \"$cargo_add\");"

	dialog --title "Sucesso" --msgbox "Usuário adicionado com sucesso" 5 35
	listar
}

function remover(){
	local userlist=".tmp/.listusers"

	mysql --skip-column-name -e "SELECT id,user FROM \`$DB\`.\`$TABLE\`" | column -t > "$userlist"

	PERMEXIT "$userlist" "$userlist"

	list=$(cat $userlist | sed 's/  / "/;s/$/"/' | sort -h)

	user_del=$(eval dialog --title \"Zapler - Remover Usuário\" --stdout --menu \"Escolha um usuário:\" 0 0 0 $list) || IFEXIT
	
	conf_remo=$(dialog --title "Confirme" --stdout --yesno "Deseja remover o ID $user_del do sistema" 0 0 ) || IFEXIT

	mysql -e "DELETE FROM \`$DB\`.\`$TABLE\` WHERE id=\"$user_del\""

	dialog --title "Sucesso" --msgbox "Usuário removido com sucesso" 5 35
	listar
}

#<-------------------------------------------------------->
# <-> Main  <->
#<-------------------------------------------------------->
function main(){
	while :
	do
		acao=$(dialog --title "Zapler - Gerenciamento de Usuários" \
			--stdout \
			--menu "Escolha uma opção" \
			0 0 0 \
			Listar "Listar usuário" \
			Adicionar "Adicionar um usuário" \
			Remover "Remover um usuário" )
		[ $? -ne 0 ] && clear && exit 1

		case $acao in
			Listar) listar && clear ;;
			Adicionar) adicionar && clear ;;
			Remover) remover && clear ;;
		esac
	done
}

#<-------------------------------------------------------->
# <-> Executando Programa  <->
#<-------------------------------------------------------->
configure_db
main
