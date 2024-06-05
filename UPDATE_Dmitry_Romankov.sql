-- Alter the rental duration and rental rates of the film you inserted before to three weeks and 9.99, respectively.
update film
set rental_duration=3, rental_rate=9.99
where film_id = 1001;

-- Alter any existing customer in the database with at least 10 rental and 10 payment records.
-- Change their personal data to yours (first name, last name, address, etc.).
-- You can use any existing address from the "address" table.
-- Please do not perform any updates on the "address" table, as this can impact multiple records with the same address.

select c.first_name, c.last_name, c.email, c.address_id
from customer c
join payment p on p.customer_id = c.customer_id 
join rental r on r.customer_id = c.customer_id
group by c.customer_id
having count(r.rental_id) >=10 and count(p.payment_id) >= 10
limit 1

update customer
set
	first_name = 'Dmitry',
	last_name = 'Romankov',
	email = 'a@b.com',
	address_id = 3
where customer_id = 1;

-- Change the customer's create_date value to current_date.
update customer
set create_date = NOW()
where customer_id = 1;


