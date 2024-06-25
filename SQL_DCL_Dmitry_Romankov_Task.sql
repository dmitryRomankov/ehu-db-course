/*
1.Create a new user with the username "rentaluser" and the password "rentalpassword".
Give the user the ability to connect to the database but no other permissions.
*/
create user rentaluser with password 'rentalpassword';
grant connect on database dvdrental to rentaluser;

/*
2.Grant "rentaluser" SELECT permission for the "customer" table.
Сheck to make sure this permission works correctly—write a SQL query to select all customers.
*/
grant select on customer to rentaluser;
select * from customer;

/*
3.Create a new user group called "rental" and add "rentaluser" to the group. 
*/
create group rental with user rentaluser;

/*
4.Grant the "rental" group INSERT and UPDATE permissions for the "rental" table.
Insert a new row and update one existing row in the "rental" table under that role. 
*/
grant insert, update on rental to rental;

insert into rental(
	rental_date, inventory_id, customer_id, return_date, staff_id)
	values (CURRENT_DATE, 3, 23, CURRENT_DATE, 5);

update rental
	set inventory_id=5, customer_id=24
	where customer_id = 20;

/*
5.Revoke the "rental" group's INSERT permission for the "rental" table.
Try to insert new rows into the "rental" table make sure this action is denied.
*/
revoke insert on rental from rental;
insert into rental(
	rental_date, inventory_id, customer_id, return_date, staff_id)
	values (CURRENT_DATE, 4, 25, CURRENT_DATE, 2);

