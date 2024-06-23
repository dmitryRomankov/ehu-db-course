/*
Create a view called "sales_revenue_by_category_qtr"
that shows the film category and total sales revenue for the current quarter.
The view should only display categories with at least one sale in the current quarter.
The current quarter should be determined dynamically.
*/

create view sales_revenue_by_category_qtr as
with current_quarter as (
    select
        date_trunc('quarter', current_date) as start_of_quarter,
        date_trunc('quarter', current_date) + interval '3 month' - interval '1 day' as end_of_quarter
),
category_revenue as (
    select c.name as category, sum(p.amount) as total_sales_revenue
    from payment p
    join rental r on p.rental_id = r.rental_id
    join inventory i on r.inventory_id = i.inventory_id
    join film f on i.film_id = f.film_id
    join film_category fc on f.film_id = fc.film_id
    join category c on fc.category_id = c.category_id
    join current_quarter cq on r.rental_date between cq.start_of_quarter and cq.end_of_quarter
    group by c.name
    having sum(p.amount) > 0
)
select
    category,
    total_sales_revenue
from category_revenue
order by total_sales_revenue desc;


/*
Create a query language function called "get_sales_revenue_by_category_qtr"
that accepts one parameter representing the current quarter
and returns the same result as the "sales_revenue_by_category_qtr" view.
*/
create or replace function get_sales_revenue_by_category_qtr(current_quarter_date date)
returns table (
    category_name text,
    total_sales_revenue numeric
) as $$
begin
    return query
    with current_quarter as (
        select
            date_trunc('quarter', current_quarter_date) as start_of_quarter,
            date_trunc('quarter', current_quarter_date) + interval '3 month' - interval '1 day' as end_of_quarter
    ),
    category_revenue as (
        select
            c.name as category_name,
            sum(p.amount) as total_sales_revenue
        from payment p
        join rental r on p.rental_id = r.rental_id
        join inventory i on r.inventory_id = i.inventory_id
        join film f on i.film_id = f.film_id
        join film_category fc on f.film_id = fc.film_id
        join category c on fc.category_id = c.category_id
        join current_quarter cq on r.rental_date between cq.start_of_quarter and cq.end_of_quarter
        group by c.name
        having sum(p.amount) > 0
    )
    select
        category_name,
        total_sales_revenue
    from category_revenue
    order by total_sales_revenue desc;
end;
$$ language plpgsql;

/*
Create a procedure language function called "new_movie" that takes a movie title as a parameter
and inserts a new movie with the given title in the film table.
The function should generate a new unique film ID,
set the rental rate to 4.99, the rental duration to three days,
the replacement cost to 19.99, the release year to the current year,and "language" as Klingon. 
The function should also verify that the language exists in the "language" table. 
Then, ensure that no such function has been created before; if so, replace it.
*/

create or replace function new_movie(movie_title text)
returns void as $$
declare
    new_film_id int;
    lang_id int;
begin
    select language_id into lang_id from language where name = 'Klingon';

    if lang_id is null then
		select coalesce(max(language_id), 0) + 1 into lang_id from language;
        insert into language(language_id, name) values(lang_id, 'Klingon');
    end if;

        -- Generate a new unique film ID
        select coalesce(max(film_id), 0) + 1 into new_film_id from film;

        insert into film (film_id, title, rental_rate, rental_duration, replacement_cost, release_year, language_id)
        values (new_film_id, movie_title, 4.99, 3, 19.99, extract(year from current_date)::int, lang_id);

        raise notice 'New movie "%", with ID %, has been successfully added.', movie_title, new_film_id;
end;
$$ language plpgsql;

select new_movie('Blue elephant');


















