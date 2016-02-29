
DROP VIEW IF EXISTS infrequent_users;
DROP VIEW IF EXISTS today_convos;

DROP TABLE IF EXISTS LimitedPalEvents;
DROP TABLE IF EXISTS LimitedGroupParticipation;

DROP TABLE IF EXISTS ConversationParticipation;
DROP TABLE IF EXISTS GroupParticipation;
DROP TABLE IF EXISTS Friendship;
DROP TABLE IF EXISTS PalCornerEdits;
DROP TABLE IF EXISTS PalEventEdits;

--------------------------------------------------------------------------
DROP TABLE IF EXISTS Wave;
DROP TABLE IF EXISTS ChatMessages;
DROP TABLE IF EXISTS ChatConversations;
DROP TABLE IF EXISTS Pictures;
DROP TABLE IF EXISTS Notifications;
DROP TABLE IF EXISTS PalCorners;
DROP TABLE IF EXISTS PalEvents;
DROP TABLE IF EXISTS StatusUpdates;
DROP TABLE IF EXISTS Groups;
DROP TABLE IF EXISTS UserProfiles;
DROP TABLE IF EXISTS Users;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE TABLE Users(
		userid varchar(50) PRIMARY KEY,
		email varchar(100) NOT NULL,
		salt varchar(50) NOT NULL,
		password_hash varchar(257) NOT NULL
	);

CREATE TABLE UserProfiles(
		first_name varchar(50) NOT NULL,
		last_name varchar(50) NOT NULL,
		location varchar(100) NOT NULL,
		profile_picture_link varchar(500),
		owner varchar(50) PRIMARY KEY REFERENCES Users(userid)
	);

CREATE TABLE PalEvents(
		id SERIAL PRIMARY KEY,
		content TEXT,
		time_stamp TIMESTAMP NOT NULL DEFAULT NOW(),
		owner varchar(50) REFERENCES Users(userid)
	);

CREATE TABLE PalCorners(
		id SERIAL PRIMARY KEY,
		type varchar(50) NOT NULL,
		description TEXT,
		created_time TIMESTAMP NOT NULL DEFAULT NOW(),
		owner varchar(50) REFERENCES Users(userid)
	);

CREATE TABLE Wave(
		id SERIAL PRIMARY KEY,
		userid_source varchar(50) REFERENCES Users(userid),
		userid_destination varchar(50) REFERENCES Users(userid),
		count INTEGER
	);

CREATE TABLE Groups(
		id SERIAL PRIMARY KEY,
		group_name varchar(100) NOT NULL UNIQUE,
		description varchar(500)
	);

CREATE TABLE StatusUpdates(
		id SERIAL PRIMARY KEY,
		content TEXT,
		time_stamp TIMESTAMP NOT NULL DEFAULT NOW(),
		location varchar(100),
		owner varchar(50) REFERENCES Users(userid)
	);

CREATE TABLE Notifications(
		id SERIAL PRIMARY KEY,
		type varchar(50) NOT NULL,
		time_stamp TIMESTAMP NOT NULL DEFAULT NOW(),
		content TEXT,
		owner varchar(50) REFERENCES Users(userid)
	);

CREATE TABLE Pictures(
		id SERIAL PRIMARY KEY,
		caption varchar(500),
		time_stamp TIMESTAMP NOT NULL DEFAULT NOW(),
		location varchar(100),
		path_to_file varchar(100) NOT NULL,
		owner varchar(50) REFERENCES Users(userid)
	);

CREATE TABLE ChatConversations(
		id SERIAL PRIMARY KEY,
		title varchar(50),
		created_time TIMESTAMP NOT NULL DEFAULT NOW(),
		is_locked BOOLEAN DEFAULT TRUE,
		initiator varchar(50) REFERENCES Users(userid)
	);

CREATE TABLE ChatMessages(
		id SERIAL PRIMARY KEY,
		created_time TIMESTAMP NOT NULL DEFAULT NOW(),
		content TEXT,
		conversation INTEGER REFERENCES ChatConversations(id),
		owner varchar(50) REFERENCES Users(userid)
	);


--------------------------------------------------------------------------
CREATE TABLE PalEventEdits(
		id SERIAL PRIMARY KEY,
		editor varchar(50) REFERENCES Users(userid),
		pal_event INTEGER REFERENCES PalEvents(id),
		time_stamp TIMESTAMP NOT NULL DEFAULT NOW(),
		changes TEXT
	);

CREATE TABLE PalCornerEdits(
		id SERIAL PRIMARY KEY,
		editor varchar(50) REFERENCES Users(userid),
		pal_corner INTEGER REFERENCES PalCorners(id),
		time_stamp TIMESTAMP NOT NULL DEFAULT NOW(),
		changes TEXT
	);

CREATE TABLE Friendship(
		id SERIAL PRIMARY KEY,
		first_person varchar(50) REFERENCES Users(userid),
		second_person varchar(50) REFERENCES Users(userid),
		start_date TIMESTAMP NOT NULL DEFAULT NOW(),
		status varchar(50) NOT NULL
	);

CREATE TABLE GroupParticipation(
		id SERIAL PRIMARY KEY,
		userid varchar(50) REFERENCES Users(userid),
		group_id INTEGER REFERENCES Groups(id)
	);

CREATE TABLE ConversationParticipation(
		id SERIAL PRIMARY KEY,
		userid varchar(50) REFERENCES Users(userid),
		conversation INTEGER REFERENCES ChatConversations(id)
	);

--------------------------------------------------------------------------
--------------------------------------------------------------------------
