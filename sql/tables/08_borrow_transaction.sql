DROP TABLE IF EXISTS dloar_db.borrow_transaction;

CREATE TABLE dloar_db.borrow_transaction (
    transaction_id INT NOT NULL AUTO_INCREMENT,
    member_id INT NOT NULL,
    copy_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE DEFAULT NULL,
    CONSTRAINT pk_borrow_transaction PRIMARY KEY (transaction_id),
    CONSTRAINT fk_borrow_member FOREIGN KEY (member_id) 
        REFERENCES dloar_db.member (person_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_borrow_copy FOREIGN KEY (copy_id) 
        REFERENCES dloar_db.book_copy (copy_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_borrow_due_dates CHECK (due_date >= borrow_date),
    CONSTRAINT chk_borrow_return_dates CHECK (return_date IS NULL OR return_date >= borrow_date)
) ENGINE=InnoDB;