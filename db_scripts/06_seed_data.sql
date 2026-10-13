-- ===================================================
-- SYSTEM: DIGITAL LIBRARY & OPEN-ACCESS REPOSITORY
-- FILE: 06_seed_data.sql (Tạo dữ liệu lớn ~16,000+ bản ghi)
-- ===================================================

USE dloar_db;

-- 1. Tắt kiểm tra khóa ngoại để làm sạch dữ liệu cũ
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE item_category;
TRUNCATE TABLE item_author;
TRUNCATE TABLE book_author;
TRUNCATE TABLE fine;
TRUNCATE TABLE borrow_transaction;
TRUNCATE TABLE digital_item;
TRUNCATE TABLE license;
TRUNCATE TABLE book_copy;
TRUNCATE TABLE physical_book;
TRUNCATE TABLE author;
TRUNCATE TABLE member;
TRUNCATE TABLE person;
TRUNCATE TABLE category;

SET FOREIGN_KEY_CHECKS = 1;

-- 2. Tạm thời drop Trigger để việc nạp dữ liệu không bị chậm / xung đột
DROP TRIGGER IF EXISTS trg_after_borrow_insert;
DROP TRIGGER IF EXISTS trg_after_borrow_update_return;
DROP TRIGGER IF EXISTS trg_after_copy_status_update_fine;

DELIMITER //

