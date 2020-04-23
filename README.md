# bookstack

Despues de build ejecuta docker-compose exec bookstack /bin/bash /usr/after-run.sh para migrar base datos, y terminar configuraicon del proyecto


para migrar una base de datos usa el folder import y entra al contenedor de mariadb para cargas el .sql file con los comandos establecidos de mysql 

mysql -u username -p database_name < /etc/import/file.sql



NOTA: ajusta los parametros en el docker-compose para que apunten correctamente a tus archivos (bookstack tiene uno pero no es el que usa para correr) 

mysql mantiene las bd persistentes y tiene un import folder 

