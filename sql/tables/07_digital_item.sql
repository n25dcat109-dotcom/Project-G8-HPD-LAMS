DROP TABLE IF EXISTS dloar_db.digital_item;

CREATE TABLE dloar_db.digital_item (
    item_id INT NOT NULL AUTO_INCREMENT,
    license_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    abstract TEXT DEFAULT NULL,
    doi VARCHAR(100) DEFAULT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_format VARCHAR(10) DEFAULT 'PDF',
    access_level VARCHAR(50) NOT NULL DEFAULT 'Public_Open_Access',
    embargo_end_date DATE DEFAULT NULL,
    CONSTRAINT pk_digital_item PRIMARY KEY (item_id),
    CONSTRAINT uq_digital_item_doi UNIQUE (doi),
    CONSTRAINT fk_digital_item_license FOREIGN KEY (license_id) 
        REFERENCES dloar_db.license (license_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_access_level CHECK (access_level IN ('Public_Open_Access', 'Restricted_Campus_Only', 'Embargoed'))
) ENGINE=InnoDB;