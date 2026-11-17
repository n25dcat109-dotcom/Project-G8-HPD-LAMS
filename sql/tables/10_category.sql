DROP TABLE IF EXISTS dloar_db.category;

CREATE TABLE dloar_db.category (
    category_id INT NOT NULL AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    description TEXT DEFAULT NULL,
    CONSTRAINT pk_category PRIMARY KEY (category_id),
    CONSTRAINT uq_category_name UNIQUE (category_name)
) ENGINE=InnoDB;