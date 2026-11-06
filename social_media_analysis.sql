/* =====================================================================
   SOCIAL MEDIA (IG CLONE) — STUDENT ANSWER TEMPLATE
   ===================================================================== */

USE ig_clone;


/* =====================================================================
   OBJECTIVE QUESTIONS
   ===================================================================== */

-- O1.
-- Are there any tables with duplicate or missing null values? If so, how
-- would you handle them?
Select id, username,created_at 
from users 
where username is NULL;

Select username, count(*) as count 
from users 
group by username having count(*) > 1;

Select id, image_url, user_id, created_dat 
from photos 
where image_url IS NULL OR user_id IS NULL OR created_dat IS NULL;

select image_url, user_id, count(*) AS count
from photos
group by image_url, user_id having COUNT(*) > 1;

Select id, comment_text, photo_id, user_id, created_at
from comments
where comment_text IS NULL OR photo_id IS NULL OR user_id IS NULL OR created_at IS NULL;

select comment_text, user_id, photo_id, count(*) as count
from comments
group by comment_text, user_id, photo_id
having count(*) > 1;

select user_id, photo_id, created_at
from likes
where user_id IS NULL OR photo_id IS NULL OR created_at IS NULL;

Select user_id, photo_id, count(*) as count
from likes
group by user_id, photo_id having count(*) > 1;

Select follower_id, followee_id, created_at
from follows
where follower_id IS NULL OR followee_id IS NULL OR created_at IS NULL;

Select follower_id, followee_id, count(*) as count
from follows
group by follower_id, followee_id having count(*) > 1;

-- O2.
-- What is the distribution of user activity levels (e.g., number of posts,
-- likes, comments) across the user base?
Select u.id as user_id, u.username, count(DISTINCT p.id) as total_posts, 
count(distinct CONCAT(l.user_id, '-', l.photo_id)) as total_likes_given, 
count(distinct c.id) AS total_comments_made
from users u
left join  photos p ON p.user_id = u.id
left join likes l ON l.user_id = u.id
left join comments c ON c.user_id = u.id
group by u.id, u.username
order by u.id;

-- O3.
-- Calculate the average number of tags per post (photo_tags and photos
-- tables).
Select round(AVG(tag_count), 4) as AverageTags
from ( SELECT p.id, COUNT(pt.tag_id) as tag_count 
from photos p
left join photo_tags pt ON pt.photo_id = p.id
group by p.id
) as per_photo;

-- O4.
-- Identify the top users with the highest engagement rates (likes, comments)
-- on their posts and rank them.
with likes_per_photo as (select photo_id, count(*) as like_count from likes
    group by photo_id ),
comments_per_photo as (select photo_id, count(*) as comment_count from comments
    group by photo_id),
user_engagement as (
    select p.user_id, 
    sum(COALESCE(l.like_count, 0) + COALESCE(c.comment_count, 0)) as Total
    from photos p
    LEFT JOIN likes_per_photo l ON l.photo_id = p.id
    LEFT JOIN comments_per_photo c ON c.photo_id = p.id
    group by p.user_id having SUM(COALESCE(l.like_count, 0)) > 0 and sum(COALESCE(c.comment_count, 0)) > 0)
Select user_id, Total, RANK() OVER (order by Total DESC) AS rnk
from user_engagement
order by rnk, user_id;

-- O5.
-- Which users have the highest number of followers and followings?
Select u.id as user_id, u.username, count(distinct followers.follower_id) as followers, count(distinct following.followee_id) as following
from users u
LEFT JOIN follows followers ON followers.followee_id = u.id
LEFT JOIN follows following ON following.follower_id = u.id
group by u.id, u.username
order by followers DESC, following DESC, u.id;

-- O6.
-- Calculate the average engagement rate (likes, comments) per post for each
-- user.
WITH likes_per_photo as (Select photo_id, count(*) as like_count 
from likes
group by photo_id ),
comments_per_photo as (Select photo_id, count(*) as comment_count 
from comments 
group by photo_id)
Select u.id, u.username,
ROUND(avg(COALESCE(l.like_count, 0) + COALESCE(c.comment_count, 0)), 2) as avg_engagement
from users u
JOIN photos p ON p.user_id = u.id
LEFT JOIN likes_per_photo l ON l.photo_id = p.id
LEFT JOIN comments_per_photo c ON c.photo_id = p.id
group by u.id, u.username
order by avg_engagement DESC, u.id;


