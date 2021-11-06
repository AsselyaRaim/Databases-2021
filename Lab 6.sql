--Task 1
SELECT *
FROM client CROSS JOIN dealer;

SELECT d.id, d.name, c.name, c.city, s.id, s.date, s.amount
FROM dealer d INNER JOIN client c on d.id = c.dealer_id INNER JOIN sell s ON c.id = s.client_id AND d.id = s.dealer_id;

SELECT d.id, d.name, c.id, c.name
FROM client c INNER JOIN dealer d ON c.city = d.location;

SELECT s.id, s.amount, c.name, c.city
FROM sell s INNER JOIN client c ON s.client_id = c.id
WHERE s.amount BETWEEN 100 AND 500;

SELECT DISTINCT d.id, d.name
FROM dealer d LEFT JOIN client c ON d.id = c.dealer_id;

SELECT c.name, d.name, d.charge
FROM client c INNER JOIN dealer d on c.dealer_id = d.id;

SELECT c.name, c.city, d.id, d.charge
FROM client c INNER JOIN dealer d on d.id = c.dealer_id
WHERE d.charge > 0.12;

SELECT c.name, c.city, s.id, s.date, s.amount, d.name, d.charge
FROM  client c LEFT JOIN sell s ON c.id = s.client_id LEFT JOIN dealer d on s.dealer_id = d.id;

SELECT c.name, d.name, s.id, s.amount
FROM client c INNER JOIN sell s ON c.id = s.client_id INNER JOIN dealer d ON d.id = s.dealer_id
WHERE s.amount >= 2000;



--Task 2

CREATE VIEW av_purchase AS
    SELECT date, count(DISTINCT client_id) as unique_clients, avg(amount) as average_purchase, sum(amount) total_purchase
    FROM sell
    GROUP BY date;

CREATE VIEW top_five_dates AS
    SELECT date, sum(amount) total_purchase
    FROM sell
    GROUP BY date
    ORDER BY total_purchase desc LIMIT 5;

CREATE VIEW dealers_sales AS
    SELECT dealer_id, count (id), avg(amount), sum(amount)
    FROM sell
    GROUP BY dealer_id;

CREATE VIEW profit_by_location AS
    SELECT d.location, sum(s.amount * d.charge)
    FROM sell s INNER JOIN dealer d ON s.dealer_id = d.id
    GROUP BY d.location;

CREATE VIEW sales_by_location AS
    SELECT d.location, count(s.id) AS num_of_sales, avg(amount) AS avg_sale, sum(amount) AS total_sale
    FROM sell s INNER JOIN dealer d ON s.dealer_id = d.id
    GROUP BY d.location;


CREATE VIEW expenses AS
    SELECT c.city, count(s.id) AS sales_number, avg(s.amount) AS avg_expenses, sum(s.amount) AS total_expenses
    FROM client c INNER JOIN sell s ON c.id = s.client_id
    GROUP BY c.city;

CREATE VIEW expenses_more_than_sales AS
    SELECT DISTINCT expenses.city
    FROM expenses INNER JOIN sales_by_location ON expenses.city = sales_by_location.location
    WHERE expenses.total_expenses > sales_by_location.total_sale;


