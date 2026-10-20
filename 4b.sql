
USE dloar_db;

DROP TEMPORARY TABLE IF EXISTS tc_results;
CREATE TEMPORARY TABLE tc_results (
    seq         INT AUTO_INCREMENT PRIMARY KEY,
    test_id     VARCHAR(10),
    rule_ref    VARCHAR(30),
    description VARCHAR(200),
    expected    VARCHAR(120),
    actual      VARCHAR(255),
    verdict     VARCHAR(10)
);

DROP PROCEDURE IF EXISTS sp_tc;

DELIMITER //

CREATE PROCEDURE sp_tc (
    IN p_id        VARCHAR(10),
    IN p_rule      VARCHAR(30),
    IN p_desc      VARCHAR(200),
    IN p_pre       TEXT,
    IN p_action    TEXT,
    IN p_verify    TEXT,
    IN p_exp_errno INT,
    IN p_exp_text  VARCHAR(120)
)
BEGIN
    DECLARE v_errno   INT DEFAULT 0;
    DECLARE v_actual  VARCHAR(255);
    DECLARE v_verdict VARCHAR(10) DEFAULT 'FAIL';
    -- Mỗi mã lỗi mong đợi có một handler riêng (chỉ ghi lỗi ĐẦU TIÊN);
    -- handler SQLEXCEPTION cuối cùng bắt mọi lỗi còn lại (ghi -1).
    DECLARE CONTINUE HANDLER FOR 1062 SET v_errno = IF(v_errno = 0, 1062, v_errno);
    DECLARE CONTINUE HANDLER FOR 3819 SET v_errno = IF(v_errno = 0, 3819, v_errno);
    DECLARE CONTINUE HANDLER FOR 1452 SET v_errno = IF(v_errno = 0, 1452, v_errno);
    DECLARE CONTINUE HANDLER FOR 1451 SET v_errno = IF(v_errno = 0, 1451, v_errno);
    DECLARE CONTINUE HANDLER FOR 1644 SET v_errno = IF(v_errno = 0, 1644, v_errno);
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_errno = IF(v_errno = 0, -1, v_errno);

    SET @tc_actual = NULL;
    START TRANSACTION;

    IF p_pre IS NOT NULL THEN
        SET @tc_sql = p_pre;
        PREPARE tc_s1 FROM @tc_sql;
        EXECUTE tc_s1;
        DEALLOCATE PREPARE tc_s1;
    END IF;

    SET @tc_sql = p_action;
    PREPARE tc_s2 FROM @tc_sql;
    EXECUTE tc_s2;
    DEALLOCATE PREPARE tc_s2;

    IF v_errno = 0 AND p_verify IS NOT NULL THEN
        SET @tc_sql = p_verify;
        PREPARE tc_s3 FROM @tc_sql;
        EXECUTE tc_s3;
        DEALLOCATE PREPARE tc_s3;
    END IF;

    ROLLBACK;

    SET v_actual = CASE
        WHEN v_errno = 0  THEN 'Thành công (không bị chặn)'
        WHEN v_errno = -1 THEN 'Lỗi khác (không thuộc nhóm mong đợi)'
        ELSE CONCAT('ERROR ', v_errno)
    END;

    IF p_exp_errno IS NOT NULL THEN
        SET v_verdict = IF(v_errno = p_exp_errno, 'PASS', 'FAIL');
        INSERT INTO tc_results (test_id, rule_ref, description, expected, actual, verdict)
        VALUES (p_id, p_rule, p_desc, CONCAT('ERROR ', p_exp_errno), v_actual, v_verdict);
    ELSE
        IF v_errno = 0 THEN
            SET v_actual = COALESCE(@tc_actual, '(không có dữ liệu)');
        END IF;
        SET v_verdict = IF(v_errno = 0
            AND CONVERT(COALESCE(@tc_actual, '') USING utf8mb4)
              = CONVERT(p_exp_text USING utf8mb4), 'PASS', 'FAIL');
        INSERT INTO tc_results (test_id, rule_ref, description, expected, actual, verdict)
        VALUES (p_id, p_rule, p_desc, p_exp_text, v_actual, v_verdict);
    END IF;
END //

DELIMITER ;

-- Nhóm A – Ràng buộc miền giá trị và tính duy nhất
CALL sp_tc('TC-01', 'BR-01.4', 'Email trùng trong person',
     NULL,
     'INSERT INTO person (first_name, last_name, email) SELECT ''Trung'', ''Email'', email FROM person WHERE person_id = 1',
     NULL,
     1062, NULL);