-- O7.
-- Get the list of users who have never liked any post (users and likes
-- tables)
Select u.id, u.username
from users u
where not exists( Select 1 
from likes l
where l.user_id = u.id )
order by u.id;

-- O8.
-- How can you leverage user-generated content (posts, hashtags, photo tags)
-- to create more personalized and engaging ad campaigns?
WITH photo_engagement as ( Select p.id as photo_id, p.user_id,
count(distinct l.user_id) as likes_received,
count(distinct c.id) as comments_received
from photos p
LEFT JOIN likes l ON l.photo_id = p.id
LEFT JOIN comments c ON c.photo_id = p.id
group by p.id, p.user_id )
Select u.id as user_id, u.username, t.tag_name,
count(distinct pt.photo_id) as tag_usage,
SUM(pe.likes_received) as total_likes_received,
SUM(pe.comments_received) as total_comments_received,
SUM(pe.likes_received + pe.comments_received) as total_engagement
from photos p
JOIN users u ON u.id = p.user_id
JOIN photo_tags pt ON pt.photo_id = p.id
JOIN tags t ON t.id = pt.tag_id
JOIN photo_engagement pe ON pe.photo_id = p.id
group by u.id, u.username, t.id, t.tag_name
order by total_engagement DESC, u.id, t.tag_name;

-- O9.
-- Are there any correlations between user activity levels and specific
-- content types (e.g., photos, videos, reels)? How can this information
-- guide content creation and curation strategies?
WITH likes_per_photo as (select photo_id, count(*) as total_likes
from likes
group by photo_id),
comments_per_photo as (select photo_id, count(*) as total_comments
from comments
group by photo_id)
select p.user_id,
count(distinct p.id) as total_posts,
SUM(COALESCE(l.total_likes, 0)) as total_likes,
SUM(COALESCE(c.total_comments, 0)) as total_comments,
SUM(COALESCE(l.total_likes, 0) + COALESCE(c.total_comments, 0)) as total_engagement
from photos p
LEFT JOIN likes_per_photo l ON l.photo_id = p.id
LEFT JOIN comments_per_photo c ON c.photo_id = p.id
group by p.user_id
order by total_engagement DESC, p.user_id;

-- O10.
-- Calculate the total number of likes, comments, and photo tags for each
-- user.
WITH likes_received as (Select p.user_id, count(l.photo_id) as total_likes
from photos p
LEFT JOIN likes l ON l.photo_id = p.id
group by p.user_id),
comments_received as (select p.user_id, count(c.id) as total_comments
from photos p
LEFT JOIN comments c ON c.photo_id = p.id
GROUP BY p.user_id),
tags_used as (select p.user_id, COUNT(pt.tag_id) as total_tags
from photos p
LEFT JOIN photo_tags pt ON pt.photo_id = p.id
group by p.user_id)
select u.id as user_id, u.username,
COALESCE(l.total_likes, 0) as total_likes,
COALESCE(c.total_comments, 0) as total_comments,
COALESCE(t.total_tags, 0) as total_tags
from users u
LEFT JOIN likes_received l ON l.user_id = u.id
LEFT JOIN comments_received c ON c.user_id = u.id
LEFT JOIN tags_used t ON t.user_id = u.id
order by u.id;

-- O11.
-- Rank users based on their total engagement (likes, comments, shares) over a
-- month.
with likes_given as (select user_id, COUNT(*) AS likes_given
from likes
group by user_id),
comments_made as (select user_id, count(*) as comments_made
from comments
group by user_id),
activity as (select u.id as user_id, u.username,
COALESCE(l.likes_given, 0) as likes_given,
COALESCE(c.comments_made, 0) as comments_made,
COALESCE(l.likes_given, 0) + COALESCE(c.comments_made, 0) as total_engagement
from users u
LEFT JOIN likes_given l ON l.user_id = u.id
LEFT JOIN comments_made c ON c.user_id = u.id
)
select user_id, username, likes_given, comments_made, total_engagement,
rank() over (order by total_engagement DESC) as engagement_rank
from activity
order by engagement_rank, user_id;

