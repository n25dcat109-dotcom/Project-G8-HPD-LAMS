-- ===================================================
-- SYSTEM: DIGITAL LIBRARY & OPEN-ACCESS REPOSITORY
-- FILE: 02_indexes.sql
-- ===================================================

USE dloar_db;

CREATE INDEX idx_person_names 
    ON dloar_db.person (last_name, first_name);

CREATE INDEX idx_borrow_member_status 
    ON dloar_db.borrow_transaction (member_id, return_date);

CREATE INDEX idx_borrow_copy_status 
    ON dloar_db.borrow_transaction (copy_id, return_date);

CREATE INDEX idx_book_copy_status 
    ON dloar_db.book_copy (copy_status);

CREATE INDEX idx_digital_item_access 
    ON dloar_db.digital_item (access_level, embargo_end_date);

CREATE INDEX idx_fine_status 
    ON dloar_db.fine (fine_status);