-- Zomato Food Delivery Analytics Project
-- SQL Portfolio Analysis
-- Database: zomato_analytics

USE zomato_analytics;

-- 1. Overall Business Summary
SELECT
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    COUNT(DISTINCT o.Customer_ID) AS Total_Customers,
    COUNT(DISTINCT o.Restaurant_ID) AS Total_Restaurants,
    ROUND(SUM(p.Final_Amount), 2) AS Total_Revenue
FROM orders o
JOIN payments p
    ON o.Order_ID = p.Order_ID
WHERE p.Payment_Status = 'Paid';

-- 2. Top 10 Restaurants by Revenue
SELECT
    r.Restaurant_Name,
    r.City,
    ROUND(SUM(p.Final_Amount), 2) AS Total_Revenue
FROM orders o
JOIN restaurants r
    ON o.Restaurant_ID = r.Restaurant_ID
JOIN payments p
    ON o.Order_ID = p.Order_ID
WHERE p.Payment_Status = 'Paid'
GROUP BY
    r.Restaurant_ID,
    r.Restaurant_Name,
    r.City
ORDER BY Total_Revenue DESC
LIMIT 10;

-- 3. Revenue by Cuisine
SELECT
    r.Cuisine,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    ROUND(SUM(p.Final_Amount), 2) AS Total_Revenue
FROM orders o
JOIN restaurants r
    ON o.Restaurant_ID = r.Restaurant_ID
JOIN payments p
    ON o.Order_ID = p.Order_ID
WHERE p.Payment_Status = 'Paid'
GROUP BY r.Cuisine
ORDER BY Total_Revenue DESC;

-- 4. Monthly Revenue Trend
SELECT
    DATE_FORMAT(o.Order_Date, '%Y-%m') AS Month,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    ROUND(SUM(p.Final_Amount), 2) AS Total_Revenue
FROM orders o
JOIN payments p
    ON o.Order_ID = p.Order_ID
WHERE p.Payment_Status = 'Paid'
GROUP BY DATE_FORMAT(o.Order_Date, '%Y-%m')
ORDER BY Month;

-- 5. Top 3 Restaurants in Each City by Revenue
WITH RestaurantRevenue AS (
    SELECT
        r.City,
        r.Restaurant_ID,
        r.Restaurant_Name,
        SUM(p.Final_Amount) AS Revenue
    FROM restaurants r
    JOIN orders o
        ON r.Restaurant_ID = o.Restaurant_ID
    JOIN payments p
        ON o.Order_ID = p.Order_ID
    WHERE p.Payment_Status = 'Paid'
    GROUP BY
        r.City,
        r.Restaurant_ID,
        r.Restaurant_Name
),

RankedRestaurants AS (
    SELECT
        City,
        Restaurant_Name,
        Revenue,
        DENSE_RANK() OVER (
            PARTITION BY City
            ORDER BY Revenue DESC
        ) AS Revenue_Rank
    FROM RestaurantRevenue
)

SELECT
    City,
    Restaurant_Name,
    ROUND(Revenue, 2) AS Revenue,
    Revenue_Rank
FROM RankedRestaurants
WHERE Revenue_Rank <= 3
ORDER BY City, Revenue_Rank;