CALL sp_tc('TC-02', 'BR-02.2', 'Hạn mức mượn = 0',
     NULL,
     'INSERT INTO member (person_id, member_code, membership_status, max_borrow_limit, expiry_date) VALUES (700, ''MEM999'', ''Active'', 0, ''2028-12-31'')',
     NULL,
     3819, NULL);
CALL sp_tc('TC-03', 'BR-02.1', 'Trạng thái thẻ sai miền giá trị',
     NULL,
     'UPDATE member SET membership_status = ''Banned'' WHERE person_id = 1',
     NULL,
     3819, NULL);
CALL sp_tc('TC-04', 'Mục 3.2', 'Mã thẻ thành viên trùng',
     NULL,
     'INSERT INTO member (person_id, member_code, expiry_date) SELECT 700, member_code, ''2028-12-31'' FROM member WHERE person_id = 1',
     NULL,
     1062, NULL);
CALL sp_tc('TC-05', 'Mục 3.4', 'ISBN trùng',
     NULL,
     'INSERT INTO physical_book (title, isbn) SELECT ''Sách trùng ISBN'', isbn FROM physical_book WHERE book_id = 1',
     NULL,
     1062, NULL);
CALL sp_tc('TC-06', 'Mục 3.4', 'Năm xuất bản < 1500',
     NULL,
     'UPDATE physical_book SET publication_year = 1400 WHERE book_id = 1',
     NULL,
     3819, NULL);
CALL sp_tc('TC-07', 'BR-03.1', 'Mã vạch bản sao trùng',
     NULL,
     'INSERT INTO book_copy (book_id, barcode) SELECT 1, barcode FROM book_copy WHERE copy_id = 1',
     NULL,
     1062, NULL);
CALL sp_tc('TC-08', 'BR-03.2', 'Trạng thái bản sao sai miền giá trị',
     NULL,
     'UPDATE book_copy SET copy_status = ''Broken'' WHERE copy_id = 1',
     NULL,
     3819, NULL);
CALL sp_tc('TC-09', 'BR-06.1', 'DOI trùng',
     NULL,
     'INSERT INTO digital_item (license_id, title, file_path, doi) SELECT 1, ''Tài liệu trùng DOI'', ''/repository/docs/tc09.pdf'', doi FROM digital_item WHERE item_id = 1',
     NULL,
     1062, NULL);
CALL sp_tc('TC-10', 'BR-06.3', 'Mức truy cập sai miền giá trị',
     NULL,
     'UPDATE digital_item SET access_level = ''Secret'' WHERE item_id = 1',
     NULL,
     3819, NULL);
CALL sp_tc('TC-11', 'BR-04.2', 'Hạn trả trước ngày mượn',
     NULL,
     'INSERT INTO borrow_transaction (member_id, copy_id, borrow_date, due_date) VALUES (1, 1, ''2026-08-20'', ''2026-08-10'')',
     NULL,
     3819, NULL);
CALL sp_tc('TC-12', 'BR-04.2', 'Ngày trả trước ngày mượn',
     NULL,
     'UPDATE borrow_transaction SET return_date = DATE_SUB(borrow_date, INTERVAL 1 DAY) WHERE transaction_id = 1',
     NULL,
     3819, NULL);
CALL sp_tc('TC-13', 'BR-05.2', 'Số tiền phạt âm',
     NULL,
     'UPDATE fine SET fine_amount = -1 WHERE fine_id = 1',
     NULL,
     3819, NULL);
CALL sp_tc('TC-14', 'BR-05.3', 'Trạng thái phạt sai miền giá trị',
     NULL,
     'UPDATE fine SET fine_status = ''Pending'' WHERE fine_id = 1',
     NULL,
     3819, NULL);
CALL sp_tc('TC-15', 'Mục 3.9', 'Hai khoản phạt cho một giao dịch',
     NULL,
     'INSERT INTO fine (transaction_id, fine_amount) SELECT transaction_id, 1000 FROM fine WHERE fine_id = 1',
     NULL,
     1062, NULL);
CALL sp_tc('TC-16', 'BR-07.2', 'Vai trò tác giả sách sai miền giá trị',
     NULL,
     'UPDATE book_author SET author_role = ''Reviewer'' WHERE book_id = 1 AND author_id = 602',
     NULL,
     3819, NULL);
CALL sp_tc('TC-17', 'BR-07.2', 'Thứ tự tác giả = 0',
     NULL,
     'UPDATE item_author SET author_order = 0 WHERE item_id = 1 AND author_id = 602',
     NULL,
     3819, NULL);
CALL sp_tc('TC-18', 'Mục 3.6', 'Mã giấy phép trùng',
     NULL,
     'INSERT INTO license (license_name, license_code) SELECT ''Giấy phép trùng mã'', license_code FROM license WHERE license_id = 1',
     NULL,
     1062, NULL);
