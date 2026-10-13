-- ===================================================
-- SYSTEM: DIGITAL LIBRARY & OPEN-ACCESS REPOSITORY
-- FILE: 04_triggers.sql
-- ===================================================

USE dloar_db;

DELIMITER //

-- Trigger 1: Tự động cập nhật trạng thái 'Borrowed' khi mượn sách
DROP TRIGGER IF EXISTS dloar_db.trg_after_borrow_insert //
CREATE TRIGGER dloar_db.trg_after_borrow_insert
AFTER INSERT ON dloar_db.borrow_transaction
FOR EACH ROW
BEGIN
    UPDATE dloar_db.book_copy 
    SET copy_status = 'Borrowed'
    WHERE copy_id = NEW.copy_id;
END //

-- Trigger 2: Cập nhật trạng thái Available và tính tiền phạt quá hạn khi trả sách
DROP TRIGGER IF EXISTS dloar_db.trg_after_borrow_update_return //
CREATE TRIGGER dloar_db.trg_after_borrow_update_return
AFTER UPDATE ON dloar_db.borrow_transaction
FOR EACH ROW
BEGIN
    DECLARE v_days_overdue INT;
    DECLARE v_penalty_rate DECIMAL(10,2) DEFAULT 5000.00;
    
    IF NEW.return_date IS NOT NULL AND OLD.return_date IS NULL THEN
        -- Chỉ cập nhật về Available nếu bản sao chưa bị ghi nhận Damaged/Lost trước đó
        UPDATE dloar_db.book_copy 
        SET copy_status = 'Available'
        WHERE copy_id = NEW.copy_id AND copy_status = 'Borrowed';
        
        -- Tính tiền phạt quá hạn nếu return_date > due_date
        IF NEW.return_date > NEW.due_date THEN
            SET v_days_overdue = DATEDIFF(NEW.return_date, NEW.due_date);
            
            INSERT INTO dloar_db.fine (
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

-- Trigger 3: Phạt đền bù khi chuyển trạng thái sách sang 'Damaged' hoặc 'Lost'
DROP TRIGGER IF EXISTS dloar_db.trg_after_copy_status_update_fine //
CREATE TRIGGER dloar_db.trg_after_copy_status_update_fine
AFTER UPDATE ON dloar_db.book_copy
FOR EACH ROW
BEGIN
    DECLARE v_active_trans_id INT;
    
    IF NEW.copy_status IN ('Damaged', 'Lost') AND OLD.copy_status != NEW.copy_status THEN
        -- Tìm giao dịch mượn gần nhất liên quan đến bản sao này
        SELECT transaction_id INTO v_active_trans_id
        FROM dloar_db.borrow_transaction
        WHERE copy_id = NEW.copy_id
        ORDER BY borrow_date DESC
        LIMIT 1;
        
        IF v_active_trans_id IS NOT NULL THEN
            INSERT INTO dloar_db.fine (transaction_id, fine_amount, fine_reason, fine_status)
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