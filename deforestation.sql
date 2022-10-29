DROP VIEW IF EXISTS forestation;
CREATE VIEW forestation AS
SELECT  f_a.country_code code, 
		f_a.country_name country, 
  		f_a.year "year", 
        f_a.forest_area_sqkm forest_area_sqkm,
  		l_a.total_area_sq_mi total_area_sq_mi, 
 		r.region region,
        r.income_group income_group,
  (f_a.forest_area_sqkm / (l_a.total_area_sq_mi * 2.59))*100.0 AS percentage
FROM 	forest_area f_a, 
        land_area l_a, 
        regions r
WHERE (f_a.country_code  = l_a.country_code 
       AND f_a.year = l_a.year AND
  		r.country_code = l_a.country_code);
                

                -- GLOBAL SITUATION
-- Total forest area in 1990 and 2016
-- a and b
SELECT *
FROM forest_area
WHERE country_name = 'World'
AND (year = 2016 OR year = 1990);

-- c.
SELECT  
  current.forest_area_sqkm - former.forest_area_sqkm AS change
FROM forest_area AS current
JOIN forest_area AS former
  ON  (current.year = '2016' AND former.year = '1990'
  AND current.country_name = 'World' AND former.country_name = 'World');

-- d.
SELECT  
  (current.forest_area_sqkm - former.forest_area_sqkm)*100.0 / 
  former.forest_area_sqkm AS percent_change
FROM forest_area AS current
JOIN forest_area AS former
  ON  (current.year = '2016' AND former.year = '1990'
  AND current.country_name = 'World' AND former.country_name = 'World');
 
-- e.
SELECT country, (total_area_sq_mi * 2.59) AS total_area_sqkm
FROM forestation
WHERE year = 2016
ORDER BY total_area_sqkm DESC;

-- Regional outlook
                           
CREATE OR REPLACE VIEW regional_distr
AS
SELECT r.region,
       l.year,
       SUM(f.forest_area_sqkm) total_forest_area_sqkm,
       SUM(l.total_area_sq_mi*2.59) AS total_area_sqkm,
        (SUM(f.forest_area_sqkm)/SUM(l.total_area_sq_mi*2.59))*100 AS percent_fa_region
      FROM forest_area f
      JOIN land_area l
      ON f.country_code = l.country_code AND f.year = l.year
      JOIN regions r
      ON l.country_code = r.country_code
      GROUP BY 1,2
      ORDER BY 1,2;

SELECT ROUND(CAST(percent_fa_region AS numeric),2) AS percent_fa_region
	   FROM regional_distr
     WHERE year = 2016 AND region = 'World';
                                     
SELECT region,
       ROUND(CAST(total_area_sqkm AS NUMERIC),2) AS total_area_sqkm,
       ROUND(CAST(percent_fa_region AS NUMERIC),2) AS percent_fa_region
       FROM regional_distr
       WHERE ROUND(CAST(percent_fa_region AS NUMERIC),2) = (SELECT MAX(ROUND(CAST(percent_fa_region AS numeric),2)) AS max_percent
                                      	   					         FROM regional_distr
WHERE year = 2016)
AND year=2016;
                                                                       
                                                                       SELECT ROUND(CAST(percent_fa_region AS numeric),2) AS percent_fa_region
	   FROM regional_distr
     WHERE year = 2016 AND region = 'World';
                                     
SELECT region,
       ROUND(CAST(total_area_sqkm AS NUMERIC),2) AS total_area_sqkm,
       ROUND(CAST(percent_fa_region AS NUMERIC),2) AS percent_fa_region
       FROM regional_distr
       WHERE ROUND(CAST(percent_fa_region AS NUMERIC),2) = (SELECT MIN(ROUND(CAST(percent_fa_region AS numeric),2)) AS max_percent
                                      	   					         FROM regional_distr
WHERE year = 2016)
AND year=2016;
                                                                       
-- World forest percentage in 1990
               
