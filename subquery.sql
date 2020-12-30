/*> (greater than), < (less than), >= (greater than or equal to), <= (less than or equal to), = (equal to), != (not equal to)*/
/*******************************************/
/****Solutions to Your First Subquery 1****/
/*****************************************/
/* 1-First, we needed to group by the day and channel. Then ordering by the number of events (the third column) gave us a quick way to answer the first question.*/
SELECT DATE_TRUNC('day',occurred_at) AS day,
   channel, COUNT(*) as events
FROM web_events
GROUP BY 1,2
ORDER BY 3 DESC;

/* 2-Here you can see that to get the entire table in question 1 back, we included an * in our SELECT statement. You will need to be sure to alias your table.*/
SELECT *
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
           channel, COUNT(*) as events
     FROM web_events
     GROUP BY 1,2
     ORDER BY 3 DESC) sub;
/* 3-Finally, here we are able to get a table that shows the average number of events a day for each channel.*/
SELECT channel, AVG(events) AS average_events
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
             channel, COUNT(*) as events
      FROM web_events
      GROUP BY 1,2) sub
GROUP BY channel
ORDER BY 2 DESC;
/*******************************************/
/****Solutions to Your First Subquery 2****/
/*****************************************/
/* 1-Here is the necessary quiz to pull the first month/year combo from the orders table.*/
SELECT DATE_TRUNC('month', MIN(occurred_at)) AS min_occur
FROM orders

/* 2-Then to pull the average for each, we could do this all in one query, but for readability, I provided two queries below to perform each separately.*/
SELECT AVG(standard_qty) avg_std, AVG(gloss_qty) avg_gls, AVG(poster_qty) avg_pst
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
     (SELECT DATE_TRUNC('month', MIN(occurred_at)) FROM orders);

SELECT SUM(total_amt_usd)
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
      (SELECT DATE_TRUNC('month', MIN(occurred_at)) FROM orders);
/************************/
/****Subquery QUIZZ ****/
/**********************/
/* Question 1 : Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.*/
SELECT RegionNAME, MAX(total_sales)
FROM(
  SELECT r.name AS RegionNAME, s.name AS SalesRepsNAME, SUM(o.total_amt_usd) AS total_sales
  FROM region r
  JOIN sales_reps s ON s.region_id = r.id
  JOIN accounts a ON a.sales_rep_id = s.id
  JOIN orders o ON o.account_id = a.id
  GROUP BY r.name, s.name) SRAL
GROUP BY 1
ORDER BY 2 DESC /* 4 elements, southeast:1098137.72*/
/*Udacity solution*/
/* step 1: First, I wanted to find the total_amt_usd totals associated with each sales rep, and I also wanted the region in which they were located. The query below provided this information.*/
SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s
JOIN accounts a ON a.sales_rep_id = s.id
JOIN orders o ON o.account_id = a.id
JOIN region r ON r.id = s.region_id
GROUP BY 1,2
ORDER BY 3 DESC;
/* step 2: I pulled the max for each region, and then we can use this to pull those rows in our final result.*/
SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
          FROM sales_reps s
          JOIN accounts a ON a.sales_rep_id = s.id
          JOIN orders o ON o.account_id = a.id
          JOIN region r ON r.id = s.region_id
          GROUP BY 1, 2) t1
     GROUP BY 1;
/* step 3: Essentially, this is a JOIN of these two tables, where the region and amount match.*/
SELECT t3.rep_name, t3.region_name, t3.total_amt
FROM(SELECT region_name, MAX(total_amt) max_total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a ON a.sales_rep_id = s.id
             JOIN orders o ON o.account_id = a.id
             JOIN region r ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1) t2
JOIN (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
     FROM sales_reps s
     JOIN accounts a ON a.sales_rep_id = s.id
     JOIN orders o ON o.account_id = a.id
     JOIN region r ON r.id = s.region_id
     GROUP BY 1,2
     ORDER BY 3 DESC) t3
ON t3.region_name = t2.region_name AND t3.total_amt = t2.max_total_amt;
/* Question 2 : For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?*/
SELECT t3.SalesRepsNAME, t2.RegionNAME, t2.max_total_amt, t2.max_total_count
FROM
  (SELECT RegionNAME, MAX(total_sales_amt) AS max_total_amt, MAX(total_sales_qty) AS max_total_count
  FROM(
    SELECT r.name AS RegionNAME, s.name AS SalesRepsNAME, SUM(o.total_amt_usd) AS total_sales_amt, COUNT(o.total) AS total_sales_qty
    FROM region r
    JOIN sales_reps s ON s.region_id = r.id
    JOIN accounts a ON a.sales_rep_id = s.id
    JOIN orders o ON o.account_id = a.id
    GROUP BY 1, 2 ) t1
  GROUP BY 1)t2
