DROP TABLE IF EXISTS dloar_db.item_author;

CREATE TABLE dloar_db.item_author (
    item_id INT NOT NULL,
    author_id INT NOT NULL,
    author_order INT NOT NULL DEFAULT 1,
    author_role VARCHAR(50) DEFAULT 'Principal Investigator',
    CONSTRAINT pk_item_author PRIMARY KEY (item_id, author_id),
    CONSTRAINT fk_ia_item FOREIGN KEY (item_id) 
        REFERENCES dloar_db.digital_item (item_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ia_author FOREIGN KEY (author_id) 
        REFERENCES dloar_db.author (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_item_author_order CHECK (author_order >= 1)
) ENGINE=InnoDB;