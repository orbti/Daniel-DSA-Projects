-- Find the title and language of all films that are rated G.

SELECT 
    f.title, l.name, f.rating
FROM
    sakila.film f
        JOIN
    sakila.language l ON f.language_id = l.language_id
WHERE
    rating = 'g'


-- Find the address and city for all addresses in the United States.

select
	a.address, c.city, ctry.country
FROM
    sakila.address a
        JOIN
    sakila.city c ON a.city_id = c.city_id
        JOIN
    sakila.country ctry ON c.country_id = ctry.country_id
WHERE
    ctry.country = 'United States'


-- Three or more tables:
-- List the address, city, and country for all addresses.

SELECT 
    a.address, c.city, ctry.country
FROM
    sakila.address a
        JOIN
    sakila.city c ON a.city_id = c.city_id
        JOIN
    sakila.country ctry ON c.country_id = ctry.country_id
WHERE
    country = 'united states'

-- Find the actor’s first and last name and title of film for all actors whose last name begins with S.

SELECT 
    a.last_name, a.first_name, f.title
FROM
    sakila.actor a
        JOIN
    sakila.film_actor fa ON a.actor_id = fa.actor_id
        JOIN
    sakila.film f ON fa.film_id = f.film_id
WHERE
    a.last_name LIKE 'S%'
GROUP BY f.film_id
ORDER BY a.last_name , a.first_name , f.title

-- Get the total number of customers from the United States of America.

SELECT 
    ctry.country, COUNT(cus.customer_id) num_cus
FROM
    sakila.country ctry
        JOIN
    sakila.city c ON ctry.country_id = c.country_id
        JOIN
    sakila.address a ON c.city_id = a.city_id
        JOIN
    sakila.customer cus ON a.address_id = cus.address_id
WHERE
    country = 'United States'

/*
Create a table that has the following:
customer name
customer email
amount paid for rental
when payment was made
when movie was rented
when it was returned
name of movie
BONUS: calculate how long each rental was
*/

SELECT 
    c.last_name,
    c.first_name,
    c.email,
    p.amount,
    DATE_FORMAT(p.payment_date, '%Y-%m-%d') payment_date,
    DATE_FORMAT(r.rental_date, '%Y-%m-%d') rental_date,
    DATE_FORMAT(r.return_date, '%Y-%m-%d') return_date,
    f.title,
    DATEDIFF(r.return_date, r.rental_date) rental_duration
FROM
    customer c
        JOIN
    rental r ON c.customer_id = r.customer_id
        JOIN
    payment p ON c.customer_id = p.customer_id
        JOIN
    inventory i ON r.inventory_id = i.inventory_id
        JOIN
    film f ON i.film_id = f.film_id
ORDER BY payment_date



/*
Sakila Database Questions
These questions, while not a formal project, do demonstrate intermediate level familiarity with many SQL techniques common in business and often asked in interviews.
*/

-- 1.	How many distinct actor last names are there?
SELECT 
    COUNT(DISTINCT actor.last_name) AS num_unique_actors
FROM
    sakila.actor

-- 2.	Which last names are duplicates? 
SELECT 
    actor.last_name
FROM
    sakila.actor
GROUP BY actor.last_name
HAVING COUNT(actor.last_name) > 1

Which are not duplicates?
SELECT 
    actor.last_name
FROM
    sakila.actor
GROUP BY actor.last_name
HAVING COUNT(actor.last_name) = 1

-- 3.	Which actor has appeared in the most films?
SELECT 
    actor.last_name,
    actor.first_name,
    COUNT(film.film_id) num_films
FROM
    sakila.actor
        JOIN
    sakila.film_actor ON actor.actor_id = film_actor.actor_id
        JOIN
    sakila.film ON film.film_id = film_actor.film_id
GROUP BY actor.actor_id
ORDER BY num_films DESC
LIMIT 1
-- This works also. Uses subquery
with q1 as (
SELECT 
    concat(a.last_name,' ', a.first_name) Name, COUNT(r.rental_id) num_rentals
FROM sakila.actor a
        JOIN sakila.film_actor fa ON a.actor_id = fa.actor_id
        JOIN sakila.film f ON f.film_id = fa.film_id
        JOIN sakila.inventory i ON f.film_id = i.film_id
        JOIN sakila.rental r ON i.inventory_id = r.inventory_id
GROUP BY a.actor_id)
select * from q1
where num_rentals = (select max(q1.num_rentals) from q1)

