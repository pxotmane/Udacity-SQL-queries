/*
odrders table: id	account_id	occurred_at	standard_qty	gloss_qty	poster_qty	total	standard_amt_usd	gloss_amt_usd	poster_amt_usd	total_amt_usd
accounts table: id	name	website	lat	long	primary_poc	sales_rep_id
region table: id	name
sales_reps table: id	name	region_id
web_events: id	account_id	occurred_at	channel
*/

/* database creation*/
Create database Udacity_db;
USE Udacity_db;

CREATE TABLE accounts(
  id INT NOT NUll,
  name VARCHAR(250) NOT NULL,
  website VARCHAR(250) NOT NULL,
  lat DECIMAL(10,8) NOT NULL,
  long DECIMAL(10,8) NOT NULL,
  primary_poc VARCHAR(255) NOT NULL,
  sales_rep_id INT(8) NOT NULL,
  PRIMARY KEY(id),
  CONSTRAINT sales_reps_ibfk_1 FOREIGN KEY (sales_rep_id) REFERENCES sales_reps (id)
  ON UPDATE CASCADE
  ON DELETE CASCADE
) ENGINE = InnoDB, CHARSET = latin1;

CREATE TABLE orders (
  id INT NOT NULL AUTO_INCREMENT,
  account_id INT NOT NULL,
  occurred_at DATETIME NOT NULL,
  standard_qty INT,
  gloss_qty INT,
  poster_qty INT,
  total INT,
  standard_amt_usd FLOAT(6,2),
  gloss_amt_usd FLOAT(6,2),
  poster_amt_usd FLOAT(6,2),
  total_amt_usd FLOAT(6,2),
  PRIMARY KEY (id),
  CONSTRAINT account_id_ibfk_1 FOREIGN KEY (account_id)
  REFERENCES accounts (id)
  ON UPDATE CASCADE
  ON DELETE CASCADE
) ENGINE = InnoDB, CHARSET = latin1;

DROP TABLE IF EXISTS web_events;
CREATE TABLE web_events (
  id int NOT NULL AUTO_INCREMENT,
  account_id INT NOT NULL,
  occurred_at DATETIME NOT NULL,
  channel VARCHAR(255) NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT account_id_ibfk_2 FOREIGN KEY(account_id)
  REFERENCES accounts(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE
) ENGINE = InnoDB, CHARSET = latin1;


CREATE TABLE sales_reps (
  id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  region_id INT NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT region_id_ibkf_1 FOREIGN KEY (region_id)
  REFERENCES region (id)
  ON UPDATE CASCADE
  ON DELETE CASCADE
) ENGINE = InnoDB, CHARSET = latin1;

CREATE TABLE region (
  id INT NOT NUll AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY(id)
) ENGINE = InnoDB, CHARSET = latin1
