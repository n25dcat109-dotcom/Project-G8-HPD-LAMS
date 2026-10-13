DROP TABLE IF EXISTS dloar_db.person;

CREATE TABLE dloar_db.person (
    person_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_person PRIMARY KEY (person_id),
    CONSTRAINT uq_person_email UNIQUE (email)
) ENGINE=InnoDB;