JOIN(
  SELECT r.name AS RegionNAME, s.name AS SalesRepsNAME, SUM(o.total_amt_usd) AS total_sales_amt, COUNT(o.total) AS total_sales_qty
  FROM region r
  JOIN sales_reps s ON s.region_id = r.id
  JOIN accounts a ON a.sales_rep_id = s.id
  JOIN orders o ON o.account_id = a.id
  GROUP BY 1, 2
)t3
ON t2.RegionNAME = t3.RegionNAME AND t2.max_total_amt = t3.total_sales_amt AND t2.max_total_count = t3.total_sales_qty
ORDER BY t2.max_total_count DESC
/* Udacity solution*/
/* step 1 :The first query I wrote was to pull the total_amt_usd for each region.*/
SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s
JOIN accounts a ON a.sales_rep_id = s.id
JOIN orders o ON o.account_id = a.id
JOIN region r ON r.id = s.region_id
GROUP BY r.name;
/* Step 2 : Then we just want the region with the max amount from this table. There are two ways I considered getting this amount. One was to pull the max using a subquery. Another way is to order descending and just pull the top value.*/
SELECT MAX(total_amt)
FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a ON a.sales_rep_id = s.id
             JOIN orders o ON o.account_id = a.id
             JOIN region r ON r.id = s.region_id
             GROUP BY r.name) sub;
/*Finally, we want to pull the total orders for the region with this amount:*/
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a ON a.sales_rep_id = s.id
JOIN orders o ON o.account_id = a.id
JOIN region r ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (
      SELECT MAX(total_amt)
      FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
              FROM sales_reps s
              JOIN accounts a ON a.sales_rep_id = s.id
              JOIN orders o ON o.account_id = a.id
              JOIN region r ON r.id = s.region_id
              GROUP BY r.name) sub);
/*This provides the Northeast with 2357 orders.*/

/* Question 3 : How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?*/
SELECT COUNT(NameACCOUNT) AS Acc_name_count
FROM(
  SELECT a.name AS NameACCOUNT, SUM(o.standard_qty) AS max_std_count, SUM(o.total) AS max_total_count
  FROM accounts a
  JOIN orders o ON o.account_id = a.id
  GROUP BY 1
  /*ORDER BY 1 DESC*/) t1
WHERE t1.max_std_count < t1.max_total_count /*347*/
/*Udacity solution*/
/*First, we want to find the account that had the most standard_qty paper. The query here pulls that account, as well as the total amount:*/
SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
/*Now, I want to use this to pull all the accounts with more total sales:*/
SELECT a.name
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY 1
HAVING SUM(o.total) > (SELECT total
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) sub);
/*This is now a list of all the accounts with more total orders. We can get the count with just another simple subquery.*/
SELECT COUNT(*)
FROM (SELECT a.name
       FROM orders o
       JOIN accounts a
       ON a.id = o.account_id
       GROUP BY 1
       HAVING SUM(o.total) > (SELECT total
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) inner_tab)) counter_tab; /*3 accounts*/

/* 4-For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?*/
SELECT a.name AS NameFinal, w.channel, COUNT(w.channel) AS Channel_count
FROM accounts a
JOIN web_events w
ON w.account_id = a.id AND a.id = (
  SELECT id
  FROM(
    SELECT a.id, a.name AS NameACCOUNT, SUM(o.total_amt_usd) AS total_spent
    FROM accounts a
    JOIN orders o ON o.account_id = a.id
    GROUP BY 1,2
    ORDER BY 3 DESC
    LIMIT 1
  ) t1 )
GROUP BY 1,2
ORDER BY 3 DESC
/*Udacity solution*/
/*Here, we first want to pull the customer with the most spent in lifetime value.*/
SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY 3 DESC
LIMIT 1;
/*Now, we want to look at the number of events on each channel this company had, which we can match with just the id.*/
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id
                     FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
                           FROM orders o
                           JOIN accounts a
                           ON a.id = o.account_id
                           GROUP BY a.id, a.name
                           ORDER BY 3 DESC
                           LIMIT 1) inner_table)
GROUP BY 1, 2
ORDER BY 3 DESC;
/*I added an ORDER BY for no real reason, and the account name to assure I was only pulling from one account.*/

/* 5-What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?*/
SELECT AVG(total_sales)
FROM(
  SELECT a.name, SUM(o.total_amt_usd) AS total_sales
  FROM accounts a
  JOIN orders o ON o.account_id = a.id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 10
) t1
/* Udacity solution*/
/*First, we just want to find the top 10 accounts in terms of highest total_amt_usd.*/
SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY 3 DESC
LIMIT 10;
/*Now, we just want the average of these 10 amounts.*/
SELECT AVG(tot_spent)
FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY a.id, a.name
      ORDER BY 3 DESC
       LIMIT 10) temp;
/* 6-What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.*/

SELECT a.id AS AccountID, a.name AS NameACCOUNT, SUM(o.total_amt_usd) AS total_sales_amt, COUNT(o.total) AS total_sales_qty
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY 1, 2
HAVING COUNT(o.total) > ( SELECT AVG(total_sales_qty)
                            FROM (
                              SELECT a.id AS AccountID, a.name AS NameACCOUNT, SUM(total_amt_usd) AS total_sales_amt, COUNT(o.total) AS total_sales_qty
                              FROM accounts a
                              JOIN orders o ON o.account_id = a.id
                              GROUP BY 1, 2
                              ORDER BY 4 DESC
                            ) t2)
ORDER BY 4 DESC
/* Udacity solution*/
/*First, we want to pull the average of all accounts in terms of total_amt_usd:*/
SELECT AVG(o.total_amt_usd) avg_all
FROM orders o
/*Then, we want to only pull the accounts with more than this average amount.*/
SELECT o.account_id, AVG(o.total_amt_usd)
FROM orders o
GROUP BY 1
HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                               FROM orders o);
/*Finally, we just want the average of these values.*/
SELECT AVG(avg_amt)
FROM (SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
    FROM orders o
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                                   FROM orders o)) temp_table;
