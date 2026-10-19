-- ===================================================
-- SYSTEM: DIGITAL LIBRARY & OPEN-ACCESS REPOSITORY
-- FILE: 07d_revoke_demo.sql  (5.2 Thu hồi quyền REVOKE)
-- Chạy bằng root. Có 3 tab kết quả:
--   (1) quyền của role_librarian trước khi thu hồi
--   (2) sau REVOKE: không còn INSERT trên borrow_transaction
--   (3) sau khi GRANT lại: quyền được khôi phục như ban đầu
-- ===================================================

USE dloar_db;

SHOW GRANTS FOR 'role_librarian'@'%';

REVOKE INSERT ON dloar_db.borrow_transaction FROM 'role_librarian';
SHOW GRANTS FOR 'role_librarian'@'%';

GRANT INSERT ON dloar_db.borrow_transaction TO 'role_librarian';
SHOW GRANTS FOR 'role_librarian'@'%';
