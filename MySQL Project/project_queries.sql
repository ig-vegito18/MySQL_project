-- 1. Complete Order Details Using Multiple JOINs

SELECT
    o.order_id,
    c.name AS customer_name,
    c.city,
    p.product_name,
    p.category,
    oi.quantity,
    p.price,
    oi.quantity * p.price AS item_total,
    o.order_status
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
ORDER BY o.order_id;

-- 2. Total Revenue by Product

SELECT
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * p.price) AS total_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;

-- 3. Total Revenue by Category

SELECT
    p.category,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * p.price) AS total_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- 4. Top Customers by Total Spending

SELECT
    c.customer_id,
    c.name,
    SUM(oi.quantity * p.price) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;

-- 5. Customers Who Have Not Placed Any Order

SELECT
    c.customer_id,
    c.name,
    c.email,
    c.city
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 6. Products That Have Never Been Ordered

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;

-- 7. Inventory Value by Category

SELECT
    category,
    SUM(price * stock) AS inventory_value
FROM products
GROUP BY category
ORDER BY inventory_value DESC;

-- 8. Top Customers Using a CTE

WITH customer_sales AS (
    SELECT
        c.customer_id,
        c.name,
        SUM(oi.quantity * p.price) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.name
)
SELECT
    customer_id,
    name,
    total_spent
FROM customer_sales
ORDER BY total_spent DESC
LIMIT 10;

-- 9. Rank Products by Revenue Using Window Function

WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity * p.price) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_id,
    product_name,
    revenue,
    RANK() OVER (ORDER BY revenue DESC) AS sales_rank
FROM product_sales;

-- 10. Products Priced Above the Average Price

SELECT
    product_id,
    product_name,
    category,
    price
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products
)
ORDER BY price DESC;

-- 11. Order Value Analysis

SELECT
    o.order_id,
    c.name AS customer_name,
    SUM(oi.quantity * p.price) AS order_value
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY o.order_id, c.name
ORDER BY order_value DESC;

-- 12. Revenue by Payment Mode

SELECT
    payment_mode,
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_amount
FROM payments
GROUP BY payment_mode
ORDER BY total_amount DESC;

-- 13. Order Status Analysis

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- 14. Low Stock Product Analysis
SELECT
    product_id,
    product_name,
    category,
    stock
FROM products
WHERE stock < 50
ORDER BY stock ASC;

-- 15. Customer Order Count

SELECT
    c.customer_id,
    c.name,
    COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_orders DESC;