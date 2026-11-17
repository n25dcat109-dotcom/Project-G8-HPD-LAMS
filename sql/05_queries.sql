-- ===================================================
-- SYSTEM: DIGITAL LIBRARY & OPEN-ACCESS REPOSITORY
-- FILE: 05_queries.sql (Advanced Queries)
-- ===================================================

USE dloar_db;

-- ---------------------------------------------------
-- Truy vấn 1: Báo cáo thực thể trùng lặp (Cá nhân vừa là Độc giả vừa là Tác giả)
-- ---------------------------------------------------
WITH member_borrow_stats AS (
    SELECT 
        member_id, 
        COUNT(*) AS total_borrows
    FROM dloar_db.borrow_transaction
    GROUP BY member_id
),
author_item_stats AS (
    SELECT 
        author_id, 
        COUNT(*) AS total_digital_publications
    FROM dloar_db.item_author
    GROUP BY author_id
)
SELECT 
    p.person_id,
    CONCAT(p.last_name, ' ', p.first_name) AS full_name,
    p.email,
    m.member_code,
    a.author_code,
    a.affiliation,
    COALESCE(mbs.total_borrows, 0) AS total_borrows,
    COALESCE(ais.total_digital_publications, 0) AS total_digital_publications
FROM dloar_db.person p
JOIN dloar_db.member m ON p.person_id = m.person_id
JOIN dloar_db.author a ON p.person_id = a.person_id
LEFT JOIN member_borrow_stats mbs ON m.person_id = mbs.member_id
LEFT JOIN author_item_stats ais ON a.person_id = ais.author_id
ORDER BY 
    total_digital_publications DESC, 
    total_borrows DESC;

-- ---------------------------------------------------
-- Truy vấn 2: Xếp hạng các đầu sách vật lý được mượn nhiều nhất (DENSE_RANK)
-- ---------------------------------------------------
WITH book_usage AS (
    SELECT 
        pb.book_id,
        pb.title,
        pb.isbn,
        COUNT(bt.transaction_id) AS borrow_count
    FROM dloar_db.physical_book pb
    JOIN dloar_db.book_copy bc ON pb.book_id = bc.book_id
    JOIN dloar_db.borrow_transaction bt ON bc.copy_id = bt.copy_id
    GROUP BY pb.book_id, pb.title, pb.isbn
)
SELECT 
    bu.book_id,
    bu.title,
    bu.isbn,
    bu.borrow_count,
    DENSE_RANK() OVER (ORDER BY bu.borrow_count DESC) AS overall_rank
FROM book_usage bu
LIMIT 10;

-- ---------------------------------------------------
-- Truy vấn 3: Phân tích vi phạm quá hạn & tổng tiền phạt chưa thu theo từng loại thẻ
-- ---------------------------------------------------
SELECT 
    m.membership_status,
    COUNT(DISTINCT m.person_id) AS total_members,
    COUNT(f.fine_id) AS total_fine_records,
    SUM(CASE WHEN f.fine_status = 'Unpaid' THEN f.fine_amount ELSE 0 END) AS total_unpaid_amount,
    SUM(CASE WHEN f.fine_status = 'Paid' THEN f.fine_amount ELSE 0 END) AS total_collected_amount
FROM dloar_db.member m
JOIN dloar_db.borrow_transaction bt ON m.person_id = bt.member_id
JOIN dloar_db.fine f ON bt.transaction_id = f.transaction_id
GROUP BY m.membership_status;

-- ---------------------------------------------------
-- Truy vấn 4: Kiểm tra điều kiện mượn sách mới của độc giả (Theo [BR-02.3] - Đã tối ưu bằng CTE)
-- ---------------------------------------------------
WITH active_loans AS (
    SELECT 
        member_id, 
        COUNT(*) AS active_loan_count
    FROM dloar_db.borrow_transaction
    WHERE return_date IS NULL
    GROUP BY member_id
),
unpaid_fines AS (
    SELECT 
        bt.member_id, 
        SUM(f.fine_amount) AS total_unpaid_fine
    FROM dloar_db.fine f
    JOIN dloar_db.borrow_transaction bt ON f.transaction_id = bt.transaction_id
    WHERE f.fine_status = 'Unpaid'
    GROUP BY bt.member_id
)
SELECT 
    m.person_id,
    m.member_code,
    CONCAT(p.last_name, ' ', p.first_name) AS member_name,
    m.membership_status,
    m.max_borrow_limit,
    COALESCE(al.active_loan_count, 0) AS current_active_loans,
    COALESCE(uf.total_unpaid_fine, 0) AS total_unpaid_fine,
    CASE 
        WHEN m.membership_status != 'Active' THEN 'BLOCKED: Tài khoản không hoạt động'
        WHEN m.expiry_date < CURRENT_DATE THEN 'BLOCKED: Thẻ đã hết hạn'
        WHEN COALESCE(al.active_loan_count, 0) >= m.max_borrow_limit THEN 'BLOCKED: Đạt giới hạn mượn tối đa'
        WHEN COALESCE(uf.total_unpaid_fine, 0) > 0 THEN 'BLOCKED: Đang có khoản nợ tiền phạt'
        ELSE 'ELIGIBLE: Đủ điều kiện mượn'
    END AS borrow_eligibility_status
