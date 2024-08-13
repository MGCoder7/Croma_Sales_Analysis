-- SQL Queries No 3 :-

-- Create a dataset of customer ids whose monthly transaction amount has increased every month for at least 3 consecutive months. 

-- To solve the above query we will use our Cleaned_Transaction_Data
-- Creating Table 
create table Transaction_Data (
    CustID varchar(500),
    ItemDesc varchar(500),
    MerchCategoryDescription varchar(500),
    MerchClassDescription varchar(500),
    MerchGroupDescription varchar(500),
    SaleValue varchar(500),
    OrderedQuantity decimal(10, 5),
    OrderDate date,
    SalesChannelCode varchar(500),
    Ecom_BnM_Indicator varchar(500),
    StoreID varchar(500),
    StoreCode varchar(500),
    StoreCity varchar(500),
    StoreState varchar(500),
    StorePincode varchar(500),
    Log_OrderedQuantity varchar(500),
    Sqrt_SaleValue varchar(500)
);


-- Below step loads our CSV file into the above table Transaction_Data
load data infile 'C:/Users/Omen/OneDrive/Documents/Final Project/TechNova Sales Insights/Cleaned_Customer_Transaction_Data.csv'
into table Transaction_Data
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;


-- Creating temporary table for monthly transactions
create temporary table monthly_transactions as
select
    CustID,
    date_format(OrderDate, '%Y-%m') as yearr_month,
    sum(SaleValue) as monthly_transaction_amount
from Transaction_Data
group by CustID, yearr_month;
    
 
 -- Indexing to speed up subsequent queries
create index idx_monthly_transactions on monthly_transactions(CustID, yearr_month);
 
 
 -- Creating a table for the previous month's transactions
create temporary table previous_month_transactions as
select
    a.CustID,
    a.yearr_month,
    a.monthly_transaction_amount,
    b.monthly_transaction_amount as previous_month_amount
from
    monthly_transactions a
    join monthly_transactions b on a.CustID = b.CustID 
    and b.yearr_month = date_format(date_sub(str_to_date(concat(a.yearr_month, '-01'), '%Y-%m-%d'), interval 1 month), '%Y-%m');
    
    
-- Indexing to speed up the next step
create index idx_previous_month_transactions on previous_month_transactions(CustID, yearr_month);


-- Creating a table for the two months ago transactions
create temporary table two_months_ago_transactions as
select
    a.CustID,
    a.yearr_month,
    a.monthly_transaction_amount,
    a.previous_month_amount,
    b.monthly_transaction_amount as two_months_ago_amount
from
    previous_month_transactions a
    join monthly_transactions b on a.CustID = b.CustID 
    and b.yearr_month = date_format(date_sub(str_to_date(concat(a.yearr_month, '-01'), '%Y-%m-%d'), interval 2 month), '%Y-%m');
    
    
-- Indexing to speed up the final step
create index idx_two_months_ago_transactions on two_months_ago_transactions(CustID, yearr_month);


-- Identifying customers with at least 3 consecutive months of increasing transactions
create temporary table consecutive_increases as
select
    CustID,
    yearr_month,
    monthly_transaction_amount,
    previous_month_amount,
    two_months_ago_amount
from
    two_months_ago_transactions
where
    monthly_transaction_amount > previous_month_amount
    and previous_month_amount > two_months_ago_amount;


-- Creating final dataset of customer IDs
create table customers_with_increasing_transactions as
select distinct
    CustID
from
    consecutive_increases;
    

select * from customers_with_increasing_transactions;    
    
