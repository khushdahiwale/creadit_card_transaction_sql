select *
from credit_card_transcations

1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

with cte1 as 
(select city,sum(amount) as spends
from credit_card_transcations
group by city
),
total_amount as 
( select sum(amount) as total_amount 
from credit_card_transcations
)
select top 5 c.city as city,c.spends as spends,
ROUND((c.spends/t.total_amount)*100,2) as percentage_contribution
from cte1 c
inner join total_amount t
on 1=1
order by spends desc

2- write a query to print highest spend month and amount spent in that month for each card type

with cte as 
(select card_type,datepart(year,transaction_date) as year,
datepart(month,transaction_date) as month,sum(amount) as amount
from credit_card_transcations
group by card_type,datepart(year,transaction_date),datepart(month,transaction_date)
) 
select * from (select *, rank() over(partition by card_type order by amount desc) as rn
from cte) a where rn=1


3- write a query to print the transaction details(all columns from the table) for each card type when
it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)

with cte as (
select *,
sum(amount) over(partition by card_type order by transaction_date,transaction_id) as total_spend
from credit_card_transcations
) 
select * from 
(
select *,rank() over(partition by card_type order by total_spend desc) as rn
from cte
where total_spend >=1000000
) a
where rn = 1

4- write a query to find city which had lowest percentage spend for gold card type

select * from credit_card_transcations

with cte as (
select top 1 city,card_type,sum(amount) as amount
,sum(case when card_type='Gold' then amount end) as gold_amount
from credit_card_transcations
group by city,card_type)
select 
city,sum(gold_amount)*1.0/sum(amount) as gold_ratio
from cte
group by city
having count(gold_amount) > 0 and sum(gold_amount)>0
order by gold_ratio;

5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

select * from credit_card_transcations

with cte as (
select city,exp_type,sum(amount) as total_amount
from credit_card_transcations
group by city,exp_type
)
select
city , max(case when lowest_expense_type=1 then exp_type end) as lowest_exp_type
, min(case when highest_expense_type=1 then exp_type end) as highest_exp_type
from
 (
select *,
rank() over(partition by city order by total_amount desc) as highest_expense_type,
rank() over(partition by city order by total_amount asc) as lowest_expense_type
from cte 
) a
group by city;


6- write a query to find percentage contribution of spends by females for each expense type

select * from credit_card_transcations

with cte as(
select exp_type,sum(amount) as total_amount
from credit_card_transcations
group by exp_type
),
total_spend as
(select sum(case when gender='F' then amount else 0 end) as spend
from credit_card_transcations
)
select exp_type,ROUND((spend/total_amount)*1.0 ,2) as percentage_contribution
from cte c
inner join total_spend t
on 1=1
order by percentage_contribution desc

7- which card and expense type combination saw highest month over month growth in Jan-2014

select * from credit_card_transcations

with cte as (
select card_type,exp_type,datepart(year,transaction_date) as year,
datepart(month,transaction_date) as month,sum(amount) as total_amount
from credit_card_transcations
group by card_type,exp_type,datepart(year,transaction_date),
datepart(month,transaction_date)
)
select top 1 *,total_amount-prev as mom
from
(
select *,lag(total_amount,1) over(partition by card_type,exp_type order by year,month) as prev
from cte
) a
where year = 2014 and month = 1
order by mom desc;

9- during weekends which city has highest total spend to total no of transcations ratio 

select city , sum(amount)*1.0,count(1) as ratio
from credit_card_transcations
group by city
order by ratio desc;

--8- during weekends which city has highest total spend to total no of transcations ratio 

select top 1 city , sum(amount)*1.0/count(*) as ratio
from credit_card_transcations
where datepart(weekday,transaction_date) in (1,7)
group by city
order by ratio desc;


10- which city took least number of days to reach its 500th transaction after the first transaction in that city

select * from credit_card_transcations

with cte as (
select *
,row_number() over(partition by city order by transaction_date,transaction_id) as rn
from credit_card_transcations)
select top 1 city,datediff(day,min(transaction_date),max(transaction_date)) as datediff1
from cte
where rn=1 or rn=500
group by city
having count(1)=2
order by datediff1 











