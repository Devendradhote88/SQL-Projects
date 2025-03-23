/* Feature Engineering: This will help us generate some new columns from existing ones.
2.1 Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. 
This will help answer the question on which part of the day most sales are made */
select * from amazon;
# inserting a new column timeofday
alter table amazon 
add column timeofday varchar(20);

# updating timeofday with values.
SET SQL_SAFE_UPDATES = 0;
update amazon 
set timeofday = CASE
    WHEN time < '12:00:00' THEN 'Morning'
    WHEN time >= '12:00:00' AND time < '17:00:00' THEN 'Afternoon'
    ELSE 'Evening'
END;
SET SQL_SAFE_UPDATES = 1;

/*2.2 Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri).
 This will help answer the question on which week of the day each branch is busiest.*/
select * from amazon;
#Adding a new column.
alter table amazon 
add column dayname varchar(15); 

# updating dayname column with values.
SET SQL_SAFE_UPDATES = 0;
UPDATE amazon
SET dayname = CASE
    WHEN DAYOFWEEK(date) = 2 THEN 'Mon'
    WHEN DAYOFWEEK(date) = 3 THEN 'Tue'
    WHEN DAYOFWEEK(date) = 4 THEN 'Wed'
    WHEN DAYOFWEEK(date) = 5 THEN 'Thu'
    WHEN DAYOFWEEK(date) = 6 THEN 'Fri'
    WHEN DAYOFWEEK(date) = 7 THEN 'Sat'
    ELSE 'Sun'
END;
SET SQL_SAFE_UPDATES = 1;

/* 2.3 Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar).
 Help determine which month of the year has the most sales and profit. */
# Adding a new column to store the month of the transaction
ALTER TABLE amazon
ADD COLUMN monthname VARCHAR(10);

# Updating the new column with the month of the transaction
SET SQL_SAFE_UPDATES = 0;
UPDATE amazon
SET monthname = CASE
    WHEN MONTH(date) = 1 THEN 'Jan'
    WHEN MONTH(date) = 2 THEN 'Feb'
    WHEN MONTH(date) = 3 THEN 'Mar'
    WHEN MONTH(date) = 4 THEN 'Apr'
    WHEN MONTH(date) = 5 THEN 'May'
    WHEN MONTH(date) = 6 THEN 'Jun'
    WHEN MONTH(date) = 7 THEN 'Jul'
    WHEN MONTH(date) = 8 THEN 'Aug'
    WHEN MONTH(date) = 9 THEN 'Sep'
    WHEN MONTH(date) = 10 THEN 'Oct'
    WHEN MONTH(date) = 11 THEN 'Nov'
    ELSE 'Dec'
END;
SET SQL_SAFE_UPDATES = 1;

# 1. What is the count of distinct cities in the dataset?
select  distinct city as city_count from amazon ;
# Ans = There are 3 distinct count of cities in the dataset

# 2. For each branch, what is the corresponding city?
select distinct branch , city from amazon
order by branch asc;
# Ans = for A branch the corresponding city is Yangon , for B the city is Mandalay and 
#       for C the city is Naypyitaw.


# 3. What is the count of distinct product lines in the dataset?
select count(distinct `product line`) as distinct_product_lines from amazon;
# Ans = the count of distinct product lines in the dataset is 6.

# 4. Which payment method occurs most frequently?
SELECT payment, COUNT(*) AS frequency
FROM amazon
GROUP BY payment
ORDER BY frequency DESC
LIMIT 3;
# Ans = Ewallet payment method occurs most frequently.

# 5. Which product line has the highest sales?
select `product line`,round(sum(total),2) as total_sales from amazon
group by `product line`
order by total_sales desc
limit 1;
# Ans = Food and beverages has the highest sales with 56144.84.

# 6. How much revenue is generated each month?
select monthname(date) as month_name , round(sum(total),2) as Revenue 
from amazon
group by monthname(date);
# the revenue  generated each month is January = 116291.87 ,March = 109455.51, February= 97219.37.

