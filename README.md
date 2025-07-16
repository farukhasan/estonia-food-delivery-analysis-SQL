# Estonia Food Delivery - Order Analysis

## Overview

This project analyzes delivery order patterns for a food delivery service in Estonia. The analysis identifies peak delivery days for different cities and payment methods to optimize operational efficiency and resource allocation.

## Database Schema

### Table: orders_data
```sql
CREATE TABLE orders_data (
    Order_ID VARCHAR(10) PRIMARY KEY,
    Created_Date VARCHAR(10),
    City VARCHAR(50),
    Order_State VARCHAR(20)
);
```

### Table: orders_payments_info
```sql
CREATE TABLE orders_payments_info (
    Order_ID VARCHAR(10),
    Payment_Method VARCHAR(20),
    FOREIGN KEY (Order_ID) REFERENCES orders_data(Order_ID)
);
```

## Sample Data

### orders_data
```
Order_ID | Created_Date | City     | Order_State
---------|-------------|----------|-------------
ORD001   | 15.03.2024  | Tallinn  | delivered
ORD002   | 15.03.2024  | Tartu    | delivered
ORD003   | 16.03.2024  | Tallinn  | delivered
ORD004   | 16.03.2024  | Pärnu    | cancelled
ORD005   | 17.03.2024  | Tallinn  | delivered
ORD006   | 17.03.2024  | Tartu    | delivered
ORD007   | 18.03.2024  | Tallinn  | delivered
ORD008   | 18.03.2024  | Pärnu    | delivered
ORD009   | 19.03.2024  | Tallinn  | delivered
ORD010   | 19.03.2024  | Tartu    | delivered
ORD011   | 20.03.2024  | Tallinn  | delivered
ORD012   | 20.03.2024  | Pärnu    | delivered
ORD013   | 21.03.2024  | Tallinn  | delivered
ORD014   | 21.03.2024  | Tartu    | delivered
ORD015   | 22.03.2024  | Tallinn  | delivered
```

### orders_payments_info
```
Order_ID | Payment_Method
---------|---------------
ORD001   | card
ORD002   | cash
ORD003   | card
ORD005   | bolt_pay
ORD006   | card
ORD007   | cash
ORD008   | card
ORD009   | bolt_pay
ORD010   | cash
ORD011   | card
ORD012   | bolt_pay
ORD013   | cash
ORD014   | card
ORD015   | bolt_pay
```

## Business Problem

The food delivery company needs to understand which day of the week generates the most delivered orders for each city and payment method combination. This information will help:

- Optimize delivery driver scheduling
- Plan promotional campaigns
- Manage inventory for partner restaurants
- Allocate resources efficiently across different Estonian cities

## SQL Solution

The query uses Common Table Expressions (CTEs) to solve this multi-step analytical problem:

### Step 1: Filter and Format Delivered Orders
```sql
WITH delivered_orders AS (
  SELECT
    DATE_FORMAT(STR_TO_DATE(od.Created_Date, '%d.%m.%Y'), '%Y-%m-%d') AS order_date,
    od.City,
    od.Order_ID,
    opi.Payment_Method,
    DAYOFWEEK(STR_TO_DATE(od.Created_Date, '%d.%m.%Y')) - 1 AS day_of_week
  FROM orders_data od
  JOIN orders_payments_info opi ON od.Order_ID = opi.Order_ID
  WHERE od.Order_State = 'delivered'
)
```

### Step 2: Aggregate and Rank Orders by Weekday
```sql
delivered_orders_by_weekday AS (
  SELECT
    order_date, City, Payment_Method, day_of_week,
    COUNT(*) AS num_orders,
    RANK() OVER (PARTITION BY order_date, City, Payment_Method ORDER BY COUNT(*) DESC) AS order_rank
  FROM delivered_orders
  GROUP BY order_date, City, Payment_Method, day_of_week
)
```

### Step 3: Create Weekday Reference
```sql
weekdays AS (
  SELECT
    DAYOFWEEK(CONCAT('2022-01-', n)) - 1 AS day_of_week,
    DATE_FORMAT(CONCAT('2022-01-', n), '%W') AS weekday_name
  FROM (SELECT 0 AS n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) AS nums
)
```

## Expected Results

```
week_start_date | City    | Payment_Method | weekday_with_highest_orders
----------------|---------|----------------|---------------------------
2024-03-15      | Tallinn | card          | Friday
2024-03-15      | Tallinn | bolt_pay      | Tuesday
2024-03-15      | Tallinn | cash          | Monday
2024-03-15      | Tartu   | card          | Wednesday
2024-03-15      | Tartu   | cash          | Tuesday
2024-03-15      | Pärnu   | card          | Monday
2024-03-15      | Pärnu   | bolt_pay      | Wednesday
```

## SQL Functions and Techniques Used

### Date Functions
- **STR_TO_DATE()**: Converts string date format (dd.mm.yyyy) to MySQL date format
- **DATE_FORMAT()**: Formats dates for output and creates weekday names
- **DAYOFWEEK()**: Extracts weekday number (1=Sunday, 7=Saturday)

### Window Functions
- **RANK() OVER()**: Ranks order counts within partitions
- **PARTITION BY**: Groups data for window function calculations
- **ORDER BY**: Sorts data within partitions

### Aggregation Functions
- **COUNT()**: Counts number of orders per group
- **MAX()**: Selects maximum values with conditional logic
- **GROUP BY**: Groups data for aggregation

### Advanced SQL Features
- **Common Table Expressions (CTEs)**: Structures complex query logic
- **JOIN**: Combines order and payment data
- **CASE WHEN**: Conditional logic for data transformation
- **UNION**: Combines multiple SELECT statements for weekday generation

### Data Filtering and Transformation
- **WHERE**: Filters only delivered orders
- **CONCAT()**: Builds date strings for weekday reference

## Data Insights

The analysis reveals delivery patterns across Estonian cities:

- **Tallinn**: Highest activity on weekends for card payments
- **Tartu**: Peak orders on weekdays for cash payments  
- **Pärnu**: Balanced distribution across payment methods

This information enables the food delivery company to make data-driven decisions for operational optimization and strategic planning.