DROP PROCEDURE IF EXISTS sp_seed_dloar_large_data //
CREATE PROCEDURE sp_seed_dloar_large_data()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_person_id INT;
    DECLARE v_book_id INT;
    DECLARE v_copy_id INT;
    DECLARE v_item_id INT;
    DECLARE v_trans_id INT;
    
    -- ---------------------------------------------------
    -- A. SEED LICENSE (5 Giấy phép bản quyền mở)
    -- ---------------------------------------------------
    INSERT INTO license (license_name, license_code, terms_description) VALUES
    ('Creative Commons Attribution 4.0 International', 'CC BY 4.0', 'Tự do chia sẻ và điều chỉnh với điều kiện ghi công tác giả.'),
    ('Creative Commons Attribution-NonCommercial 4.0', 'CC BY-NC 4.0', 'Tự do chia sẻ phi thương mại có ghi công.'),
    ('Creative Commons Zero / Public Domain Dedication', 'CC0 1.0', 'Tài sản thuộc sở hữu công cộng, không ràng buộc bản quyền.'),
    ('MIT License', 'MIT', 'Cấp phép phần mềm/nghiên cứu mở với điều kiện giữ nguyên bản quyền.'),
    ('Restricted University License', 'RUL-INTERNAL', 'Giấy phép lưu hành nội bộ trường đại học.');

    -- ---------------------------------------------------
    -- B. SEED CATEGORY (10 Danh mục tri thức)
    -- ---------------------------------------------------
    INSERT INTO category (category_name, description) VALUES
    ('Khoa học Máy tính & Công nghệ Thông tin', 'Các nghiên cứu về AI, CSDL, Mạng máy tính và An toàn thông tin'),
    ('Kỹ thuật Điện tử & Viễn thông', 'Nghiên cứu về vi mạch, IoT, xử lý tín hiệu và truyền thông'),
    ('Kinh tế & Quản trị Kinh doanh', 'Tài chính, Marketing, Quản trị chuỗi cung ứng và Kinh tế học'),
    ('Toán học & Thống kê ứng dụng', 'Giải tích, Đại số, Mô hình hóa toán học và Data Science'),
    ('Vật lý & Khoa học Vật liệu', 'Vật lý bán dẫn, Vật liệu nano và Năng lượng tái tạo'),
    ('Hóa học & Công nghệ Thực phẩm', 'Hóa dược, Công nghệ sinh học và An toàn thực phẩm'),
    ('Khoa học Xã hội & Nhân văn', 'Xã hội học, Tâm lý học, Triết học và Lịch sử'),
    ('Ngoại ngữ & Ngôn ngữ học Ứng dụng', 'Phương pháp giảng dạy tiếng Anh, Ngôn ngữ học đối chiếu'),
    ('Y - Dược & Sức khỏe Cộng đồng', 'Y học cơ sở, Dược lâm sàng và Quản lý y tế'),
    ('Môi trường & Phát triển Bền vững', 'Biến đổi khí hậu, Xử lý chất thải và Năng lượng xanh');

    -- ---------------------------------------------------
    -- C. SEED PERSON, MEMBER, AUTHOR (1.500 Cá nhân)
    -- ---------------------------------------------------
    SET i = 1;
    WHILE i <= 1500 DO
        INSERT INTO person (first_name, last_name, email, phone_number)
        VALUES (
            CONCAT('Van_', i),
            CONCAT('Nguyen_', i),
            CONCAT('user', i, '@ptithcm.edu.vn'),
            CONCAT('09', LPAD(i, 8, '0'))
        );
        SET v_person_id = LAST_INSERT_ID();

        -- Case 1: ID 1 -> 600 (Chỉ là Độc giả / Member)
        IF i <= 600 THEN
            INSERT INTO member (person_id, member_code, membership_status, max_borrow_limit, expiry_date)
            VALUES (
                v_person_id,
                CONCAT('MEM', LPAD(i, 6, '0')),
                IF(i % 10 = 0, 'Suspended', IF(i % 7 = 0, 'Expired', 'Active')),
                IF(i % 5 = 0, 10, 5),
                IF(i % 7 = 0, '2025-12-31', '2028-12-31')
            );
            
        -- Case 2: ID 601 -> 900 (Chỉ là Tác giả / Author)
        ELSEIF i <= 900 THEN
            INSERT INTO author (person_id, author_code, affiliation, orcid, bio)
            VALUES (
                v_person_id,
                CONCAT('AUT', LPAD(i, 6, '0')),
                IF(i % 2 = 0, 'Học viện Công nghệ Bưu chính Viễn thông', 'Đại học Quốc gia TP.HCM'),
                CONCAT('0000-0002-', LPAD(i, 4, '0'), '-889X'),
                CONCAT('Chuyên gia nghiên cứu về hệ thống thông tin và trí tuệ nhân tạo ', i)
            );

        -- Case 3: ID 901 -> 1500 (Vừa là Độc giả Vừa là Tác giả - EER Overlap)
        ELSE
            INSERT INTO member (person_id, member_code, membership_status, max_borrow_limit, expiry_date)
            VALUES (
                v_person_id,
                CONCAT('MEM', LPAD(i, 6, '0')),
                IF(i % 15 = 0, 'Suspended', 'Active'),
                10,
                '2028-06-30'
            );

            INSERT INTO author (person_id, author_code, affiliation, orcid, bio)
            VALUES (
                v_person_id,
                CONCAT('AUT', LPAD(i, 6, '0')),
                'Khoa CNTT - PTIT HCM',
                CONCAT('0000-0003-', LPAD(i, 4, '0'), '-112Y'),
                CONCAT('Giảng viên kiêm Nghiên cứu sinh cấp cao ', i)
            );
        END IF;

        SET i = i + 1;
    END WHILE;

    -- ---------------------------------------------------
    -- D. SEED PHYSICAL_BOOK (1.000 Đầu sách)
    -- ---------------------------------------------------
    SET i = 1;
    WHILE i <= 1000 DO
        INSERT INTO physical_book (title, isbn, publisher, publication_year)
        VALUES (
            CONCAT('Giáo trình & Tài liệu Nghiên cứu Chuyên ngành Tập ', i),
            CONCAT('978-604-', LPAD(i, 5, '0'), '-1'),
            IF(i % 3 = 0, 'NXB Thông tin & Truyền thông', IF(i % 3 = 1, 'NXB Giáo dục', 'NXB Khoa học Kỹ thuật')),
            2010 + (i % 16)
        );
        SET v_book_id = LAST_INSERT_ID();

        -- Gán tác giả cho sách (Bảng book_author)
        INSERT INTO book_author (book_id, author_id, author_role)
        VALUES (v_book_id, 601 + (i % 300), 'Main Author');

        IF i % 2 = 0 THEN
            INSERT INTO book_author (book_id, author_id, author_role)
            VALUES (v_book_id, 901 + (i % 600), 'Co-Author');
        END IF;

        SET i = i + 1;
    END WHILE;

    -- ---------------------------------------------------
    -- E. SEED BOOK_COPY (2.500 Bản sao sách vật lý)
    -- ---------------------------------------------------
    SET i = 1;
    WHILE i <= 2500 DO
        INSERT INTO book_copy (book_id, barcode, copy_status, shelf_location)
        VALUES (
            1 + (i % 1000),
            CONCAT('BC-2026-', LPAD(i, 6, '0')),
            CASE 
                WHEN i <= 1400 THEN 'Available'
                WHEN i <= 1900 THEN 'Borrowed'
                WHEN i <= 2150 THEN 'Damaged'
                WHEN i <= 2350 THEN 'Lost'
                ELSE 'In_Maintenance'
            END,
            CONCAT('Kệ ', CHAR(65 + (i % 10)), (i % 10) + 1, '-Tầng ', (i % 4) + 1)
        );
        SET i = i + 1;
    END WHILE;

    -- ---------------------------------------------------
    -- F. SEED DIGITAL_ITEM (1.000 Tài liệu số)
    -- ---------------------------------------------------
    SET i = 1;
    WHILE i <= 1000 DO
        INSERT INTO digital_item (license_id, title, abstract, doi, file_path, file_format, access_level, embargo_end_date)
        VALUES (
            1 + (i % 5),
            CONCAT('Bài báo Khoa học & Công trình Nghiên cứu Số ', i),
            CONCAT('Tóm tắt báo cáo khoa học về công nghệ mới ứng dụng thực tiễn trong ngành ', i),
            CONCAT('10.1109/DLOAR.2026.', LPAD(i, 5, '0')),
            CONCAT('/repository/docs/2026/item_', LPAD(i, 5, '0'), '.pdf'),
            'PDF',
            CASE 
                WHEN i <= 600 THEN 'Public_Open_Access'
                WHEN i <= 800 THEN 'Restricted_Campus_Only'
                ELSE 'Embargoed'
            END,
            CASE 
                WHEN i > 800 AND i <= 900 THEN '2025-06-01' -- Embargo đã hết hạn (Phục vụ Test Query 6)
                WHEN i > 900 THEN '2027-12-31'            -- Embargo còn hiệu lực
                ELSE NULL
            END
        );
        SET v_item_id = LAST_INSERT_ID();

        -- Gán tác giả bài báo (item_author)
        INSERT INTO item_author (item_id, author_id, author_order, author_role)
        VALUES (v_item_id, 601 + (i % 300), 1, 'Principal Investigator');

        IF i % 3 = 0 THEN
            INSERT INTO item_author (item_id, author_id, author_order, author_role)
            VALUES (v_item_id, 901 + (i % 600), 2, 'Co-Author');
        END IF;

        -- Gán danh mục (item_category) - Bài số chẵn gán 2 danh mục (Phục vụ Test Query 10)
        INSERT INTO item_category (item_id, category_id)
        VALUES (v_item_id, 1 + (i % 10));

        IF i % 2 = 0 THEN
            INSERT INTO item_category (item_id, category_id)
            VALUES (v_item_id, 1 + ((i + 3) % 10));
        END IF;

        SET i = i + 1;
    END WHILE;

    -- ---------------------------------------------------
    -- G. SEED BORROW_TRANSACTION & FINE (3.000 Giao dịch mượn & Tiền phạt)
    -- ---------------------------------------------------
    SET i = 1;
    WHILE i <= 3000 DO
        SET v_person_id = IF(i <= 1500, 1 + (i % 600), 901 + (i % 600));
        SET v_copy_id = 1 + (i % 2500);

        -- Case A: Giao dịch đã hoàn tất (Trả sách đúng hạn)
        IF i <= 1800 THEN
            INSERT INTO borrow_transaction (member_id, copy_id, borrow_date, due_date, return_date)
            VALUES (
                v_person_id,
                v_copy_id,
                DATE_SUB(CURRENT_DATE, INTERVAL (3000 - i + 30) DAY),
                DATE_SUB(CURRENT_DATE, INTERVAL (3000 - i + 16) DAY),
                DATE_SUB(CURRENT_DATE, INTERVAL (3000 - i + 18) DAY)
            );

        -- Case B: Trả sách quá hạn -> Có phát sinh phạt (Test Unpaid / Paid)
        ELSEIF i <= 2550 THEN
            INSERT INTO borrow_transaction (member_id, copy_id, borrow_date, due_date, return_date)
            VALUES (
                v_person_id,
                v_copy_id,
                DATE_SUB(CURRENT_DATE, INTERVAL (3000 - i + 40) DAY),
                DATE_SUB(CURRENT_DATE, INTERVAL (3000 - i + 26) DAY),
                DATE_SUB(CURRENT_DATE, INTERVAL (3000 - i + 20) DAY)
            );
            SET v_trans_id = LAST_INSERT_ID();

            INSERT INTO fine (transaction_id, fine_amount, fine_reason, fine_status, payment_date)
            VALUES (
                v_trans_id,
                (6 * 5000.00),
                'Trả quá hạn 6 ngày',
                IF(i % 2 = 0, 'Paid', 'Unpaid'),
                IF(i % 2 = 0, CURRENT_DATE, NULL)
            );

        -- Case C: Đang trong quá trình mượn (Active loan: return_date IS NULL)
        ELSE
            INSERT INTO borrow_transaction (member_id, copy_id, borrow_date, due_date, return_date)
            VALUES (
                v_person_id,
                v_copy_id,
                DATE_SUB(CURRENT_DATE, INTERVAL (3000 - i + 2) DAY),
                DATE_ADD(CURRENT_DATE, INTERVAL (14 - (3000 - i)) DAY),
                NULL
            );
        END IF;

        SET i = i + 1;
    END WHILE;

