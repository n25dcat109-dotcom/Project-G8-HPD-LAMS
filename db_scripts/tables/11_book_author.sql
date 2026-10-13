DROP TABLE IF EXISTS dloar_db.book_author;

CREATE TABLE dloar_db.book_author (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_role VARCHAR(50) DEFAULT 'Main Author',
    CONSTRAINT pk_book_author PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_ba_book FOREIGN KEY (book_id) 
        REFERENCES dloar_db.physical_book (book_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ba_author FOREIGN KEY (author_id) 
        REFERENCES dloar_db.author (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_book_author_role CHECK (author_role IN ('Main Author', 'Co-Author', 'Editor', 'Translator'))
) ENGINE=InnoDB;