SELECT ROUND(CAST(percent_fa_region AS numeric),2) AS percent_fa_region
	   FROM regional_distr
     WHERE year = 1990 AND region = 'World';                           -- Highest percent by Region in 1990
                                                                     SELECT region,
       ROUND(CAST(total_area_sqkm AS NUMERIC),2) AS total_area_sqkm,
       ROUND(CAST(percent_fa_region AS NUMERIC),2) AS percent_fa_region
       FROM regional_distr
       WHERE ROUND(CAST(percent_fa_region AS NUMERIC),2) = (SELECT MAX(ROUND(CAST(percent_fa_region AS numeric),2)) AS max_percent
                                      	   					         FROM regional_distr
WHERE year = 1990)
AND year=1990;

                                                                     ---- Lowest region 1990
SELECT region,
       ROUND(CAST(total_area_sqkm AS NUMERIC),2) AS total_area_sqkm,
       ROUND(CAST(percent_fa_region AS NUMERIC),2) AS percent_fa_region
       FROM regional_distr
       WHERE ROUND(CAST(percent_fa_region AS NUMERIC),2) = (SELECT MIN(ROUND(CAST(percent_fa_region AS numeric),2)) AS max_percent
                                      	   					         FROM regional_distr
WHERE year = 1990)
AND year=1990;
 
-- Region with decrease
-- c.
WITH t_1990 AS (SELECT * FROM regional_distr WHERE year =1990),
	   t_2016 AS (SELECT * FROM regional_distr WHERE year = 2016)
SELECT t_1990.region,
       ROUND(CAST(t_1990.percent_fa_region AS NUMERIC),2) AS fa_1990,
       ROUND(CAST(t_2016.percent_fa_region AS NUMERIC),2) AS fa_2016
    FROM t_1990
    JOIN t_2016
    ON t_1990.region = t_2016.region
    WHERE t_1990.percent_fa_region > t_2016.percent_fa_region;
                                                                     
                                                                     
                                                                     -- Country Level detail
                                                                     
WITH t_1990 AS (SELECT f.country_code,
                       f.country_name,
                       f.year,
                       f.forest_area_sqkm
FROM forest_area f
WHERE f.year = 1990 AND f.forest_area_sqkm IS NOT NULL AND f.country_name != 'World'),

t_2016 AS (SELECT f.country_code,
                  f.country_name,
                  f.year,
                  f.forest_area_sqkm
FROM forest_area f
WHERE f.year = 2016 AND f.forest_area_sqkm IS NOT NULL AND f.country_name != 'World')

SELECT t_1990.country_code,
       t_1990.country_name,
       r.region,
       t_1990.forest_area_sqkm AS fa_1990_sqkm,
       t_2016.forest_area_sqkm AS fa_2016_sqkm,
       t_1990.forest_area_sqkm-t_2016.forest_area_sqkm AS diff_fa_sqkm
FROM t_1990
JOIN t_2016
      ON t_1990.country_code = t_2016.country_code
      AND (t_1990.forest_area_sqkm IS NOT NULL AND t_2016.forest_area_sqkm IS NOT NULL)
JOIN regions r 
ON t_2016.country_code = r.country_code
ORDER BY 6 DESC
LIMIT 5;
                                                                     
-- Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?
                                                                       
WITH t_1990 AS (SELECT f.country_code,
                          f.country_name,
                          f.year,
                          f.forest_area_sqkm
	            FROM forest_area f
                          WHERE f.year = 1990 AND f.forest_area_sqkm IS NOT NULL AND f.country_name != 'World'
                     ),

      t_2016 AS (SELECT f.country_code,
                           f.country_name,
                           f.year,
                           f.forest_area_sqkm
	              FROM forest_area f
                       WHERE f.year = 2016 AND f.forest_area_sqkm IS NOT NULL AND f.country_name != 'World'
                     )

 SELECT t_1990.country_code,
        t_1990.country_name,
        r.region,
        t_1990.forest_area_sqkm AS fa_1990_sqkm,
        t_2016.forest_area_sqkm AS fa_2016_sqkm,
        t_1990.forest_area_sqkm-t_2016.forest_area_sqkm AS diff_fa_sqkm,
        ABS(ROUND(CAST(((t_2016.forest_area_sqkm-t_1990.forest_area_sqkm)/t_1990.forest_area_sqkm*100) AS NUMERIC),2)) AS perc_change
      FROM t_1990
      JOIN t_2016
      ON t_1990.country_code = t_2016.country_code
      AND (t_1990.forest_area_sqkm IS NOT NULL AND t_2016.forest_area_sqkm IS NOT NULL) JOIN regions r ON t_2016.country_code = r.country_code
      ORDER BY ROUND(CAST(((t_2016.forest_area_sqkm-t_1990.forest_area_sqkm)/t_1990.forest_area_sqkm*100) AS NUMERIC),2)
      LIMIT 5;                                                       
                                                                     
