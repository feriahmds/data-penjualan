-- melihat sampel data pada tiap tabel

SELECT TOP 10 * FROM customers;
SELECT TOP 10 * FROM order_items;
SELECT TOP 10 * FROM orders;
SELECT TOP 10 * FROM payments;
SELECT TOP 10 * FROM products;


-- membuat tabel untuk dilakukan visualisasikan

SELECT
    oi.order_id,
    c.customer_name,
    c.country,
    p.product_name,
    p.category,
    oi.quantity,
    p.price,
    oi.quantity * p.price AS amount,
    o.order_date,
    o.status,
    py.payment_status,
    py.payment_date
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN payments py ON o.order_id = py.order_id
ORDER BY oi.order_item_id, oi.order_id;


-- mencari produk dengan keuntungan terbanyak dan peringkat dalam kategorinya

WITH sales_amount AS (
    SELECT
        p.product_name,
        p.category,
        CAST(SUM(oi.quantity * p.price) AS INT) AS amount
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN orders o ON oi.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN payments py ON o.order_id = py.order_id
    WHERE py.payment_status = 'paid'
    GROUP BY p.product_name, p.category
)
SELECT
    product_name,
    category,
    amount,
    RANK() OVER (PARTITION BY category ORDER BY amount DESC) AS rank_in_category
FROM sales_amount
ORDER BY category, product_name;


-- mencari produk yang paling banyak terjual

SELECT
    p.product_name,
    SUM(oi.quantity) AS banyak_terjual
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY banyak_terjual DESC;


-- pelanggan yang melakukan spending diatas rata-rata

WITH cte AS (
    SELECT
        oi.order_id,
        c.customer_name,
        p.product_name,
        p.category,
        oi.quantity,
        p.price,
        oi.quantity * p.price AS amount
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN orders o ON oi.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN payments py ON o.order_id = py.order_id
)
, total_per_customer AS (
    SELECT
        customer_name,
        SUM(amount) AS total_spending
    FROM cte
    GROUP BY customer_name
)
SELECT
    customer_name,
    total_spending
FROM total_per_customer
WHERE total_spending > (
    SELECT AVG(total_spending) FROM total_per_customer
)
ORDER BY total_spending DESC;


-- mencari customer yang belum pernah melakukan transaksi

SELECT
    c.customer_name,
    c.country
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
