-- SQL Queries No 2 :-
-- [Find the States for which the average time of delivery from Sale Timestamp to Delivered Timestamp is the minimum 
--    and the maximum respectively. Use the Delivery data for this and only those records for which Sale Timestamp, 
--    Delivery Timestamp and Ship to State – all variables are populated.]

-- Using capstone database
use capstone;

-- Gives a list of tables present in our database
show tables;

-- To create table named as delivery data 
create table delivery_data (
	orderdate date,
	articletype varchar(500),
	originalreqdeliverydate datetime,
	currentstatus varchar(500),
	currentstatustimestamp datetime,
	sale_timestamp datetime,
	delivered_timestamp datetime,
	articlename varchar(500),
	merchcategorydescription varchar(500),
	merchclassdescription varchar(500),
	merchgroupdescription varchar(500),
	itemdesc varchar(500),
	shiptozipcode varchar(50),
	shiptocity varchar(200),
	shiptostate varchar(200)
    );


-- Below step loads our CSV file into the above table delivery_data 
load data infile 'C:/Users/Omen/OneDrive/Documents/Final Project/TechNova Sales Insights/Cleaned_Customer_Delivery_Data.csv'
into table delivery_data
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;


-- Shows first 3 rows from table delivery_data
select * from delivery_data limit 3;


-- Calculating Delivery Time and Filtering Records
create temporary table delivery_times as
select shiptostate,
timestampdiff(second, sale_timestamp, delivered_timestamp) as delivery_time_seconds
from delivery_data
where sale_timestamp is not null
and delivered_timestamp is not null
and shiptostate is not null;


-- Calculating Average Delivery Time for each State
create temporary table average_delivery_times as
select shiptostate,
avg(delivery_time_seconds) as average_delivery_time_seconds
from delivery_times
group by shiptostate;


-- State with the minimum average delivery time
select shiptostate, average_delivery_time_seconds
from average_delivery_times
order by average_delivery_time_seconds asc
limit 1;


-- State with the maximum average delivery time
select shiptostate, average_delivery_time_seconds
from average_delivery_times
order by average_delivery_time_seconds desc
limit 1;