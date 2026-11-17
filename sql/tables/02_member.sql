DROP TABLE IF EXISTS dloar_db.member;

CREATE TABLE dloar_db.member (
    person_id INT NOT NULL,
    member_code VARCHAR(20) NOT NULL,
    membership_status VARCHAR(20) NOT NULL DEFAULT 'Active',
    max_borrow_limit INT NOT NULL DEFAULT 5,
    expiry_date DATE NOT NULL,
    CONSTRAINT pk_member PRIMARY KEY (person_id),
    CONSTRAINT uq_member_code UNIQUE (member_code),
    CONSTRAINT fk_member_person FOREIGN KEY (person_id) 
        REFERENCES dloar_db.person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_member_status CHECK (membership_status IN ('Active', 'Expired', 'Suspended')),
    CONSTRAINT chk_member_max_borrow CHECK (max_borrow_limit > 0)
) ENGINE=InnoDB;