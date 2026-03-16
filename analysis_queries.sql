-- =====================================================
-- Food Delivery Delay Analysis Project
-- Tools Used: PostgreSQL + Power BI
-- Objective: Analyze delivery delays based on distance,
-- traffic, weather, peak hours, and city performance
-- =====================================================

-- Create Database
CREATE DATABASE food_delivery_analysis;

-- =====================================================
-- Create Table
-- =====================================================

CREATE TABLE deliveries (
    order_id INT,
    city VARCHAR(50),
    distance_km DECIMAL(5,2),
    order_time TIME,
    delivery_time_min INT,
    weather VARCHAR(20),
    traffic_level VARCHAR(20),
    rider_id VARCHAR(20),
    restaurant_prep_time INT
);

-- =====================================================
-- Import CSV File
-- =====================================================

COPY deliveries
FROM 'D:/Food-Delivery-Delay-Analysis/food_delivery_data.csv'
DELIMITER ','
CSV HEADER;

-- =====================================================
-- Basic Data Exploration
-- =====================================================

-- View data
SELECT * FROM deliveries;

-- Total Orders
SELECT COUNT(*) AS total_orders
FROM deliveries;

-- Average Delivery Time
SELECT AVG(delivery_time_min) AS avg_delivery_time
FROM deliveries;

-- =====================================================
-- City Performance Analysis
-- =====================================================

-- Average delivery time by city
SELECT city,
AVG(delivery_time_min) AS avg_delivery_time
FROM deliveries
GROUP BY city
ORDER BY avg_delivery_time DESC;

-- Cities with highest delays
SELECT city,
COUNT(*) AS delayed_orders
FROM deliveries
WHERE delivery_time_min > 40
GROUP BY city
ORDER BY delayed_orders DESC;

-- Cities with longest delivery distance
SELECT city,
AVG(distance_km) AS avg_distance
FROM deliveries
GROUP BY city
ORDER BY avg_distance DESC;

-- =====================================================
-- Weather Impact Analysis
-- =====================================================

SELECT weather,
COUNT(*) AS total_orders,
AVG(delivery_time_min) AS avg_delivery_time
FROM deliveries
GROUP BY weather
ORDER BY avg_delivery_time DESC;

-- =====================================================
-- Traffic Impact Analysis
-- =====================================================

SELECT traffic_level,
COUNT(*) AS total_orders,
AVG(delivery_time_min) AS avg_delivery_time
FROM deliveries
GROUP BY traffic_level
ORDER BY avg_delivery_time DESC;

-- Weather + Traffic combined impact
SELECT weather,
traffic_level,
COUNT(*) AS total_orders,
AVG(delivery_time_min) AS avg_delivery_time
FROM deliveries
GROUP BY weather, traffic_level
ORDER BY avg_delivery_time DESC;

-- =====================================================
-- Peak Hour Analysis
-- =====================================================

SELECT EXTRACT(HOUR FROM order_time) AS order_hour,
COUNT(*) AS total_orders,
AVG(delivery_time_min) AS avg_delivery_time
FROM deliveries
GROUP BY order_hour
ORDER BY order_hour;

-- Peak vs Non-Peak classification
SELECT
CASE
WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 14 THEN 'Lunch Peak'
WHEN EXTRACT(HOUR FROM order_time) BETWEEN 19 AND 22 THEN 'Dinner Peak'
ELSE 'Non Peak'
END AS time_category,
COUNT(*) AS total_orders,
AVG(delivery_time_min) AS avg_delivery_time
FROM deliveries
GROUP BY time_category;

-- =====================================================
-- Distance Analysis
-- =====================================================

-- Distance vs delivery time
SELECT distance_km,
delivery_time_min
FROM deliveries
ORDER BY distance_km;

-- Distance category analysis
SELECT
CASE
WHEN distance_km < 3 THEN 'Short Distance'
WHEN distance_km BETWEEN 3 AND 6 THEN 'Medium Distance'
ELSE 'Long Distance'
END AS distance_category,
COUNT(*) AS total_orders,
AVG(delivery_time_min) AS avg_delivery_time
FROM deliveries
GROUP BY distance_category;

-- =====================================================
-- Delivery Performance Classification
-- =====================================================

SELECT order_id,
delivery_time_min,
CASE
WHEN delivery_time_min <= 25 THEN 'Fast'
WHEN delivery_time_min BETWEEN 26 AND 40 THEN 'Moderate'
ELSE 'Delayed'
END AS delivery_status
FROM deliveries;

-- =====================================================
-- Top Deliveries Analysis
-- =====================================================

-- Top 10 longest deliveries
SELECT order_id, city, distance_km, delivery_time_min
FROM deliveries
ORDER BY delivery_time_min DESC
LIMIT 10;

-- =====================================================
-- Rider Performance Analysis
-- =====================================================

SELECT rider_id,
COUNT(*) AS total_orders,
AVG(delivery_time_min) AS avg_delivery_time
FROM deliveries
GROUP BY rider_id
ORDER BY avg_delivery_time
LIMIT 10;

-- =====================================================
-- Subquery Analysis
-- =====================================================

-- Orders slower than average
SELECT *
FROM deliveries
WHERE delivery_time_min >
(
SELECT AVG(delivery_time_min)
FROM deliveries
);

-- =====================================================
-- Window Function Analysis
-- =====================================================

-- City ranking based on delivery performance
SELECT city,
AVG(delivery_time_min) AS avg_delivery_time,
RANK() OVER(ORDER BY AVG(delivery_time_min)) AS city_rank
FROM deliveries
GROUP BY city;

-- Running average delivery time
SELECT order_id,
delivery_time_min,
AVG(delivery_time_min) OVER(ORDER BY order_id) AS running_avg_delivery
FROM deliveries;

-- =====================================================
-- Restaurant Preparation Impact
-- =====================================================

SELECT restaurant_prep_time,
AVG(delivery_time_min) AS avg_delivery_time
FROM deliveries
GROUP BY restaurant_prep_time
ORDER BY restaurant_prep_time;

-- =====================================================
-- End of SQL Analysis
-- =====================================================