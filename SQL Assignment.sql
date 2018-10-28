USE sakila;

SELECT * FROM actor;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name, ',', last_name) AS "Actor Name"
FROM actor;


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name 
FROM actor
WHERE first_name = "Joe"; 

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * 
FROM actor
WHERE last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor
WHERE last_name like "%LI%"
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan","Bangladesh","China");


-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant). 
ALTER TABLE actor
ADD description BLOB;

SELECT * FROM actor;


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

SELECT * FROM actor;


-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) 
FROM actor
GROUP BY last_name;


-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) 
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >= 2;


-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name="GROUCHO" AND last_name = "WILLIAMS";

SELECT * FROM actor
WHERE last_name = "WILLIAMS";


-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

SELECT * FROM actor
WHERE last_name = "WILLIAMS";


-- 	5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- 		Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html 
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT * 
FROM address;

SELECT * 
FROM staff;

SELECT first_name, last_name, address
FROM staff
INNER JOIN address
ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. 
SELECT * 
FROM payment;

SELECT SUM(amount) AS total_payment, payment_date, first_name, last_name
FROM payment 
LEFT JOIN staff 
ON payment.staff_id = staff.staff_id AND (payment_date like '2005-08%')
GROUP BY last_name;


SELECT SUM(amount) AS total_payment, payment_date
FROM payment 
WHERE payment_date like "2005-08%";

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT * FROM film;
SELECT * FROM film_actor;

SELECT f.film_id, title, description, COUNT(actor_id) AS number_actors
FROM film f
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY title;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT * FROM inventory;

SELECT COUNT(film_id)  
FROM inventory
WHERE film_id in
	(
	SELECT film_id
	FROM film
	WHERE title = "Hunchback Impossible"  
	);


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:    
SELECT * FROM customer;

SELECT  p.customer_id, c.first_name, c.last_name,SUM(p.amount) AS total_payment
FROM payment p
LEFT JOIN customer c
ON p.customer_id = c.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY c.last_name;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT * 
FROM film;
SELECT * 
FROM language;

SELECT film_id, title, description, language_id
FROM film
WHERE (title like "K%" OR title like "Q%") AND language_id IN
	(	
	SELECT language_id 
	FROM language
	WHERE name = "English"
    );



-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id in
	(
	SELECT actor_id
	FROM film
	WHERE title = "Alone Trip"
	);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information. 
SELECT *
FROM customer;
SELECT * 
FROM city;
SELECT * 
FROM country;

SELECT customer.first_name, customer.last_name, customer.email, city.city, country.country
FROM customer 
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id AND country.country = "Canada";


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT * 
FROM film_category;
SELECT * 
FROM category;

SELECT film_id, title, description, rating FROM film
WHERE film_id IN
	(
	SELECT film_id FROM film_category
	WHERE category_id IN
		(
		SELECT category_id FROM category
		WHERE category.name = "Family"
		)
    );


-- 7e. Display the most frequently rented movies in descending order.
SELECT * 
FROM rental;
SELECT * 
FROM inventory;
SELECT *
FROM film;

SELECT COUNT(f.film_id) AS Rental_Count, title, f.film_id FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON  i.inventory_id = r.inventory_id 
GROUP BY title
ORDER BY Rental_Count DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- payment <- staff <- store_id 
SELECT SUM(amount), staff.store_id FROM payment 
JOIN staff ON payment.staff_id = staff.staff_id
GROUP BY staff.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.--
SELECT * FROM store;

SELECT s.store_id, c.city, r.country FROM store s
JOIN address a ON s.address_id = a.address_id
JOIN city c ON c.city_id = a.city_id
JOIN country r ON r.country_id = c.country_id;


-- 7h. List the top five genres in gross revenue in descending order.
-- (Hint: you may need to use the following tables: category, film_category, invFentory, payment, and rental.)
SELECT * FROM film_category;
SELECT * FROM category;

DROP TABLE IF EXISTS top_five_genres;
CREATE TABLE top_five_genres
SELECT SUM(p.amount) AS gross_revenue , c.name AS top_five_genres
FROM payment p

JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category f ON i.film_id = f.film_id
JOIN category c ON f.category_id = c.category_id

GROUP BY c.name
ORDER BY gross_revenue DESC
LIMIT 5;

SELECT * FROM top_five_genres;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW view_top_five AS
SELECT * 
FROM top_five_genres;


-- 8b. How would you display the view that you created in 8a?
SELECT * 
FROM view_top_five;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW view_top_five;