-- O12.
-- Retrieve the hashtags that have been used in posts with the highest average
-- number of likes. Use a CTE to calculate the average likes for each
-- hashtag first.
WITH likes_per_photo as (select photo_id, count(*) as like_count
from likes
group by photo_id),
hashtag_likes as (select t.id as tag_id,t.tag_name,
avg(COALESCE(lp.like_count, 0)) as avg_likes_per_photo,
SUM(COALESCE(lp.like_count, 0)) as total_likes,
count(distinct pt.photo_id) as total_photos
from tags t
JOIN photo_tags pt ON pt.tag_id = t.id
LEFT JOIN likes_per_photo lp ON lp.photo_id = pt.photo_id
group by t.id, t.tag_name)
select tag_id, tag_name,
round(avg_likes_per_photo, 2) as avg_likes_per_photo,total_likes, total_photos
from hashtag_likes
order by avg_likes_per_photo DESC, total_likes DESC
limit 10;

-- O13.
-- Retrieve the users who have started following someone after being followed
-- by that person.
Select distinct u.id, u.username
from users u
JOIN follows f1 ON f1.follower_id = u.id
JOIN follows f2 ON f2.follower_id = f1.followee_id and f2.followee_id = u.id
order by u.id;

/* =====================================================================
   SUBJECTIVE QUESTIONS
   ===================================================================== */

-- S1.
-- Based on user engagement and activity levels, which users would you
-- consider the most loyal or valuable? How would you reward or incentivize
-- these users?
WITH received AS (select p.user_id,
count(distinct l.user_id, l.photo_id) as likes_received, count(distinct c.id) AS comments_received
from photos p
LEFT JOIN likes l ON l.photo_id = p.id
LEFT JOIN comments c ON c.photo_id = p.id
group by p.user_id),
given_activity as ( select u.id as user_id,
count(distinct l.photo_id) as likes_given,
count(distinct c.id) as comments_made
from users u
LEFT JOIN likes l ON l.user_id = u.id
LEFT JOIN comments c ON c.user_id = u.id
group by  u.id)
select u.id as user_id, u.username,
COALESCE(r.likes_received, 0) AS likes_received,
COALESCE(r.comments_received, 0) AS comments_received,
COALESCE(g.likes_given, 0) AS likes_given,
CoALESCE(g.comments_made, 0) AS comments_made,
COALESCE(r.likes_received, 0) + COALESCE(r.comments_received, 0) + COALESCE(g.likes_given, 0) + COALESCE(g.comments_made, 0) AS activity_score
from users u
LEFT JOIN received r ON r.user_id = u.id
LEFT JOIN given_activity g ON g.user_id = u.id
order by activity_score DESC, u.id
LIMIT 20;

-- S2.
-- For inactive users, what strategies would you recommend to re-engage them
-- and encourage them to start posting or engaging again?
WITH all_activity as (Select user_id, created_dat as activity_date from photos
    UNION ALL
    select user_id, created_at as activity_date from comments
    UNION ALL
    select user_id, created_at as activity_date from likes),
last_activity as (SElect u.id as user_id, u.username, MAX(a.activity_date) As last_activity
FROM users u
LEFT JOIN all_activity a ON a.user_id = u.id
group by u.id, u.username),
dataset_end as (select MAX(activity_date) as max_date from all_activity)
select la.user_id, la.username, la.last_activity
from last_activity la
cross JOIN dataset_end de
where la.last_activity is null OR la.last_activity < DATE_SUB(de.max_date, INTERVAL 60 DAY)
order by la.last_activity, la.user_id;

-- S3.
-- Which hashtags or content topics have the highest engagement rates? How can
-- this information guide content strategy and ad campaigns?
WITH photo_engagement as (select p.id as photo_id,
CounT(DISTINCT l.user_id) as likes_count,
count(DISTINCT c.id) as comments_count
FROM photos p
LEFT JOIN likes l ON l.photo_id = p.id
LEFT JOIN comments c ON c.photo_id = p.id
group by p.id)
select t.id as tag_id, t.tag_name,
count(DISTINCT pt.photo_id) as tagged_photos,
round(AVG(pe.likes_count), 2) as avg_likes_per_photo,
round(AVG(pe.comments_count), 2) as avg_comments_per_photo,
round(AVG(pe.likes_count + pe.comments_count), 2) as avg_engagement_per_photo
from tags t
JOIN photo_tags pt ON pt.tag_id = t.id
JOIN photo_engagement pe ON pe.photo_id = pt.photo_id
group by t.id, t.tag_name
order by avg_engagement_per_photo DESC, tagged_photos DESC;

