-- DATA ANALYSIS PROJECT FOR RENTAL MOVIES BUSINESS
-- THE STEPS INVOLVED ARE EDA, UNDERSTANDING THR SCHEMA AND ANSWERING THE AD-HOC QUESTIONS
-- BUSINESS QUESTIONS LIKE EXPANDING MOVIES COLLECTION AND FETCHING EMAIL IDS FOR MARKETING ARE INCLUDED
-- HELPING COMPANY KEEP A TRACK OF INVENTORY AND HELP MANAGE IT.

USE mavenmovies;

-- EXPLORATORY DATA ANALYSIS --

-- UNDERSTANDING THE SCHEMA --

select * from city;

select * from inventory;

select * from customer;

select * from film;


-- You need to provide customer firstname, lastname and email id to the marketing team --

select first_name,last_name,email from customer;

-- How many movies are with rental rate of $0.99? --

select count(*) as cheap_rental
from film
where rental_rate = 0.99;


-- We want to see rental rate and how many movies are in each rental category --

select rental_rate,count(*) as total_number_of_movies
from film
group by rental_rate;


-- Which rating has the most films? --

select rating,count(*) as rating_count
from film
group by rating
order by rating_count desc;


-- Which rating is most prevalant in each store? --


SELECT I.store_id,F.rating,COUNT(F.rating) AS TOTAL_FILMS
FROM inventory AS I LEFT JOIN
	film AS F
ON I.film_id = F.film_id
GROUP BY I.store_id,F.rating
ORDER BY TOTAL_FILMS DESC;


-- List of films by Film Name, Category, Language --

select F.title, C.name , LANG.name from film as F
left join film_category as FC
on F.film_id = FC.film_id
left join category as C
on FC.category_id = C.category_id
left join language as LANG
on F.language_id = LANG.language_id;


-- How many times each movie has been rented out?

select F.title, count(*) as popularity 
from rental as R 
left join inventory as INV 
on R.inventory_id = INV.inventory_id 
left join film as f
on INV.film_id = F.film_id
group by F.title
order by popularity desc;


-- REVENUE PER FILM (TOP 10 GROSSERS)

select F.title, sum(P.amount) as revenue  
from rental as R
left join payment as P
on R.rental_id = P.rental_id
left join inventory as INV
on R.inventory_id = INV.inventory_id
left join film as F
on INV.film_id = F.film_id
group by F.title
order by revenue DESC
limit 10;


-- Most Spending Customer so that we can send him/her rewards or debate points

select C.customer_id, sum(amount) as spending, C.first_name, C.last_name
from payment as P
left join customer as C
on P.customer_id = C.customer_id
group by C.customer_id
order by spending desc
limit 5;


-- Which Store has historically brought the most revenue?

select S.store_id, sum(P.amount) as store_revenue
from payment as P left join staff as S
on P.staff_id = S.staff_id
group by S.store_id;


-- How many rentals we have for each month

select extract(year from rental_date) as year_,extract(month from rental_date) as month_, count(rental_id) as num
from rental
group by extract(year from rental_date),extract(month from rental_date);


-- Reward users who have rented at least 30 times (with details of customers)

select customer_id,count(rental_id) as number_of_trans
from rental
group by customer_id
having number_of_trans > 29
order by number_of_trans desc;


-- Could you pull all payments from our first 100 customers (based on customer ID)

select * from payment
order by customer_id
limit 100;


-- Now I’d love to see just payments over $5 for those same customers, since January 1, 2006


select * from payment
where (customer_id between 1 and	 100) and amount>5 and payment_date> "2006-01-01";


-- Now, could you please write a query to pull all payments from those specific customers, along
-- with payments over $5, from any customer?

select * from payment
where amount > 5 and customer_id in 
(select customer_id from payment)
where(customer_id between 1 and 100 ) and amount > 5 payment_date > "2006-01-01");


-- We need to understand the special features in our films. Could you pull a list of films which
-- include a Behind the Scenes special feature?


SELECT TITLE,SPECIAL_FEATURES
FROM FILM
WHERE SPECIAL_FEATURES LIKE '%Behind the Scenes%';


-- unique movie ratings and number of movies

select rating, count(film_id) as number_of_films
from film
group by rating
order by number_of_films desc;


-- Could you please pull a count of titles sliced by rental duration?

select rental_duration,count(title) from film
group by rental_duration;


-- RATING, COUNT_MOVIES,LENGTH OF MOVIES AND COMPARE WITH RENTAL DURATION

