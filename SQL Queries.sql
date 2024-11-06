Q1.Input	 	 
Year   	Product    Revenue_Projection
2018   	P1       	100
2017   	P2       	200
2018   	P2       	300
2019   	P2       	300
2018	P1       	50
Output	 	 
Product   	Revenue_Projection_2017   	Revenue_Projection_2018
P1       	0               	150
P2       	200               	300
Answer:
SELECT
    Product,
    SUM(CASE WHEN Year = 2017 THEN Revenue_Projection ELSE 0 END) AS Revenue_Projection_2017,
    SUM(CASE WHEN Year = 2018 THEN Revenue_Projection ELSE 0 END) AS Revenue_Projection_2018
FROM your_table_name
GROUP BY Product;

-----------If date not formatted ----------
SELECT    Product, SUM(CASE WHEN YEAR(CONVERT(DATE, Year, 120)) = 2022 THEN Revenue_Projection  ELSE 0 
    END) AS Revenue_Projection_2022,
    SUM(CASE 
        WHEN YEAR(CONVERT(DATE, Year, 120)) = 2020 THEN Revenue_Projection 
        ELSE 0 
    END) AS Revenue_Projection_2020  FROM ProductRevenue
GROUP BY Product;


#Q2.Query the two names in EMPLOYEE with the shortest and longest employee names, as well as their respective lengths
 (i.e.: number of characters in the name). 
If there is more than one smallest or largest name, choose the one that comes first when ordered alphabetically.
Answer:
(select Name, length(Name) as Name_len from STATION 
order by Name_len asc, Name asc limit 1) 
union
(select Name, length(Name) as Name_len from STATION 
order by Name_len desc, Name asc limit 1);

two sepaerate query answer:
-- Query to find the city with the shortest name
 SELECT TOP 1 game_title AS ShortestCityName, LEN(game_title) AS Length FROM games 
ORDER BY LEN(game_title) ASC, game_title ASC;

 -- Query to find the city with the longest name
 SELECT TOP 1 game_title AS LongestCityName, LEN(game_title) AS Length FROM games 
ORDER BY LEN(game_title) DESC, game_title ASC;

#Q3. Table A: Empno, empname, sal 
1 to 10 rows
Table B:  empno,empname,depno,deptname,sal
11 to 20 rows
result
1 to 20 rows 

Answer:SELECT empname,empno,
    NULL AS deptno,        -- NULL for deptno in Table A
   NULL AS deptname,       -- NULL for deptname in Table A
    sal FROM TableA
UNION ALL
SELECT empname,empno,depno,deptname,sal FROM TableB;

#Q4. 
Input : Country name: 001 india,  oo2 austrialia ,oo3 southafrica etc
Result: india,austrialia,southafrica
Answer : SELECT  CountryName,
    REGEXP_REPLACE(CountryName, '[0-9]', '') AS CountryName_new
FROM  your_table;



#Q5. Second Max salary :
Answer: WITH RankedSalaries AS (
    SELECT sal, ROW_NUMBER() OVER (ORDER BY sal DESC) AS rank    FROM employees )
SELECT sal  FROM RankedSalaries
WHERE rank = 2;

##Q6. employees whose salaries are higher than their managers salaries?
Answer: SELECT e.name AS employee_name, 
       e.salary AS employee_salary,   m.name AS manager_name,
       m.salary AS manager_salary  FROM employees e 
JOIN employees m ON e.manager_id = m.id
WHERE e.salary > m.salary;

##Q7.write a query to find employees whose salary is above the average salary in their department
Input :
empid name   depid salary
1     jon     1     5000
2     alice   1     7000
3     bob     2     6000 
4     carol   2     4000
SELECT empid, name, depid, salary  FROM employees e
WHERE salary > (
    SELECT AVG(salary)      FROM employees d
    WHERE d.depid = e.depid    );
-----Or--------------
SELECT empid, name, depid, salary
FROM (     SELECT empid, name, depid, salary,
           AVG(salary) OVER (PARTITION BY depid) AS avg_dept_salary
    FROM employees  ) AS subquery
WHERE salary > avg_dept_salary;

##Q8. find customers who bought product at least 2 times consecutively
 custid,  prodid, orderdate
