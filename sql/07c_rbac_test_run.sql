-- ===================================================
-- SYSTEM: DIGITAL LIBRARY & OPEN-ACCESS REPOSITORY
-- FILE: 07c_rbac_test_run.sql  (5.2 Kiểm thử phân quyền)
-- Chạy 07a_rbac_setup.sql bằng root trước.
-- Sau đó đăng nhập lần lượt bằng reader_user, librarian_user, admin_user và chạy file này.
-- Thủ tục tự nhận tài khoản đang đăng nhập và chạy đúng kịch bản của vai trò đó.
-- ===================================================

USE dloar_db;
CALL sp_rbac_probe();
