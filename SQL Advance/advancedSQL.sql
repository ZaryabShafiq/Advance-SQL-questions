-- Please note that some questions have been answwered using two different approaches. 
-- e.g CTE & subquery

--Q1
-- with sub as(
-- select
-- 	contactfirstname,
-- 	contactlastname,
-- 	territory,
-- 	sum(priceeach* quantityordered) as total_amt,
-- 	rank() over (partition by territory order by sum(priceeach* quantityordered) )
-- from 
-- 	sales
-- group by
-- 	contactfirstname, contactlastname, territory
-- )

-- select contactfirstname, contactlastname, territory, total_amt
-- from sub
-- where sub.rank <=3 and territory not ilike 'NA'

-- order by territory







-- Q2
-- WITH sales_per_quarter AS (
--     SELECT 
--         productline, 
--         qtr_id, 
--         SUM(priceeach * quantityordered) AS total_amt
--     FROM 
--         sales
--     GROUP BY 
--         productline, 
--         qtr_id
-- ),
-- ranked_sales AS (
--     SELECT 
--         productline, 
--         qtr_id, 
--         total_amt,
--         LEAD(total_amt) OVER (PARTITION BY productline ORDER BY qtr_id) AS next_quarter_amt
--     FROM 
--         sales_per_quarter
-- )
-- SELECT 
--     productline,
--     qtr_id AS current_quarter,
--     next_quarter_amt,
--     total_amt AS current_total,
--     100.0 * (next_quarter_amt - total_amt) / total_amt AS percent_change
-- FROM 
--     ranked_sales
-- WHERE 
--     next_quarter_amt IS NOT NULL
-- ORDER BY 
--     productline, 
--     qtr_id;








-- Q3
-- with highest_value as (
-- select sum(priceeach * quantityordered) as total_amt, ordernumber,
-- 		contactfirstname,
-- 		contactlastname,
-- 		productline
-- from sales
-- group by productline, ordernumber, contactfirstname, contactlastname
-- ),

-- top_five as (
-- 	select
-- 		ordernumber,
-- 		contactfirstname,
-- 		contactlastname,
-- 		productline,
-- 		total_amt,
-- 		rank() over (partition by productline order by total_amt) as top_rank   
-- 	from highest_value
-- )

-- select 
-- 	ordernumber, contactfirstname, contactlastname, productline, total_amt
-- from
-- 	top_five
-- where
-- 	top_rank <= 5
-- order by
-- 	productline








-- Q4
-- select to_char(to_date(month_id::text, 'MM'), 'Month'), sum(quantityordered * priceeach) as total_amt, dealsize
-- from sales
-- where year_id = 2003
-- group by dealsize, month_id
-- order by month_id, dealsize







-- Q5
-- with sales_value as(
-- select contactfirstname, contactlastname, sum(quantityordered * priceeach) as total_amt, territory
-- from sales
-- where territory not ilike 'NA'
-- group by contactfirstname, contactlastname, territory
-- )

-- select contactfirstname, contactlastname, territory, round(avg(total_amt), 2)
-- from sales_value
-- group by contactfirstname, contactlastname, territory







-- Q6
-- with sales_amt as(
-- 	select
-- 	productline,
-- 	productcode,
-- 	qtr_id,
-- 	year_id,
-- 	rank() over (partition by qtr_id order by sum(priceeach * quantityordered)) as ranked,
-- 	sum(priceeach * quantityordered) as prev_qtr_sales
-- 	from 
-- 		sales
-- 	group by 
-- 		productline,
-- 		productcode,
-- 		qtr_id,
-- 	year_id
-- ),

-- next_qtr as(
-- 	select
-- 	productline,
-- 	productcode,
-- 	qtr_id,
-- 	prev_qtr_sales,
-- 	year_id,
-- 	lead(prev_qtr_sales) over (order by qtr_id) as next_qtr_sales
-- 	from sales_amt
-- 	group by
-- 	productline,
-- 	productcode,
-- 	qtr_id,
-- 	prev_qtr_sales,
-- 	year_id
-- )

