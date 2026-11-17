-- ===================================================
-- SYSTEM: DIGITAL LIBRARY & OPEN-ACCESS REPOSITORY
-- FILE: 03_views.sql
-- ===================================================

USE dloar_db;

-- ---------------------------------------------------
-- View 1: Thống kê giao dịch mượn đang hoạt động
-- ---------------------------------------------------
CREATE OR REPLACE VIEW dloar_db.vw_active_loans AS
SELECT 
    bt.transaction_id,
    m.member_code,
    CONCAT(p.last_name, ' ', p.first_name) AS member_name,
    p.email,
    pb.title AS book_title,
    bc.barcode,
    bt.borrow_date,
    bt.due_date,
    DATEDIFF(CURRENT_DATE, bt.due_date) AS days_overdue
FROM dloar_db.borrow_transaction bt
JOIN dloar_db.member m ON bt.member_id = m.person_id
JOIN dloar_db.person p ON m.person_id = p.person_id
JOIN dloar_db.book_copy bc ON bt.copy_id = bc.copy_id
JOIN dloar_db.physical_book pb ON bc.book_id = pb.book_id
WHERE bt.return_date IS NULL;

-- ---------------------------------------------------
-- View 2: Tổng hợp nợ phạt chưa thanh toán
-- ---------------------------------------------------
CREATE OR REPLACE VIEW dloar_db.vw_unpaid_fines_summary AS
SELECT 
    m.person_id AS member_id,
    m.member_code,
    CONCAT(p.last_name, ' ', p.first_name) AS member_name,
    p.email,
    COUNT(f.fine_id) AS unpaid_fines_count,
    SUM(f.fine_amount) AS total_unpaid_amount
FROM dloar_db.fine f
JOIN dloar_db.borrow_transaction bt ON f.transaction_id = bt.transaction_id
JOIN dloar_db.member m ON bt.member_id = m.person_id
JOIN dloar_db.person p ON m.person_id = p.person_id
WHERE f.fine_status = 'Unpaid'
GROUP BY 
    m.person_id, 
    m.member_code, 
    p.last_name, 
    p.first_name, 
    p.email;

-- ---------------------------------------------------
-- View 3: Danh mục tài liệu số mở công khai
-- ---------------------------------------------------
CREATE OR REPLACE VIEW dloar_db.vw_public_repository_catalog AS
SELECT 
    di.item_id,
    di.title,
    di.doi,
    l.license_name,
    l.license_code,
    di.file_path,
    GROUP_CONCAT(c.category_name SEPARATOR ', ') AS categories
FROM dloar_db.digital_item di
JOIN dloar_db.license l ON di.license_id = l.license_id
LEFT JOIN dloar_db.item_category ic ON di.item_id = ic.item_id
LEFT JOIN dloar_db.category c ON ic.category_id = c.category_id
WHERE di.access_level = 'Public_Open_Access'
   OR (di.access_level = 'Embargoed' AND di.embargo_end_date < CURRENT_DATE)
GROUP BY 
    di.item_id, 
    di.title, 
    di.doi, 
    l.license_name, 
    l.license_code, 
    di.file_path;