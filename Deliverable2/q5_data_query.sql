
-- 1) Get the list of id of users who have participated in at least 40 conversation
SELECT Users.userid FROM Users INNER JOIN ConversationParticipation ON (Users.userid = ConversationParticipation.userid) GROUP BY Users.userid HAVING COUNT(*) > 40;

-- 2) Get all ids of conversations whose last message is prior to February 2016
SELECT ChatConversations.id FROM ChatConversations INNER JOIN ChatMessages ON (ChatConversations.id = ChatMessages.conversation) GROUP BY ChatConversations.id HAVING MAX(ChatMessages.created_time) < '2016-02-01'::date;

-- 3) Count how many messages id that are from users whose last names are longer than 10 characters
SELECT COUNT(*) FROM (Users AS a INNER JOIN UserProfiles AS b ON (a.userid = b.owner)) AS c INNER JOIN ChatMessages AS d ON (c.userid = d.owner) WHERE LENGTH(c.last_name) < 10;

-- 4) For each type of friendship, summarize the total number of wave count.
SELECT c.status, COUNT(*) FROM (Users AS a INNER JOIN Friendship AS b ON (a.userid = b.first_person)) AS c INNER JOIN Wave AS d ON (c.userid = d.userid_source) GROUP BY c.status;

-- 5) For each user, give a count of messages his friends have sent out
SELECT userid, COUNT(*) FROM (Users AS a INNER JOIN Friendship AS b ON (a.userid = b.first_person)) AS c INNER JOIN ChatMessages as d ON (c.userid = d.owner) WHERE c.status = 'friend' GROUP BY userid;
