-- ===================================================
-- SYSTEM: DIGITAL LIBRARY & OPEN-ACCESS REPOSITORY
-- FILE: 07a_rbac_setup.sql  (5.2 Thiết lập phân quyền (RBAC))
-- Chạy bằng root, sau khi đã chạy 00..04 và 06_seed_data.sql.
-- Mật khẩu bên dưới chỉ dùng để DEMO.
-- ===================================================

USE dloar_db;

-- 1. Tạo các vai trò (Roles)
CREATE ROLE IF NOT EXISTS 'role_admin';
CREATE ROLE IF NOT EXISTS 'role_librarian';
CREATE ROLE IF NOT EXISTS 'role_reader';

-- 2. Admin: toàn quyền hệ thống
GRANT ALL PRIVILEGES ON dloar_db.* TO 'role_admin';

-- 3. Thủ thư: sách, độc giả, giao dịch mượn/trả, cập nhật tiền phạt
GRANT SELECT, INSERT, UPDATE ON dloar_db.person TO 'role_librarian';
GRANT SELECT, INSERT, UPDATE ON dloar_db.physical_book TO 'role_librarian';
GRANT SELECT, INSERT, UPDATE ON dloar_db.book_copy TO 'role_librarian';
GRANT SELECT, INSERT, UPDATE ON dloar_db.member TO 'role_librarian';
GRANT SELECT, INSERT, UPDATE ON dloar_db.borrow_transaction TO 'role_librarian';
GRANT SELECT ON dloar_db.fine TO 'role_librarian';
GRANT UPDATE (fine_status, payment_date) ON dloar_db.fine TO 'role_librarian';
GRANT SELECT ON dloar_db.vw_active_loans TO 'role_librarian';
GRANT SELECT ON dloar_db.vw_unpaid_fines_summary TO 'role_librarian';

-- 4. Độc giả: chỉ tra cứu công khai
GRANT SELECT ON dloar_db.vw_public_repository_catalog TO 'role_reader';
GRANT SELECT (book_id, title, isbn, publisher, publication_year)
    ON dloar_db.physical_book TO 'role_reader';
GRANT SELECT (copy_id, book_id, copy_status, shelf_location)
    ON dloar_db.book_copy TO 'role_reader';

-- 5. Tài khoản demo và gán vai trò mặc định
CREATE USER IF NOT EXISTS 'admin_user'@'localhost' IDENTIFIED BY 'AdminPass123!';
GRANT 'role_admin' TO 'admin_user'@'localhost';
SET DEFAULT ROLE 'role_admin' TO 'admin_user'@'localhost';

CREATE USER IF NOT EXISTS 'librarian_user'@'localhost' IDENTIFIED BY 'LibPass123!';
GRANT 'role_librarian' TO 'librarian_user'@'localhost';
SET DEFAULT ROLE 'role_librarian' TO 'librarian_user'@'localhost';

CREATE USER IF NOT EXISTS 'reader_user'@'localhost' IDENTIFIED BY 'ReaderPass123!';
GRANT 'role_reader' TO 'reader_user'@'localhost';
SET DEFAULT ROLE 'role_reader' TO 'reader_user'@'localhost';

-- 6. (Tùy chọn) Dọn dẹp khi cần chạy lại
-- DROP USER IF EXISTS 'admin_user'@'localhost', 'librarian_user'@'localhost',
--     'reader_user'@'localhost';
-- DROP ROLE IF EXISTS 'role_admin', 'role_librarian', 'role_reader';

-- 7. Thủ tục kiểm thử phân quyền (chạy bằng quyền của NGƯỜI GỌI, SQL SECURITY INVOKER)
--    Chỉ phục vụ chạy thử; được cấp EXECUTE trực tiếp cho 3 tài khoản demo,
--    không làm thay đổi quyền của các vai trò ở trên.
DROP PROCEDURE IF EXISTS sp_rbac_try;
DROP PROCEDURE IF EXISTS sp_rbac_probe;

DELIMITER //