-- C.
With t1 AS (SELECT f.country_code,
                       f.country_name,
                       f.year,
                       f.forest_area_sqkm,
                       l.total_area_sq_mi*2.59 AS total_area_sqkm,
                        (f.forest_area_sqkm/(l.total_area_sq_mi*2.59))*100 AS perc_fa
                        FROM forest_area f
                        JOIN land_area l
                        ON f.country_code = l.country_code
                        AND (f.country_name != 'World' AND f.forest_area_sqkm IS NOT NULL AND l.total_area_sq_mi IS NOT NULL)
                        AND (f.year=2016 AND l.year = 2016)
                        ORDER BY 6 DESC
                  ),
      t2 AS (SELECT t1.country_code,
                        t1.country_name,
                         t1.year,
                         t1.perc_fa,
                         CASE WHEN t1.perc_fa >= 75 THEN 4
                              WHEN t1.perc_fa < 75 AND t1.perc_fa >= 50 THEN 3
                              WHEN t1.perc_fa < 50 AND t1.perc_fa >=25 THEN 2
                              ELSE 1
                         END AS percentile
                         FROM t1 ORDER BY 5 DESC
                  )

SELECT t2.percentile,
       COUNT(t2.percentile)
       FROM t2
       GROUP BY 1
       ORDER BY 2 DESC;  

-- Countries in the 4th quartile
 
                       
With t1 AS (SELECT f.country_code,
                       f.country_name,
                       f.year,
                       f.forest_area_sqkm,
                       l.total_area_sq_mi*2.59 AS total_area_sqkm,
                        (f.forest_area_sqkm/(l.total_area_sq_mi*2.59))*100 AS perc_fa
                        FROM forest_area f
                        JOIN land_area l
                        ON f.country_code = l.country_code
                        AND (f.country_name != 'World' AND f.forest_area_sqkm IS NOT NULL AND l.total_area_sq_mi IS NOT NULL)
                        AND (f.year=2016 AND l.year = 2016)
                        ORDER BY 6 DESC
                  ),
      t2 AS (SELECT t1.country_code,
                        t1.country_name,
                         t1.year,
                         t1.perc_fa,
                         CASE WHEN t1.perc_fa >= 75 THEN 4
                              WHEN t1.perc_fa < 75 AND t1.perc_fa >= 50 THEN 3
                              WHEN t1.perc_fa < 50 AND t1.perc_fa >=25 THEN 2
                              ELSE 1
                         END AS percentile
                         FROM t1 ORDER BY 5 DESC
                  )
SELECT t2.country_name,
       r.region,
       ROUND(CAST(t2.perc_fa AS NUMERIC),2) AS perc_fa,
       t2.percentile
       FROM t2
       JOIN regions r
       ON t2.country_code = r.country_code
       WHERE t2.percentile = 4
       ORDER BY 1;
                         
-- Countries higher than the US in 2016
                         
With t1 AS (SELECT f.country_code,
                       f.country_name,
                       f.year,
                       f.forest_area_sqkm,
                       l.total_area_sq_mi*2.59 AS total_area_sqkm,
                        (f.forest_area_sqkm/(l.total_area_sq_mi*2.59))*100 AS perc_fa
                        FROM forest_area f
                        JOIN land_area l
                        ON f.country_code = l.country_code
                        AND (f.country_name != 'World' AND f.forest_area_sqkm IS NOT NULL AND l.total_area_sq_mi IS NOT NULL)
                        AND (f.year=2016 AND l.year = 2016)
                        ORDER BY 6 DESC
                  )
SELECT COUNT(t1.country_name)
      FROM t1
      WHERE t1.perc_fa > (SELECT t1.perc_fa
                                     FROM t1
                                     WHERE t1.country_name = 'United States'
                              )
