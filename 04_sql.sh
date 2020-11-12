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
