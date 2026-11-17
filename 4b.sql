-- ===================================================
-- FILE: 04b_extra_constraints.sql
-- BỔ SUNG TRIGGER NGHIỆP VỤ MỨC CAO
-- ===================================================
USE dloar_db;
DROP TRIGGER IF EXISTS trg_before_borrow_insert; 
DROP TRIGGER IF EXISTS trg_after_copy_status_update; 
DROP TRIGGER IF EXISTS trg_after_copy_status_update_fine;
DELIMITER //

-- 1. Trigger kiểm tra điều kiện trước khi cho mượn sách (BR-02, BR-03.3, BR-04.1 / TC-38 -> TC-44)
CREATE TRIGGER trg_before_borrow_insert
BEFORE INSERT ON borrow_transaction
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_expiry DATE;
    DECLARE v_limit INT;
    DECLARE v_active_loans INT;
    DECLARE v_unpaid_fines DECIMAL(10, 2);
    DECLARE v_copy_status VARCHAR(20);
    DECLARE v_copy_active INT;

    -- Kiểm tra thông tin thành viên
    SELECT membership_status, expiry_date, max_borrow_limit
    INTO v_status, v_expiry, v_limit
    FROM member
    WHERE person_id = NEW.member_id;

    IF v_status <> 'Active' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loi BR-02.1: Tai khoan thanh vien khong o trang thai Active.';
    END IF;

    IF v_expiry < NEW.borrow_date THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loi BR-02.3: The thanh vien da het han su dung.';
    END IF;

    -- Kiểm tra số sách đang mượn hiện tại
    SELECT COUNT(*)
    INTO v_active_loans
    FROM borrow_transaction
    WHERE member_id = NEW.member_id
      AND return_date IS NULL;

    IF v_active_loans >= v_limit THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loi BR-02.3: Thanh vien da dat han muc muon toi da.';
    END IF;

    -- Kiểm tra tổng nợ phạt chưa thanh toán vượt ngưỡng 100.000 VNĐ (BR-02.3)
    SELECT COALESCE(SUM(f.fine_amount), 0.00)
    INTO v_unpaid_fines
    FROM fine f
    JOIN borrow_transaction bt 
        ON f.transaction_id = bt.transaction_id
    WHERE bt.member_id = NEW.member_id
      AND f.fine_status = 'Unpaid';

    IF v_unpaid_fines > 100000.00 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loi BR-02.3: Thanh vien co khoan no phat chua thanh toan vuot nguong cho phep.';
    END IF;

    -- Kiểm tra trạng thái bản sao sách (BR-03.3)
    SELECT copy_status
    INTO v_copy_status
    FROM book_copy
    WHERE copy_id = NEW.copy_id;

    IF v_copy_status <> 'Available' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loi BR-03.3: Ban sao sach khong o trang thai Available.';
    END IF;

    -- Kiểm tra bản sao có đang nằm trong giao dịch chưa trả nào khác không (BR-04.1)
    SELECT COUNT(*)
    INTO v_copy_active
    FROM borrow_transaction
    WHERE copy_id = NEW.copy_id
      AND return_date IS NULL;

    IF v_copy_active > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loi BR-04.1: Ban sao sach dang nam trong mot giao dich chua tra.';
    END IF;
END //

-- 2. Trigger tự động sinh phạt đền bù khi sách đang mượn chuyển sang Damaged hoặc Lost (BR-05.1 / TC-34, TC-35)
CREATE TRIGGER trg_after_copy_status_update
AFTER UPDATE ON book_copy
FOR EACH ROW
BEGIN
    DECLARE v_active_tx_id INT;

    -- Chỉ xử lý phạt độc giả khi bản sao đang ở trạng thái Borrowed
    IF NEW.copy_status IN ('Damaged', 'Lost') 
       AND OLD.copy_status = 'Borrowed' THEN
        -- Tìm giao dịch đang mượn hiện tại (chưa trả) của bản sao này
        SELECT transaction_id
        INTO v_active_tx_id
        FROM borrow_transaction
        WHERE copy_id = NEW.copy_id
          AND return_date IS NULL
        ORDER BY borrow_date DESC, transaction_id DESC
        LIMIT 1;

        IF v_active_tx_id IS NOT NULL THEN
            IF NEW.copy_status = 'Damaged' THEN
                INSERT INTO fine (
                    transaction_id, fine_amount, 
                    fine_reason, fine_status
                )
                VALUES (
                    v_active_tx_id, 50000.00, 
                    'Den bu lam hu hong sach', 'Unpaid'
                );
            ELSEIF NEW.copy_status = 'Lost' THEN
                INSERT INTO fine (
                    transaction_id, fine_amount, 
                    fine_reason, fine_status
                )
                VALUES (
                    v_active_tx_id, 200000.00, 
                    'Den bu lam mat sach', 'Unpaid'
                );
            END IF;
        END IF;
    END IF;
END //

DELIMITER ;
