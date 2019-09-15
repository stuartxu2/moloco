/*Q1: Consider only the rows with country_id = "BDV" (there are 844 such rows).
For each site_id, we can compute the number of unique user_id's found in these
844 rows. Which site_id has the largest number of unique users? And what's the
number?
*/
SELECT site_id, COUNT(DISTINCT user_id) AS unique_user_num
FROM `stuart-251306.moloch_exercise.visits`
WHERE country_id = 'BDV'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1


/*Q2:
Between 2019-02-03 00:00:00 and 2019-02-04 23:59:59, there are four users who
visited a certain site more than 10 times. Find these four users & which sites
they (each) visited more than 10 times. (Simply provides four triples in the
form (user_id, site_id, number of visits) in the box below.)
*/

SELECT user_id, site_id, COUNT(1) AS number_of_visits
FROM `stuart-251306.moloch_exercise.visits`
WHERE ts >= '2019-02-03 00:00:00' AND ts <= '2019-02-04 23:59:59' --subquerry to get a new table Between 2019-02-03 00:00:00 and 2019-02-04 23:59:59
GROUP BY 2, 1
HAVING number_of_visits > 10
ORDER BY 3 DESC


/*Q3:
For each site, compute the unique number of users whose last visit (found in the
original data set) was to that site. For instance, user "LC3561"'s last visit is
to "N0OTG" based on timestamp data. Based on this measure, what are top three
sites? (hint: site "3POLC" is ranked at 5th with 28 users whose last visit in
the data set was to 3POLC; simply provide three pairs in the form (site_id,
number of users).)
*/
WITH t1 AS (
SELECT *, RANK() OVER (PARTITION BY user_id ORDER BY ts DESC) AS seq
FROM `stuart-251306.moloch_exercise.visits`)

SELECT site_id, COUNT(*) as cnt
FROM
(
SELECT user_id, site_id
FROM t1
WHERE seq = 1
)
GROUP BY site_id
ORDER BY 2 DESC


/*Q4:
For each user, determine the first site he/she visited and the last site he/she
visited based on the timestamp data. Compute the number of users whose first/last
visits are to the same website. What is the number?
*/
WITH r AS(
SELECT *, RANK() OVER(PARTITION BY user_id ORDER BY ts DESC) AS desc_rank, RANK() OVER(PARTITION BY user_id ORDER BY ts) asc_rank
FROM `stuart-251306.moloch_exercise.visits`), --get the ranking of time when a user visited a certain site.
a AS(
SELECT user_id, site_id AS last_site
FROM r
WHERE desc_rank = 1
), -- get the last site a user visited
b AS (
SELECT user_id, site_id AS first_site
FROM r
WHERE asc_rank = 1
) -- get the first site a user visited

SELECT COUNT(1) -- count the total number of the users whose first/last visits are to the same site
FROM
(SELECT a.user_id, last_site, first_site
FROM a
JOIN b
ON a.user_id=b.user_id
WHERE last_site = first_site) --subquerry to get the users whose first/last visits are to the same site