-- select
-- 	productcode,
-- 	productline,
-- 	prev_qtr_sales,
-- 	next_qtr_sales,
-- 	qtr_id,
-- 	year_id,
-- 	100 * (next_qtr_sales - prev_qtr_sales)/prev_qtr_sales as growth_percent
-- from next_qtr
-- where 
-- 	next_qtr_sales is not NULL and year_id = 2003
-- group by
-- 	productline,
-- 	productcode,
-- prev_qtr_sales,
-- next_qtr_sales,
-- qtr_id,
-- 	year_id
-- order by productline, qtr_id










--Q7
-- with s03 as(
-- 	select
-- 	productline,
-- 	sum(priceeach * quantityordered) as total_amt_03
-- 	from sales
-- 	where year_id = 2003
-- 	group by productline
-- ),

-- s04 as (
-- 	select
-- 	productline,
-- 	sum(priceeach * quantityordered) as total_amt_04
-- 	from sales
-- 	where year_id = 2004
-- 	group by productline
-- )

-- select
-- 	s03.productline,
-- 	s03.total_amt_03,
-- 	s04.total_amt_04,
-- 	100 * (total_amt_04 - total_amt_03) / total_amt_03 as growth
-- from s04
-- 	join s03 on s03.productline = s04.productline
-- order by productline












--Q8
-- with time as(
-- 	select contactfirstname,
-- 	contactlastname,
-- 	to_char(to_date(month_id::text, 'MM'), 'Month') as start_month, 
-- 	to_char(to_date(month_id::text, 'MM')+ INTERVAL '6 months', 'Month') as end_month,
-- 	ordernumber, 
-- 	sales,
-- 	month_id
-- 	from sales	
-- )

-- select
-- 	ordernumber,
-- 	contactfirstname,
-- 	contactlastname,
-- 	sum(sales),
-- 	start_month,
-- 	end_month
-- from time
-- where to_char(to_date(month_id::text, 'MM'), 'Month') between start_month and end_month
-- group by ordernumber, contactfirstname, contactlastname, start_month, end_month
-- having sum(sales) > 10000
-- order by start_month, end_month












--Q9
-- with freq as(
-- 	select
-- 	ordernumber,
-- 	contactfirstname,
-- 	contactlastname,
-- 	count(ordernumber) as frequency
-- 	from sales
-- 	group by contactfirstname, contactlastname, ordernumber
-- ),

-- avg_frequency as(
-- select
-- 	avg(frequency) as avg_freq
-- 	from freq
-- 	)
	
-- select 
-- 	f.ordernumber,
-- 	f.contactfirstname,
-- 	f.contactlastname,
-- 	f.frequency
-- from freq f
-- cross join avg_frequency a
-- where f.frequency > a.avg_freq









	
-- Q10
-- with line_terr as (
-- select  productline,
-- 		sum(priceeach * quantityordered) as total_sales,
-- 		territory
-- from sales
-- group by productline, territory
-- ),

-- terr_sales as (
-- 	select
-- 	sum(priceeach * quantityordered) as total_sales,
-- 	territory
-- 	from sales
-- 	group by territory
-- )

-- select
-- 	lt.productline,
-- 	ts.territory,
-- 	ts.total_sales as territory_sales,
-- 	100 * lt.total_sales / ts.total_sales as contribution
-- from line_terr lt
-- join terr_sales ts
-- on lt.territory = ts.territory
-- order by contribution




-- with cust_qtr as(
-- select
-- 	distinct ordernumber,
-- 	sum(priceeach * quantityordered) as total_amt,
-- 	contactfirstname,
-- 	contactlastname
-- 	qtr_id
-- from
-- 	sales
-- where
-- 	year_id = 2003
-- group by
-- 	contactfirstname,
-- 	contactlastname,
-- 	qtr_id,
-- 	ordernumber
-- order by ordernumber
-- ),

-- pat as (
-- select 
-- 	contactfirstname,
-- 	contactlastname,
-- 	ordernumber,
-- 	qtr_id
-- 	from sales
-- 	-- group by contactfirstname,
-- 	-- contactlastname,
-- 	-- ordernumber
-- )

-- select
-- 	p.contactfirstname,
-- 	p.contactlastname,
-- 	c.ordernumber,
-- 	c.total_amt,
-- 	c.qtr_id
-- from cust_qtr c
-- join pat p
-- on p.qtr_id::text = c.qtr_id::text
-- where total_amt > 500