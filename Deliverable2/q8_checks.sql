CREATE TABLE LimitedPalEvents(
		id SERIAL PRIMARY KEY,
		content TEXT,
		time_stamp TIMESTAMP NOT NULL DEFAULT NOW(),
		owner varchar(50) REFERENCES Users(userid),
        CHECK (LENGTH(content)<50)
	);
    
CREATE TABLE LimitedGroupParticipation(
		id SERIAL PRIMARY KEY,
		userid varchar(50) REFERENCES Users(userid),
		group_id INTEGER REFERENCES Groups(id),
        CHECK (LENGTH(userid)<50)  
	);