FROM dloar_db.member m
JOIN dloar_db.person p ON m.person_id = p.person_id
LEFT JOIN active_loans al ON m.person_id = al.member_id
LEFT JOIN unpaid_fines uf ON m.person_id = uf.member_id;

-- ---------------------------------------------------
-- Truy vấn 5: Phân bổ tài liệu số theo loại giấy phép bản quyền và mức độ truy cập
-- ---------------------------------------------------
SELECT 
    l.license_code,
    l.license_name,
    SUM(CASE WHEN di.access_level = 'Public_Open_Access' THEN 1 ELSE 0 END) AS public_access_count,
    SUM(CASE WHEN di.access_level = 'Restricted_Campus_Only' THEN 1 ELSE 0 END) AS campus_only_count,
    SUM(CASE WHEN di.access_level = 'Embargoed' THEN 1 ELSE 0 END) AS embargoed_count,
    COUNT(di.item_id) AS total_items
FROM dloar_db.license l
LEFT JOIN dloar_db.digital_item di ON l.license_id = di.license_id
GROUP BY l.license_id, l.license_code, l.license_name
ORDER BY total_items DESC;

-- ---------------------------------------------------
-- Truy vấn 6: Danh sách tài liệu số bị khóa tạm thời (Embargoed) đã hết hạn khóa (Theo [BR-06.3])
-- ---------------------------------------------------
SELECT 
    di.item_id,
    di.title,
    di.doi,
    di.access_level,
    di.embargo_end_date,
    DATEDIFF(CURRENT_DATE, di.embargo_end_date) AS days_since_embargo_expired
FROM dloar_db.digital_item di
WHERE di.access_level = 'Embargoed'
  AND di.embargo_end_date IS NOT NULL
  AND di.embargo_end_date < CURRENT_DATE;

-- ---------------------------------------------------
-- Truy vấn 7: Tìm kiếm tác giả có nhiều đóng góp nhất cho Kho lưu trữ mở
-- ---------------------------------------------------
SELECT 
    a.person_id AS author_id,
    a.author_code,
    CONCAT(p.last_name, ' ', p.first_name) AS author_name,
    a.affiliation,
    a.orcid,
    COUNT(ia.item_id) AS total_publications,
    MIN(ia.author_order) AS highest_authorship_order
FROM dloar_db.author a
JOIN dloar_db.person p ON a.person_id = p.person_id
JOIN dloar_db.item_author ia ON a.person_id = ia.author_id
GROUP BY 
    a.person_id, a.author_code, p.last_name, p.first_name, 
    a.affiliation, a.orcid
HAVING COUNT(ia.item_id) >= 1
ORDER BY total_publications DESC;

-- ---------------------------------------------------
-- Truy vấn 8: Thống kê số lượng bản sao sách (book_copy) theo từng trạng thái
-- ---------------------------------------------------
SELECT 
    pb.book_id,
    pb.title,
    pb.isbn,
    COUNT(bc.copy_id) AS total_copies,
    SUM(CASE WHEN bc.copy_status = 'Available' THEN 1 ELSE 0 END) AS available_copies,
    SUM(CASE WHEN bc.copy_status = 'Borrowed' THEN 1 ELSE 0 END) AS borrowed_copies,
    SUM(CASE WHEN bc.copy_status = 'Damaged' THEN 1 ELSE 0 END) AS damaged_copies,
    SUM(CASE WHEN bc.copy_status = 'Lost' THEN 1 ELSE 0 END) AS lost_copies,
    SUM(CASE WHEN bc.copy_status = 'In_Maintenance' THEN 1 ELSE 0 END) AS maintenance_copies
FROM dloar_db.physical_book pb
LEFT JOIN dloar_db.book_copy bc ON pb.book_id = bc.book_id
GROUP BY pb.book_id, pb.title, pb.isbn;

-- ---------------------------------------------------
-- Truy vấn 9: Tổng hợp doanh thu tiền phạt đã thu được theo từng tháng
-- ---------------------------------------------------
SELECT 
    DATE_FORMAT(f.payment_date, '%Y-%m') AS payment_month,
    COUNT(f.fine_id) AS total_fines_paid,
    SUM(f.fine_amount) AS total_revenue
FROM dloar_db.fine f
WHERE f.fine_status = 'Paid' 
  AND f.payment_date IS NOT NULL
GROUP BY DATE_FORMAT(f.payment_date, '%Y-%m')
ORDER BY payment_month DESC;

-- ---------------------------------------------------
-- Truy vấn 10: Tìm các tài liệu số thuộc nhiều hơn 1 danh mục (Đa ngành/Liên ngành)
-- ---------------------------------------------------
SELECT 
    di.item_id,
    di.title,
    di.doi,
    COUNT(ic.category_id) AS category_count,
    GROUP_CONCAT(c.category_name ORDER BY c.category_name SEPARATOR ' | ') AS categories_list
FROM dloar_db.digital_item di
JOIN dloar_db.item_category ic ON di.item_id = ic.item_id
JOIN dloar_db.category c ON ic.category_id = c.category_id
GROUP BY di.item_id, di.title, di.doi
HAVING COUNT(ic.category_id) > 1
ORDER BY category_count DESC;