CREATE PROCEDURE sp_rbac_try (
    IN p_id        VARCHAR(10),
    IN p_sql       TEXT,
    IN p_exp_errno INT
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_errno INT DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR 1142 SET v_errno = IF(v_errno = 0, 1142, v_errno);
    DECLARE CONTINUE HANDLER FOR 1143 SET v_errno = IF(v_errno = 0, 1143, v_errno);
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_errno = IF(v_errno = 0, -1, v_errno);

    START TRANSACTION;
    SET @rbac_stmt = p_sql;
    PREPARE rbac_s FROM @rbac_stmt;
    EXECUTE rbac_s;
    DEALLOCATE PREPARE rbac_s;
    ROLLBACK;

    SET @rbac_row = CONCAT(
        'SELECT ', QUOTE(p_id), ' AS test_id, ',
        QUOTE(LEFT(p_sql, 90)), ' AS statement_text, ',
        QUOTE(IF(p_exp_errno = 0, 'Thành công', CONCAT('ERROR ', p_exp_errno))), ' AS expected, ',
        QUOTE(IF(v_errno = 0, 'Thành công', CONCAT('ERROR ', v_errno))), ' AS actual, ',
        QUOTE(IF(v_errno = p_exp_errno, 'PASS', 'FAIL')), ' AS verdict');
    SET @rbac_union = IF(@rbac_union IS NULL, @rbac_row,
                         CONCAT(@rbac_union, ' UNION ALL ', @rbac_row));
END //

CREATE PROCEDURE sp_rbac_probe ()
SQL SECURITY INVOKER
BEGIN
    DECLARE v_who VARCHAR(64);
    SET v_who = SUBSTRING_INDEX(USER(), '@', 1);
    SET @rbac_union = NULL;

    IF v_who = 'reader_user' THEN
        CALL sp_rbac_try('R-01', 'SELECT COUNT(*) INTO @rbac_n FROM (SELECT item_id, title FROM vw_public_repository_catalog LIMIT 5) AS t', 0);
        CALL sp_rbac_try('R-02', 'SELECT COUNT(*) INTO @rbac_n FROM (SELECT book_id, title, isbn FROM physical_book LIMIT 5) AS t', 0);
        CALL sp_rbac_try('R-03', 'SELECT COUNT(*) INTO @rbac_n FROM (SELECT * FROM book_copy LIMIT 1) AS t', 1142);
        CALL sp_rbac_try('R-03b', 'SELECT barcode INTO @rbac_n FROM book_copy LIMIT 1', 1143);
        CALL sp_rbac_try('R-04', 'SELECT COUNT(*) INTO @rbac_n FROM (SELECT email FROM person LIMIT 1) AS t', 1142);
        CALL sp_rbac_try('R-05', 'INSERT INTO book_copy (book_id, barcode) VALUES (1, ''BC-RBAC-01'')', 1142);
    ELSEIF v_who = 'librarian_user' THEN
        CALL sp_rbac_try('R-06', 'SELECT COUNT(*) INTO @rbac_n FROM (SELECT * FROM vw_active_loans LIMIT 5) AS t', 0);
        CALL sp_rbac_try('R-07', 'INSERT INTO person (first_name, last_name, email) VALUES (''Thu'', ''Quyen'', ''rbac@test.local'')', 0);
        CALL sp_rbac_try('R-08', 'UPDATE book_copy SET shelf_location = ''Ke TEST'' WHERE copy_id = 1', 0);
        CALL sp_rbac_try('R-09', 'UPDATE fine SET fine_status = ''Paid'', payment_date = CURRENT_DATE WHERE fine_id = 1', 0);
        CALL sp_rbac_try('R-10', 'UPDATE fine SET fine_amount = 0 WHERE fine_id = 1', 1143);
        CALL sp_rbac_try('R-11', 'DELETE FROM fine WHERE fine_id = 1', 1142);
        CALL sp_rbac_try('R-12', 'DELETE FROM borrow_transaction WHERE transaction_id = 1', 1142);
        CALL sp_rbac_try('R-13', 'INSERT INTO digital_item (license_id, title, file_path) VALUES (1, ''Trai quyen'', ''/repository/docs/x.pdf'')', 1142);
        CALL sp_rbac_try('R-14', 'SELECT COUNT(*) INTO @rbac_n FROM (SELECT * FROM license LIMIT 1) AS t', 1142);
    ELSEIF v_who = 'admin_user' THEN
        CALL sp_rbac_try('R-15', 'SELECT COUNT(*) INTO @rbac_n FROM fine', 0);
    END IF;

    IF @rbac_union IS NULL THEN
        SELECT 'Hay dang nhap bang reader_user, librarian_user hoac admin_user roi chay lai' AS thong_bao;
    ELSE
        SET @rbac_final = @rbac_union;
        PREPARE rbac_f FROM @rbac_final;
        EXECUTE rbac_f;
        DEALLOCATE PREPARE rbac_f;
    END IF;
END //

DELIMITER ;

GRANT EXECUTE ON PROCEDURE dloar_db.sp_rbac_try TO 'reader_user'@'localhost';
GRANT EXECUTE ON PROCEDURE dloar_db.sp_rbac_probe TO 'reader_user'@'localhost';
GRANT EXECUTE ON PROCEDURE dloar_db.sp_rbac_try TO 'librarian_user'@'localhost';
GRANT EXECUTE ON PROCEDURE dloar_db.sp_rbac_probe TO 'librarian_user'@'localhost';
GRANT EXECUTE ON PROCEDURE dloar_db.sp_rbac_try TO 'admin_user'@'localhost';
GRANT EXECUTE ON PROCEDURE dloar_db.sp_rbac_probe TO 'admin_user'@'localhost';

-- 8. Kiểm tra quyền hiệu lực của thủ thư
SHOW GRANTS FOR 'librarian_user'@'localhost' USING 'role_librarian';
