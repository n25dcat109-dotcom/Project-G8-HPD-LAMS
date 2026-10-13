-- ===================================================
-- SYSTEM: DIGITAL LIBRARY & OPEN-ACCESS REPOSITORY
-- FILE: 07_security_and_tests.sql (Verification & RBAC Security)
-- ===================================================

USE dloar_db;

-- ===================================================
-- 5.1 KỊCH BẢN KIỂM THỬ RÀNG BUỘC TOÀN VẸN (CONSTRAINT TEST CASES)
-- ===================================================

-- Test Case 1: Thêm mới Email trùng lặp vào bảng PERSON (Kiểm tra uq_person_email)
-- Kết quả mong đợi: FAIL (ERROR 1062: Duplicate entry)
INSERT INTO dloar_db.person (first_name, last_name, email) 
VALUES ('An', 'Nguyễn', 'n25dcat107@gmail.student.ptithcm.edu.vn');

-- Test Case 2: Thêm Member có giới hạn mượn <= 0 (Kiểm tra chk_member_max_borrow)
-- Kết quả mong đợi: FAIL (ERROR 3819: Check constraint violated)
INSERT INTO dloar_db.member (person_id, member_code, membership_status, max_borrow_limit, expiry_date)
VALUES (1, 'MEM999', 'Active', 0, '2026-12-31');

-- Test Case 3: Thêm Giao dịch mượn có due_date nhỏ hơn borrow_date (Kiểm tra chk_borrow_due_dates)
-- Kết quả mong đợi: FAIL (ERROR 3819: Check constraint violated)
INSERT INTO dloar_db.borrow_transaction (member_id, copy_id, borrow_date, due_date)
VALUES (1, 1, '2026-08-20', '2026-08-10');

-- Test Case 4: Xóa bản ghi MEMBER khi đang có lịch sử mượn sách (Kiểm tra ON DELETE RESTRICT)
-- Kết quả mong đợi: FAIL (ERROR 1451: Cannot delete or update a parent row)
DELETE FROM dloar_db.member WHERE person_id = 1;


-- ===================================================
-- 5.2 THIẾT LẬP BẢO MẬT VÀ PHÂN QUYỀN TRUY CẬP (RBAC DEFINITION)
-- ===================================================

-- 1. Tạo các vai trò (Roles)
CREATE ROLE IF NOT EXISTS 'role_admin';
CREATE ROLE IF NOT EXISTS 'role_librarian';
CREATE ROLE IF NOT EXISTS 'role_reader';

-- 2. Phân quyền cho Vai trò Admin (Toàn quyền hệ thống)
GRANT ALL PRIVILEGES ON dloar_db.* TO 'role_admin';

-- 3. Phân quyền cho Vai trò Thủ thư (Librarian)
-- Quản lý sách, độc giả, giao dịch mượn/trả, cập nhật tiền phạt
GRANT SELECT, INSERT, UPDATE ON dloar_db.physical_book TO 'role_librarian';
GRANT SELECT, INSERT, UPDATE ON dloar_db.book_copy TO 'role_librarian';
GRANT SELECT, INSERT, UPDATE ON dloar_db.member TO 'role_librarian';
GRANT SELECT, INSERT, UPDATE ON dloar_db.borrow_transaction TO 'role_librarian';
GRANT SELECT, INSERT, UPDATE ON dloar_db.fine TO 'role_librarian';
GRANT SELECT ON dloar_db.vw_active_loans TO 'role_librarian';
GRANT SELECT ON dloar_db.vw_unpaid_fines_summary TO 'role_librarian';

-- 4. Phân quyền cho Vai trò Độc giả/Sinh viên (Reader)
-- Chỉ có quyền xem danh mục tài liệu số mở và tra cứu thông tin sách
GRANT SELECT ON dloar_db.vw_public_repository_catalog TO 'role_reader';
GRANT SELECT (book_id, title, isbn, publisher, publication_year) ON dloar_db.physical_book TO 'role_reader';
GRANT SELECT (copy_id, book_id, copy_status, shelf_location) ON dloar_db.book_copy TO 'role_reader';

-- 5. Áp dụng cấp Vai trò cho Người dùng cụ thể
CREATE USER IF NOT EXISTS 'librarian_user'@'localhost' IDENTIFIED BY 'LibPass123!';
GRANT 'role_librarian' TO 'librarian_user'@'localhost';
SET DEFAULT ROLE 'role_librarian' TO 'librarian_user'@'localhost';

FLUSH PRIVILEGES;