CALL sp_tc('TC-19', 'Mục 3.10', 'Tên danh mục trùng',
     NULL,
     'INSERT INTO category (category_name) SELECT category_name FROM category WHERE category_id = 1',
     NULL,
     1062, NULL);
CALL sp_tc('TC-20', 'BR-01.4', 'ORCID trùng giữa hai tác giả',
     NULL,
     'INSERT INTO author (person_id, author_code, orcid) SELECT 1, ''AUT-TEST'', orcid FROM author WHERE person_id = 601',
     NULL,
     1062, NULL);

-- Nhóm B – Toàn vẹn tham chiếu (khóa ngoại, RESTRICT, CASCADE)
CALL sp_tc('TC-21', 'BR-01.3', 'Thành viên không có cá nhân tương ứng',
     NULL,
     'INSERT INTO member (person_id, member_code, expiry_date) VALUES (999999, ''MEM-X'', ''2028-12-31'')',
     NULL,
     1452, NULL);
CALL sp_tc('TC-22', 'BR-01.3', 'Tác giả không có cá nhân tương ứng',
     NULL,
     'INSERT INTO author (person_id, author_code) VALUES (999999, ''AUT-X'')',
     NULL,
     1452, NULL);
CALL sp_tc('TC-23', 'BR-06.2', 'Tài liệu số gắn giấy phép không tồn tại',
     NULL,
     'INSERT INTO digital_item (license_id, title, file_path) VALUES (999, ''Sai giấy phép'', ''/repository/docs/tc23.pdf'')',
     NULL,
     1452, NULL);
CALL sp_tc('TC-24', 'BR-08.1', 'Giao dịch mượn bản sao không tồn tại',
     NULL,
     'INSERT INTO borrow_transaction (member_id, copy_id, borrow_date, due_date) VALUES (1, 999999, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY))',
     NULL,
     1452, NULL);
CALL sp_tc('TC-25', 'BR-08.2', 'Xóa thành viên đang có lịch sử mượn',
     NULL,
     'DELETE FROM member WHERE person_id = 1',
     NULL,
     1451, NULL);
CALL sp_tc('TC-26', 'BR-08.2', 'Xóa đầu sách đang có bản sao',
     NULL,
     'DELETE FROM physical_book WHERE book_id = 1',
     NULL,
     1451, NULL);
CALL sp_tc('TC-27', 'BR-05.3', 'Xóa giao dịch đã có khoản phạt',
     NULL,
     'DELETE FROM borrow_transaction WHERE transaction_id = 1801',
     NULL,
     1451, NULL);
CALL sp_tc('TC-28', 'BR-08.2', 'Xóa giấy phép đang được dùng',
     NULL,
     'DELETE FROM license WHERE license_id = 1',
     NULL,
     1451, NULL);
CALL sp_tc('TC-29', 'BR-08.2', 'CASCADE: xóa cá nhân kéo theo hồ sơ tác giả và liên kết',
     NULL,
     'DELETE FROM person WHERE person_id = 601',
     'SELECT CONCAT_WS(''|'', (SELECT COUNT(*) FROM author WHERE person_id = 601), (SELECT COUNT(*) FROM book_author WHERE author_id = 601), (SELECT COUNT(*) FROM item_author WHERE author_id = 601)) INTO @tc_actual',
     NULL, '0|0|0');
CALL sp_tc('TC-30', 'BR-08.2', 'CASCADE: xóa tài liệu số kéo theo liên kết tác giả, danh mục',
     NULL,
     'DELETE FROM digital_item WHERE item_id = 3',
     'SELECT CONCAT_WS(''|'', (SELECT COUNT(*) FROM item_author WHERE item_id = 3), (SELECT COUNT(*) FROM item_category WHERE item_id = 3)) INTO @tc_actual',
     NULL, '0|0');

-- Nhóm C – Hành vi của trigger
CALL sp_tc('TC-31', 'BR-04.3', 'Tạo giao dịch mượn: bản sao chuyển Borrowed',
     NULL,
     'INSERT INTO borrow_transaction (member_id, copy_id, borrow_date, due_date) VALUES (1, 1, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY))',
     'SELECT copy_status INTO @tc_actual FROM book_copy WHERE copy_id = 1',
     NULL, 'Borrowed');
