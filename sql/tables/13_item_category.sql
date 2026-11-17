DROP TABLE IF EXISTS dloar_db.item_category;

CREATE TABLE dloar_db.item_category (
    item_id INT NOT NULL,
    category_id INT NOT NULL,
    CONSTRAINT pk_item_category PRIMARY KEY (item_id, category_id),
    CONSTRAINT fk_ic_item FOREIGN KEY (item_id) 
        REFERENCES dloar_db.digital_item (item_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ic_category FOREIGN KEY (category_id) 
        REFERENCES dloar_db.category (category_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;