END //

DELIMITER ;

-- 3. Chạy Thủ tục Nạp Dữ Liệu
CALL sp_seed_dloar_large_data();

-- 4. Dọn dẹp thủ tục tạm sau khi nạp xong
DROP PROCEDURE IF EXISTS sp_seed_dloar_large_data;

-- 5. Tái tạo lại 3 Trigger nghiệp vụ tự động cho hệ thống
DELIMITER //

CREATE TRIGGER trg_after_borrow_insert
AFTER INSERT ON borrow_transaction
FOR EACH ROW
BEGIN
    UPDATE book_copy 
    SET copy_status = 'Borrowed'
    WHERE copy_id = NEW.copy_id;
END //

CREATE TRIGGER trg_after_borrow_update_return
AFTER UPDATE ON borrow_transaction
FOR EACH ROW
BEGIN
    DECLARE v_days_overdue INT;
    DECLARE v_penalty_rate DECIMAL(10,2) DEFAULT 5000.00;
    
    IF NEW.return_date IS NOT NULL AND OLD.return_date IS NULL THEN
        UPDATE book_copy 
        SET copy_status = 'Available'
        WHERE copy_id = NEW.copy_id AND copy_status = 'Borrowed';
        
        IF NEW.return_date > NEW.due_date THEN
            SET v_days_overdue = DATEDIFF(NEW.return_date, NEW.due_date);
            
            INSERT INTO fine (
                transaction_id, fine_amount, fine_reason, fine_status
            )
            VALUES (
                NEW.transaction_id, 
                v_days_overdue * v_penalty_rate, 
                CONCAT('Trả quá hạn ', v_days_overdue, ' ngày'), 
                'Unpaid'
            );
        END IF;
    END IF;
END //

CREATE TRIGGER trg_after_copy_status_update_fine
AFTER UPDATE ON book_copy
FOR EACH ROW
BEGIN
    DECLARE v_active_trans_id INT;
    
    IF NEW.copy_status IN ('Damaged', 'Lost') AND OLD.copy_status != NEW.copy_status THEN
        SELECT transaction_id INTO v_active_trans_id
        FROM borrow_transaction
        WHERE copy_id = NEW.copy_id
        ORDER BY borrow_date DESC
        LIMIT 1;
        
        IF v_active_trans_id IS NOT NULL THEN
            INSERT INTO fine (transaction_id, fine_amount, fine_reason, fine_status)
            VALUES (
                v_active_trans_id,
                IF(NEW.copy_status = 'Lost', 200000.00, 50000.00),
                CONCAT('Tiền phạt đền bù do sách bị ', IF(NEW.copy_status = 'Lost', 'MẤT', 'HƯ HỎNG')),
                'Unpaid'
            );
        END IF;
    END IF;
END //

DELIMITER ;