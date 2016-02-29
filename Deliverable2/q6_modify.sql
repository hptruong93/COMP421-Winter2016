
-- 1) Remove all messages that belong to conversation started prior to August 2015
DELETE FROM ChatMessages WHERE id IN(SELECT b.id FROM ChatConversations AS a INNER JOIN ChatMessages AS b ON (a.id = b.conversation) WHERE a.created_time < '2015-08-01'::date);

-- 2) Modify all user's location to "Mordor" if his last name is more than 20 characters
UPDATE UserProfiles SET location = 'Mordor' WHERE owner IN(SELECT userid FROM Users INNER JOIN UserProfiles ON (Users.userid = UserProfiles.owner) WHERE LENGTH(last_name) > 20);

-- 3) Set profile picture of users who have sent less than 150 messages to blank
UPDATE UserProfiles SET profile_picture_link = '' WHERE owner IN(SELECT a.userid  FROM Users AS a INNER JOIN ChatMessages AS b ON (a.userid = b.owner) GROUP BY a.userid HAVING COUNT(*) < 150);

-- 4) Lock all conversations whose have less than 10 messages
UPDATE ChatConversations SET is_locked = TRUE WHERE id IN(SELECT a.id FROM ChatConversations AS a INNER JOIN ChatMessages AS b ON (a.id = b.conversation) GROUP BY a.id HAVING COUNT(*) < 10);
