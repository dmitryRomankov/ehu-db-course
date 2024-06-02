-- Which staff members made the highest revenue for each store and deserve a bonus for the year 2017?
with staff_revenues as (
    select s.store_id, st.staff_id, st.first_name, st.last_name, sum(p.amount) as total_revenue
    from payment p
    join rental r ON p.rental_id = r.rental_id
    join inventory i ON r.inventory_id = i.inventory_id
    join store s ON i.store_id = s.store_id
    join staff st ON r.staff_id = st.staff_id
    where extract(year from p.payment_date) = 2017
    group by s.store_id, st.staff_id, st.first_name, st.last_name
),
ranked_staff as (
    select sr.*, rank() over (partition by sr.store_id order by sr.total_revenue desc) as revenue_rank
    from staff_revenues sr
)
select store_id, staff_id, first_name, last_name, total_revenue
from ranked_staff
where revenue_rank = 1;

-- Which five movies were rented more than the others, and what is the expected age of the audience for these movies?
with top_rented_movies as (
    select f.film_id, f.title, f.rating, count(r.rental_id) as rental_count
    from rental r
    join inventory i on r.inventory_id = i.inventory_id
    join film f on i.film_id = f.film_id
    group by f.film_id, f.title
    order by rental_count DESC
    limit 5
)

select trm.film_id, trm.title, trm.rental_count, trm.rating,
	case
		when trm.rating = 'G' then 10
		when trm.rating = 'PG' then 13
		when trm.rating = 'PG-13' then 16
		when trm.rating = 'R' then 18
		when trm.rating = 'NC-17' then 20
		else null
	end as expected_age
from top_rented_movies trm;

-- Which actors/actresses didn't act for a longer period of time than the others?
with latest_actor_films as (
    select a.actor_id, a.first_name, a.last_name, max(f.release_year) as latest_film_year
    from actor a
    join film_actor fa on a.actor_id = fa.actor_id
    join film f on fa.film_id = f.film_id
    group by a.actor_id, a.first_name, a.last_name
)

select laf.actor_id, laf.first_name, laf.last_name, laf.latest_film_year,
    extract(year from AGE(CURRENT_DATE, make_date(laf.latest_film_year, 1, 1))) as years_since_last_film
from latest_actor_films laf
order by years_since_last_film desc
limit 10;