-- S4.
-- Are there any patterns or trends in user engagement based on demographics
-- (age, location, gender) or posting times? How can these insights inform
-- targeted marketing campaigns?
Select HOUR(p.created_dat) as posting_hour, DAYNAME(p.created_dat) as posting_day,
count(distinct p.id) as total_posts, ROUND(AVG(coalesce(le.likes_count, 0)), 2) as avg_likes_per_post,
round(AVG(coalesce(co.comments_count, 0)), 2) as avg_comments_per_post
from photos p
LEFT JOIN ( select photo_id, count(*) as likes_count 
from likes
group by photo_id
) le ON le.photo_id = p.id
LEFT JOIN ( select photo_id, count(*) as comments_count
from comments
group by photo_id
) co on co.photo_id = p.id
group by HOUR(p.created_dat), DAYOFWEEK(p.created_dat), DAYNAME(p.created_dat)
order by avg_likes_per_post + avg_comments_per_post DESC;

-- S5.
-- Based on follower counts and engagement rates, which users would be ideal
-- candidates for influencer marketing campaigns? How would you approach
-- and collaborate with these influencers?
WITH follower_counts as (select followee_id as user_id, count(*) as followers
from follows
group by followee_id),
per_photo as (select p.id as photo_id, p.user_id,
count(distinct l.user_id) as likes_received,
count(distinct c.id) as comments_received
from photos p
LEFT JOIN likes l ON l.photo_id = p.id
LEFT JOIN comments c ON c.photo_id = p.id
group by p.id, p.user_id),
creator_metrics as (select user_id,
count(*) as total_posts,
round(AVG(likes_received + comments_received), 2) as avg_engagement_per_post
from per_photo
group by user_id)
select u.id as user_id, u.username,
COALESCE(f.followers, 0) as followers,
cm.total_posts,avg_engagement_per_post,
RANK() OVER ( ORDER BY COALESCE(f.followers, 0) DESC,
cm.avg_engagement_per_post DESC) AS influencer_rank
from creator_metrics cm
JOIN users u ON u.id = cm.user_id
LEFT JOIN follower_counts f ON f.user_id = u.id
order by influencer_rank, u.id
LIMIT 20;

-- S6.
-- Based on user behavior and engagement data, how would you segment the user
-- base for targeted marketing campaigns or personalized recommendations?
WITH posts as (select user_id, count(*) as post_count
from photos
group by user_id),
likes_given as (select user_id, count(*) as likes_given
from likes
group by user_id),
comments_made as (select user_id, count(*) as comments_made
from comments
group by user_id),
engagement_received as (select p.user_id,
count(DISTINCT l.user_id, l.photo_id) as likes_received,
count(DISTINCT c.id) as comments_received
from photos p
LEFT JOIN likes l ON l.photo_id = p.id
LEFT JOIN comments c ON c.photo_id = p.id
group by p.user_id)
select u.id as user_id, u.username,
COALESCE(p.post_count, 0) as post_count,
COaLESCE(l.likes_given, 0) as likes_given,
COALESCE(c.comments_made, 0) as comments_made,
cOALESCE(e.likes_received, 0) + COALESCE(e.comments_received, 0) as engagement_received,
case WHEN COALESCE(p.post_count, 0) >= 5 AND COALESCE(e.likes_received, 0) + COALESCE(e.comments_received, 0) >= 10 THEN 'Active creator'
WHEN COALESCE(l.likes_given, 0) + COALESCE(c.comments_made, 0) >= 10 THEN 'Active engager'
WHEN COALESCE(p.post_count, 0) = 0 AND COALESCE(l.likes_given, 0) + COALESCE(c.comments_made, 0) = 0 THEN 'Inactive / no activity'
ELSE 'Casual user'
END AS user_segment
from users u
LEFT JOIN posts p ON p.user_id = u.id
LEFT JOIN likes_given l ON l.user_id = u.id
LEFT JOIN comments_made c ON c.user_id = u.id
LEFT JOIN engagement_received e ON e.user_id = u.id
order by u.id;

