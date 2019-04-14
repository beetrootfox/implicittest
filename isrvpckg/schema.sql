DROP TABLE IF EXISTS personal;
DROP TABLE IF EXISTS test;

CREATE TABLE personal (
	id TEXT PRIMARY KEY,
	epi INTEGER NOT NULL,
	comfy INTEGER NOT NULL,
        rozetka INTEGER NOT NULL
);
CREATE TABLE test (
	item TEXT NOT NULL,
	attribute TEXT NOT NULL,
	time TEXT NOT NULL,
	sessionid TEXT NOT NULL,
	FOREIGN KEY(sessionid) REFERENCES personal(id)
);
