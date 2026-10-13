DROP TABLE IF EXISTS dloar_db.book_copy;

CREATE TABLE dloar_db.book_copy (
    copy_id INT NOT NULL AUTO_INCREMENT,
    book_id INT NOT NULL,
    barcode VARCHAR(50) NOT NULL,
    copy_status VARCHAR(20) NOT NULL DEFAULT 'Available',
    shelf_location VARCHAR(50) DEFAULT NULL,
    CONSTRAINT pk_book_copy PRIMARY KEY (copy_id),
    CONSTRAINT uq_book_copy_barcode UNIQUE (barcode),
    CONSTRAINT fk_book_copy_book FOREIGN KEY (book_id) 
        REFERENCES dloar_db.physical_book (book_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_copy_status CHECK (copy_status IN ('Available', 'Borrowed', 'Lost', 'Damaged', 'In_Maintenance'))
) ENGINE=InnoDB;