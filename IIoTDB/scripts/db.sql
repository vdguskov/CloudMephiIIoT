-- create user ubuntu with encrypted password 'qwerty123';
--
-- grant all privileges on database iiot to ubuntu;
--
-- grant all privileges on all tables in schema public to ubuntu;

create table if not exists lidar
(
    id serial primary key,
    ts timestamp(0),
    longitude varchar(256),
    latitude varchar(256)
);

create table if not exists log
(
    id serial primary key,
    action varchar(32),
    ts timestamp(0),
    param varchar(256)
);

truncate table lidar;

insert into lidar
values (1, '2021-01-01 15:15:15', '37.6629568', '55.650207'),
       (2, '2021-01-01 15:15:19', '37.6461588', '55.6537359'),
       (3, '2021-01-01 15:15:30', '37.6387118', '55.658833'),
       (4, '2021-01-01 15:16:30', '37.6340055', '55.7579427');