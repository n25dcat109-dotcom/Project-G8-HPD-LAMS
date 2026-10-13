DROP TABLE IF EXISTS dloar_db.physical_book;

CREATE TABLE dloar_db.physical_book (
    book_id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) NOT NULL,
    publisher VARCHAR(100) DEFAULT NULL,
    publication_year INT DEFAULT NULL,
    CONSTRAINT pk_physical_book PRIMARY KEY (book_id),
    CONSTRAINT uq_physical_book_isbn UNIQUE (isbn),
    CONSTRAINT chk_publication_year CHECK (publication_year >= 1500)
) ENGINE=InnoDB;