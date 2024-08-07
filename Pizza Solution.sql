create database if not exists pizzahut;
use pizzahut;
create table orders(
order_id int primary key,
order_date date not null,
order_time time not null
);

create table order_details(
order_details_id int primary key,
order_id int not null,
pizza_id text not null,
quantity int not null
);


-- Calculate the total revenue generated from pizza sales.
select round(sum(order_details.quantity * pizzas.price),2) as Revenue 
from pizzas join order_details 
on pizzas.pizza_id = order_details.pizza_id;

-- Identify the most common pizza size ordered
select pizzas.size, count(order_details.order_details_id) as Common_pizzas 
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size order by  count(order_details.order_details_id) desc 
limit 1;

-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name, count(order_details.order_details_id) as Most_ordered 
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.name order by  count(order_details.order_details_id) desc 
limit 5;

-- Determine the distribution of orders by hour of the day.
select hour(order_time) as Hour, count(order_id) as orders from pizzahut.orders
group by hour(order_time); 


-- Group the orders by date and calculate the average number of pizzas ordered per day.
select order_date, count(order_id) from pizzahut.orders
group by order_date;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.name, sum(order_details.quantity) as total_quantity
from pizzas join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name order by  count(order_details.quantity) desc ;


-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue
select pizza_types.category,
round (sum(order_details.quantity*pizzas.price) / (SELECT ROUND(SUM(order_details.quantity* pizzas.price),2) AS total_sales
from 
order_details
JOIN
pizzas ON pizzas.pizza_id=order_details.pizza_id)*100,2) as revenue
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category order by revenue desc;


-- Analyze the cumulative revenue generated over time.
select order_date,
sum(revenue) over (order by order_date) as cum_revenue
from
(select orders.order_date,
sum(order_details.quantity* pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;
