-- 1. Khởi tạo Database
SOURCE 00_init_db.sql;

-- 2. Tạo từng Bảng theo đúng thứ tự
SOURCE tables/01_person.sql;
SOURCE tables/02_member.sql;
SOURCE tables/03_author.sql;
SOURCE tables/04_physical_book.sql;
SOURCE tables/05_book_copy.sql;
SOURCE tables/06_license.sql;
SOURCE tables/07_digital_item.sql;
SOURCE tables/08_borrow_transaction.sql;
SOURCE tables/09_fine.sql;
SOURCE tables/10_category.sql;
SOURCE tables/11_book_author.sql;
SOURCE tables/12_item_author.sql;
SOURCE tables/13_item_category.sql;

-- 3. Tạo Indexes, Views & Triggers
SOURCE 02_indexes.sql;
SOURCE 03_views.sql;
SOURCE 04_triggers.sql;