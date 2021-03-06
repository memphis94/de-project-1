INSERT INTO dm_rfm_segments ("Updated Rows","Query","Finish time") VALUES
	 (0,'INSERT INTO dm_rfm_segments (user_id,recency,frequency,monetary_value)

WITH T AS(SELECT u.id,
       COUNT(CASE WHEN o2."key"=''Closed''THEN o.order_id ELSE NULL END) AS orders_count,
       COALESCE (SUM(CASE WHEN o2."key"=''Closed''THEN o."cost" ELSE NULL END),0) AS orders_sum,
       count(*) OVER ()

       FROM users u
JOIN orders o ON u.id =o.user_id 
JOIN orderstatuses o2 ON o.status = o2.id 

GROUP BY 1
ORDER BY 2),


T2 AS (SELECT u.id,
       order_ts,
       o2."key",
       MAX(order_ts) OVER () AS max_date,
       MAX(order_ts) OVER () - MIN(order_ts) OVER () AS oldest_order,
       MAX(o.order_ts) OVER (PARTITION BY u.id ORDER BY o.order_ts ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_order,
       MAX(order_ts) OVER ()-MAX(o.order_ts) OVER (PARTITION BY u.id ORDER BY o.order_ts ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS time_since_last_order,
       count(u.id) OVER ()

FROM users u
JOIN orders o ON u.id =o.user_id 
JOIN orderstatuses o2 ON o.status = o2.id 

GROUP BY 1,2,3

),

T3 AS(SELECT 
	T.id,
	orders_count,
	orders_sum,
	CASE WHEN T.orders_count>0 THEN time_since_last_order ELSE oldest_order END AS time_since_last_order,
	count(*) OVER ()
FROM T2
RIGHT JOIN T ON T2.id=T.id

GROUP BY 1,2,3,4
ORDER BY 3),

RFM AS (SELECT 
	id,
	NTILE(5) OVER (ORDER BY time_since_last_order DESC) AS "Recency",
	NTILE(5) OVER (ORDER BY orders_count) AS "Frequency",
	NTILE(5) OVER (ORDER BY orders_sum) AS "Monetary Value"
	

FROM T3
ORDER BY 2)

SELECT * FROM RFM',2022-05-01 15:49:09.000);