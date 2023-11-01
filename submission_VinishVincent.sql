/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			
USE test;
-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/

SELECT 
    state, COUNT(customer_id) AS customer_count
FROM
    customer_t
GROUP BY state
ORDER BY customer_count DESC;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter.*/

WITH feedback_scores AS (
    SELECT quarter_number, customer_feedback,
    CASE
        WHEN CUSTOMER_FEEDBACK = 'Very Bad' THEN '1'
        WHEN CUSTOMER_FEEDBACK = 'Bad' THEN '2'
        WHEN CUSTOMER_FEEDBACK = 'Okay' THEN '3'
        WHEN CUSTOMER_FEEDBACK = 'Good' THEN '4'
        WHEN CUSTOMER_FEEDBACK = 'Very Good' THEN '5'
    END AS rating_count
    FROM order_t
)

SELECT quarter_number, ROUND(AVG(rating_count),2) AS average_rating
FROM feedback_scores
GROUP BY quarter_number
ORDER BY quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.*/
      
WITH Feedback_counts AS (
  SELECT
    quarter_number,
    customer_feedback,
    COUNT(*) AS feedback_count,
    SUM(COUNT(*)) OVER (PARTITION BY quarter_number) AS total_feedback
  FROM order_t
  GROUP BY quarter_number, customer_feedback
)

SELECT
  quarter_number,
  customer_feedback,
  ROUND((CAST(feedback_count AS DECIMAL) / total_feedback) * 100, 2) AS feedback_percentage
FROM Feedback_counts;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/

SELECT 
    vehicle_maker, COUNT(*) AS total_customers
FROM
    product_t
GROUP BY vehicle_maker
ORDER BY total_customers DESC
LIMIT 5;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

SELECT
    state,
    vehicle_maker, no_of_customers
FROM (
    SELECT
        state,
        vehicle_maker,
        COUNT(c.customer_id) AS no_of_customers,
        RANK() OVER (PARTITION BY state ORDER BY COUNT(c.customer_id) DESC) AS vehicle_rank
    FROM
        customer_t c
    JOIN
        order_t o ON c.customer_id = o.customer_id
    JOIN
        product_t p ON o.product_id = p.product_id
    GROUP BY
        state, vehicle_maker
) AS tbl
WHERE
    vehicle_rank = 1;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/

SELECT 
    quarter_number, COUNT(order_id) AS num_orders
FROM
    order_t
GROUP BY quarter_number
ORDER BY quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.*/
      
WITH QoQ AS
(
  SELECT
    quarter_number,
    SUM(quantity * vehicle_price * (1 - discount)) AS revenue
  FROM order_t
  GROUP BY quarter_number
)
SELECT
  quarter_number,
  revenue,
  LAG(revenue) OVER (ORDER BY quarter_number) AS previous_quarter_revenue,
  ROUND(((revenue - LAG(revenue) OVER (ORDER BY quarter_number)) / LAG(revenue) OVER (ORDER BY quarter_number) * 100),2) AS qoq_percentage_change
FROM QoQ;
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

SELECT 
    quarter_number,
    SUM(quantity * vehicle_price * (1 - discount)) AS total_revenue,
    COUNT(order_id) AS orders
FROM
    order_t
GROUP BY quarter_number
ORDER BY quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/


SELECT 
    customer_t.credit_card_type,
    ROUND(AVG(order_t.discount), 2) AS average_discount
FROM
    order_t,
    customer_t
WHERE
    order_t.customer_id = customer_t.customer_id
GROUP BY customer_t.credit_card_type
ORDER BY average_discount DESC;
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/

SELECT 
    quarter_number,
    ROUND(AVG(DATEDIFF(ship_date, order_date)), 0) AS avg_time_to_ship
FROM
    order_t
GROUP BY quarter_number
ORDER BY quarter_number DESC;
-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



