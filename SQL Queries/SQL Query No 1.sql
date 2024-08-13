-- SQL Queries No 1 :-
-- Return the Cust ID that received the 5th highest number of campaigns for the entire duration (using only the campaign data)


-- To create table named as campaign_data
create table campaign_data (
    CustID varchar(255),
    status varchar(255),
    Campaign_Exec_Date date,
    Campaign_Channel varchar(255)
    );
    
    
-- Below step loads our CSV file into the above table campaign_data
load data infile 'C:/Users/Omen/OneDrive/Documents/Final Project/wetransfer_campaign_data-csv_2024-04-13_0433/Campaign_Data.csv'
into table campaign_data
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;


-- The below query will show only one CustID with 5th highest number of campaigns.
select CustID
from (
		select CustID, COUNT(*) as campaign_count
		from campaign_data
		group by CustID
		order by campaign_count desc
		limit 1 offset 4
	) as fifth_highest_campaign;


-- If there are multiple CustID with 5th highest number of campaigns then will use distinct in our query,
-- which will give us all distinct CustID that are tied at 5th position.
select distinct CustID
from (
    select CustID,
           dense_rank() over (order by campaign_count desc) as rankk
    from (
        select CustID, COUNT(*) as campaign_count
        from campaign_data
        group by CustID
    ) as counted_campaigns
) as ranked_campaigns
where rankk = 5;