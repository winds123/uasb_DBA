drop table invoice_line;
drop table invoice;
drop table customer;
drop table employee;
drop table playlist_track;
drop table playlist;
drop table track;
drop table media_type;
drop table genre;
drop table album;
drop table artist;

drop view vista1;
drop view vista2;
drop view vista3;
drop view vista4;


create table artist(
  artist_id serial primary key,
  name varchar(100)
);
create table album(
  album_id serial primary key,
  title varchar(100),
  artist_id integer not null,
  constraint fk_artist_album foreign key(artist_id) references artist(artist_id)
);
create table media_type(
  media_type_id serial primary key,
  name varchar(100)
);
create table genre(
  genre_id serial primary key,
  name varchar(100)
);
create table track(
  track_id serial primary key,
  name varchar(500),
  album_id integer not null,
  media_type_id integer not null,
  genre_id integer not null,
  composer varchar(500),
  milliseconds integer,
  bytes bytea,
  unit_price float,
  constraint fk_album_track foreign key(album_id) references album(album_id),
  constraint fk_media_type_track foreign key(media_type_id) references media_type(media_type_id),
  constraint fk_genre_track foreign key(genre_id) references genre(genre_id)
);
create table playlist(
  playlist_id serial primary key,
  name varchar(100)
);
create table playlist_track(
  playlist_id integer not null,
  track_id integer not null,
  constraint pk_playlist_track primary key (playlist_id,track_id),
  constraint fk_playlist_playlist_track foreign key(playlist_id) references playlist(playlist_id),
  constraint fk_track_playlist_track foreign key(track_id) references track(track_id)
);
CREATE TABLE employee (
    employee_id        serial,
    last_name           varchar(100),
    first_name          varchar(100),
    title              varchar(100),
    reports_to          int,
    birth_date          date,
    hire_date           date,
    address            varchar(100),
    city               varchar(100),
    state              varchar(100),
    country            varchar(100),
    postal_code         varchar(100),
    phone              varchar(100),
    fax                varchar(100),
    email              varchar(100),
    CONSTRAINT pk_employee PRIMARY KEY(employee_id),
    CONSTRAINT fk_employee_employee FOREIGN KEY(reports_to) REFERENCES employee(employee_id)
);
CREATE TABLE customer (
    customer_id        serial primary key,
    first_name         varchar(100),
    last_name          varchar(100),
    company           varchar(100),
    address           varchar(100),
    city              varchar(100),
    state             varchar(100),
    country           varchar(100),
    postal_code        varchar(100),
    phone             varchar(100),
    fax               varchar(100),
    email             varchar(100),
    support_rep_id    integer,
   constraint fk_employee_customer foreign key(support_rep_id) references employee(employee_id)
);
CREATE TABLE invoice (
    invoice_id        serial primary key,
    customer_id       integer not null,
    invoice_date      date,
    billing_address   varchar(100),
    billing_city      varchar(100),
    billing_state     varchar(100),
    billing_country   varchar(100),
    billing_postal_code varchar(100),
    total             float,
    constraint fk_customer_invoice foreign key(customer_id) references customer(customer_id)
);
create table invoice_line(
  invoice_line_id serial primary key,
  invoice_id integer not null,
  track_id integer not null,
  unit_price float,
  quantity float,
  constraint fk_track_invoice_line foreign key(track_id) references track(track_id),
  constraint fk_invoice_invoice_line foreign key(invoice_id) references invoice(invoice_id)
);

copy artist("artist_id","name") from '/root/Documentos/Modulo 3.2/uasb_DBA-master/RAW_CSV/artist_data.csv' delimiters ';' with csv header;
copy album("album_id","title","artist_id") from '/root/Documentos/Modulo 3.2/uasb_DBA-master/RAW_CSV/album_data.csv' delimiters ';' with csv header;
copy genre("genre_id","name") from '/root/Documentos/Modulo 3.2/uasb_DBA-master/RAW_CSV/genre_data.csv' delimiters ';' with csv header;
copy media_type("media_type_id","name") from '/root/Documentos/Modulo 3.2/uasb_DBA-master/RAW_CSV/mediatype_data.csv' delimiters ';' with csv header;
copy track("track_id","name","album_id","media_type_id","genre_id","composer","milliseconds","bytes","unit_price") from '/root/Documentos/Modulo 3.2/uasb_DBA-master/RAW_CSV/track_data.csv' delimiters ';' with csv header;
copy playlist("playlist_id","name") from '/root/Documentos/Modulo 3.2/uasb_DBA-master/RAW_CSV/playlist_data.csv' delimiters ';' with csv header;
copy playlist_track("playlist_id","track_id") from '/root/Documentos/Modulo 3.2/uasb_DBA-master/RAW_CSV/playlisttrack_data.csv' delimiters ';' with csv header;
copy employee("employee_id","last_name","first_name","title","reports_to","birth_date","hire_date","address","city","state","country","postal_code","phone","fax","email") from '/root/Documentos/Modulo 3.2/uasb_DBA-master/RAW_CSV/employee_data.csv' delimiters ';' with csv header;
copy customer("customer_id","first_name","last_name","company","address","city","state","country","postal_code","phone","fax","email","support_rep_id") from '/root/Documentos/Modulo 3.2/uasb_DBA-master/RAW_CSV/customer_data.csv' delimiters ';' with csv header;
copy invoice("invoice_id","customer_id","invoice_date","billing_address","billing_city","billing_state","billing_country","billing_postal_code","total") from '/root/Documentos/Modulo 3.2/uasb_DBA-master/RAW_CSV/invoice_data.csv' delimiters ';' with csv header;
copy invoice_line("invoice_line_id","invoice_id","track_id","unit_price","quantity") from '/root/Documentos/Modulo 3.2/uasb_DBA-master/RAW_CSV/invoiceline_data.csv' delimiters ';' with csv header;