1           a1   2024-02-01,  
2           b1   2024-02-04,
1           c1   2024-02-06,
1           d1   2024-02-07,
6           e1   2024-02-10,
6           f1   2024-02-11,
6           g1   2024-02-12,
Answer:
SELECT custid, prodid, orderdate
FROM (
    SELECT custid, prodid, orderdate,
           LAG(prodid) OVER (PARTITION BY custid ORDER BY orderdate) AS prev_prodid
    FROM orders
) AS subquery
WHERE prodid = prev_prodid;
Explanation:
LAG(prodid) OVER (PARTITION BY custid ORDER BY orderdate) retrieves the previous product purchased by the same customer in chronological order.

##Q9: customer_id,purchase_id,date,amount
 write a sql query to find  the first and last purchase of each customer.
the query should return customerid, firstpurchasedate, lastpurchase date

Answer:
SELECT    customer_id, 
    MIN(date) AS first_purchase_date,
    MAX(date) AS last_purchase_date  FROM purchases
   GROUP BY customer_id;

##Q10: 
Country	Point
Australia	10
USA	15
India	9
England	12
Canada	13

result: India  and candada top and bottom positions wont change:if we add new country name as well and other countries desc order.
Ans: SELECT Country, Point FROM your_table
ORDER BY  CASE    WHEN Country = 'India' THEN 1
        WHEN Country = 'Canada' THEN 3    ELSE 2  END,
   CASE  WHEN Country NOT IN ('India', 'Canada') THEN Country
    END DESC;


##Q11: input
Word	   Count of 'ab'
Abcdabxy	    2
mnabxyabcdab	3
pqab abcd	    2

Answer: SELECT word,  (LENGTH(word) - LENGTH(REPLACE(word, 'ab', ''))) / LENGTH('ab') AS "Count of 'ab'"FROM your_table;

##Q12.Total Claim Amount from cust(cust_id 1,2,3) and claim tables( cust_id 1,1,3).  result :NO claim cust_id 2 as 0
Answer:
SELECT c.cust_id,
       COALESCE(SUM(cl.amount), 0) AS total_claim_amount
FROM customers c
LEFT JOIN claims cl ON c.cust_id = cl.cust_id
GROUP BY c.cust_id;

##Q13.
inpout :1,ca1,50,10june 1,ca1,100,12june 3,ca1,70,20june
result : 1,ca1,150,10june 1    ca1,150,12june
Answer: 
SELECT cust_id, claim_id,
    SUM(amount) OVER (PARTITION BY cust_id ORDER BY claim_date) AS cumulative_amount,
    claim_date  FROM  claims
ORDER BY   cust_id, claim_date;      result : 1,ca1,150,10june 1    ca1,150,12june


##Q14. Find Duplicate
SELECT cust_id, claim_id, claim_date, COUNT(*) AS count
FROM claims
GROUP BY cust_id, claim_id, claim_date
HAVING COUNT(*) > 1;

##Q15: Delete Dupliacte rows
DELETE FROM claims
WHERE (cust_id, claim_id, claim_date) IN (
    SELECT cust_id, claim_id, claim_date
    FROM claims  GROUP BY cust_id, claim_id, claim_date  HAVING COUNT(*) > 1
---------------different ways to delete duplicate records----
1.WITH CTE AS ( SELECT *,
           ROW_NUMBER() OVER (PARTITION BY cust_id, claim_id, claim_date ORDER BY claim_id) AS row_num    FROM claims )
DELETE FROM claims
WHERE claim_id IN (  SELECT claim_idFROM CTE WHERE row_num > 1);

2.DELETE FROM claims WHERE claim_id NOT IN ( SELECT MIN(claim_id)
    FROM claims     GROUP BY cust_id, claim_id, claim_date );

3.DELETE c1  FROM claims c1
INNER JOIN claims c2   ON c1.cust_id = c2.cust_id 
   AND c1.claim_id = c2.claim_id  AND c1.claim_date = c2.claim_date
   AND c1.claim_id > c2.claim_id;

4.WITH CTE AS ( SELECT *,
           RANK() OVER (PARTITION BY cust_id, claim_id, claim_date ORDER BY claim_id) AS rank_num
    FROM claims )
DELETE FROM claims
WHERE claim_id IN (SELECT claim_id FROM CTE
    WHERE rank_num > 1);

5.---Using temp table-----
CREATE TABLE temp_claims AS
SELECT cust_id, claim_id, claim_date, amount
FROM claims  GROUP BY cust_id, claim_id, claim_date, amount;
-- Clear original table   DELETE FROM claims;
-- Insert back unique rows
INSERT INTO claims   SELECT * FROM temp_claims;
-- Drop temporary table       
DROP TABLE temp_claims;



