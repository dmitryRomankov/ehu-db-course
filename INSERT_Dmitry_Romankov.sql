-- 1. Choose one of your favorite films and add it to the "film" table.
-- Fill in rental rates with 4.99 and rental durations with 2 weeks.
insert into film(title, description, release_year, language_id, rental_duration, rental_rate, length)
values ('Forrest Gump', 'The story of Forrest Gump', 1994, 1, 2, 4.99, 144);

-- 2. Add the actors who play leading roles in your favorite film to the "actor" and "film_actor" tables (three or more actors in total).
insert into actor (first_name, last_name)
values
('Tom', 'Hanks'),
('Gary', 'Sinise'),
('Mykelti', 'Williamson')

insert into film_actor (actor_id, film_id)
values
	(201, 1001),
	(202, 1001),
	(203, 1001)

-- 3.Add your favorite movies to any store's inventory.
insert into inventory (film_id, store_id)
values
	(1001, 1),
	(1001, 2)








