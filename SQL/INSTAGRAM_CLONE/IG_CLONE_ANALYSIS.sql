-- CHALLENGES FOR IG_CLONE
/*We want to reward our users who have been around the longest.  
1. Find the 5 oldest users.*/

SELECT USERNAME 
	FROM USERS 
		ORDER BY CREATED_AT DESC LIMIT 5;


/*What day of the week do most users register on?
2. We need to figure out when to schedule an ad campgain*/

SELECT DAYNAME(CREATED_AT) AS 'DAY_OF_THE_WEEK',COUNT(ID) AS 'TOTAL REGISTRATION' 
	FROM USERS 
		GROUP BY 1 
        ORDER BY 2 DESC;


/*3. We want to target our inactive users with an email campaign.
Find the users who have never posted a photo*/

SELECT USERNAME 
	FROM USERS 
    LEFT JOIN PHOTOS 
		ON USERS.ID = PHOTOS.USER_ID 
        WHERE USER_ID IS NULL 
			GROUP BY 1;

/*4. We want to target our inactive users with an email campaign.
Find the TOP 5 users who have posted photo*/

SELECT USERNAME AS TOP_POSERS 
	FROM (
    SELECT USERNAME, COUNT(USER_ID) 
		FROM USERS 
		JOIN PHOTOS 
			ON USERS.ID = PHOTOS.USER_ID 
            GROUP BY 1
            ) AS TOP_POSERS 
	ORDER BY 1 DESC LIMIT 5;


/*5. We're running a new contest to see who can get the most likes on a single photo.
WHO WON??!!*/

SELECT USERNAME 
	FROM USERS 
    WHERE ID = (
				SELECT PHOTOS.USER_ID 
					FROM LIKES 
                    JOIN PHOTOS 
						ON LIKES.PHOTO_ID = PHOTOS.ID 
                        GROUP BY PHOTO_ID 
                        ORDER BY COUNT(LIKES.USER_ID) DESC LIMIT 1
				);

/****OR****/

SELECT users.username,photos.id,photos.image_url,COUNT(*) AS Total_Likes
	FROM likes
	JOIN photos 
		ON photos.id = likes.photo_id
	JOIN users 
		ON users.id = likes.user_id
			GROUP BY photos.id
			ORDER BY Total_Likes DESC LIMIT 1;


/* 6. Our Investors want to know...
How many times does the average user post?*/
/*total number of photos/total number of users*/

SELECT ROUND((SELECT COUNT(*) FROM PHOTOS) / (SELECT COUNT(*) FROM USERS) , 2) AS AVERAGE_POSTS_PER_USER;


/* 7. user ranking by postings higher to lower*/

SELECT USERNAME, COUNT(PHOTOS.ID) 
	FROM PHOTOS 
		JOIN USERS 
			ON PHOTOS.USER_ID = USERS.ID 
				GROUP BY USER_ID 
                ORDER BY COUNT(ID) DESC ;


/*8. Total Posts by users (longer versionof SELECT COUNT(*)FROM photos) */

SELECT SUM(TOTAL_PICS) AS TOTAL_PICS 
	FROM (
    SELECT USERNAME,COUNT(PHOTOS.ID) AS TOTAL_PICS 
		FROM PHOTOS 
			JOIN USERS 
            ON PHOTOS.USER_ID = USERS.ID 
            GROUP BY 1 
            ORDER BY 2 DESC 
		) AS POSTS_PER_USER;



/*9. total numbers of users who have posted at least one time */

SELECT COUNT(DISTINCT USER_ID) NO_OF_ACTIVE_POSTING_USERS 
	FROM PHOTOS;

/****OR****/

SELECT DISTINCT USERNAME 
	FROM USERS 
		JOIN PHOTOS ON USERS.ID = PHOTOS.USER_ID;

/*10. A brand wants to know which hashtags to use in a post
What are the top 5 most commonly used hashtags?*/

SELECT TAG_NAME,COUNT(TAG_ID) AS NO_OF_TIMES_USED 
	FROM TAGS 
		JOIN PHOTO_TAGS 
			ON TAGS.ID = PHOTO_TAGS.TAG_ID 
            GROUP BY TAG_NAME 
            ORDER BY COUNT(ID) DESC;

/*11. We have a small problem with bots on our site...
Find users who have liked every single photo on the site*/

SELECT USERNAME,COUNT(LIKES.USER_ID) 
	FROM LIKES 
    JOIN USERS 
		ON LIKES.USER_ID = USERS.ID  
		GROUP BY USERNAME 
			HAVING COUNT(LIKES.USER_ID) = (SELECT COUNT(ID) FROM PHOTOS);


