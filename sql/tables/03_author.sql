DROP TABLE IF EXISTS dloar_db.author;

CREATE TABLE dloar_db.author (
    person_id INT NOT NULL,
    author_code VARCHAR(20) NOT NULL,
    affiliation VARCHAR(100) DEFAULT NULL,
    orcid VARCHAR(20) DEFAULT NULL,
    bio TEXT DEFAULT NULL,
    CONSTRAINT pk_author PRIMARY KEY (person_id),
    CONSTRAINT uq_author_code UNIQUE (author_code),
    CONSTRAINT uq_author_orcid UNIQUE (orcid),
    CONSTRAINT fk_author_person FOREIGN KEY (person_id) 
        REFERENCES dloar_db.person (person_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;