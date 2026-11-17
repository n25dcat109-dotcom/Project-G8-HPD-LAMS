# Digital Library & Open-Access Repository Management System (DLOAR)

> **Project Title:** Design and Implementation of a Relational Database for Academic Open-Access Digital Library and Repository System  
> **Course:** Database Management Systems / Cơ sở dữ liệu (PTITHCM)  
> **Instructor:** ThS. Lê Hà Thanh (`lehathanh@ptithcm.edu.vn`) — *Đã được thêm vào repository với quyền thành viên dự án*  
> **Due Date:** 26/08/2026 (Week 3)

---

## 👥 Project Identity & Team Members

* **Team Name:** G8
* **Repository URL:** `<Điền đường dẫn GitHub Repo của nhóm tại đây>`
* **Team Members (Sinh viên PTITHCM):**

| STT | Họ và Tên | MSSV | Lớp / Khóa học | Email Sinh viên (PTITHCM) | GitHub |
| :---: | :--- | :---: | :---: | :--- | :--- |
| 1 | **Nguyễn Trung Thiện** | `N25DCAT107` | `D25CQAT02-N` (Khóa 2025) | `n25dcat107@student.ptithcm.edu.vn` | [@thiennguyentrung123-png](https://github.com/thiennguyentrung123-png) |
| 2 | **Trần Nguyễn Quốc Thịnh** | `N25DCAT109` | `D25CQAT02-N` (Khóa 2025) | `n25dcat109@student.ptithcm.edu.vn` | [@n25dcat109-dotcom](https://github.com/n25dcat109-dotcom) |
| 3 | **Nguyễn Phúc Thịnh** | `N22DCCN182` | ` D22CQCN02-N` (Khóa 2022) | `n22dccn182@student.ptithcm.edu.vn` | [@Darkbreaker2412](https://github.com/Darkbreaker2412) |

---

## 📂 Repository Structure

```text
├── docs/                                      # Tài liệu thiết kế, sơ đồ và báo cáo chi tiết
│   ├── G8_CoSoDuLieu_DLOAR.pdf                # Tập tin báo cáo chi tiết đồ án (PDF nộp giảng viên)
│   └── images/                                # Thư mục chứa các hình ảnh sơ đồ & minh chứng kiểm thử
│       ├── fig_2_1_eer_diagram.png            # Hình 2.1 – Sơ đồ Thực thể - Liên kết Mở rộng (Conceptual EER)
│       ├── fig_2_2_logical_schema.png         # Hình 2.2 – Sơ đồ Lược đồ Quan hệ (Logical Schema)
│       └── fig_5_1_to_5_7_rbac_*.png          # Hình 5.1 – 5.7 – Minh chứng kết quả kiểm thử RBAC
├── sql/                                       # Toàn bộ mã nguồn SQL (chuẩn SQLStyle.guide)
│   ├── 00_init_db.sql                         # Khởi tạo cơ sở dữ liệu dloar_db (utf8mb4_unicode_ci)
│   ├── 01_tables.sql                          # Định nghĩa 13 bảng dữ liệu & các ràng buộc toàn vẹn
│   ├── 02_indexes.sql                         # Tạo 6 chỉ mục (Indexes) tối ưu hóa hiệu năng truy vấn
│   ├── 03_views.sql                           # Tạo 3 khung nhìn (Views) thống kê & danh mục công khai
│   ├── 04_triggers.sql                        # Cài đặt Triggers tự động hóa nghiệp vụ mượn – trả – phạt
│   ├── 04b_extra_constraints.sql              # Bổ sung Triggers kiểm tra điều kiện mượn & phạt đền bù
│   ├── 06_seed_data.sql                       # Tập dữ liệu mẫu (~16.000 dòng) phục vụ vận hành & kiểm thử
│   ├── 06b_advanced_queries.sql               # Bộ 10 truy vấn phức hợp (CTE, Window Functions, JOIN)
│   ├── 07a_rbac_setup.sql                     # Thiết lập phân quyền theo vai trò (RBAC: Roles, Users, GRANT)
│   ├── 07b_tests.sql                          # Bộ 44 kịch bản kiểm thử toàn vẹn dữ liệu (TC-01 -> TC-44)
│   ├── 07c_rbac_test_run.sql                  # Bộ 16 kịch bản kiểm thử phân quyền (R-01 -> R-15)
│   ├── 07d_revoke_demo.sql                    # Kịch bản kiểm thử thu hồi quyền (REVOKE & SHOW GRANTS)
│   └── run_all.sql                            # Script tổng hợp chạy tự động toàn bộ CSDL
├── app/                                       # Ứng dụng minh họa kết nối CSDL (Phase 4)
└── README.md                                  # Tài liệu hướng dẫn và báo cáo kỹ thuật tổng quan
```

---

## 🚀 Hướng dẫn Cài đặt, Triển khai & Vận hành

### 1. Yêu cầu Môi trường
* **Hệ quản trị CSDL:** MySQL Server **8.0.16** trở lên (bắt buộc để hỗ trợ đầy đủ ràng buộc `CHECK` và `ROLE`), sử dụng Storage Engine `InnoDB`.
* **Công cụ quản trị:** MySQL Workbench 8.0+, DBeaver hoặc MySQL Command Line Client.

### 2. Các bước Triển khai Cơ sở dữ liệu
1. **Clone repository về máy cục bộ:**
   ```bash
   git clone <URL_REPO_CUA_NHOM>
   cd <TEN_THU_MUC_REPO>
   ```
2. **Khởi tạo Schema, Triggers và Nạp dữ liệu mẫu:**
   Đăng nhập vào MySQL bằng tài khoản quản trị (`root`) và chạy tuần tự các tệp SQL hoặc chạy tệp tổng hợp `run_all.sql`:
   ```bash
   mysql -u root -p < sql/run_all.sql
   ```
   *(Nếu chạy thủ công từng tệp trong MySQL Workbench, vui lòng thực thi theo đúng thứ tự: `00_init_db.sql` $\rightarrow$ `01_tables.sql` $\rightarrow$ `02_indexes.sql` $\rightarrow$ `03_views.sql` $\rightarrow$ `04_triggers.sql` $\rightarrow$ `04b_extra_constraints.sql` $\rightarrow$ `06_seed_data.sql`).*

### 3. Vận hành, Kiểm thử & Phân quyền (RBAC)
* **Thiết lập Phân quyền Bảo mật (`07a_rbac_setup.sql`):** Chạy bằng tài khoản `root` để khởi tạo 3 vai trò và 3 tài khoản dùng thử (mật khẩu chỉ phục vụ mục đích demo):
  * **Quản trị viên (`role_admin`):** `admin_user`@`localhost` | Mật khẩu: `AdminPass123!`
  * **Thủ thư (`role_librarian`):** `librarian_user`@`localhost` | Mật khẩu: `LibPass123!`
  * **Độc giả (`role_reader`):** `reader_user`@`localhost` | Mật khẩu: `ReaderPass123!`
* **Kiểm thử Toàn vẹn Dữ liệu (`07b_tests.sql`):** Mở file bằng tài khoản `root` và nhấn **Execute (Biểu tượng tia sét)**. Tất cả 44 kịch bản (`TC-01` đến `TC-44`) đều chạy trong khối `START TRANSACTION ... ROLLBACK` nên giữ nguyên vẹn dữ liệu mẫu.
* **Kiểm thử Bảo mật (`07c_rbac_test_run.sql` & `07d_revoke_demo.sql`):** Tạo 3 kết nối riêng biệt cho 3 tài khoản trên để chạy kiểm thử phân quyền (`R-01` đến `R-15`), và dùng `root` chạy `07d_revoke_demo.sql` để kiểm chứng hiệu lực `REVOKE`.
* **Sao lưu & Phục hồi (Backup & Restore):**
  ```bash
  # Sao lưu toàn bộ cấu trúc, dữ liệu, routines và triggers
  mysqldump -u root -p --routines --triggers dloar_db > dloar_db_backup.sql

  # Phục hồi cơ sở dữ liệu
  mysql -u root -p dloar_db < dloar_db_backup.sql
  ```

---

## 📋 Table of Contents

* [1. Introduction & Project Scope](#1-introduction--project-scope)
  * [1.1 System Objective](#11-system-objective)
    * [1.1.1 Problem Statement](#111-problem-statement)
    * [1.1.2 Rationale](#112-rationale)
    * [1.1.3 System Scope](#113-system-scope)
    * [1.1.4 Project Objectives](#114-project-objectives)
    * [1.1.5 Entity Overview](#115-entity-overview)
  * [1.2 Business Rules & Constraints](#12-business-rules--constraints)
* [2. Database Design](#2-database-design)
  * [2.1 Conceptual Model (EER Diagram)](#21-conceptual-model-eer-diagram)
    * [🖼️ Hình 2.1 – Sơ đồ Thực thể - Liên kết Mở rộng (Conceptual EER Diagram)](#hình-21--sơ-đồ-thực-thể---liên-kết-mở-rộng-conceptual-eer-diagram)
  * [2.2 Logical Schema Mapping](#22-logical-schema-mapping)
    * [🖼️ Hình 2.2 – Sơ đồ Lược đồ Quan hệ (Logical Schema Diagram)](#hình-22--sơ-đồ-lược-đồ-quan-hệ-logical-schema-diagram)
  * [2.3 Normalization Verification (1NF → BCNF)](#23-normalization-verification-1nf--bcnf)
* [3. Data Dictionary](#3-data-dictionary)
  * [3.1 Bảng `person`](#31-bảng-person-thực-thể-cha-supertype)
  * [3.2 Bảng `member`](#32-bảng-member-thực-thể-con-subtype---độc-giả)
  * [3.3 Bảng `author`](#33-bảng-author-thực-thể-con-subtype---tác-giả)
  * [3.4 Bảng `physical_book`](#34-bảng-physical_book-đầu-sách-vật-lý)
  * [3.5 Bảng `book_copy`](#35-bảng-book_copy-bản-sao-sách-vật-lý)
  * [3.6 Bảng `license`](#36-bảng-license-giấy-phép-bản-quyền-mở)
  * [3.7 Bảng `digital_item`](#37-bảng-digital_item-tài-liệu-số--lưu-trữ-mở)
  * [3.8 Bảng `borrow_transaction`](#38-bảng-borrow_transaction-giao-dịch-mượn---trả-sách)
  * [3.9 Bảng `fine`](#39-bảng-fine-tiền-phạt-quá-hạn--hư-hỏng--mất-sách)
  * [3.10 Bảng `category`](#310-bảng-category-danh-mục--chủ-đề)
  * [3.11 Bảng `book_author`](#311-bảng-book_author-liên-kết-sách---tác-giả)
  * [3.12 Bảng `item_author`](#312-bảng-item_author-liên-kết-tài-liệu-số---tác-giả)
  * [3.13 Bảng `item_category`](#313-bảng-item_category-liên-kết-tài-liệu-số---danh-mục)
* [4. Database Implementation](#4-database-implementation)
  * [4.1 DDL Script (Tables, Indexes, Views & Triggers)](#41-ddl-script-tables-indexes-views--triggers)
  * [4.2 Advanced Queries & Performance Optimization](#42-advanced-queries--performance-optimization)
* [5. Verification & Security](#5-verification--security)
  * [5.1 Constraint Verification Test Cases (44 Test Cases)](#51-constraint-verification-test-cases-44-test-cases)
  * [5.2 Role-Based Access Control (RBAC)](#52-role-based-access-control-rbac)
    * [🖼️ Hình 5.1 – Kết quả kiểm thử phân quyền của `reader_user`](#hình-51--kết-quả-kiểm-thử-phân-quyền-của-reader_user)
    * [🖼️ Hình 5.2 – Kết quả kiểm thử phân quyền của `librarian_user`](#hình-52--kết-quả-kiểm-thử-phân-quyền-của-librarian_user)
    * [🖼️ Hình 5.3 – Kết quả kiểm thử phân quyền của `admin_user`](#hình-53--kết-quả-kiểm-thử-phân-quyền-của-admin_user)
    * [🖼️ Hình 5.4 – Hình 5.7 – Minh chứng thu hồi quyền (`REVOKE`) và quyền hiệu lực (`SHOW GRANTS`)](#hình-54--hình-57--minh-chứng-thu-hồi-quyền-revoke-và-quyền-hiệu-lực-show-grants)

---

## 1. Introduction & Project Scope

*(Adapted from ISO/IEC/IEEE 29148 Systems and software engineering — Life cycle processes — Requirements engineering)*

### 1.1 System Objective

#### 1.1.1 Problem Statement

Trong bối cảnh giáo dục và nghiên cứu hiện đại, thư viện của các trường đại học không còn chỉ quản lý sách giấy mà còn phải quản lý ngày càng nhiều tài liệu số như bài báo khoa học, tạp chí điện tử, luận văn và báo cáo nghiên cứu. Việc thiếu một hệ thống dữ liệu thống nhất dẫn đến các bất cập sau:

1. **Sự phân mảnh giữa tài liệu vật lý và tài liệu số:** Sách giấy được quản lý tách biệt với tạp chí điện tử, bài báo và các nguồn tài nguyên số, khiến dữ liệu bị phân tán và gây khó khăn khi tra cứu.
2. **Lưu trữ tài liệu số thiếu chuẩn hóa & thiếu công cụ quản lý giấy phép Open Access:** Thiếu siêu dữ liệu (metadata) thống nhất (DOI, định dạng tệp), chưa quản lý chặt chẽ giấy phép sử dụng (Creative Commons, Public Domain) và thời hạn khóa truy cập tạm thời (*embargo*).
3. **Nghiệp vụ thư viện phức tạp & thực thể chồng chéo vai trò:** Quản lý giới hạn mượn, hạn trả và tiền phạt quá hạn/hư hỏng dễ sai lệch nếu xử lý rời rạc. Đặc biệt, một cá nhân có thể vừa là độc giả mượn sách, vừa là tác giả của các công trình nghiên cứu, dễ dẫn đến trùng lặp dữ liệu cá nhân.

| STT | Vấn đề thực tế | Hướng giải quyết trong thiết kế CSDL |
| :---: | :--- | :--- |
| 1 | Dữ liệu tài liệu vật lý và tài liệu số bị phân mảnh | Một cơ sở dữ liệu duy nhất chứa cả `PHYSICAL_BOOK` / `BOOK_COPY` và `DIGITAL_ITEM`; người dùng và tác giả dùng chung dữ liệu cá nhân. |
| 2 | Lưu trữ tài liệu số thiếu metadata và định danh bền vững | `DIGITAL_ITEM` lưu tiêu đề, tóm tắt, `doi` (duy nhất), `file_path`, `file_format`; `CATEGORY` và `ITEM_CATEGORY` phân loại theo chủ đề. |
| 3 | Giấy phép và quyền truy cập không rõ ràng | `LICENSE` gắn bắt buộc với mỗi tài liệu số; `access_level` và `embargo_end_date` quản lý mức truy cập và thời hạn khóa tạm thời. |
| 4 | Nghiệp vụ mượn – trả và tiền phạt dễ sai lệch | `BORROW_TRANSACTION` và `FINE` cùng các ràng buộc `CHECK`, `TRIGGER` kiểm tra hạn mức, trạng thái bản sao, ngày hợp lệ và tự tính tiền phạt. |
| 5 | Thực thể nhiều vai trò bị lưu trùng | Mô hình EER với chuyên môn hóa `PERSON` $\rightarrow$ `MEMBER`, `AUTHOR` (*overlapping, partial*): dữ liệu cá nhân chỉ lưu một lần. |

#### 1.1.2 Rationale

* **Nền tảng tập trung:** Kết hợp quản lý mượn/trả sách vật lý và chia sẻ công khai các ấn phẩm nghiên cứu của trường đại học trên một kho dữ liệu thống nhất.
* **Chuẩn bản quyền mở:** Hỗ trợ giấy phép Creative Commons (`CC BY 4.0`, `CC BY-NC 4.0`, `Public Domain`...) bảo vệ quyền tác giả và thúc đẩy chia sẻ tri thức minh bạch.
* **Tự động hóa & Toàn vẹn dữ liệu:** Thực thi trực tiếp các quy tắc nghiệp vụ mượn/trả, tính tiền phạt tự động và kiểm soát truy cập ngay ở tầng cơ sở dữ liệu, đạt chuẩn hóa **BCNF**.

#### 1.1.3 System Scope

* **In-Scope (Trong phạm vi):**
  * Quản lý Thành viên & Tác giả: Xử lý mô hình EER chồng chéo (`PERSON`, `MEMBER`, `AUTHOR`).
  * Quản lý Tài liệu vật lý: Quản lý đầu sách (`PHYSICAL_BOOK`) và từng bản sao cụ thể (`BOOK_COPY`).
  * Quản lý Nghiệp vụ Mượn - Trả: Giao dịch mượn/trả, kiểm soát hạn mức và thời gian.
  * Quản lý Tiền phạt: Tính toán tự động tiền phạt quá hạn, đền bù hư hỏng/mất sách (`FINE`).
  * Quản lý Tài liệu số & Bản quyền mở: Lưu trữ bài báo/tạp chí (`DIGITAL_ITEM`), giấy phép (`LICENSE`), và thiết lập chính sách khóa tạm thời (*Embargo*).
  * Quản lý Phân loại: Cấu trúc danh mục/chủ đề (`CATEGORY`) và liên kết tác giả (`BOOK_AUTHOR`, `ITEM_AUTHOR`, `ITEM_CATEGORY`).
* **Out-of-Scope (Ngoài phạm vi):**
  * Tích hợp cổng thanh toán trực tuyến (hệ thống chỉ lưu trữ trạng thái nộp phạt `Paid`/`Unpaid` do thủ thư xác nhận).
  * Quản lý nhân sự, chấm công, tính lương thủ thư.
  * Quản lý logistics & vận chuyển sách giữa các kho hoặc nhà cung cấp.
  * Đặt trước, gia hạn sách, tự cấp mã DOI mới hoặc lập chỉ mục tìm kiếm toàn văn nội dung tệp.

#### 1.1.4 Project Objectives

* Xây dựng cơ sở dữ liệu quan hệ hoàn chỉnh (`dloar_db`), tối ưu hóa hiệu năng tra cứu và quản lý thư viện số mở.
* Áp dụng thành công mô hình Extended ER (EER) với tính năng Specialization/Generalization (*Overlapping, Partial*) để giải quyết triệt để bài toán thực thể chồng chéo.
* Đạt chuẩn hóa toàn bộ 13 bảng ở dạng chuẩn **BCNF** và chứng minh tính đúng đắn thông qua bộ 44 kịch bản kiểm thử toàn vẹn dữ liệu cùng 16 kịch bản kiểm thử phân quyền RBAC.

#### 1.1.5 Entity Overview

* 🏢 **Phân hệ Thành viên & Tác giả:**
  * `PERSON`: Thực thể cha (*Supertype*) lưu thông tin định danh cơ bản (họ tên, email, số điện thoại) tránh trùng lặp dữ liệu.
  * `MEMBER`: *Subtype* đại diện cho sinh viên, giảng viên, nghiên cứu sinh được cấp thẻ mượn sách vật lý.
  * `AUTHOR`: *Subtype* đại diện cho tác giả sáng tạo hoặc đóng góp nội dung cho sách và tài liệu số.
* 📚 **Phân hệ Tài liệu vật lý:**
  * `PHYSICAL_BOOK`: Đại diện cho đầu sách xuất bản (tiêu đề, ISBN, nhà xuất bản, năm xuất bản).
  * `BOOK_COPY`: Bản sao vật lý cụ thể tồn tại trên kệ (mã vạch Barcode, trạng thái, vị trí lưu trữ).
* 💻 **Phân hệ Tài liệu số & Lưu trữ mở:**
  * `DIGITAL_ITEM`: Ấn phẩm điện tử (bài báo khoa học, luận văn, tạp chí, đường dẫn tệp, DOI, mức truy cập).
  * `LICENSE`: Giấy phép bản quyền mở quy định điều khoản pháp lý sử dụng (Creative Commons, Public Domain).
* 🔄 **Phân hệ Mượn – Trả & Tiền phạt:**
  * `BORROW_TRANSACTION`: Ghi nhận lượt mượn – trả sách của độc giả.
  * `FINE`: Khoản nghĩa vụ tài chính khi trả quá hạn, làm hư hỏng hoặc làm mất sách.
* 🔗 **Phân hệ Liên kết & Phân loại:**
  * `BOOK_AUTHOR`: Liên kết Nhiều - Nhiều giữa `AUTHOR` và `PHYSICAL_BOOK` (lưu vai trò tác giả).
  * `ITEM_AUTHOR`: Liên kết Nhiều - Nhiều giữa `AUTHOR` và `DIGITAL_ITEM` (lưu thứ tự đóng góp `author_order` và vai trò).
  * `CATEGORY`: Danh mục / Lĩnh vực tri thức.
  * `ITEM_CATEGORY`: Liên kết Nhiều - Nhiều giữa `DIGITAL_ITEM` và `CATEGORY`.

### 1.2 Business Rules & Constraints

* **[BR-01] Quy tắc Thực thể Cá nhân, Thành viên & Tác giả (EER Overlap):**
  * `BR-01.1`: Định danh duy nhất bằng `person_id`. Họ tên, Email, SĐT chỉ lưu 1 lần tại `PERSON`.
  * `BR-01.2`: Mối quan hệ giữa `PERSON` và (`MEMBER`, `AUTHOR`) tuân thủ *Overlapping* & *Partial Participation*. Một `PERSON` có thể chỉ là `MEMBER`, chỉ là `AUTHOR`, hoặc đồng thời là cả hai.
  * `BR-01.3`: Mọi bản ghi trong `MEMBER` và `AUTHOR` bắt buộc tham chiếu đến `person_id` hợp lệ.
  * `BR-01.4`: Thuộc tính `email` trong `PERSON` và `orcid` trong `AUTHOR` (nếu có) phải là duy nhất (`UNIQUE`).
* **[BR-02] Quy tắc Quản lý Thành viên & Hạn mức Mượn:**
  * `BR-02.1`: `membership_status` $\in$ `{'Active', 'Expired', 'Suspended'}`.
  * `BR-02.2`: Mỗi thành viên có hạn mức mượn tối đa (`max_borrow_limit > 0`).
  * `BR-02.3`: Thành viên chỉ được mượn sách mới khi thỏa đồng thời: `membership_status = 'Active'`, thẻ còn hạn (`current_date <= expiry_date`), số sách đang mượn `< max_borrow_limit`, và tổng nợ phạt chưa thanh toán không vượt ngưỡng `100.000 VNĐ`.
* **[BR-03] Quy tắc Quản lý Sách Vật lý & Bản sao:**
  * `BR-03.1`: Một `PHYSICAL_BOOK` có 0 hoặc nhiều `BOOK_COPY`. Mỗi `BOOK_COPY` có mã vạch `barcode` duy nhất.
  * `BR-03.2`: `copy_status` $\in$ `{'Available', 'Borrowed', 'Lost', 'Damaged', 'In_Maintenance'}`.
  * `BR-03.3`: Chỉ bản sao có `copy_status = 'Available'` mới được phép khởi tạo giao dịch mượn mới.
* **[BR-04] Quy tắc Mượn - Trả & Chuyển đổi Trạng thái:**
  * `BR-04.1`: Tại 1 thời điểm, 1 `BOOK_COPY` chỉ nằm trong tối đa 01 giao dịch đang hoạt động (`return_date IS NULL`).
  * `BR-04.2`: Ràng buộc thời gian: `borrow_date <= due_date` và `borrow_date <= return_date`.
  * `BR-04.3`: Tự động chuyển trạng thái bản sao: `Available` $\rightarrow$ `Borrowed` khi mượn; `Borrowed` $\rightarrow$ `Available` khi trả bình thường; hoặc sang `Damaged` / `Lost` nếu ghi nhận hư hỏng/mất sách.
* **[BR-05] Quy tắc Tính Tiền phạt & Lưu vết Tài chính:**
  * `BR-05.1`: Khoản phạt `FINE` tự động khởi tạo khi `return_date > due_date` hoặc khi bản sao đang mượn chuyển sang `Damaged` (`50.000 VNĐ`) / `Lost` (`200.000 VNĐ`).
  * `BR-05.2`: Phạt quá hạn: `fine_amount = (return_date - due_date) * daily_penalty_rate` (mặc định `5.000 VNĐ/ngày`).
  * `BR-05.3`: `fine_status` $\in$ `{'Unpaid', 'Paid'}`. Khi `fine_status = 'Paid'`, bắt buộc ghi nhận `payment_date`. Tuyệt đối không xóa bản ghi `FINE` khỏi CSDL.
* **[BR-06] Quy tắc Tài liệu Số, Giấy phép & Embargo:**
  * `BR-06.1`: Mỗi `DIGITAL_ITEM` bắt buộc có `file_path` và định dạng tệp; mã `doi` (nếu có) phải là `UNIQUE`.
  * `BR-06.2`: Mỗi `DIGITAL_ITEM` bắt buộc liên kết với đúng 01 `LICENSE`.
  * `BR-06.3`: `access_level` $\in$ `{'Public_Open_Access', 'Restricted_Campus_Only', 'Embargoed'}`. Nếu ở trạng thái `Embargoed`, bắt buộc có `embargo_end_date` và chỉ được công khai khi `current_date > embargo_end_date`.
* **[BR-07] Quy tắc Phân loại & Quyền Tác giả:**
  * `BR-07.1`: Quản lý quan hệ Nhiều - Nhiều qua `BOOK_AUTHOR`, `ITEM_AUTHOR`, `ITEM_CATEGORY`.
  * `BR-07.2`: `BOOK_AUTHOR.author_role` $\in$ `{'Main Author', 'Co-Author', 'Editor', 'Translator'}`; `ITEM_AUTHOR.author_order >= 1`.
* **[BR-08] Ràng buộc Toàn vẹn Kỹ thuật CSDL:**
  * `BR-08.1`: Khóa chính (`PK`) duy nhất, `NOT NULL`; Khóa ngoại (`FK`) tham chiếu chính xác.
  * `BR-08.2`: Áp dụng `ON DELETE RESTRICT` cho các bảng nghiệp vụ mượn/trả và tiền phạt; áp dụng `ON DELETE CASCADE` cho các bảng con kế thừa và bảng liên kết trung gian.

---

## 2. Database Design

*(Adapted from ISO/IEC 19505 / Information Engineering Standards)*

### 2.1 Conceptual Model (EER Diagram)

Mô hình EER sử dụng cơ chế chuyên môn hóa/tổng quát hóa (*Specialization/Generalization*) với ràng buộc **Overlapping (o)** và **Partial Participation** từ thực thể cha `PERSON` xuống hai thực thể con `MEMBER` và `AUTHOR`.

#### Hình 2.1 – Sơ đồ Thực thể - Liên kết Mở rộng (Conceptual EER Diagram)

```text
                       +--------------------+
                       |       PERSON       |
                       +--------------------+
                       | PK  person_id      |
                       |     first_name     |
                       |     last_name      |
                       | UQ  email          |
                       |     phone_number   |
                       +---------+----------+
                                 | (o, Partial) Specialization
            +--------------------+--------------------+
            |                                         |
+-----------v----------+                  +-----------v----------+
|        MEMBER        |                  |        AUTHOR        |
+----------------------+                  +----------------------+
| PK,FK person_id      |                  | PK,FK person_id      |
| UQ    member_code    |                  | UQ    author_code    |
|       status         |                  | UQ    orcid          |
|       borrow_limit   |                  |       affiliation    |
+-----------+----------+                  +---+--------------+---+
            |                                 |              |
            | 1:N                             | N:M          | N:M
+-----------v----------+          +-----------v--+        +--v-----------+
| BORROW_TRANSACTION   |          | BOOK_AUTHOR  |        | ITEM_AUTHOR  |
+----------------------+          +--------------+        +--------------+
| PK  transaction_id   |          | PK,FK book_id|        | PK,FK item_id|
| FK  member_id        |          | PK,FK auth_id|        | PK,FK auth_id|
| FK  copy_id          |          +-------+------+        +------+-------+
+-----------+----------+                  |                      |
            |                             |                      |
            | 1:0..1                      |                      |
+-----------v----------+          +-------v------+        +------v-------+
|         FINE         |          |PHYSICAL_BOOK |        | DIGITAL_ITEM |
+----------------------+          +--------------+        +--------------+
| PK  fine_id          |          | PK  book_id  |        | PK  item_id  |
| FK  transaction_id   |          | UQ  isbn     |        | FK  license_id|
|     fine_amount      |          +-------+------+        | UQ  doi      |
+----------------------+                  |               +------+-------+
                                          | 1:N                  |
                                  +-------v------+               | N:M
                                  |  BOOK_COPY   |        +------v-------+
                                  +--------------+        |ITEM_CATEGORY |
                                  | PK  copy_id  |        +--------------+
                                  | UQ  barcode  |        |PK,FK item_id |
                                  +--------------+        |PK,FK cat_id  |
                                                          +--------------+
```

### 2.2 Logical Schema Mapping

1. `PERSON`: (`person_id` [PK], `first_name`, `last_name`, `email` [UQ], `phone_number`, `created_at`)
2. `MEMBER`: (`person_id` [PK, FK $\rightarrow$ `PERSON.person_id`], `member_code` [UQ], `membership_status`, `max_borrow_limit`, `expiry_date`)
3. `AUTHOR`: (`person_id` [PK, FK $\rightarrow$ `PERSON.person_id`], `author_code` [UQ], `affiliation`, `orcid` [UQ], `bio`)
4. `PHYSICAL_BOOK`: (`book_id` [PK], `title`, `isbn` [UQ], `publisher`, `publication_year`)
5. `BOOK_COPY`: (`copy_id` [PK], `book_id` [FK $\rightarrow$ `PHYSICAL_BOOK.book_id`], `barcode` [UQ], `copy_status`, `shelf_location`)
6. `LICENSE`: (`license_id` [PK], `license_name`, `license_code` [UQ], `terms_description`)
7. `DIGITAL_ITEM`: (`item_id` [PK], `license_id` [FK $\rightarrow$ `LICENSE.license_id`], `title`, `abstract`, `doi` [UQ], `file_path`, `file_format`, `access_level`, `embargo_end_date`)
8. `BORROW_TRANSACTION`: (`transaction_id` [PK], `member_id` [FK $\rightarrow$ `MEMBER.person_id`], `copy_id` [FK $\rightarrow$ `BOOK_COPY.copy_id`], `borrow_date`, `due_date`, `return_date`)
9. `FINE`: (`fine_id` [PK], `transaction_id` [FK, UQ $\rightarrow$ `BORROW_TRANSACTION.transaction_id`], `fine_amount`, `fine_reason`, `fine_status`, `payment_date`)
10. `CATEGORY`: (`category_id` [PK], `category_name` [UQ], `description`)
11. `BOOK_AUTHOR`: (`book_id` [PK, FK $\rightarrow$ `PHYSICAL_BOOK.book_id`], `author_id` [PK, FK $\rightarrow$ `AUTHOR.person_id`], `author_role`)
12. `ITEM_AUTHOR`: (`item_id` [PK, FK $\rightarrow$ `DIGITAL_ITEM.item_id`], `author_id` [PK, FK $\rightarrow$ `AUTHOR.person_id`], `author_order`, `author_role`)
13. `ITEM_CATEGORY`: (`item_id` [PK, FK $\rightarrow$ `DIGITAL_ITEM.item_id`], `category_id` [PK, FK $\rightarrow$ `CATEGORY.category_id`])

#### Hình 2.2 – Sơ đồ Lược đồ Quan hệ (Logical Schema Diagram)

```text
+-----------------------------------+       +---------------------------------------+
|              PERSON               |       |             PHYSICAL_BOOK             |
+-----------------------------------+       +---------------------------------------+
| PK  person_id      INT            |       | PK  book_id          INT            |
|     first_name     VARCHAR(50)    |       |     title            VARCHAR(255)   |
|     last_name      VARCHAR(50)    |       | UQ  isbn             VARCHAR(20)    |
| UQ  email          VARCHAR(100)   |       |     publisher        VARCHAR(100)   |
|     phone_number   VARCHAR(20)    |       |     publication_year INT            |
|     created_at     TIMESTAMP      |       +---+-------------------------------+---+
+----+-------------------------+----+           | 1                             | 1
     | 1                       | 1              |                               |
     | (1:0..1)                | (1:0..1)       | *                             | *
+----v------------------------+ +---v-----------+---------+       +-------------v-------------+
|           MEMBER            | |         AUTHOR          |       |        BOOK_COPY        |
+-----------------------------+ +-------------------------+       +---------------------------+
| PK,FK person_id    INT      | | PK,FK person_id    INT  |       | PK  copy_id        INT    |
| UQ    member_code  VARCHAR  | | UQ    author_code  VARCHAR|     | FK  book_id        INT    |
|       membership_status     | |       affiliation  VARCHAR|     | UQ  barcode    VARCHAR(50)|
|       max_borrow_limit INT  | | UQ    orcid        VARCHAR|     |     copy_status VARCHAR(20)|
|       expiry_date  DATE     | |       bio          TEXT |       |     shelf_location VARCHAR|
+----+------------------------+ +---+-----------------+---+       +-------------+-------------+
     | 1                            | 1               | 1                       | 1
     |                              |                 |                         |
     |                              | *               | *                       |
     |            +-----------------v---+           +-v-------------------+     |
     |            |     BOOK_AUTHOR     |           |     ITEM_AUTHOR     |     |
     |            +---------------------+           +---------------------+     |
     |            | PK,FK book_id   INT |           | PK,FK item_id   INT |     |
     |            | PK,FK author_id INT |           | PK,FK author_id INT |     |
     |            |       author_role   |           |       author_order  |     |
     |            +---------------------+           |       author_role   |     |
     |                                              +---------+-----------+     |
     |                                                        | *                 |
     |                                                        |                   |
     |   +------------------------------------+               | 1                 |
     |   |              LICENSE               |     +---------v---------------+   |
     |   +------------------------------------+     |      DIGITAL_ITEM       |   |
     |   | PK  license_id      INT            |     +-------------------------+   |
     |   |     license_name    VARCHAR(100)   |     | PK  item_id         INT |   |
     |   | UQ  license_code    VARCHAR(50)    | 1 * | FK  license_id      INT |   |
     |   |     terms_description TEXT         +---->|     title   VARCHAR(255)|   |
     |   +------------------------------------+     |     abstract       TEXT |   |
     |                                              | UQ  doi    VARCHAR(100) |   |
     |                                              |     file_path  VARCHAR  |   |
     |                                              |     file_format VARCHAR |   |
     |                                              |     access_level VARCHAR|   |
     |                                              |     embargo_end_date    |   |
     |                                              +------------+------------+   |
     |                                                           | 1              |
     |                                                           |                |
     | *                                                         | *              |
+----v------------------------+                     +------------v------------+   |
|     BORROW_TRANSACTION      |<--------------------+      ITEM_CATEGORY      |   |
+-----------------------------+      (copy_id)      +-------------------------+   |
| PK  transaction_id INT      |<--------------------+ PK,FK item_id       INT |   |
| FK  member_id      INT      | 1                 * | PK,FK category_id   INT |   |
| FK  copy_id        INT      |                     +------------+------------+   |
|     borrow_date    DATE     |                                  | *              |
|     due_date       DATE     |                                  |                |
|     return_date    DATE     |                                  | 1              |
+----+------------------------+                     +------------v------------+   |
     | 1                                            |        CATEGORY         |   |
     |                                              +-------------------------+   |
     | 0..1                                         | PK  category_id     INT |   |
+----v------------------------+                     | UQ  category_name VARCHAR|  |
|            FINE             |                     |     description    TEXT |   |
+-----------------------------+                     +-------------------------+   |
| PK     fine_id     INT      |                                                   |
| FK,UQ  transaction_id INT   | (Liên kết từ BOOK_COPY.copy_id -------------------+ )
|        fine_amount DECIMAL  |
|        fine_reason VARCHAR  |
|        fine_status VARCHAR  |
|        payment_date DATE    |
+-----------------------------+
```

### 2.3 Normalization Verification (1NF → BCNF)

#### 2.3.1 Core Functional Dependencies (FDs)

* `PERSON`: `FD1: person_id` $\rightarrow$ `first_name, last_name, email, phone_number, created_at`; `FD2: email` $\rightarrow$ `person_id, ...`
* `MEMBER`: `FD1: person_id` $\rightarrow$ `member_code, membership_status, max_borrow_limit, expiry_date`; `FD2: member_code` $\rightarrow$ `person_id, ...`
* `AUTHOR`: `FD1: person_id` $\rightarrow$ `author_code, affiliation, orcid, bio`; `FD2: orcid` $\rightarrow$ `person_id, ...` (khi `orcid IS NOT NULL`)
* `PHYSICAL_BOOK`: `FD1: book_id` $\rightarrow$ `title, isbn, publisher, publication_year`; `FD2: isbn` $\rightarrow$ `book_id, ...`
* `BOOK_COPY`: `FD1: copy_id` $\rightarrow$ `barcode, copy_status, shelf_location, book_id`; `FD2: barcode` $\rightarrow$ `copy_id, ...`
* `BORROW_TRANSACTION`: `FD1: transaction_id` $\rightarrow$ `borrow_date, due_date, return_date, member_id, copy_id`
* `FINE`: `FD1: fine_id` $\rightarrow$ `fine_amount, fine_reason, fine_status, payment_date, transaction_id`; `FD2: transaction_id` $\rightarrow$ `fine_id, ...`
* `DIGITAL_ITEM`: `FD1: item_id` $\rightarrow$ `title, abstract, doi, file_path, file_format, access_level, embargo_end_date, license_id`; `FD2: doi` $\rightarrow$ `item_id, ...` (khi `doi IS NOT NULL`)
* `LICENSE` & `CATEGORY`: `license_id` $\rightarrow$ `license_name, license_code, terms_description`; `category_id` $\rightarrow$ `category_name, description`
* **Associative Tables:** `(book_id, author_id)` $\rightarrow$ `author_role`; `(item_id, author_id)` $\rightarrow$ `author_order, author_role`; `(item_id, category_id)` $\rightarrow \emptyset$

#### 2.3.2 Proof of Normal Forms

1. **1NF (First Normal Form):** Tất cả thuộc tính đều chứa giá trị đơn lẻ (*Atomic*), các thuộc tính phức hợp (như họ tên) đã tách thành `first_name`, `last_name`, và không tồn tại thuộc tính đa trị.
2. **2NF (Second Normal Form):** Các bảng khóa đơn nghiễm nhiên đạt 2NF. Các bảng khóa phức hợp (`BOOK_AUTHOR`, `ITEM_AUTHOR`, `ITEM_CATEGORY`) không có phụ thuộc hàm một phần (*Partial Dependency*).
3. **3NF (Third Normal Form):** Không tồn tại phụ thuộc hàm bắc cầu (*Transitive Dependency*). Các thông tin như chi tiết giấy phép (`LICENSE`), thông tin đầu sách (`PHYSICAL_BOOK`) hay hồ sơ cá nhân (`PERSON`) đều được tách thành các bảng độc lập.
4. **BCNF (Boyce-Codd Normal Form):** Mọi vế trái `X` của các phụ thuộc hàm `X` $\rightarrow$ `Y` trong toàn bộ hệ thống đều là Khóa chính (*Primary Key*) hoặc Khóa ứng viên (*Candidate Key* như `email`, `member_code`, `orcid`, `isbn`, `barcode`, `transaction_id` trong `FINE`, `doi`).
   * $\Rightarrow$ **Kết luận:** Toàn bộ 13 bảng của hệ thống đạt chuẩn **BCNF**.

---

## 3. Data Dictionary

*(Adapted from ISO/IEC 11179 Information technology — Metadata registries)*

### 3.1 Bảng `person` (Thực thể cha Supertype)

| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `person_id` | `INT` | `PK` | No | `AUTO_INCREMENT` | Định danh cá nhân duy nhất |
| `first_name` | `VARCHAR(50)` | — | No | `None` | Tên cá nhân |
| `last_name` | `VARCHAR(50)` | — | No | `None` | Họ và tên đệm |
| `email` | `VARCHAR(100)` | `CK` | No | `None` | Email duy nhất (`UNIQUE`) `[BR-01.4]` |
| `phone_number` | `VARCHAR(20)` | — | Yes | `NULL` | Số điện thoại liên hệ |
| `created_at` | `TIMESTAMP` | — | No | `CURRENT_TIMESTAMP` | Thời điểm tạo hồ sơ |

### 3.2 Bảng `member` (Thực thể con Subtype - Độc giả)

| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `person_id` | `INT` | `PK, FK` | No | `None` | `FK -> person(person_id) ON DELETE CASCADE` `[BR-01.3]` |
| `member_code` | `VARCHAR(20)` | `CK` | No | `None` | Mã thẻ thành viên (`UNIQUE`) |
| `membership_status` | `VARCHAR(20)` | — | No | `'Active'` | `CHECK (membership_status IN ('Active','Expired','Suspended'))` `[BR-02.1]` |
| `max_borrow_limit` | `INT` | — | No | `5` | `CHECK (max_borrow_limit > 0)` `[BR-02.2]` |
| `expiry_date` | `DATE` | — | No | `None` | Ngày hết hạn thẻ |

### 3.3 Bảng `author` (Thực thể con Subtype - Tác giả)

| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `person_id` | `INT` | `PK, FK` | No | `None` | `FK -> person(person_id) ON DELETE CASCADE` `[BR-01.3]` |
| `author_code` | `VARCHAR(20)` | `CK` | No | `None` | Mã số tác giả (`UNIQUE`) |
| `affiliation` | `VARCHAR(100)` | — | Yes | `NULL` | Đơn vị / Cơ quan công tác |
| `orcid` | `VARCHAR(20)` | `CK` | Yes | `NULL` | Mã ORCID iD quốc tế (`UNIQUE`) `[BR-01.4]` |
| `bio` | `TEXT` | — | Yes | `NULL` | Tiểu sử tác giả |

### 3.4 Bảng `physical_book` (Đầu sách vật lý)

| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `book_id` | `INT` | `PK` | No | `AUTO_INCREMENT` | Định danh đầu sách |
| `title` | `VARCHAR(255)` | — | No | `None` | Tiêu đề sách |
| `isbn` | `VARCHAR(20)` | `CK` | No | `None` | Mã ISBN (`UNIQUE`) |
| `publisher` | `VARCHAR(100)` | — | Yes | `NULL` | Nhà xuất bản |
| `publication_year` | `INT` | — | Yes | `NULL` | `CHECK (publication_year >= 1500)` |

### 3.5 Bảng `book_copy` (Bản sao sách vật lý)

| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `copy_id` | `INT` | `PK` | No | `AUTO_INCREMENT` | Định danh bản sao |
| `book_id` | `INT` | `FK` | No | `None` | `FK -> physical_book(book_id) ON DELETE RESTRICT` |
| `barcode` | `VARCHAR(50)` | `CK` | No | `None` | Mã vạch (`UNIQUE`) `[BR-03.1]` |
| `copy_status` | `VARCHAR(20)` | — | No | `'Available'` | `CHECK (copy_status IN ('Available','Borrowed','Lost','Damaged','In_Maintenance'))` `[BR-03.2]` |
| `shelf_location` | `VARCHAR(50)` | — | Yes | `NULL` | Vị trí thực tế trên kệ |

### 3.6 Bảng `license` (Giấy phép bản quyền mở)

| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `license_id` | `INT` | `PK` | No | `AUTO_INCREMENT` | Định danh giấy phép |
| `license_name` | `VARCHAR(100)` | — | No | `None` | Tên đầy đủ giấy phép |
| `license_code` | `VARCHAR(50)` | `CK` | No | `None` | Ký hiệu viết tắt (`UNIQUE`) |
| `terms_description` | `TEXT` | — | Yes | `NULL` | Điều khoản sử dụng |

### 3.7 Bảng `digital_item` (Tài liệu số & Lưu trữ mở)

| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `item_id` | `INT` | `PK` | No | `AUTO_INCREMENT` | Định danh tài liệu số |
| `license_id` | `INT` | `FK` | No | `None` | `FK -> license(license_id) ON DELETE RESTRICT` `[BR-06.2]` |
| `title` | `VARCHAR(255)` | — | No | `None` | Tiêu đề tài liệu |
| `abstract` | `TEXT` | — | Yes | `NULL` | Tóm tắt nội dung |
| `doi` | `VARCHAR(100)` | `CK` | Yes | `NULL` | Mã định danh DOI (`UNIQUE`) `[BR-06.1]` |
| `file_path` | `VARCHAR(500)` | — | No | `None` | Đường dẫn lưu trữ tệp `[BR-06.1]` |
| `file_format` | `VARCHAR(10)` | — | Yes | `'PDF'` | Định dạng tệp |
| `access_level` | `VARCHAR(50)` | — | No | `'Public_Open_Access'` | `CHECK (access_level IN ('Public_Open_Access','Restricted_Campus_Only','Embargoed'))` `[BR-06.3]` |
| `embargo_end_date` | `DATE` | — | Yes | `NULL` | `CHECK (access_level <> 'Embargoed' OR embargo_end_date IS NOT NULL)` `[BR-06.3]` |

### 3.8 Bảng `borrow_transaction` (Giao dịch mượn - trả sách)

| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `transaction_id` | `INT` | `PK` | No | `AUTO_INCREMENT` | Định danh giao dịch |
| `member_id` | `INT` | `FK` | No | `None` | `FK -> member(person_id) ON DELETE RESTRICT` |
| `copy_id` | `INT` | `FK` | No | `None` | `FK -> book_copy(copy_id) ON DELETE RESTRICT` |
| `borrow_date` | `DATE` | — | No | `None` | Ngày mượn |
| `due_date` | `DATE` | — | No | `None` | `CHECK (due_date >= borrow_date)` `[BR-04.2]` |
| `return_date` | `DATE` | — | Yes | `NULL` | `CHECK (return_date IS NULL OR return_date >= borrow_date)` `[BR-04.1, BR-04.2]` |

### 3.9 Bảng `fine` (Tiền phạt quá hạn / hư hỏng / mất sách)

| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `fine_id` | `INT` | `PK` | No | `AUTO_INCREMENT` | Định danh khoản phạt |
| `transaction_id` | `INT` | `FK, CK` | No | `None` | `FK -> borrow_transaction(transaction_id) ON DELETE RESTRICT` `[BR-05.3]` |
| `fine_amount` | `DECIMAL(10,2)` | — | No | `0.00` | `CHECK (fine_amount >= 0.00)` `[BR-05.2]` |
| `fine_reason` | `VARCHAR(255)` | — | Yes | `NULL` | Lý do xử phạt |
| `fine_status` | `VARCHAR(20)` | — | No | `'Unpaid'` | `CHECK (fine_status IN ('Unpaid', 'Paid'))` `[BR-05.3]` |
| `payment_date` | `DATE` | — | Yes | `NULL` | `CHECK (fine_status <> 'Paid' OR payment_date IS NOT NULL)` `[BR-05.3]` |

### 3.10 Bảng `category` (Danh mục / Chủ đề)

| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `category_id` | `INT` | `PK` | No | `AUTO_INCREMENT` | Định danh danh mục |
| `category_name` | `VARCHAR(100)` | `CK` | No | `None` | Tên danh mục (`UNIQUE`) |
| `description` | `TEXT` | — | Yes | `NULL` | Mô tả phạm vi |

### 3.11 Bảng `book_author` (Liên kết Sách - Tác giả)

| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `book_id` | `INT` | `PK, FK` | No | `None` | `FK -> physical_book(book_id) ON DELETE CASCADE` |
| `author_id` | `INT` | `PK, FK` | No | `None` | `FK -> author(person_id) ON DELETE CASCADE` |
| `author_role` | `VARCHAR(50)` | — | Yes | `'Main Author'` | `CHECK (author_role IN ('Main Author', 'Co-Author', 'Editor', 'Translator'))` `[BR-07.2]` |

### 3.12 Bảng `item_author` (Liên kết Tài liệu số - Tác giả)

| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `item_id` | `INT` | `PK, FK` | No | `None` | `FK -> digital_item(item_id) ON DELETE CASCADE` |
| `author_id` | `INT` | `PK, FK` | No | `None` | `FK -> author(person_id) ON DELETE CASCADE` |
| `author_order` | `INT` | — | No | `1` | `CHECK (author_order >= 1)` `[BR-07.2]` |
| `author_role` | `VARCHAR(50)` | — | Yes | `'Principal Investigator'` | Vai trò đối với công trình số `[BR-07.2]` |

### 3.13 Bảng `item_category` (Liên kết Tài liệu số - Danh mục)

| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `item_id` | `INT` | `PK, FK` | No | `None` | `FK -> digital_item(item_id) ON DELETE CASCADE` `[BR-07.3]` |
| `category_id` | `INT` | `PK, FK` | No | `None` | `FK -> category(category_id) ON DELETE CASCADE` `[BR-07.3]` |

---

## 4. Database Implementation

*(SQL Style Guide Compliant)*

### 4.1 DDL Script (Tables, Indexes, Views & Triggers)

```sql
DROP DATABASE IF EXISTS dloar_db;
CREATE DATABASE dloar_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE dloar_db;

-- 1. Table PERSON
CREATE TABLE person (
    person_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_person PRIMARY KEY (person_id),
    CONSTRAINT uq_person_email UNIQUE (email)
) ENGINE=InnoDB;

-- 2. Table MEMBER
CREATE TABLE member (
    person_id INT NOT NULL,
    member_code VARCHAR(20) NOT NULL,
    membership_status VARCHAR(20) NOT NULL DEFAULT 'Active',
    max_borrow_limit INT NOT NULL DEFAULT 5,
    expiry_date DATE NOT NULL,
    CONSTRAINT pk_member PRIMARY KEY (person_id),
    CONSTRAINT uq_member_code UNIQUE (member_code),
    CONSTRAINT fk_member_person FOREIGN KEY (person_id)
        REFERENCES person (person_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_member_status CHECK (membership_status IN ('Active', 'Expired', 'Suspended')),
    CONSTRAINT chk_member_max_borrow CHECK (max_borrow_limit > 0)
) ENGINE=InnoDB;

-- 3. Table AUTHOR
CREATE TABLE author (
    person_id INT NOT NULL,
    author_code VARCHAR(20) NOT NULL,
    affiliation VARCHAR(100) DEFAULT NULL,
    orcid VARCHAR(20) DEFAULT NULL,
    bio TEXT DEFAULT NULL,
    CONSTRAINT pk_author PRIMARY KEY (person_id),
    CONSTRAINT uq_author_code UNIQUE (author_code),
    CONSTRAINT uq_author_orcid UNIQUE (orcid),
    CONSTRAINT fk_author_person FOREIGN KEY (person_id)
        REFERENCES person (person_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 4. Table PHYSICAL_BOOK
CREATE TABLE physical_book (
    book_id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) NOT NULL,
    publisher VARCHAR(100) DEFAULT NULL,
    publication_year INT DEFAULT NULL,
    CONSTRAINT pk_physical_book PRIMARY KEY (book_id),
    CONSTRAINT uq_physical_book_isbn UNIQUE (isbn),
    CONSTRAINT chk_publication_year CHECK (publication_year >= 1500)
) ENGINE=InnoDB;

-- 5. Table BOOK_COPY
CREATE TABLE book_copy (
    copy_id INT NOT NULL AUTO_INCREMENT,
    book_id INT NOT NULL,
    barcode VARCHAR(50) NOT NULL,
    copy_status VARCHAR(20) NOT NULL DEFAULT 'Available',
    shelf_location VARCHAR(50) DEFAULT NULL,
    CONSTRAINT pk_book_copy PRIMARY KEY (copy_id),
    CONSTRAINT uq_book_copy_barcode UNIQUE (barcode),
    CONSTRAINT fk_book_copy_book FOREIGN KEY (book_id)
        REFERENCES physical_book (book_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_copy_status CHECK (copy_status IN ('Available', 'Borrowed', 'Lost', 'Damaged', 'In_Maintenance'))
) ENGINE=InnoDB;

-- 6. Table LICENSE
CREATE TABLE license (
    license_id INT NOT NULL AUTO_INCREMENT,
    license_name VARCHAR(100) NOT NULL,
    license_code VARCHAR(50) NOT NULL,
    terms_description TEXT DEFAULT NULL,
    CONSTRAINT pk_license PRIMARY KEY (license_id),
    CONSTRAINT uq_license_code UNIQUE (license_code)
) ENGINE=InnoDB;

-- 7. Table DIGITAL_ITEM
CREATE TABLE digital_item (
    item_id INT NOT NULL AUTO_INCREMENT,
    license_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    abstract TEXT DEFAULT NULL,
    doi VARCHAR(100) DEFAULT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_format VARCHAR(10) DEFAULT 'PDF',
    access_level VARCHAR(50) NOT NULL DEFAULT 'Public_Open_Access',
    embargo_end_date DATE DEFAULT NULL,
    CONSTRAINT pk_digital_item PRIMARY KEY (item_id),
    CONSTRAINT uq_digital_item_doi UNIQUE (doi),
    CONSTRAINT fk_digital_item_license FOREIGN KEY (license_id)
        REFERENCES license (license_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_access_level CHECK (access_level IN ('Public_Open_Access', 'Restricted_Campus_Only', 'Embargoed')),
    CONSTRAINT chk_embargo_end_date CHECK (access_level <> 'Embargoed' OR embargo_end_date IS NOT NULL)
) ENGINE=InnoDB;

-- 8. Table BORROW_TRANSACTION
CREATE TABLE borrow_transaction (
    transaction_id INT NOT NULL AUTO_INCREMENT,
    member_id INT NOT NULL,
    copy_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE DEFAULT NULL,
    CONSTRAINT pk_borrow_transaction PRIMARY KEY (transaction_id),
    CONSTRAINT fk_borrow_member FOREIGN KEY (member_id)
        REFERENCES member (person_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_borrow_copy FOREIGN KEY (copy_id)
        REFERENCES book_copy (copy_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_borrow_due_dates CHECK (due_date >= borrow_date),
    CONSTRAINT chk_borrow_return_dates CHECK (return_date IS NULL OR return_date >= borrow_date)
) ENGINE=InnoDB;

-- 9. Table FINE
CREATE TABLE fine (
    fine_id INT NOT NULL AUTO_INCREMENT,
    transaction_id INT NOT NULL,
    fine_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    fine_reason VARCHAR(255) DEFAULT NULL,
    fine_status VARCHAR(20) NOT NULL DEFAULT 'Unpaid',
    payment_date DATE DEFAULT NULL,
    CONSTRAINT pk_fine PRIMARY KEY (fine_id),
    CONSTRAINT uq_fine_transaction UNIQUE (transaction_id),
    CONSTRAINT fk_fine_transaction FOREIGN KEY (transaction_id)
        REFERENCES borrow_transaction (transaction_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_fine_amount CHECK (fine_amount >= 0.00),
    CONSTRAINT chk_fine_status CHECK (fine_status IN ('Unpaid', 'Paid')),
    CONSTRAINT chk_fine_paid_date CHECK (fine_status <> 'Paid' OR payment_date IS NOT NULL)
) ENGINE=InnoDB;

-- 10. Table CATEGORY
CREATE TABLE category (
    category_id INT NOT NULL AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    description TEXT DEFAULT NULL,
    CONSTRAINT pk_category PRIMARY KEY (category_id),
    CONSTRAINT uq_category_name UNIQUE (category_name)
) ENGINE=InnoDB;

-- 11. Table BOOK_AUTHOR
CREATE TABLE book_author (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_role VARCHAR(50) DEFAULT 'Main Author',
    CONSTRAINT pk_book_author PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_ba_book FOREIGN KEY (book_id)
        REFERENCES physical_book (book_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ba_author FOREIGN KEY (author_id)
        REFERENCES author (person_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_book_author_role CHECK (author_role IN ('Main Author', 'Co-Author', 'Editor', 'Translator'))
) ENGINE=InnoDB;

-- 12. Table ITEM_AUTHOR
CREATE TABLE item_author (
    item_id INT NOT NULL,
    author_id INT NOT NULL,
    author_order INT NOT NULL DEFAULT 1,
    author_role VARCHAR(50) DEFAULT 'Principal Investigator',
    CONSTRAINT pk_item_author PRIMARY KEY (item_id, author_id),
    CONSTRAINT fk_ia_item FOREIGN KEY (item_id)
        REFERENCES digital_item (item_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ia_author FOREIGN KEY (author_id)
        REFERENCES author (person_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_item_author_order CHECK (author_order >= 1)
) ENGINE=InnoDB;

-- 13. Table ITEM_CATEGORY
CREATE TABLE item_category (
    item_id INT NOT NULL,
    category_id INT NOT NULL,
    CONSTRAINT pk_item_category PRIMARY KEY (item_id, category_id),
    CONSTRAINT fk_ic_item FOREIGN KEY (item_id)
        REFERENCES digital_item (item_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ic_category FOREIGN KEY (category_id)
        REFERENCES category (category_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
```

```sql
USE dloar_db;

-- INDEXING STRATEGY
CREATE INDEX idx_person_names ON person (last_name, first_name);
CREATE INDEX idx_borrow_member_status ON borrow_transaction (member_id, return_date);
CREATE INDEX idx_borrow_copy_status ON borrow_transaction (copy_id, return_date);
CREATE INDEX idx_book_copy_status ON book_copy (copy_status);
CREATE INDEX idx_digital_item_access ON digital_item (access_level, embargo_end_date);
CREATE INDEX idx_fine_status ON fine (fine_status);

-- DATABASE VIEWS
CREATE OR REPLACE VIEW vw_active_loans AS
SELECT 
    bt.transaction_id,
    m.member_code,
    CONCAT(p.last_name, ' ', p.first_name) AS member_name,
    p.email,
    pb.title AS book_title,
    bc.barcode,
    bt.borrow_date,
    bt.due_date,
    DATEDIFF(CURRENT_DATE, bt.due_date) AS days_overdue
FROM borrow_transaction bt
JOIN member m ON bt.member_id = m.person_id
JOIN person p ON m.person_id = p.person_id
JOIN book_copy bc ON bt.copy_id = bc.copy_id
JOIN physical_book pb ON bc.book_id = pb.book_id
WHERE bt.return_date IS NULL;

CREATE OR REPLACE VIEW vw_unpaid_fines_summary AS
SELECT 
    m.person_id AS member_id,
    m.member_code,
    CONCAT(p.last_name, ' ', p.first_name) AS member_name,
    p.email,
    COUNT(f.fine_id) AS unpaid_fines_count,
    SUM(f.fine_amount) AS total_unpaid_amount
FROM fine f
JOIN borrow_transaction bt ON f.transaction_id = bt.transaction_id
JOIN member m ON bt.member_id = m.person_id
JOIN person p ON m.person_id = p.person_id
WHERE f.fine_status = 'Unpaid'
GROUP BY m.person_id, m.member_code, p.last_name, p.first_name, p.email;

CREATE OR REPLACE VIEW vw_public_repository_catalog AS
SELECT 
    di.item_id,
    di.title,
    di.doi,
    l.license_name,
    l.license_code,
    di.file_path,
    GROUP_CONCAT(c.category_name SEPARATOR ', ') AS categories
FROM digital_item di
JOIN license l ON di.license_id = l.license_id
LEFT JOIN item_category ic ON di.item_id = ic.item_id
LEFT JOIN category c ON ic.category_id = c.category_id
WHERE di.access_level = 'Public_Open_Access'
   OR (di.access_level = 'Embargoed' AND di.embargo_end_date < CURRENT_DATE)
GROUP BY di.item_id, di.title, di.doi, l.license_name, l.license_code, di.file_path;

-- TRIGGERS AUTOMATION
DELIMITER //

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

    SELECT membership_status, expiry_date, max_borrow_limit
    INTO v_status, v_expiry, v_limit
    FROM member WHERE person_id = NEW.member_id;

    IF v_status <> 'Active' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loi BR-02.1: Tai khoan thanh vien khong o trang thai Active.';
    END IF;
    IF v_expiry < NEW.borrow_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loi BR-02.3: The thanh vien da het han su dung.';
    END IF;

    SELECT COUNT(*) INTO v_active_loans FROM borrow_transaction WHERE member_id = NEW.member_id AND return_date IS NULL;
    IF v_active_loans >= v_limit THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loi BR-02.3: Thanh vien da dat han muc muon toi da.';
    END IF;

    SELECT COALESCE(SUM(f.fine_amount), 0.00) INTO v_unpaid_fines
    FROM fine f JOIN borrow_transaction bt ON f.transaction_id = bt.transaction_id
    WHERE bt.member_id = NEW.member_id AND f.fine_status = 'Unpaid';
    IF v_unpaid_fines > 100000.00 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loi BR-02.3: Thanh vien co khoan no phat vuot nguong 100.000 VND.';
    END IF;

    SELECT copy_status INTO v_copy_status FROM book_copy WHERE copy_id = NEW.copy_id;
    IF v_copy_status <> 'Available' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loi BR-03.3: Ban sao sach khong o trang thai Available.';
    END IF;

    SELECT COUNT(*) INTO v_copy_active FROM borrow_transaction WHERE copy_id = NEW.copy_id AND return_date IS NULL;
    IF v_copy_active > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loi BR-04.1: Ban sao sach dang nam trong mot giao dich chua tra.';
    END IF;
END //

CREATE TRIGGER trg_after_borrow_insert
AFTER INSERT ON borrow_transaction
FOR EACH ROW
BEGIN
    UPDATE book_copy SET copy_status = 'Borrowed' WHERE copy_id = NEW.copy_id;
END //

CREATE TRIGGER trg_after_borrow_update_return
AFTER UPDATE ON borrow_transaction
FOR EACH ROW
BEGIN
    DECLARE v_days_overdue INT;
    DECLARE v_penalty_rate DECIMAL(10,2) DEFAULT 5000.00;
    IF NEW.return_date IS NOT NULL AND OLD.return_date IS NULL THEN
        UPDATE book_copy SET copy_status = 'Available' WHERE copy_id = NEW.copy_id;
        IF NEW.return_date > NEW.due_date THEN
            SET v_days_overdue = DATEDIFF(NEW.return_date, NEW.due_date);
            INSERT INTO fine (transaction_id, fine_amount, fine_reason, fine_status)
            VALUES (NEW.transaction_id, v_days_overdue * v_penalty_rate, CONCAT('Trả quá hạn ', v_days_overdue, ' ngày'), 'Unpaid');
        END IF;
    END IF;
END //

CREATE TRIGGER trg_after_copy_status_update
AFTER UPDATE ON book_copy
FOR EACH ROW
BEGIN
    DECLARE v_active_tx_id INT;
    IF NEW.copy_status IN ('Damaged', 'Lost') AND OLD.copy_status = 'Borrowed' THEN
        SELECT transaction_id INTO v_active_tx_id FROM borrow_transaction
        WHERE copy_id = NEW.copy_id AND return_date IS NULL
        ORDER BY borrow_date DESC, transaction_id DESC LIMIT 1;
        IF v_active_tx_id IS NOT NULL THEN
            IF NEW.copy_status = 'Damaged' THEN
                INSERT INTO fine (transaction_id, fine_amount, fine_reason, fine_status)
                VALUES (v_active_tx_id, 50000.00, 'Den bu lam hu hong sach', 'Unpaid');
            ELSEIF NEW.copy_status = 'Lost' THEN
                INSERT INTO fine (transaction_id, fine_amount, fine_reason, fine_status)
                VALUES (v_active_tx_id, 200000.00, 'Den bu lam mat sach', 'Unpaid');
            END IF;
        END IF;
    END IF;
END //

DELIMITER ;
```

### 4.2 Advanced Queries & Performance Optimization

Hệ thống xây dựng **10 truy vấn phức hợp** (`sql/06b_advanced_queries.sql`) áp dụng CTEs, Window Functions (`DENSE_RANK()`), Subqueries, Conditional Aggregation và Multi-table JOINs:

1. **Báo cáo thực thể trùng lặp:** Thống kê cá nhân vừa là `MEMBER` vừa là `AUTHOR` kèm tổng lượt mượn sách và số công trình số đã xuất bản.
2. **Xếp hạng TOP 10 đầu sách được mượn nhiều nhất:** Sử dụng hàm cửa sổ `DENSE_RANK() OVER (ORDER BY borrow_count DESC)`.
3. **Phân tích vi phạm & doanh thu phạt:** Tổng hợp số tiền phạt `Unpaid` và `Paid` theo từng trạng thái thẻ thành viên.
4. **Kiểm tra điều kiện mượn sách mới của độc giả:** Đánh giá tự động 4 tiêu chí hợp lệ (`Active`, còn hạn, chưa chạm `max_borrow_limit`, nợ phạt $\le 100.000$ VNĐ).
5. **Phân bổ tài liệu số theo giấy phép & mức truy cập:** Thống kê số lượng tài liệu theo `LICENSE` và các mức `Public_Open_Access`, `Restricted_Campus_Only`, `Embargoed`.
6. **Danh sách tài liệu hết hạn Embargo:** Truy vấn các tài liệu `Embargoed` có `embargo_end_date < CURRENT_DATE` cần mở công khai.
7. **Xếp hạng tác giả đóng góp nhiều nhất cho kho lưu trữ mở:** Thống kê tổng ấn phẩm số và thứ tự tác giả cao nhất (`MIN(author_order)`).
8. **Kiểm kê tình trạng bản sao sách vật lý:** Thống kê số lượng bản sao theo từng trạng thái (`Available`, `Borrowed`, `Damaged`, `Lost`, `In_Maintenance`).
9. **Tổng hợp doanh thu tiền phạt theo tháng:** Nhóm theo `DATE_FORMAT(payment_date, '%Y-%m')`.
10. **Tìm tài liệu số liên ngành / đa ngành:** Lọc các tài liệu thuộc từ 2 danh mục (`CATEGORY`) trở lên.

**Chiến lược tối ưu hóa hiệu năng (`EXPLAIN Analysis`):**
* Khi truy vấn lịch sử mượn đang hoạt động (`WHERE member_id = ? AND return_date IS NULL`), việc tạo chỉ mục phức hợp `idx_borrow_member_status (member_id, return_date)` giúp chuyển kế hoạch thực thi từ **Full Table Scan** sang **Index Range Scan**, rút ngắn thời gian phản hồi xuống dưới **10 ms** trên tập dữ liệu lớn.

---

## 5. Verification & Security

### 5.1 Constraint Verification Test Cases (44 Test Cases)

Toàn bộ 44 kịch bản kiểm thử trong `07b_tests.sql` đã được thực thi trên dữ liệu mẫu (~16.000 bản ghi) và đạt kết quả **44/44 PASS (0 FAIL)**:

| Nhóm kiểm thử | Nội dung kiểm tra | Số kịch bản | Kết quả (PASS) | Mã lỗi MySQL kiểm chứng |
| :---: | :--- | :---: | :---: | :--- |
| **Nhóm A** | Miền giá trị (`CHECK`) & Tính duy nhất (`UNIQUE`) (`TC-01` $\rightarrow$ `TC-20`) | 20 | **20 / 20** | `1062` (Duplicate), `3819` (Check) |
| **Nhóm B** | Toàn vẹn tham chiếu: Khóa ngoại, `RESTRICT`, `CASCADE` (`TC-21` $\rightarrow$ `TC-30`) | 10 | **10 / 10** | `1452` (No parent), `1451` (Child exists) |
| **Nhóm C** | Hành vi tự động hóa của `TRIGGER` (`TC-31` $\rightarrow$ `TC-35`) | 5 | **5 / 5** | Tự động đổi trạng thái & tính tiền phạt |
| **Nhóm D** | Quy tắc nghiệp vụ mượn – trả & ràng buộc mức cao (`TC-36` $\rightarrow$ `TC-44`) | 9 | **9 / 9** | `3819` (Check), `1644` (Trigger `SIGNAL`) |
| **Tổng cộng** | **Toàn bộ kịch bản kiểm thử toàn vẹn CSDL** | **44** | **44 / 44** | **100% Đạt** |

### 5.2 Role-Based Access Control (RBAC)

Áp dụng nguyên tắc **đặc quyền tối thiểu (Least Privilege)** thông qua 3 vai trò và phân quyền mức cột/view (`07a_rbac_setup.sql`):

| Vai trò (`Role`) | Tài khoản Demo | Quyền được cấp (`GRANT`) | Quyền bị chặn (`REVOKE` / Không cấp) |
| :---: | :--- | :--- | :--- |
| **`role_admin`** | `admin_user` | Toàn quyền quản trị trên `dloar_db.*` | Không có `GRANT OPTION` |
| **`role_librarian`** | `librarian_user` | `SELECT, INSERT, UPDATE` trên `person`, `physical_book`, `book_copy`, `member`, `borrow_transaction`; `SELECT` & `UPDATE (fine_status, payment_date)` trên `fine`; `SELECT` trên các View nghiệp vụ. | Cấm `DELETE` ở mọi bảng; cấm sửa `fine_amount`; cấm truy cập phân hệ tài liệu số (`digital_item`, `license`). |
| **`role_reader`** | `reader_user` | `SELECT` trên `vw_public_repository_catalog`; `SELECT` các cột công khai của `physical_book` và `book_copy`. | Cấm truy cập bảng `person` (email, SĐT), cột `barcode`, và mọi thao tác `INSERT, UPDATE, DELETE`. |

Kết quả chạy kiểm thử phân quyền (`07c_rbac_test_run.sql`) đạt **16/16 PASS** (chặn chính xác với lỗi `1142` mức bảng và `1143` mức cột):

#### Hình 5.1 – Kết quả kiểm thử phân quyền của `reader_user`
> *6/6 kịch bản Đạt (`R-01` đến `R-05`, bao gồm `R-03b`)*

#### Hình 5.2 – Kết quả kiểm thử phân quyền của `librarian_user`
> *9/9 kịch bản Đạt (`R-06` đến `R-14`)*

#### Hình 5.3 – Kết quả kiểm thử phân quyền của `admin_user`
> *1/1 kịch bản Đạt (`R-15`)*

#### Hình 5.4 – Hình 5.7 – Minh chứng thu hồi quyền (`REVOKE`) và quyền hiệu lực (`SHOW GRANTS`)
> *Kiểm chứng kịch bản `R-16` và `R-17` qua `07d_revoke_demo.sql`: thu hồi quyền `INSERT` trên `borrow_transaction` của `role_librarian`, kiểm tra quyền hiệu lực, và khôi phục lại quyền.*