SELECT RATING,
	COUNT(FILM_ID)  AS COUNT_OF_FILMS,
    MIN(LENGTH) AS SHORTEST_FILM,
    MAX(LENGTH) AS LONGEST_FILM,
    AVG(LENGTH) AS AVERAGE_FILM_LENGTH,
    AVG(RENTAL_DURATION) AS AVERAGE_RENTAL_DURATION
FROM FILM
GROUP BY RATING
ORDER BY AVERAGE_FILM_LENGTH;


-- I’m wondering if we charge more for a rental when the replacement cost is higher.
-- Can you help me pull a count of films, along with the average, min, and max rental rate,
-- grouped by replacement cost?


SELECT REPLACEMENT_COST,
	COUNT(FILM_ID) AS NUMBER_OF_FILMS,
    MIN(RENTAL_RATE) AS CHEAPEST_RENTAL,
    MAX(RENTAL_RATE) AS EXPENSIVE_RENTAL,
    AVG(RENTAL_RATE) AS AVERAGE_RENTAL
FROM FILM
GROUP BY REPLACEMENT_COST
ORDER BY REPLACEMENT_COST;


-- “I’d like to talk to customers that have not rented much from us to understand if there is something
-- we could be doing better. Could you pull a list of customer_ids with less than 15 rentals all-time?”


SELECT CUSTOMER_ID,COUNT(*) AS TOTAL_RENTALS
FROM RENTAL
GROUP BY CUSTOMER_ID
HAVING TOTAL_RENTALS < 15;

-- “I’d like to see if our longest films also tend to be our most expensive rentals.
-- Could you pull me a list of all film titles along with their lengths and rental rates, and sort them
-- from longest to shortest?”

SELECT TITLE,LENGTH,RENTAL_RATE
FROM FILM
ORDER BY LENGTH DESC
LIMIT 20;


-- CATEGORIZE MOVIES AS PER LENGTH

SELECT TITLE,LENGTH,
	CASE
		WHEN LENGTH < 60 THEN 'UNDER 1 HR'
        WHEN LENGTH BETWEEN 60 AND 90 THEN '1 TO 1.5 HRS'
        WHEN LENGTH > 90 THEN 'OVER 1.5 HRS'
        ELSE 'ERROR'
	END AS LENGTH_BUCKET
FROM FILM;

SELECT *
FROM CATEGORY;


-- CATEGORIZING MOVIES TO RECOMMEND VARIOUS AGE GROUPS AND DEMOGRAPHIC

SELECT DISTINCT TITLE,
	CASE
		WHEN RENTAL_DURATION <= 4 THEN 'RENTAL TOO SHORT'
        WHEN RENTAL_RATE >= 3.99 THEN 'TOO EXPENSIVE'
        WHEN RATING IN ('NC-17','R') THEN 'TOO ADULT'
        WHEN LENGTH NOT BETWEEN 60 AND 90 THEN 'TOO SHORT OR TOO LONG'
        WHEN DESCRIPTION LIKE '%Shark%' THEN 'NO_NO_HAS_SHARKS'
        ELSE 'GREAT_RECOMMENDATION_FOR_CHILDREN'
	END AS FIT_FOR_RECOMMENDATTION
FROM FILM;


-- “Can you pull for me a list of each film we have in inventory?
-- I would like to see the film’s title, description, and the store_id value
-- associated with each item, and its inventory_id. Thanks!”

select F.title, F.description, INV.store_id, INV.inventory_id, F.film_id 
from film as F
inner join inventory as INV
on F.film_id = INV.film_id;


-- Actor first_name, last_name and number of movies

select * from film_actor;
select * from actor;

select AC.first_name, AC.last_name, count(Fa.film_id)as number_of_movies
from actor as AC
left join film_actor as FA
on AC.actor_id = FA.actor_id
group by AC.actor_id
order by number_of_movies desc;


-- “One of our investors is interested in the films we carry and how many actors are listed for each
-- film title. Can you pull a list of all titles, and figure out how many actors are
-- associated with each title?”

select F.title, count(actor_id) as nummber_of_actors
from film as F left join film_actor as FA
on F.film_id = FA.film_id
group by F.title
order by number_of_actors desc;


-- “We will be hosting a meeting with all of our staff and advisors soon. Could you pull one list of all staff
-- and advisor names, and include a column noting whether they are a staff member or advisor? Thanks!”

(select first_name, last_name, "staff" as designation 
from staff
union all
select first_name, last_name, "advisor" as designation 
from staff);
