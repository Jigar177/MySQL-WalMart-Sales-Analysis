CREATE DATABASE IF NOT EXISTS SalesDataWalmart;
USE SalesDataWalmart;

CREATE TABLE IF NOT EXISTS Sales(
	Invoice_ID varchar(30) NOT NULL PRIMARY KEY,
    Branch VARCHAR(5) NOT NULL,
    City VARCHAR(30) NOT NULL,
    Customer_type VARCHAR(30) NOT NULL, 
    Gender VARCHAR(10) NOT NULL,
    Product_line VARCHAR(100) NOT NULL,
    Unit_price DECIMAL(10,2) NOT NULL,
    Quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    Total DECIMAL(12,4) NOT NULL,
    Date DATETIME NOT NULL,
    Time TIME NOT NULL,
    Payment VARCHAR(15) NOT NULL,
    Cogs DECIMAL(10,2),
    Gross_Margin_Pct FLOAT(11,9),
    Gross_Income DECIMAL(12,4),
    Rating FLOAT(2,1)
);

select count(*) from sales;


-- --------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------Feature Engineering----------------------------------------------------------------

-- Time_of_day

SELECT 	
	time,
		(CASE 
			WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
            WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
            ELSE "Evening"
		END)
        AS time_of_date
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_date VARCHAR(20);

SELECT * FROM sales;

UPDATE sales
SET time_of_date = (
	CASE
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END
);


-- Day_Name

SELECT 
	date,
    DAYNAME(date) AS Day_Name
FROM sales;

ALTER TABLE sales ADD COLUMN Day_Name VARCHAR(10);

UPDATE Sales
SET Day_Name = dayname(date);

select * from sales;



-- Month_Name

select * from sales;

select monthname(date) Month_Name from sales;

ALTER TABLE sales ADD COLUMN Month_Name varchar(10);

select * from sales;

UPDATE sales
SET Month_Name = MONTHNAME(date);
--  -----------------------------------------------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------Generic------------------------------------------------------------

-- How many unique cities does the data have?

select * from sales;
select distinct(city) from sales;

-- In which city is each branch ?

select * from sales;
select city,branch from sales group by branch;



-- ------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------Product------------------------------------------------------------

-- How many unique product lines does the data have?

select * from sales;
select distinct Product_line from sales;

-- What is the most common payment method?

select * from sales;
select count(payment) as Counts,payment  from sales group by payment order by Counts desc limit 1;

--  What is the most selling product line?

select * from sales;
select distinct Product_line , count(Quantity)  as Counts from sales  group by product_line order by Counts desc limit 1;

-- What is the total revenue by month?

select * from sales;
select Month_Name,sum(Total)as Total from sales group by  Month_Name order by Total desc; 

-- What month had the largest COGS?

select * from sales;
select month_name, sum(Cogs) AS Counts  from sales group by month_name order by Counts;

-- What product line had the largest revenue?

select * from sales;
select Product_line,sum(total) as Counts from sales group by product_line order by Counts desc;

-- What is the city with the largest revenue?

select * from sales;
select  city,sum(total) as counts from sales group by city order by counts;

-- What product line had the largest VAT?

select * from sales;
select Product_line , sum(VAT) as VAT from sales group by Product_line order by VAT desc;



-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

select total from sales where total > (select avg(total) from sales);
select avg(total) from sales;

select * from sales;

select total,
	(CASE 
		WHEN total > (select avg(total) from sales) then "GOOD"
        else "BAD"
	END) as Rating
from sales;

ALTER TABLE sales ADD COLUMN Rating VARCHAR(10);
        
        
SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;

SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;
        
-- Which branch sold more products than average product sold?

select * from sales;
SELECT 
	branch, 
    SUM(quantity) AS qnty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?
select * from sales;

select Product_line,count(Gender) as Counts , Gender from sales group by Gender,Product_line order by Counts desc;

-- What is the average rating of each product line?

select * from sales;
select product_line ,avg(rating) from sales group by product_line;




-- ------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------Sales--------------------------------------------------------------

-- Number of sales made in each time of the day per weekday

select * from sales;
select Day_Name,count(*) as total_sales from sales  where Day_Name = "Sunday" group by Day_Name order by total_sales desc;


-- Which of the customer types brings the most revenue?

select * from sales;
select Customer_type , sum(total) as counts from sales group by Customer_type order by counts desc;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?

select * from sales;
select city,round(avg(VAT),2) as counts from sales  group by city order by counts desc;

--  Which customer type pays the most in VAT?

select * from sales;
select Customer_type,round((VAT),2) as counts from sales  group by Customer_type order by counts desc;


-- ------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------Customer-----------------------------------------------------------

-- How many unique customer types does the data have?

select * from sales;
select distinct Customer_type  from sales;

-- How many unique payment methods does the data have?

select * from sales;
select distinct Payment from sales;

-- What is the most common customer type?

select * from sales;
select Customer_type,count(*) as counts from sales group by Customer_type order by counts desc;

-- Which customer type buys the most?

select * from sales;
select Customer_type,count(*) as counts from sales group by Customer_type order by counts;

-- What is the gender of most of the customers?

select * from sales;
select Gender,count(*) as counts from sales group by Gender order by counts desc;

-- What is the gender distribution per branch?

select * from sales;
select Branch,Gender,count(Gender)as distri from  sales group by branch;

SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;


-- Which time of the day do customers give most ratings?

select * from sales;
select Day_Name,count(Rating) as Rating from sales group by Day_Name order by Rating desc;
select Day_Name,round((Rating)) as Rating from sales group by Day_Name order by Rating desc;

-- Which time of the day do customers give most ratings per branch?

select * from sales;
select Branch,round(avg(rating),2) as rating from sales group by Branch order by rating desc;

SELECT
	Day_Name,
	AVG(rating) AS avg_rating
FROM sales
WHERE branch = "A"
GROUP BY Day_Name
ORDER BY avg_rating DESC;

-- Which day of the week has the best avg ratings?

select * from sales;
select Day_Name , avg(Rating) as ratings from sales group by Day_Name order by ratings desc;

-- why is that the case, how many sales are made on these days?

select * from sales;
select Day_Name ,count(Day_Name) total_sales from sales where branch = "C" group by Day_Name order by total_sales desc;

