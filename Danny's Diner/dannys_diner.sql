Use dannys_dinner;


Create view  diner_loyality as(
	select s.customer_id, s.order_date, s.product_id, m.product_name, m.price, mem.join_date
    from sales s 
    join menu m 
    on s.product_id = m.product_id 
    left join members mem
    on s.customer_id = mem.customer_id
    
);

select * from diner_loyality;


select customer_id, sum(price) as total_amount	
from  diner_loyality 
group by customer_id;


select customer_id, count(distinct order_date ) as days_visit	
from sales  
group by customer_id;



select s.customer_id, s.product_id, s.product_name
from
(select *, rank() over (partition by customer_id order by order_date) as rn
from diner_loyality) s
where rn = 1;



select product_name , count(customer_id) as no_of_purchase
from diner_loyality
group by 1
order by 2 desc
limit 1;


select distinct customer_id, product_name
from (select *, rank() over(partition by customer_id order by product_count desc) as rn
from
(select customer_id,product_name, count(product_name) over(partition by customer_id, product_name) as product_count
from diner_loyality)s ) final
where rn = 1;




select s.customer_id, s.product_name
from
(select *, rank() over(partition by customer_id order by order_date) as rn
from diner_loyality
where order_date >= join_date) s 
where rn =1;




select s.customer_id, s.product_name
from
(select *, rank() over(partition by customer_id order by order_date desc) as rn
from diner_loyality
where order_date < join_date) s 
where rn =1;




select customer_id, count(product_id) as total_item, sum(price) as amount_spent
from diner_loyality
where order_date < join_date
group by 1
order by 1;



select customer_id,
	sum(case when product_name = 'sushi' then price * 20
    else price * 10
    end )as points
from diner_loyality
group by 1;
    
    


select customer_id,
	sum(case when order_date between join_date and date_add(join_date, interval 6 day)  or product_name = 'sushi'
			then price*20
			else price*10 end
    ) as points
from diner_loyality
where order_date >= join_date and extract(month from order_date) = 1
group by 1
order by 1;