# 7. In which month did the cost of goods sold reach its peak?
select month_name from 
(select monthname(date) as month_name , round(sum(cogs),2) as Revenue
from amazon
group by monthname(date)
order by Revenue desc
limit 1 ) as one;
# Ans = In the month of january the cost of goods sold reach its peak.

# 8. Which product line generated the highest revenue?
select `product line` from 
(select `product line`,round(sum(total),2) as total_revenue from amazon
group by `product line`
order by total_revenue desc
limit 1) as one ;
# Ans = Food and beverages generated the highest revenue.

# 9.  In which city was the highest revenue recorded?
select city from 
(select city , round(sum(total),2) as Revenue from amazon
group by city
order by Revenue desc
limit 1) as one ;
# Ans = Naypyitaw city recorded the highest revenue.

# 10. Which product line incurred the highest Value Added Tax?
select `product line` from 
(select `product line`, round(sum(`Tax 5%`),2) as added_tax from amazon 
group by `product line`
order by added_tax desc
limit 1) as one;
# Ans = Food and beverages incurred the highest Value Added Tax.

# 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
WITH avg_sales AS (
    SELECT AVG(am.quantity) AS avg_total
    FROM amazon am
    group by am.`product line`
)
SELECT a.`product line`, 
       count(a.quantity) as count_of_products,
       CASE 
           WHEN count(a.quantity) > (SELECT avg(avg_total) FROM avg_sales) THEN 'Good'
           ELSE 'Bad'
       END AS sales_performance
FROM amazon a
group by a.`product line`;

/* Ans = For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad." 
is good.*/

# 12. Identify the branch that exceeded the average number of products sold.
WITH avg_products_sold AS (
    SELECT AVG(Quantity) AS avg_quantity
    FROM amazon
)
SELECT branch, count(Quantity) AS total_products_sold
FROM amazon
GROUP BY branch
HAVING count(Quantity) > (SELECT avg_quantity FROM avg_products_sold)
ORDER BY total_products_sold DESC;
# Ans = The branch that exceeded the average number of products sold are A,B,C.

# 13. Which product line is most frequently associated with each gender?
WITH RankedProductLines AS (
    SELECT 
        gender,
        `product line`,
        COUNT(*) AS frequency,
        ROW_NUMBER() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS ranking
    FROM 
        amazon
    GROUP BY 
        gender, `product line`)
SELECT 
    gender,
     `product line`,ranking,frequency
FROM 
    RankedProductLines
WHERE 
    ranking = 1;
# Ans = female associated with fashion accessories and male associate with health and beauty.


# 14. Calculate the average rating for each product line.
select `product line`, round(avg(rating),2) as avg_rating from amazon 
group by `product line`;
/* Ans = the average rating for each product line is Health and beauty = 7
Electronic accessories = 6.92
Home and lifestyle = 6.84
Sports and travel =	6.92
Food and beverages = 7.11
Fashion accessories = 7.03 */

# 15.Count the sales occurrences for each time of day on every weekday.
SELECT dayname, timeofday, COUNT(*) AS sales_count
FROM amazon
GROUP BY dayname, timeofday
ORDER BY dayname, timeofday;
/* Ans = the sales occurrences for each time of day on every weekday is 
Fri	 Afternoon	68  Mon	Afternoon	64  Sat	Afternoon	69 Sun	Afternoon	59 Thu	Afternoon	61 
     Evening	42      Evening	    40      Evening 	67      Evening	    52      Evening 	44
	 Morning	29      Morning	    21      Morning 	28      Morning 	22      Morning 	33

Tue	Afternoon	62 Wed	Afternoon	71
    Evening 	60      Evening 	50
    Morning 	36      Morning 	22 */


# 16. Identify the customer type contributing the highest revenue.
select `customer type` from 
( select `customer type` , round(sum(total),2) as total_revenue from amazon 
group by `customer type`
order by total_revenue desc
limit 1) as one ;
# Ans = the customer type contributing the highest revenue is Member.

# 17. Determine the city with the highest VAT percentage.
select city from 
(select city, round(sum(`tax 5%`),2) as Total_percentage 
FROM amazon
group by city
order by Total_percentage desc
limit 1) as one ;
# Ans = The city with the highest VAT percentage is Naypyitaw..


