WITH delivered_orders AS (
  SELECT
    DATE_FORMAT(STR_TO_DATE(od.Created_Date, '%d.%m.%Y'), '%Y-%m-%d') AS order_date,
    od.City,
    od.Order_ID,
    opi.Payment_Method,
    DAYOFWEEK(STR_TO_DATE(od.Created_Date, '%d.%m.%Y')) - 1 AS day_of_week
  FROM
    orders_data od
    JOIN orders_payments_info opi ON od.Order_ID = opi.Order_ID
  WHERE
    od.Order_State = 'delivered'
),
delivered_orders_by_weekday AS (
  SELECT
    order_date,
    City,
    Payment_Method,
    day_of_week,
    COUNT(*) AS num_orders,
    RANK() OVER (PARTITION BY order_date, City, Payment_Method ORDER BY COUNT(*) DESC) AS order_rank
  FROM
    delivered_orders
  GROUP BY
    order_date,
    City,
    Payment_Method,
    day_of_week
),
weekdays AS (
  SELECT
    DAYOFWEEK(CONCAT('2022-01-', n)) - 1 AS day_of_week,
    DATE_FORMAT(CONCAT('2022-01-', n), '%W') AS weekday_name
  FROM
    (SELECT 0 AS n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) AS nums
),
max_orders_per_weekday AS (
  SELECT
    order_date,
    City,
    Payment_Method,
    day_of_week,
    num_orders,
    order_rank
  FROM
    delivered_orders_by_weekday
  WHERE
    order_rank = 1
)
SELECT
  DATE_FORMAT(order_date, '%Y-%m-%d') AS week_start_date,
  City,
  Payment_Method,
  MAX(CASE WHEN order_rank = 1 THEN weekday_name END) AS weekday_with_highest_orders
FROM
  max_orders_per_weekday
  JOIN weekdays ON weekdays.day_of_week = max_orders_per_weekday.day_of_week
GROUP BY
  week_start_date,
  City,
  Payment_Method
ORDER BY
  week_start_date ASC,
  City ASC,
  Payment_Method ASC;
