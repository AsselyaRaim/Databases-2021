--QUERIES
--20 top-selling products at each store

SELECT store_id,product_id, p.name
FROM store_statistics s INNER JOIN products p on p.id = s.product_id
WHERE s.store_id = 1
ORDER BY s.quantity desc LIMIT 20;

--The 20 top-selling products in each state (city)
SELECT st.city, ss.product_id, p.name
FROM store_statistics ss INNER JOIN products p on ss.product_id = p.id INNER JOIN stores st on ss.store_id = st.id
WHERE st.city = 'Almaty'
ORDER BY ss.quantity desc LIMIT 20;

--The 5 stores with the most sales so far this year
SELECT o.store_id, sum(oi.quantity) as sales_count
FROM orders o INNER JOIN order_items oi on o.id = oi.order_id
WHERE o.made_on >= '2021-01-01'
GROUP BY o.store_id
ORDER BY sales_count desc LIMIT 5;

--In how many stores does Coke outsell Pepsi? (for example 2 Gingerale - Diet - Schweppes, 3 Juice - Clam, 46 Oz)
SELECT s1.store_id, s1.quantity, s2.quantity
FROM (SELECT store_id, quantity FROM store_statistics WHERE product_id = 3) s1 INNER JOIN
    (SELECT store_id, quantity FROM store_statistics WHERE product_id = 2) s2 on s1.store_id = s2.store_id
WHERE s1.quantity > s2.quantity;

--What are the top 3 types of product that customers buy in addition to milk? (for example 66 Leeks - Baby, White)
select product_id, count(product_id) as number from order_items where order_id in(
SELECT o.id
FROM order_items INNER JOIN orders o on o.id = order_items.order_id
WHERE product_id = 66)
GROUP BY product_id
ORDER BY number desc LIMIT 3 OFFSET 1;