# 18.Identify the customer type with the highest VAT payments.
SELECT `customer type`, round(SUM(`Tax 5%`),2) AS total_vat
FROM amazon
GROUP BY `customer type`
ORDER BY total_vat DESC
LIMIT 1;
# Ans =  The customer type with the highest VAT payments is member.


# 19.What is the count of distinct customer types in the dataset?
select count(customer) as Total_customers from 
(select distinct `customer type` as customer from amazon
group by `customer type`) as one;
# Ans = the count of distinct customer types in the dataset is 2 

# 20.What is the count of distinct payment methods in the dataset?
select count(distinct payment) as Payment_methods from amazon;
# Ans = There are three distinct methods that is Ewallet, Cash, Credit card and the count is 3  

# 21.Which customer type occurs most frequently?
select `customer type` from 
(select gender, `customer type` , count(`customer type`) as customer_count from amazon
group by gender,`customer type`
order by customer_count desc
limit 1) as one;
# Ans = Customer type occurs most frequently is member.

# 22.Identify the customer type with the highest purchase frequency.
SELECT `Customer Type`, COUNT(*) AS Purchase_Frequency
FROM amazon
GROUP BY `Customer Type`
ORDER BY Purchase_Frequency DESC
LIMIT 1;
# Ans = The customer type with the highest purchase frequency is member.


# 23.Determine the predominant gender among customers.
select Gender,`Customer Type` from 
(SELECT Gender,`Customer Type`, COUNT(*) AS Frequency
FROM amazon 
GROUP BY Gender,`Customer Type`
ORDER BY Frequency DESC
LIMIT 1) as one;
# Ans = The predominant gender among customers is Female.


# 24.Examine the distribution of genders within each branch.
select branch,gender , count(gender) as gender_count from amazon
group by branch, gender
order by branch asc;
# Ans = The distribution of genders within each branch is 
/* 	A	Female	161
	A	Male	179
	B	Female	162
	B	Male	170
	C	Female	178
	C	Male	150 */


# 25.Identify the time of day when customers provide the most ratings.
select timeofday from 
(select timeofday , count(rating) as max_rating from amazon
group by timeofday
order by max_rating desc 
limit 1) as one;
# Ans = the time of day when customers provide the most ratings is afternoon.

# 26. Determine the time of day with the highest customer ratings for each branch.
select timeofday, branch , max_rating
from
(select timeofday ,branch, max(rating) as max_rating ,
row_number() over (partition by branch order by max(rating) desc) as rankings
from amazon
group by timeofday,branch) as one
where rankings = '1';
# Ans = The time of day with the highest customer ratings for each branch is 
/* for A branch highest rating is 10 in Afternoon.
   for A branch highest rating is 10 in Afternoon
   for A branch highest rating is 10 in evening */

# 27. Identify the day of the week with the highest average ratings.
select dayname , round(avg(rating),2) as avg_rating from amazon
group by dayname 
order by avg_rating desc 
limit 1 ;
# Ans = The day of the week with the highest average rating is Monday.

# 28. Determine the day of the week with the highest average ratings for each branch.
select branch, dayname, round(avg(rating),2) as avg_rating from amazon
group by dayname, branch
having branch = 'C' 
order by dayname asc;
# Ans = The day of the week with the highest average ratings for each branch is 
/* for A branch the highest ratings on 
Fri     7.31
Mon     7.1
Sat		6.75	
Sun		7.08
Thu		6.96
Tue		7.06
Wed     6.92
for B branch the highest ratings on 
Fri		6.69
Mon		7.34
Sat		6.74
Sun 	6.89
Thu		6.75
Tue		7
Wed		6.45
for C branch the highest ratings on 
Fri		7.28
Mon		7.04
Sat		7.23
Sun		7.03
Thu		6.95
Tue		6.95
Wed		7.06*/

select monthname , sum(`Unit price` * quantity) as total_revenue from amazon
group by monthname ;

select `product line`, sum(`Unit price` * quantity) as revenue from amazon 
group by `product line`
order by revenue desc;

 