-- S7.
-- If data on ad campaigns (impressions, clicks, conversions) is available,
-- how would you measure their effectiveness and optimize future campaigns?
-- ANswer) Assumed schema: ad_campaigns(campaign_id, campaign_name, impressions, clicks, conversions, spend, revenue)
select campaign_id, campaign_name,
impressions, clicks, conversions, spend, revenue,
ROUND(100.0 * clicks / NULLIF(impressions, 0), 2) as ctr_percent,
ROUND(100.0 * conversions / NULLIF(clicks, 0), 2) as conversion_percent,
ROUND(spend / NULLIF(clicks, 0), 2) as cost_per_click,
ROUND(spend / NULLIF(conversions, 0), 2) as cost_per_acquisition,
ROUND(revenue / NULLIF(spend, 0), 2) as return_on_ad_spend
from ad_campaigns
order by return_on_ad_spend DESC;

-- S8.
-- How can you use user activity data to identify potential brand ambassadors
-- or advocates who could help promote Instagram's initiatives or events?
WITH follower_counts as (select followee_id as user_id, count(*) as followers
from follows
group by followee_id),
user_tags as (select p.user_id, count(distinct pt.tag_id) as distinct_tags_used
from photos p
LEFT JOIN photo_tags pt ON pt.photo_id = p.id
group by p.user_id),
per_photo as (select p.id as photo_id, p.user_id,
couNT(DISTINCT l.user_id) as likes_received,
COUNT(DISTINCT c.id) as comments_received
from photos p
LEFT JOIN likes l ON l.photo_id = p.id
LEFT JOIN comments c ON c.photo_id = p.id
group by p.id, p.user_id),
creator_activity as (select user_id, COUNT(*) as posts,
SUM(likes_received + comments_received) as total_engagement,
ROUND(AVG(likes_received + comments_received), 2) as avg_engagement
from per_photo
group by user_id)
select u.id as user_id, u.username,
COALESCE(f.followers, 0) as followers,
ca.posts, ca.total_engagement, ca.avg_engagement,
COALESCE(ut.distinct_tags_used, 0) as distinct_tags_used
from creator_activity ca
JOIN users u ON u.id = ca.user_id
LEFT JOIN follower_counts f ON f.user_id = u.id
LEFT JOIN user_tags ut ON ut.user_id = u.id
order by ca.total_engagement DESC, followers DESC, u.id
LIMIT 20;

-- S9.
-- How would you approach this problem, if the objective and subjective
-- questions weren't given?
-- First we will Inspect table sizes
select 'users' AS table_name, count(*) as row_count from users
UNION ALL SELECT 'photos', COUNT(*) from photos
UNION ALL SELECT 'comments', COUNT(*) from comments
UNION ALL SELECT 'likes', COUNT(*) from likes
UNION ALL SELECT 'follows', COUNT(*) from follows
UNION ALL SELECT 'tags', COUNT(*) from tags
UNION ALL SELECT 'photo_tags', COUNT(*) from photo_tags;
 
-- Secondly, we will establish a basic activity metrics per user
select u.id as user_id, u.username,
(select COUNT(*) from photos p where p.user_id = u.id) as posts,
(select COUNT(*) from likes l where l.user_id = u.id) as likes_given,
(select COUNT(*) from comments c where c.user_id = u.id) as comments_made,
(select COUNT(*) from follows f where f.followee_id = u.id) as followers,
(select COUNT(*) from follows f where f.follower_id = u.id) as following
from users u
order by u.id;
 
-- FInally we will Inspect the date range available
select MIN(created_dat) as first_post, MAX(created_dat) as last_post
from photos;

-- S10.
-- Assuming there's a "User_Interactions" table tracking user engagements, how
-- can you update the "Engagement_Type" column to change all instances of
-- "Like" to "Heart" to align with Instagram's terminology?
-- A) Preview the rows that will change
select * from User_Interactions
where Engagement_Type = 'Like';

--  B) Update them
update User_Interactions
set Engagement_Type = 'Heart'
where Engagement_Type = 'Like';
 
-- C) Verify no matching old values remain
select count(*) as remaining_like_rows
from User_Interactions
where Engagement_Type = 'Like';


/* ===================================== END OF FILE ===================================== */
