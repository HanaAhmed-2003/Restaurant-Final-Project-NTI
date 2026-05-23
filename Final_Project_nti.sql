select *from branches
select *from customers
select *from menu
select *from orders

create database Restuarants
use Restuarants

--customers table pk
alter table customers 
alter column customer_id varchar(20) not null;

alter table customers
add constraint customers_id_PK
primary key (customer_id);

--branches table pk
alter table branches 
alter column branch_id varchar(20) not null;

alter table branches
add constraint branch_id_PK
primary key (branch_id);

--menu table pk
alter table menu 
alter column item_id varchar(20) not null;

alter table menu
add constraint item_id_PK
primary key (item_id);

--orders table pk
alter table orders 
alter column order_item_id varchar(20) not null;

alter table orders
add constraint order_id_PK
primary key (order_item_id);

--foreign keys in the orders id
alter table orders 
alter column customer_id varchar(20) not null;

alter table orders 
alter column item_id varchar(20) not null;

alter table orders 
alter column branch_id varchar(20) not null;

alter table orders
add constraint customer_id_FK
foreign key (customer_id)
references customers(customer_id)

alter table orders
add constraint item_id_FK
foreign key (item_id)
references menu(item_id)

alter table orders
add constraint branch_id_FK
foreign key (branch_id)
references branches(branch_id)

select distinct o.customer_id
from orders o
LEFT JOIN customers c
    on o.customer_id = c.customer_id
where c.customer_id IS NULL;

select distinct o.item_id
from orders o
LEFT JOIN menu c
    on o.item_id = c.item_id
where c.item_id IS NULL;

select count(order_id) #orders_id
from orders 

delete o
from orders o
LEFT JOIN customers c
    on o.customer_id = c.customer_id
where c.customer_id IS NULL;


SELECT item_id, REPLACE(item_id, ' ', '') AS cleaned_items
FROM menu
WHERE item_id LIKE '% %';

SELECT item_id, REPLACE(item_id, ' ', '') AS cleaned_items
FROM orders
WHERE item_id LIKE '% %';

UPDATE orders
SET item_id = REPLACE(item_id, ' ', '');

update orders
set item_id = replace(item_id, 'ITM01','ITEM01')

delete from orders
where item_id='ITEM99'

select *from orders
select *from customers

alter table orders
alter column quantity int

update orders
set total_sales=round(total_sales,2)

update customers
set city = replace(city,'Pariis','Paris')

update customers
set city = replace(city,'Unknown','London')

select *from branches where city = 'Pariis'

--1 Total Sales By Each City

select C.city, sum(o.total_sales) Total_Sales
from customers C
inner join orders O
on C.customer_id=O.customer_id
group by C.city
order by Total_Sales desc

--2 Maximum numbers of orders in according to the item name 

select count(O.order_id) #No_orders, M.item_name
from orders O
inner join menu M
on O.item_id=M.item_id
group by m.item_name
order by #No_orders desc

--3 most famous category in each city and country

select sum(O.quantity) Sum_Quantity, B.city , B.country , M.item_name
from orders O
inner join menu M
on O.item_id=M.item_id
inner join branches B
on O.branch_id=B.branch_id
group by B.city, B.country, M.item_name
having sum(O.quantity) = (
                          select max(A2.sum_Quantity) from
                          (
                            select sum(O2.quantity) sum_Quantity,B2.city,B2.country,M2.item_name
                            from orders O2
                            inner join menu M2
                            on O2.item_id=M2.item_id
                            inner join branches B2
                            on O2.branch_id=B2.branch_id
                            group by B2.city,B2.country,M2.item_name
                          )as A2
                          where A2.city=B.city and A2.country=B.country)
order by Sum_Quantity desc

--4 which the brand has the maximum loyal members?

select top 1 B.branch_id,B.city,B.manager, count(C.loyalty_member) #Loyalty_Members_YES
from orders O
inner join customers C
on O.customer_id=C.customer_id
inner join branches B
on O.branch_id=B.branch_id
where C.loyalty_member='Yes'
group by B.branch_id,B.city,B.manager
order by #Loyalty_Members_YES desc

--5 what is the Items of the most loyal members ?

select top 1 M.item_name,B.branch_id, B.manager,count(M.item_name) #NO_Items
from orders O
inner join Menu M
on O.item_id=M.item_id
inner join customers C
on O.customer_id=C.customer_id
inner join branches B
on B.branch_id=O.branch_id
where B.manager='Tom Jackson'
group by M.item_name,B.branch_id,B.manager
order by #NO_Items desc

--6 What is the item with the most revenue?

select round(sum(O.total_sales),2) Total_Sales,M.item_name,round(M.unit_price,2)
from orders O
inner join menu M
on O.item_id=M.item_id
group by M.item_name,M.unit_price
order by Total_Sales desc

--7 What is the most used payment method by each branch and in which city?

select O.payment_method, B.branch_id,B.city,B.manager,count(distinct O.order_id) #NO_orders
from orders O
inner join branches B
on O.branch_id=B.branch_id
group by O.payment_method, B.branch_id,B.city,B.manager
having count(O.order_id)=(select max(B2.order_id_count)
                        from (
                        select count(O3.order_id) order_id_count,
                                     B3.branch_id,
                                     B3.manager,
                                     B3.city,
                                     o.payment_method
                        from orders O3
                        inner join branches B3
                        on O3.branch_id=B3.branch_id
                        group by B3.branch_id, B3.manager,B3.city,O3.payment_method
                        )
                        as B2
                        where B.city=B2.city and B.manager=B2.manager)
order by #NO_orders Desc

--8 Do loyalty members order more frequently than non-members?

select count(distinct O.order_id) #NO_orders, C.loyalty_member
from customers C
inner join orders O
on C.customer_id=O.customer_id
group by C.loyalty_member

--9 What share of Gift Card transactions come from loyalty members?

select count(distinct O.order_id) NO_orders, 100.0*count(distinct O.order_id)/sum(count(distinct O.order_id)) over() as Percent_Of_share, C.loyalty_member
from orders O
inner join customers C
on O.customer_id=C.customer_id
where O.payment_method='Gift Card'
group by C.loyalty_member

--10 How many online, in-store and drive-thru in each branch?

select count(distinct O2.order_id) NO_orders,B2.city,B2.country,O2.purchase_type
from orders O2
inner join branches B2
on O2.branch_id=B2.branch_id
group by B2.city,B2.country,O2.purchase_type

--11 What is The top purchase_type used in each Branch?

select count(distinct O.order_id) NO_orders,O.purchase_type,B.branch_id,B.city,B.country
from orders O
inner join branches B
on O.branch_id=B.branch_id
group by O.purchase_type,B.branch_id,B.city,B.country
having count(distinct O.order_id) = (
                          select max(A3.NO_orders) from
                          (
                            select count(distinct O2.order_id) NO_orders,B2.city,B2.country,O2.purchase_type
                            from orders O2
                            inner join branches B2
                            on O2.branch_id=B2.branch_id
                            group by B2.city,B2.country,O2.purchase_type
                          )as A3
                          where A3.city=B.city and A3.country=B.country)
order by NO_orders desc