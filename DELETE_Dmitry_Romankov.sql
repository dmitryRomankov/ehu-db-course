-- Remove a previously inserted film from the inventory and all corresponding rental records
delete from inventory
where film_id = 1001;

-- Remove any records related to you (as a customer) from all tables except "Customer" and "Inventory"
with my_customer_id as (
	select customer_id
	from customer
	where first_name = 'Dmitry'
	and last_name = 'Romankov'
	and email = 'a@b.com'
)

delete from payment 
where customer_id = (select customer_id from my_customer_id)
	
delete from rental 
where customer_id = (select customer_id from my_customer_id)

