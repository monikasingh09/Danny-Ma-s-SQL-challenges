# <h1 align="center" > 🍜 Case Study #1: Danny's Diner 🍜 
 
<p align="center">
<kbd>  <img src="https://8weeksqlchallenge.com/images/case-study-designs/1.png" alt="Image" width="450" height="450"></kbd>

## 📚 Table of Contents
- [Question and Solution](#question-and-solution)

## 🤔Question and Solution 

🔖 Creating a view for the whole data make it easier to visualize the data and explore to an extent. The advantages of creating views in SQL in a concise manner:

- Simplification: Views simplify complex queries, making it easier for developers to access and manipulate data.

- Security: Views enhance data security by controlling who can access specific data, without affecting underlying tables.

- Performance: Views can improve query performance by storing results and optimizing SQL execution plans.

- Maintenance: Views ease database maintenance by isolating changes and providing code reusability.

```sql
Create view  diner_loyality as(
	select s.customer_id, s.order_date, s.product_id, m.product_name, m.price, mem.join_date
    from sales s 
    join menu m 
    on s.product_id = m.product_id 
    left join members mem
    on s.customer_id = mem.customer_id
    
);

```

### Output:
![image](https://github.com/user-attachments/assets/88df83b3-cc13-4347-92e0-7d44897d7681)

***

**Q-1. What is the total amount each customer spent at the restaurant?**

```sql
select customer_id, sum(price) as total_amount	
from  diner_loyality 
group by customer_id;
```


#### Output:

![image](https://github.com/user-attachments/assets/104e1ad8-fb9a-47d7-be6f-5449c2d58f75)


#### Insights:

- Customer A spent 76.
- Customer B spent 74.
- Customer C spent 36.

*** 

**Q-2. How many days has each customer visited the restaurant?**

```sql
select customer_id, count(distinct order_date ) as days_visit	
from sales  
group by customer_id;


```

#### Steps:
- To determine the unique number of visits for each customer, utilize **COUNT(DISTINCT `order_date`)**.
- It's important to apply the **DISTINCT** keyword while calculating the visit count to avoid duplicate counting of days. For instance, if Customer A visited the restaurant twice on '2021–01–07', counting without **DISTINCT** would result in 2 days instead of the accurate count of 1 day.

#### Output:
![image](https://github.com/user-attachments/assets/3ceda15f-efb5-46c3-9177-27a1205f8d3d)

#### Insights:

- Customer A visited 4 times.
- Customer B visited 6 times.
- Customer C visited 2 times.

***

**Q-3. What was the first item from the menu purchased by each customer?**

```sql
select s.customer_id, s.product_id, s.product_name
from
(select *, rank() over (partition by customer_id order by order_date) as rn
from diner_loyality) s
where rn = 1;

```
#### Steps:
- Create a Subquery, create a new column `rank` as rn and calculate the row number using **RANK()** window function. The **PARTITION BY** clause divides the data by `customer_id`, and the **ORDER BY** clause orders the rows within each partition by `order_date`.
- In the outer query, select the appropriate columns and apply a filter in the **WHERE** clause to retrieve only the rows where the rank column equals 1, which represents the first row within each `customer_id` partition.


#### Output: 
![image](https://github.com/user-attachments/assets/c4b0a909-2bbf-4327-85f4-5d4f63eb163c)


#### Insights:

- Customer A placed an order for both curry and sushi simultaneously, making them the first items in the order.
- Customer B's first order is curry.
- Customer C's first order is ramen.


***

**Q-4. What is the most purchased item on the menu and how many times was it purchased by all customers?**

```sql
select product_name , count(customer_id) as no_of_purchase
from diner_loyality
group by 1
order by 2 desc
limit 1;

```

#### Steps:
- Perform **GROUP BY** on product_name and  **COUNT** aggregation on the `customer_id` column and **ORDER BY** the result in descending order using `no_of_purchase` column.
- Apply the **LIMIT** 1 clause to filter and retrieve the highest number of purchased items.

#### Output: 
![image](https://github.com/user-attachments/assets/e93cd275-b778-4bce-b652-08887ff2f674)

#### Insights:

- Most purchased item on the menu is ramen which is 8 times. Yummy! it seems 😋

***

**Q-5. Which item was the most popular for each customer?**

```sql
select distinct customer_id, product_name
from (select *, rank() over(partition by customer_id order by product_count desc) as rn
from
(select customer_id,product_name, count(product_name) over(partition by customer_id, product_name) as product_count
from diner_loyality)s ) final
where rn = 1;

```
*Each user may have more than 1 favourite item.*

#### Steps:
- Utilize the **RANK()** window function to calculate the ranking of each `customer_id` partition based on the count of orders **COUNT(`product_name`)** in descending order.
- In the outer query, select the appropriate columns and apply a filter in the **WHERE** clause to retrieve only the rows where the rank column equals 1, representing the rows with the highest order count for each customer.

#### Output: 
![image](https://github.com/user-attachments/assets/cd3e6193-ce26-4cfb-9b53-a8e1cced31bc)

#### Insights:

- Customer A and C's favourite item is ramen.🍜
- Customer B enjoys all items on the menu. A true foodie, i guess 🤣.

***

**Q-6. Which item was purchased first by the customer after they became a member?**

```sql
select s.customer_id, s.product_name
from
(select *, rank() over(partition by customer_id order by order_date) as rn
from diner_loyality
where order_date >= join_date) s 
where rn =1;

```

#### Steps:

- Utilize the **RANK()** window function to calculate the ranking of each `customer_id` partition based on the date of orders  in ascending order.
- In **WHERE** clause, we use `order_date` greater than or equal to `join_date`
- In the outer query, select the appropriate columns and apply a filter in the **WHERE** clause to retrieve only the rows where the rank column equals 1, representing the rows with the first ordered item for each customer.

#### Output: 
![image](https://github.com/user-attachments/assets/308a37e6-e8e8-4ba8-b2f9-117f93092145)

#### Insights:

- Customer A bought `Curry` as the first item on the day of becoming a member.
- Customer B bought `Sushi` as the first item 2 days after becoming a member.
- Customer C didn't become the member.

***

### Q-7. Which item was purchased just before the customer became a member?

```sql
select s.customer_id, s.product_name
from
(select *, rank() over(partition by customer_id order by order_date desc) as rn
from diner_loyality
where order_date < join_date) s 
where rn =1;
```

#### Steps:
 
- Utilize the **RANK()** window function to calculate the ranking of each `customer_id` partition based on the date of orders .
- In **WHERE** clause, we use `order_date` less than `join_date`
- In the outer query, select the appropriate columns and apply a filter in the **WHERE** clause to retrieve only the rows where the rank column equals 1, representing the rows with the ordered item before becoming a member for each customer.


#### Output: 
![image](https://github.com/user-attachments/assets/5466fe55-9e96-48f4-9e9b-e289a94f4cd4)

#### Insights:

- Customer A bought `Curry & Sushi` as the *item_bought* before becoming a member.
- Customer B bought `Sushi` as the *item_bought* before becoming a member.
- Customer C didn't become the member.

***

### Q-8. What is the total items and amount spent for each member before they became a member?

```sql
select customer_id, count(product_id) as total_item, sum(price) as amount_spent
from diner_loyality
where order_date < join_date
group by 1
order by 1;
```
#### Steps:
- In **WHERE** clause, we use `order_date` less than `join_date`
- In the outer query, select the appropriate columns with **count**`product_id` with **sum**`price` as *total_cost* representing the rows with the ordered items count with amount spent before becoming a member for each customer.

#### Output: 
![image](https://github.com/user-attachments/assets/4c6c3001-9a4a-480a-9ea6-4e2fb148911e)

#### Insights:

Before becoming members,
- Customer A spent $25 on 2 items.
- Customer B spent $40 on 3 items.

***

**Q-9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?**

```sql
select customer_id,
	sum(case when product_name = 'sushi' then price * 20
    else price * 10
    end )as points
from diner_loyality
group by 1;
   
```

#### Steps:
Let's break down the question to understand the point calculation for each customer's purchases.
- Each $1 spent = 10 points. However, `product_name`  sushi gets 2x points, so each $1 spent = 20 points.
- Here's how the calculation is performed using a conditional CASE statement:
	- If product_name = sushi, multiply every $1 by 20 points.
	- Otherwise, multiply $1 by 10 points.
- Then, calculate the total points for each customer.

#### Output: 
![image](https://github.com/user-attachments/assets/51612ac6-63c1-45fc-9ecb-75f163eefd89)

#### Insights:

- Total points for Customer A is $860.
- Total points for Customer B is $940.
- Total points for Customer C is $360.

***

**Q-10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?**

```sql

select customer_id,
	sum(case when order_date between join_date and date_add(join_date, interval 6 day)  or product_name = 'sushi'
			then price*20
			else price*10 end
    ) as points
from diner_loyality
where order_date >= join_date and extract(month from order_date) = 1
group by 1
order by 1;
```

#### Assumptions:
- From Day 1 to Day 7 (the first week of membership), each $1 spent for any items earns 20 points.
- From Day 8 to the last day of January 2021, each $1 spent earns 10 points. However, sushi continues to earn double the points at 20 points per $1 spent.

#### Steps:

- In the query, calculate the points by using a `CASE` statement to determine the points based on our assumptions above. 
- If the `product_name` is 'sushi'or orders placed between `join_date` and `interval 6 day` (i.e the first week of memebership)  multiply the price by 20. 
- For all other products, multiply the price by 10.
- Calculate the sum of points for each customer.

#### Output: 
![image](https://github.com/user-attachments/assets/54e3768d-62bd-4e8e-b9d1-a60e49a3b909)

#### Insights:

- Total points for Customer A is 1,020.
- Total points for Customer B is 320.

***