/*12. We also have a problem with celebrities
Find users who have never commented on a photo*/

SELECT USERNAME, COMMENT_TEXT 
	FROM USERS 
    LEFT JOIN COMMENTS 
		ON USERS.ID = COMMENTS.USER_ID 
        GROUP BY USERNAME 
			HAVING COMMENT_TEXT IS NULL ;
            
/*****OR*****/


SELECT COUNT(*) FROM
(SELECT username,comment_text
	FROM users
	LEFT JOIN comments ON users.id = comments.user_id
	GROUP BY users.id
	HAVING comment_text IS NULL) AS total_number_of_users_without_comments;
    
/*Mega Challenges
13. Are we overrun with bots and celebrity accounts?
Find the percentage of our users who have either never commented on a photo or have commented on every photo*/

SELECT TABLE_A.RES_A AS 'Number Of Users who never commented',
		(TABLE_A.RES_A / (SELECT COUNT(*) FROM users))*100 AS '%',
		TABLE_B.RES_B,2 AS 'Number of Users who likes every photos',
		(TABLE_B.RES_B/(SELECT COUNT(*) FROM users))*100 AS '%'
	FROM (
        SELECT COUNT(*) AS RES_A FROM
        (SELECT username,comment_text
        FROM users
        LEFT JOIN comments ON users.id = comments.user_id
        GROUP BY users.id
        HAVING comment_text IS NULL) AS total_number_of_users_without_comments
        ) AS TABLE_A 
        
    JOIN (
		SELECT COUNT(*) AS RES_B FROM 
		(SELECT USERNAME,COUNT(LIKES.USER_ID)
		FROM LIKES 
		JOIN USERS ON LIKES.USER_ID = USERS.ID  
		GROUP BY USERNAME 
		HAVING COUNT(LIKES.USER_ID) = (SELECT COUNT(ID) FROM PHOTOS) ) AS TOTAL
        ) AS TABLE_B;
    
/* 14. Find users who have ever commented on a photo*/

SELECT COUNT(*) AS RES_B FROM
        (SELECT username,comment_text
        FROM users
        LEFT JOIN comments ON users.id = comments.user_id
        GROUP BY users.id
        HAVING comment_text IS NOT NULL) AS total_number_of_users_with_comments;
 /**** OR ****/
 
 SELECT USERNAME AS "UserName of people who have commented atleast once" FROM
        (SELECT username,comment_text
        FROM users
        LEFT JOIN comments ON users.id = comments.user_id
        GROUP BY users.id
        HAVING comment_text IS NOT NULL) AS total_number_of_users_with_comments;


/* 15.  Are we overrun with bots and celebrity accounts?
Find the percentage of our users who have either never commented on a photo or have commented on photos before*/

SELECT TABLE_A.RES_A AS "PERCENTAGE OF PEOPLE WHO HAVEN'T COMMENTED" ,
(TABLE_A.RES_A / (SELECT COUNT(*) FROM USERS)) * 100 AS "%",
TABLE_B.RES_B AS "PERCENTAGE OF PEOPLE WHO HAVE COMMENTED ATLEAST ONCE" ,
(TABLE_B.RES_B / (SELECT COUNT(*) FROM USERS)) * 100 AS "%"
	FROM (
        SELECT COUNT(*) AS RES_A FROM
        (SELECT username,comment_text
        FROM users
        LEFT JOIN comments ON users.id = comments.user_id
        GROUP BY users.id
        HAVING comment_text IS NULL) AS total_number_of_users_without_comments
        ) AS TABLE_A 
	
    JOIN (
		SELECT COUNT(*) AS RES_B FROM
        (SELECT username,comment_text
        FROM users
        LEFT JOIN comments ON users.id = comments.user_id
        GROUP BY users.id
        HAVING comment_text IS NOT NULL) AS total_number_of_users_with_comments
        ) AS TABLE_B;

/* 16. Top 5 most followed users */

select username , followee_id , count(follower_id)
	from `follows` 
    join users 
		on followee_id = id
		group by 2 
        order by 3 desc limit 5;
        
/* 17. Photos with no tags */

SELECT PHOTO_ID , TAG_NAME 
	FROM TAGS 
    JOIN PHOTO_TAGS
		ON TAGS.ID = PHOTO_TAGS.TAG_ID 
        GROUP BY PHOTO_ID
			HAVING TAG_NAME IS NULL;   
