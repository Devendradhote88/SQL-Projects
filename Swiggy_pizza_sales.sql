/*Basic:
Retrieve the total number of orders placed.
Calculate the total revenue generated from pizza sales.
Identify the highest-priced pizza.
Identify the most common pizza size ordered.
List the top 5 most ordered pizza types along with their quantities.*/

select count(order_id) as total_orders from orders;

select pizza_type_id, name , sum(total_price*total_qty) as revenue from 
(select p.pizza_type_id , pt.name, sum(p.price) as total_price , count(od.quantity) as total_qty from pizzas p
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
join order_details od on p.pizza_id = od.pizza_id
group by p.pizza_type_id , pt.name) as one
group by pizza_type_id ,name;

select * , dense_rank() over (order by high_price desc) as Highest_rank from 
(select pt.name ,max(p.price) as high_price from pizza_types pt 
join pizzas p on pt.pizza_type_id = p.pizza_type_id
group by  pt.name) as one ;

select size , count(size) as tsize from pizzas
group by size;

select od.pizza_id , pt.name , count(od.pizza_id) as total_quantity from order_details od 
join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pizza_id,pt.name
order by total_quantity desc 
limit 5;
