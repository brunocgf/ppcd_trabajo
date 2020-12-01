sudo su postgres

psql

\help select
\?
\l

# crear base de datos
# ddl data description langage
create database tsp;

# crear usario (rol)
create role tsp login; #equivalente# create user tsp:
\du
alter role tsp with encrypted password 'some_password'
grant all privileges on database tsp to tsp
\q # ctrl+d

# conectarte a la base de datos
psql -U tsp -d tsp -h 0.0.0.0 -W
select curret_user;

psql -U tsp -d tsp -h 0.0.0.0 -p 5432
psql postgresql://tsp:some_password@0.0.0.0:5432/tsp

#.pgpass
	# host:port:db:username:password
	0.0.0.0:5432:tsp:tsp:some_password

chmod 0600 .pgpass

# Una vez que se tiene el ppgpass
psql -U tsp -h 0.0.0.0 -d tsp
psql postgresql://tsp@0.0.0.0:5432/tsp

# .pg_service.conf
# todas las bases de datos que se quieren utilizar
	[tsp]
	host=0.0.0.0
	port=5432
	user=tsp
	db=tsp

#Una vez que se tiene pg_service
psql service=tsp

#Instalar driver de posgres
sudo apt-get install libpq-dev

# Python
import psycopg2
DB_URL = "postgresql://tsp@0.0.0.0/tsp"
DB_URL = "postgresql://?service=tsp"
with psycopg2.connect(DB_URL) as conn:
	cursor = conn.cursor()

## Ejemplo berka
sudo su postgres
psql
create database berka;
create role berka login;
alter role berka with encrypted password 'some_password';
grant all privileges on database berka to berka;

# Secciones (esquemas): raw -> clean -> semantic
# RAW
# Cada archivo -> tabla con el mismo nombre de archivo
# No cambio nombre de columnas, no limpio, solo se copa a la BD
# Los tipos de columnas son VARCHAR (STRINGS)p
# NOTA: Si los archivos estan muy sucios (faltan columnas), crear una sola columna
\dn #nombre de esquemas
create schema raw;
create schema clean;
create schema semantic;

\dt #nombre de tablas en esquemas

# Una vez copiado los archivos
\i sql/create_raw_tables.sql
\dt+ raw. 

# Copiar tablas
\copy raw.account from 'data/berka/account.asc' with csv header delimiter ';';