--1. Listar el top 5 de las canciones más vendidas por genero
create view vista1
as
	select g.name as genero,t.name as track,sum(il.quantity) as cantidad
	from invoice_line il 
	inner join track t on il.track_id=t.track_id
	inner join genre g on t.genre_id=g.genre_id
	where (g.name,t.name) in (
		select gg.name,tt.name
		from invoice_line ill 
		inner join track tt on ill.track_id=tt.track_id
		inner join genre gg on tt.genre_id=gg.genre_id
		where g.name=gg.name
		group by gg.genre_id,tt.name
		order by gg.name asc, sum(ill.quantity) desc, tt.name
		limit 5
	)
	group by g.genre_id,t.name
	order by g.name asc, sum(il.quantity) desc, t.name;
--select * from vista1

--2. Listar los 3 clientes que han comprado más canciones
create view vista2
as
	select c.first_name, c.last_name, c.city,c.country,c.phone, sum(il.quantity) as cantidad
	from invoice_line il
	inner join invoice i on il.invoice_id=i.invoice_id
	inner join customer c on c.customer_id=i.customer_id
	group by c.first_name,c.last_name, c.city,c.country,c.phone
	order by sum(il.quantity) desc
	limit 3;
--select * from vista2

--3. Listar las 20 canciones que tienen mayor duración agrupados por tipo de medio
create view vista3
as
	select mt.name as tipo_archivo, t.name as track, t.milliseconds 
	from track t 
	inner join media_type mt on t.media_type_id=mt.media_type_id
	group by mt.name, t.name, t.milliseconds
	order by t.milliseconds desc 
	limit 20;
--select * from vista3
--4. Listar total ventas por mes agrupadas por el vendedor
create view vista4
as
	select e.first_name,e.last_name,extract(year from i.invoice_date) as anio,extract(month from i.invoice_date) as mes,sum(i.total) as total
	from employee e 
	inner join customer c on e.employee_id=c.support_rep_id
	inner join invoice i on c.customer_id=i.customer_id
	group by e.employee_id,e.first_name,extract(year from i.invoice_date),extract(month from i.invoice_date)
	order by e.first_name,extract(year from i.invoice_date),extract(month from i.invoice_date);

--select * from vista4

-- Otorgar permissos a los usuarios --

-- uasb_user usuario que realiza solo consultas a los datos --

grant SELECT on invoice_line TO uasb_user;
grant SELECT on invoice TO uasb_user;
grant SELECT on customer TO uasb_user;
grant SELECT on employee TO uasb_user;
grant SELECT on playlist_track TO uasb_user;
grant SELECT on track TO uasb_user;
grant SELECT on album TO uasb_user;
grant SELECT on genre TO uasb_user;
grant SELECT on media_type TO uasb_user;
grant SELECT on playlist TO uasb_user;
grant SELECT on artist TO uasb_user;

-- operator_user usuario que realiza operaciones sobre las tablas --
-- ALL no otorga todos los permisos para al tabla. Sino, otorga los permisos ANSI-92 que son SELECT, INSERT, UPDATE, DELETE y REFERENCES.

grant ALL on invoice_line TO operator_user;
grant ALL on invoice TO operator_user;
grant ALL on customer TO operator_user;
grant ALL on employee TO operator_user;
grant ALL on playlist_track TO operator_user;
grant ALL on track TO operator_user;
grant ALL on album TO operator_user;
grant ALL on genre TO operator_user;
grant ALL on media_type TO operator_user;
grant ALL on playlist TO operator_user;
grant ALL on artist TO operator_user;

-- test_user usuario que realiza solo consultas a vistas de la base de datos --

grant SELECT on vista1 TO test_user;
grant SELECT on vista2 TO test_user;
grant SELECT on vista3 TO test_user;
grant SELECT on vista4 TO test_user;


--MANTENIMIENTO

--Backups en formato plano, se usa la contraseña de postgres
pg_dump -i -h localhost -p 5432 -U postgres -F p -b -v -f "/root/Documentos/Modulo 3.2/script/bk_musicdb_usergithub.sql" musicdb

--Backups en formato postgres, se usa la contraseña de postgres
pg_dump -i -h localhost -p 5432 -U postgres -F c -b -v -f "/root/Documentos/Modulo 3.2/script/bk_musicdb_usergithub.backup" musicdb

--Backups con -a y -v
-- -a Hace un volcado solo de los datos y no del esquema.
-- -v Especifica el modo detallado. Esto hará que pg_dump de salida detallada de objetos comentarios e iniciar / detener veces 
--para el archivo de volcado, y el progreso de los mensajes de error estándar.

--Creando base de datos musicdb_test
CREATE DATABASE musicdb_test
  WITH ENCODING='UTF8'
       OWNER=admin_user
       CONNECTION LIMIT=-1;

	--Restauramos la base de datos extraida del repositorio del maestrante Jose Erick Gutierrez Rodriguez
	pg_restore -d musicdb_test '/root/Documentos/Modulo 3.2/erick DBA/uasb_DBA-master/bk_musicdb_usergithub.sql'
	
	--Ejecutamos vacummdb para limpiar a la base de datos musicdb_test
	vacuumdb --verbose musicdb_test
	
	--Ejecutamos reindexdb para reindexar la base de datos musicdb_test
reindexdb musicdb_test