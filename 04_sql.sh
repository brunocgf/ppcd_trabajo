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

# Secciones (esquemas): raw -> clean -> semantic --> features -> dwh

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

for data_file in *.asc
do
psql service=berka -c "\copy raw.${data_file%.*} from ${data_file} with csv header delimiter ';';"
done

# CLEAN
# Unificar tablas de raw que sean del mismo tipo
# Arreglar los tipos
# NO hacemos imputaciones, agregaciones, cambio de datos, no transformamos
# Nombre de la tabla: plural
# Quitar "_id" y mantener el identificador en singular (controversial)
# ej: trans -> "transations", "trans_id" -> "transaction", "client_id" -> "client"
# Arreglar variables categóricas, poner buenos nombres, etc.
# Quitar espacios

\df #ver funciones
\i sql/helpers.sql

# Para ejecutar el codigo de clean
\i sql/helpers.sql #ó
psql service=berka -f .sql/to_clean

# SEMANTIC

# |event | entity | type | date | attr |

# Orden SQL
| 5 | SELECT |
| 6 | DISTINCT column AGG_FUN(column or expression) |
| 1 | FROM my_table |
| 1 | JOIN another_table |
| 1 | ON mytable.columns = anthe_table.COLUMN |
| 2 | WHERE constrain_expression |
| 3 | GROUP BY column |
| 4 | HAVING constraint_expression |
| 7 | ORDER BY column ASC/DESC |
| 8 | LIMIT coun

# Filter

select
	count(*) as total,
	count(*) filter(where type = 'PRIJEM') as num_prijem
	count(*) filter(where type = 'YBER') as num_yber
from raw.trans;


