#<-------------------------------->
#<--> Variáveis <-->
#<-------------------------------->
DB="zapler"
HOST="localhost"
PORT="3306"
USER="root"
PASS="root"
TABLE="zapler_users"
#<-------------------------------->
#<--> Banco de Dados <-->
#<-------------------------------->
function configure_db(){
	mysql --host="$HOST" --port="$PORT" --user="$USER" --password="$PASS" << EOF
	CREATE DATABASE IF NOT EXISTS \`$DB\`;
EOF

	mysql --host="$HOST" --port="$PORT" --user="$USER" --password="$PASS" --database="$DB" << EOF

	DELIMITER $$

	CREATE TABLE IF NOT EXISTS \`$TABLE\` (
		id      INT AUTO_INCREMENT PRIMARY KEY,
		user    VARCHAR(20) NOT NULL,
		pass    VARCHAR(20) NOT NULL,
		cargo	VARCHAR(20) NOT NULL
	);
	$$
EOF
}
