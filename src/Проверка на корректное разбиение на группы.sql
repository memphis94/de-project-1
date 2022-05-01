INSERT INTO "SELECT monetary_value ,
       COUNT(user_id)
FROM dm_rfm_segments drs 
GROUP BY 1" (monetary_value,count) VALUES
	 (1,200),
	 (3,200),
	 (5,200),
	 (4,200),
	 (2,200);