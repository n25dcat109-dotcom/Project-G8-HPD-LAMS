DROP TABLE IF EXISTS dloar_db.license;

CREATE TABLE dloar_db.license (
    license_id INT NOT NULL AUTO_INCREMENT,
    license_name VARCHAR(100) NOT NULL,
    license_code VARCHAR(50) NOT NULL,
    terms_description TEXT DEFAULT NULL,
    CONSTRAINT pk_license PRIMARY KEY (license_id),
    CONSTRAINT uq_license_code UNIQUE (license_code)
) ENGINE=InnoDB;