-- 4.	Which actor is in the most rented film?
SELECT 
    a.last_name, a.first_name, COUNT(r.rental_id) num_rentals
FROM
    sakila.actor a
        JOIN
    sakila.film_actor fa ON a.actor_id = fa.actor_id
        JOIN
    sakila.film f ON f.film_id = fa.film_id
        JOIN
    sakila.inventory i ON f.film_id = i.film_id
        JOIN
    sakila.rental r ON i.inventory_id = r.inventory_id
GROUP BY a.actor_id
ORDER BY num_rentals DESC
LIMIT 1

-- 5.	How many films are available at each store?
SELECT 
    s.store_id, COUNT(f.film_id) num_films
FROM
    sakila.store s
        JOIN
    sakila.inventory i ON s.store_id = i.store_id
        JOIN
    sakila.film f ON i.film_id = f.film_id
GROUP BY s.store_id

-- 6.	How much money has each store made?
SELECT 
    s.store_id, SUM(p.amount) total_profit
FROM
    sakila.store s
        JOIN
    sakila.customer c ON s.store_id = c.store_id
        JOIN
    sakila.payment p ON c.customer_id = p.customer_id
GROUP BY s.store_id

-- 7.	List the top 5 customers, in terms of dollar amounts spent on rentals from the sakila database
SELECT 
    c.last_name, c.first_name, SUM(p.amount) total_amt
FROM
    sakila.customer c
        JOIN
    sakila.payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY total_amt DESC
LIMIT 5

-- 8.	What are the most popular rentals, in terms of number of times rented, 
-- 		in each category? Order by category descending
/*
In this solution i first create a query where i get all the counts of each
film grouped by their category. I then use a corrleated subquery to find the 
max in each category and only select the rows where q1.Rentals = *max rentals of
that films category*
*/
with q1 as (
	select
		f.title Movie,
		c.name Category,
		count(r.rental_id) Rentals
	from
		sakila.category c
		left join sakila.film_category fa on c.category_id = fa.category_id
		join sakila.film f on fa.film_id = f.film_id
		join sakila.inventory i on f.film_id = i.film_id
		left join sakila.rental r on i.inventory_id = r.inventory_id
	group by
		c.category_id,
		f.film_id
)
select * from q1
where q1.Rentals = (
			select max(q2.Rentals) 
			from q1 as q2 
			where q1.Category = q2.Category
)
order by q1.Category desc
/* This is Melissa's solution to problem #8. She used a window function to rank the
num_rentals by category in the first qeury. Then selected all the rows 
where cat_rent_rank is equal to 1.
*/
WITH  rank_table AS (
	select 
		f.title, 
		c.name, 
		count(*) num_rentals, 
		RANK() OVER (PARTITION BY c.name ORDER BY count(*) DESC) cat_rent_rank
	FROM 
		sakila.film f 
		JOIN sakila.film_category fc ON f.film_id = fc.film_id
		JOIN sakila.category c ON fc.category_id = c.category_id
		JOIN sakila.inventory i ON i.film_id = f.film_id
		JOIN sakila.rental r ON r.inventory_id = i.inventory_id
	GROUP BY 1,2
	order by c.name asc
)
SELECT title, name, num_rentals from rank_table
WHERE cat_rent_rank = 1
order by name desc

-- 9.	In one query, list the top 5 films, by length, at each store.
select Store, Movie, Length
from (
	select 
		s.store_id Store, 
		f.title Movie, 
        f.length Length,
        row_number () over (partition by s.store_id order by f.length desc) as row_num
	from
		sakila.film f	
		join sakila.inventory i on f.film_id = i.film_id
        join sakila.store s on i.store_id = s.store_id
	group by f.film_id
) as row_order
where row_num between 1 and 5

/* 
This works but hard codes the store_id. You wont get the right 
output if the database updates and a new store is added. 
The above query is better for that reason.
*/
(select 
		s.store_id Store, 
		f.title Movie, 
        f.length Length
	from
		sakila.film f	
		join sakila.inventory i on f.film_id = i.film_id
        join sakila.store s on i.store_id = s.store_id
	where s.store_id = 1
    group by f.film_id
    order by f.length desc
    limit 5
    )
union 
(select 
		s.store_id Store, 
		f.title Movie, 
        f.length Length
	from
		sakila.film f	
		join sakila.inventory i on f.film_id = i.film_id
        join sakila.store s on i.store_id = s.store_id
	where s.store_id = 2
    group by f.film_id
    order by f.length desc
    limit 5
    )