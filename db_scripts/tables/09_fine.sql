DROP TABLE IF EXISTS dloar_db.fine;

CREATE TABLE dloar_db.fine (
    fine_id INT NOT NULL AUTO_INCREMENT,
    transaction_id INT NOT NULL,
    fine_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    fine_reason VARCHAR(255) DEFAULT NULL,
    fine_status VARCHAR(20) NOT NULL DEFAULT 'Unpaid',
    payment_date DATE DEFAULT NULL,
    CONSTRAINT pk_fine PRIMARY KEY (fine_id),
    CONSTRAINT uq_fine_transaction UNIQUE (transaction_id),
    CONSTRAINT fk_fine_transaction FOREIGN KEY (transaction_id) 
        REFERENCES dloar_db.borrow_transaction (transaction_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_fine_amount CHECK (fine_amount >= 0.00),
    CONSTRAINT chk_fine_status CHECK (fine_status IN ('Unpaid', 'Paid'))
) ENGINE=InnoDB;