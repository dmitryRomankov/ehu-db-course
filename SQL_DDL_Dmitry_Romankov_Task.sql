-- Database for climbers, climbing's and mountains.

create table mountain_club (
	club_id serial primary key,
	club_name text not null
);

alter table mountain_club add column climber_id int not null;

alter table mountain_club
add constraint fk_climber_id
foreign key (climber_id)
references climbers (climber_id);

alter table mountain_club 
add unique (club_name);

insert into mountain_club (club_name, climber_id)
values 
    ('Adventure climbers', 1),
    ('Summit seekers', 2),
    ('Peak explorers', 3);

create table climbers (
	climber_id serial primary key,
	name text not null,
	birthdate date not null
);

alter table climbers add column club_id int not null;

alter table climbers
add constraint fk_club_id
foreign key (club_id)
references mountain_club (club_id);

insert into climbers (name, birthdate, club_id)
values 
    ('john doe', '1990-05-15', 1),
    ('jane smith', '1988-09-22', 2),
    ('mike johnson', '1995-02-10', 1);

create table climber_address (
	address_id serial primary key
);

alter table climber_address
add column address_title text;

alter table climber_address
add column climber_id int;

alter table climber_address
add constraint fk_climber_address_id
foreign key (climber_id)
references climbers (climber_id);

insert into climber_address (address_title, climber_id)
values 
    ('Avenue 1', 1),
    ('Street 2', 2),
    ('Boulevard 3', 3);

create table mountains (
	mountain_id serial primary key,
	mountain_name text unique not null,
	height int not null
);

alter table mountains 
add constraint check_positive check (height > 0);

insert into mountains (mountain_name, height)
values 
    ('Mount Everest', 8848),
    ('K2', 8611),
    ('Kangchenjunga', 8586);


create table membership (
	membership_id serial primary key,
	climber_id int not null,
	club_id int not null
);

alter table membership
add constraint fk_membership_climber_id
foreign key (climber_id)
references climbers (climber_id);

alter table membership
add constraint fk_membership_club_id
foreign key (club_id)
references mountain_club (club_id);

insert into membership (climber_id, club_id)
values 
    (1, 1),
    (2, 2),
    (3, 1);


create table climbing (
	climbing_id serial primary key,
	climbing_title text unique not null default 'Climbing ' || CURRENT_DATE,
	start_date date not null,
	end_date date not null
	mountain_id int not null,
	climber_id int not null,
);

alter table climbing
add constraint fk_climbing_climber_id
foreign key (climber_id)
references climbers (climber_id);

alter table climbing
add constraint fk_climbing_mountain_id
foreign key (mountain_id)
references mountains (mountain_id);

insert into climbing (start_date, end_date, mountain_id, climber_id)
values 
    ('2024-05-01', '2024-05-05', 1, 1),
    ('2024-05-10', '2024-05-15', 2, 2),
    ('2024-05-20', '2024-05-25', 3, 3);

create table area (
	area_id serial primary key,
	area_name text unique not null,
);

insert into area (area_name)
values 
    ('Rocky Mountains'),
    ('Himalayas'),
    ('Andes');

create table mountain_area (
	mountain_area_id serial primary key,
	mountain_id int not null,
	area_id int not null,
);

alter table mountain_area
add constraint fk_mountain_area_mountain_id
foreign key (mountain_id)
references mountains (mountain_id);

alter table mountain_area
add constraint fk_mountain_area_id
foreign key (area_id)
references area (area_id);

insert into mountain_area (mountain_id, area_id)
values 
    (1, 1),
    (2, 2),
    (3, 3);

create table country (
	country_id serial primary key,
	country_name text unique not null,
);

insert into country (country_name)
values 
    ('Nepal'),
    ('United States'),
    ('Argentina');

create table mountain_country (
	mountain_country_id serial primary key,
	mountain_id int not null,
	country_id int not null,
);

alter table mountain_country
add constraint fk_mountain_country_mountain_id
foreign key (mountain_id)
references mountains (mountain_id);

alter table country
add constraint fk_mountain_country_id
foreign key (country_id)
references area (country_id);

insert into mountain_country (mountain_id, country_id)
values 
    (1, 1),
    (2, 2),
    (3, 3);

create table climbing_comment(
	comment_id serial primary key,
	climbing_id int not null,
	comment text
);

alter table climbing_comment
add constraint fk_climbing_comment
foreign key (climbing_id)
references climbing (climbing_id);

insert into climbing_comment (climbing_id, comment)
values 
    (1, 'Great climb, amazing views!'),
    (2, 'Tough climb but worth it!'),
    (3, 'Enjoyed every moment of the ascent.');

