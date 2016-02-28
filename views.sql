-- 1) Create a view displaying all users that have sent less than 50 msgs
CREATE VIEW infrequent_users AS
SELECT userid 
FROM Users INNER JOIN ChatMessages ON (userid = owner) GROUP BY userid HAVING COUNT(*) < 50;

-- 2) Create a view will all conversations started today

CREATE VIEW today_convos AS 
SELECT msg.id 
FROM ChatConversations AS convo INNER JOIN ChatMessages AS msg ON (convo.id = conversation) WHERE convo.created_time = current_date;