CALL sp_tc('TC-32', 'BR-04.3, BR-05.2', 'Trả trễ 5 ngày: bản sao Available, tự sinh phạt 5 x 5.000',
     NULL,
     'UPDATE borrow_transaction SET return_date = DATE_ADD(due_date, INTERVAL 5 DAY) WHERE transaction_id = 2551',
     'SELECT CONCAT_WS(''|'', (SELECT copy_status FROM book_copy WHERE copy_id = 52), (SELECT fine_amount FROM fine WHERE transaction_id = 2551), (SELECT fine_status FROM fine WHERE transaction_id = 2551)) INTO @tc_actual',
     NULL, 'Available|25000.00|Unpaid');
CALL sp_tc('TC-33', 'BR-05.1', 'Trả đúng hạn: không sinh khoản phạt',
     NULL,
     'UPDATE borrow_transaction SET return_date = CURRENT_DATE WHERE transaction_id = 3000',
     'SELECT CAST(COUNT(*) AS CHAR) INTO @tc_actual FROM fine WHERE transaction_id = 3000',
     NULL, '0');
CALL sp_tc('TC-34', 'BR-05.1', 'Sách chuyển Damaged: sinh phạt đền bù',
     NULL,
     'UPDATE book_copy SET copy_status = ''Damaged'' WHERE copy_id = 1001',
     'SELECT CONCAT_WS(''|'', fine_amount, fine_status) INTO @tc_actual FROM fine WHERE transaction_id = 1000',
     NULL, '50000.00|Unpaid');
CALL sp_tc('TC-35', 'BR-05.1', 'Sách chuyển Lost: sinh phạt đền bù',
     NULL,
     'UPDATE book_copy SET copy_status = ''Lost'' WHERE copy_id = 1002',
     'SELECT CONCAT_WS(''|'', fine_amount, fine_status) INTO @tc_actual FROM fine WHERE transaction_id = 1001',
     NULL, '200000.00|Unpaid');

-- Nhóm D – Quy tắc nghiệp vụ mượn – trả và ràng buộc mức cao
CALL sp_tc('TC-36', 'BR-05.3', 'Phạt Paid nhưng không có ngày thanh toán',
     NULL,
     'UPDATE fine SET fine_status = ''Paid'', payment_date = NULL WHERE fine_id = 1',
     NULL,
     3819, NULL);
CALL sp_tc('TC-37', 'BR-06.3', 'Embargoed nhưng thiếu ngày hết hạn embargo',
     NULL,
     'INSERT INTO digital_item (license_id, title, file_path, access_level, embargo_end_date) VALUES (1, ''Embargo thiếu ngày'', ''/repository/docs/tc37.pdf'', ''Embargoed'', NULL)',
     NULL,
     3819, NULL);
CALL sp_tc('TC-38', 'BR-02.1', 'Thành viên Suspended mượn sách',
     NULL,
     'INSERT INTO borrow_transaction (member_id, copy_id, borrow_date, due_date) VALUES (10, 1, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY))',
     NULL,
     1644, NULL);
CALL sp_tc('TC-39', 'BR-02.3', 'Thẻ hết hạn (member 7) mượn sách',
     NULL,
     'INSERT INTO borrow_transaction (member_id, copy_id, borrow_date, due_date) VALUES (7, 1, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY))',
     NULL,
     1644, NULL);
CALL sp_tc('TC-40', 'BR-02.3', 'Đạt hạn mức mượn tối đa',
     'UPDATE member SET max_borrow_limit = 1 WHERE person_id = 1052',
     'INSERT INTO borrow_transaction (member_id, copy_id, borrow_date, due_date) VALUES (1052, 1, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY))',
     NULL,
     1644, NULL);
CALL sp_tc('TC-41', 'BR-03.3', 'Mượn bản sao đang Lost',
     NULL,
     'INSERT INTO borrow_transaction (member_id, copy_id, borrow_date, due_date) VALUES (1, 2200, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY))',
     NULL,
     1644, NULL);
CALL sp_tc('TC-42', 'BR-03.3', 'Mượn bản sao đang Borrowed',
     NULL,
     'INSERT INTO borrow_transaction (member_id, copy_id, borrow_date, due_date) VALUES (1, 1500, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY))',
     NULL,
     1644, NULL);
CALL sp_tc('TC-43', 'BR-04.1', 'Bản sao đã có giao dịch đang hoạt động',
     NULL,
     'INSERT INTO borrow_transaction (member_id, copy_id, borrow_date, due_date) VALUES (1, 52, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY))',
     NULL,
     1644, NULL);

-- ===================================================
-- KẾT QUẢ: bảng chi tiết và bảng tổng hợp PASS/FAIL
-- ===================================================
SELECT test_id, rule_ref, description, expected, actual, verdict
FROM tc_results
ORDER BY seq;

SELECT verdict, COUNT(*) AS so_luong
FROM tc_results
GROUP BY verdict;

DROP PROCEDURE IF EXISTS sp_tc;
