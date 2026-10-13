# Digital Library & Open-Access Repository Management System (DLOAR)

![Database](https://img.shields.io/badge/Database-MySQL%20%7C%20MariaDB-blue)
![Standards](https://img.shields.io/badge/Standards-ISO%2FIEC%2FIEEE%2029148%20%7C%20ISO%2FIEC%2019505-green)
![Data Dictionary](https://img.shields.io/badge/Metadata-ISO%2FIEC%2011179-orange)
![License](https://img.shields.io/badge/License-Academic%20Open--Access-purple)

> **Project Title:** Design and Implementation of a Relational Database for Academic Open-Access Digital Library and Repository System  
> **Course:** Database Management Systems / Cơ sở dữ liệu  
> **Due Date:** 

---

## 👥 Project Identity & Team Members

* **Team Name:** G8
* **Team Members:**
  * Nguyễn Trung Thiện (`n25dcat107@gmail.student.ptithcm.edu.vn`) - GitHub: [@thiennguyentrung123-png](https://github.com/thiennguyentrung123-png)
  * Trần Nguyễn Quốc Thịnh (`n25dcat109@gmail.student.ptithcm.edu.vn`) - GitHub: [@n25dcat109-dotcom](https://github.com/n25dcat109-dotcom)
  * Nguyễn Phúc Thịnh (`n22dccn182@gmail.student.ptithcm.edu.vn`) - GitHub: [@Darkbreaker2412](https://github.com/Darkbreaker2412)

---

## 📋 Table of Contents

- [1. Introduction \& Project Scope](#1-introduction--project-scope)
  - [1.1 System Objective](#11-system-objective)
    - [1.1.1 Problem Statement](#111-problem-statement)
    - [1.1.2 Rationale](#112-rationale)
    - [1.1.3 System Scope](#113-system-scope)
    - [1.1.4 Project Objectives](#114-project-objectives)
    - [1.1.5 Entity Overview](#115-entity-overview)
  - [1.2 Business Rules \& Constraints](#12-business-rules--constraints)
- [2. Database Design](#2-database-design)
  - [2.1 Conceptual Model (EER Diagram)](#21-conceptual-model-eer-diagram)
  - [2.2 Logical Schema Mapping](#22-logical-schema-mapping)
  - [2.3 Normalization Verification (1NF $\rightarrow$ BCNF)](#23-normalization-verification-1nf--bcnf)
- [3. Data Dictionary](#3-data-dictionary)
- [4. Database Implementation](#4-database-implementation)
  - [4.1 DDL Script](#41-ddl-script)
  - [4.2 Advanced Queries \& Performance Optimization](#42-advanced-queries--performance-optimization)
- [5. Verification \& Security](#5-verification--security)
  - [5.1 Constraint Verification Test Cases](#51-constraint-verification-test-cases)
  - [5.2 Role-Based Access Control (RBAC)](#52-role-based-access-control-rbac)

---

## 1. Introduction & Project Scope

*(Adapted from ISO/IEC/IEEE 29148 Systems and software engineering — Life cycle processes — Requirements engineering)*

### 1.1 System Objective

#### 1.1.1 Problem Statement
Trong bối cảnh giáo dục hiện đại, các thư viện và trung tâm lưu trữ đang phải đối mặt với nhiều bất cập trong quá trình quản lý và vận hành hệ thống tài liệu. Sự phát triển đồng thời của tài liệu vật lý và tài liệu số đặt ra yêu cầu xây dựng một hệ thống quản lý dữ liệu thống nhất:

1. **Sự phân mảnh giữa tài liệu vật lý và tài liệu số:** Quản lý sách giấy tách biệt với các tạp chí điện tử, bài báo khoa học. Dữ liệu bị phân tán, gây khó khăn cho người dùng khi tìm kiếm và truy cập.
2. **Thiếu công cụ quản lý giấy phép Open Access:** Các kho tài liệu nghiên cứu mở chưa có cơ chế quản lý thống nhất cho các loại giấy phép sử dụng (Creative Commons, Public Domain,...), gây rủi ro về bản quyền và trích dẫn.
3. **Nghiệp vụ thư viện chồng chéo và phức tạp:** Quản lý giới hạn mượn, hạn trả sách, và tiền phạt quá hạn chưa tối ưu. Đặc biệt, bài toán **thực thể chồng chéo** (một người vừa là sinh viên/giảng viên mượn sách, vừa là tác giả của bài báo nghiên cứu) dễ dẫn đến lưu trữ trùng lặp dữ liệu cá nhân.

#### 1.1.2 Rationale
* **Nền tảng tập trung:** Kết hợp quản lý mượn/trả sách vật lý và chia sẻ công khai các ấn phẩm nghiên cứu của trường đại học.
* **Chuẩn bản quyền mở:** Hỗ trợ giấy phép Creative Commons (CC) bảo vệ quyền tác giả và thúc đẩy chia sẻ tri thức.
* **Tự động hóa nghiệp vụ:** Xử lý quy tắc mượn/trả, tự động tính tiền phạt quá hạn và phân quyền truy cập theo cấp độ bảo mật/embargo.

#### 1.1.3 System Scope

##### In-Scope (Trong phạm vi)
* **Quản lý Thành viên & Tác giả:** Xử lý mô hình EER chồng chéo (`PERSON`, `MEMBER`, `AUTHOR`).
* **Quản lý Tài liệu vật lý:** Quản lý đầu sách (`PHYSICAL_BOOK`) và từng bản sao cụ thể (`BOOK_COPY`).
* **Quản lý Nghiệp vụ Mượn - Trả:** Giao dịch mượn/trả, kiểm soát hạn mức và thời gian.
* **Quản lý Tiền phạt:** Tính toán tự động tiền phạt quá hạn, đền bù hư hỏng/mất sách (`FINE`).
* **Quản lý Tài liệu số & Bản quyền mở:** Lưu trữ bài báo/tạp chí (`DIGITAL_ITEM`), giấy phép (`LICENSE`), và thiết lập chính sách khóa tạm thời (Embargo).
* **Quản lý Phân loại:** Cấu trúc danh mục/chủ đề (`CATEGORY`).

##### Out-of-Scope (Ngoài phạm vi)
* **Tích hợp cổng thanh toán trực tuyến:** Hệ thống chỉ lưu trữ trạng thái nộp phạt do thủ thư xác nhận.
* **Quản lý nhân sự & chấm công thủ thư.**
* **Quản lý logistics & vận chuyển sách ngoài thực tế.**

#### 1.1.4 Project Objectives
* Xây dựng cơ sở dữ liệu quan hệ hoàn chỉnh, tối ưu hóa cho tra cứu và quản lý thư viện số mở.
* Áp dụng thành công mô hình **Extended ER (EER)** với tính năng **Specialization/Generalization** để giải quyết các thực thể chồng chéo.
* Đạt chuẩn hóa toàn bộ các bảng ở dạng chuẩn **BCNF**.

#### 1.1.5 Entity Overview

##### 🏢 Phân hệ Thành viên & Tác giả
* `PERSON` (Cá nhân): Thực thể cha (Supertype) lưu giữ thông tin định danh cơ bản (họ tên, email, sđt) tránh trùng lặp dữ liệu.
* `MEMBER` (Thành viên/Độc giả): Subtype đại diện cho sinh viên, giảng viên mượn sách giấy tại thư viện.
* `AUTHOR` (Tác giả): Subtype đại diện cho tác giả sáng tạo công trình nghiên cứu, bài báo số hoặc sách.

##### 📚 Phân hệ Tài liệu vật lý
* `PHYSICAL_BOOK` (Đầu sách): Đại diện cho tác phẩm xuất bản (ISBN, NXB, năm xuất bản).
* `BOOK_COPY` (Bản sao sách): Bản sao vật lý cụ thể tồn tại thực tế trên kệ (Mã vạch Barcode, trạng thái, vị trí).

##### 💻 Phân hệ Tài liệu số & Lưu trữ mở
* `DIGITAL_ITEM` (Tài liệu số): Ấn phẩm điện tử (bài báo, luận văn, tạp chí, tệp tin, DOI).
* `LICENSE` (Giấy phép bản quyền mở): Quy định điều khoản pháp lý sử dụng (Creative Commons, Public Domain).

##### 🔄 Phân hệ Mượn – Trả & Tiền phạt
* `BORROW_TRANSACTION` (Giao dịch mượn - trả): Ghi nhận lượt mượn sách của độc giả.
* `FINE` (Tiền phạt): Khoản phạt tài chính khi quá hạn, làm hỏng hoặc làm mất sách.

##### 🔗 Phân hệ Liên kết & Phân loại
* `BOOK_AUTHOR`: Liên kết Nhiều - Nhiều giữa Tác giả và Đầu sách vật lý.
* `ITEM_AUTHOR`: Liên kết Nhiều - Nhiều giữa Tác giả và Tài liệu số (lưu thứ tự tác giả `author_order`).
* `CATEGORY`: Danh mục / Lĩnh vực tri thức.
* `ITEM_CATEGORY`: Liên kết Nhiều - Nhiều giữa Tài liệu số và Danh mục.

---

### 1.2 Business Rules & Constraints

#### [BR-01] Quy tắc Thực thể Cá nhân, Thành viên & Tác giả (EER Overlap)
* **BR-01.1 (Identity & Single Storage):** Định danh duy nhất bằng `person_id`. Họ tên, Email, SĐT chỉ lưu 1 lần tại `PERSON`.
* **BR-01.2 (Overlapping Roles):** Mối quan hệ giữa `PERSON` và (`MEMBER`, `AUTHOR`) tuân thủ Overlapping & Partial Participation. Một `PERSON` có thể là `MEMBER`, `AUTHOR`, hoặc cả hai.
* **BR-01.3 (Mandatory Inheritance):** Mọi bản ghi trong `MEMBER` và `AUTHOR` phải tham chiếu đến `person_id` hợp lệ.
* **BR-01.4 (Unique Identifiers):** Thuộc tính `email` trong `PERSON` và `orcid` trong `AUTHOR` (nếu có) phải là duy nhất (`UNIQUE`).

#### [BR-02] Quy tắc Quản lý Thành viên & Hạn mức Mượn
* **BR-02.1 (Account Status):**  
  $$membership\_status \in \{\text{'Active'}, \text{'Expired'}, \text{'Suspended'}\}$$
* **BR-02.2 (Max Borrow Limit):** Mỗi thành viên có hạn mức mượn tối đa ($max\_borrow\_limit > 0$).
* **BR-02.3 (Borrowing Eligibility Check):** Điều kiện mượn sách mới:
  1. $membership\_status = \text{'Active'}$ và $current\_date \le expiry\_date$.
  2. Số sách đang mượn $< max\_borrow\_limit$.
  3. Không có khoản nợ tiền phạt chưa thanh toán ($fine\_status = \text{'Unpaid'}$).

#### [BR-03] Quy tắc Quản lý Sách Vật lý & Bản sao
* **BR-03.1 (Book & Copy Relationship):** Một `PHYSICAL_BOOK` có 0 hoặc nhiều `BOOK_COPY`. Mỗi `BOOK_COPY` có mã vạch `barcode` duy nhất.
* **BR-03.2 (Copy Status Domain):**  
  $$copy\_status \in \{\text{'Available'}, \text{'Borrowed'}, \text{'Lost'}, \text{'Damaged'}, \text{'In\_Maintenance'}\}$$
* **BR-03.3 (Availability Enforcement):** Chỉ bản sao có $copy\_status = \text{'Available'}$ mới được phép mượn.

#### [BR-04] Quy tắc Mượn - Trả & Chuyển đổi Trạng thái
* **BR-04.1 (Active Loan Uniqueness):** Tại 1 thời điểm, 1 `BOOK_COPY` chỉ nằm trong tối đa 01 giao dịch đang hoạt động ($return\_date \text{ IS NULL}$).
* **BR-04.2 (Temporal Integrity Constraints):**  
  $$borrow\_date \le due\_date \quad \text{và} \quad borrow\_date \le return\_date$$
* **BR-04.3 (Automatic State Transition):**
  * Tạo giao dịch mượn $\rightarrow$ $copy\_status$: $\text{'Available'} \rightarrow \text{'Borrowed'}$.
  * Trả sách thành công $\rightarrow$ $copy\_status$: $\text{'Borrowed'} \rightarrow \text{'Available'}$.
  * Báo hỏng / mất khi trả $\rightarrow$ $copy\_status$: $\text{'Damaged'}$ hoặc $\text{'Lost'}$.

#### [BR-05] Quy tắc Tính Tiền phạt & Lưu vết Tài chính
* **BR-05.1 (Fine Trigger):** Khởi tạo khi $return\_date > due\_date$ hoặc khi sách bị `Damaged` / `Lost`.
* **BR-05.2 (Fine Calculation):**  
  $$fine\_amount = (return\_date - due\_date) \times daily\_penalty\_rate$$
* **BR-05.3 (Payment Audit):** $fine\_status \in \{\text{'Unpaid'}, \text{'Paid'}\}$. Khi $fine\_status = \text{'Paid'}$, bắt buộc ghi nhận `payment_date`. Không xóa bản ghi `FINE` khỏi CSDL.

#### [BR-06] Quy tắc Tài liệu Số, Giấy phép & Embargo
* **BR-06.1 (Digital Identifiers):** Tệp tin có `file_path`. Mã `doi` (nếu có) phải là `UNIQUE`.
* **BR-06.2 (License Link):** Mỗi `DIGITAL_ITEM` bắt buộc liên kết 01 `LICENSE`.
* **BR-06.3 (Access Policy & Embargo):**  
  $$access\_level \in \{\text{'Public\_Open\_Access'}, \text{'Restricted\_Campus\_Only'}, \text{'Embargoed'}\}$$
  Tài liệu `Embargoed` tự động/được phép mở công khai khi $current\_date > embargo\_end\_date$.

#### [BR-07] Quy tắc Phân loại & Quyền Tác giả
* **BR-07.1 (Many-to-Many Mapping):** Bảng liên kết `BOOK_AUTHOR`, `ITEM_AUTHOR`, `ITEM_CATEGORY`.
* **BR-07.2 (Authorship Metadata):**
  * `BOOK_AUTHOR.author_role` $\in \{\text{'Main Author'}, \text{'Co-Author'}, \text{'Editor'}, \text{'Translator'}\}$.
  * `ITEM_AUTHOR.author_order` $\ge 1$.

#### [BR-08] Ràng buộc Toàn vẹn Kỹ thuật CSDL
* **BR-08.1 (Keys):** PK duy nhất, `NOT NULL`. FK tham chiếu chính xác.
* **BR-08.2 (Deletion Policy):** `ON DELETE RESTRICT` cho giao dịch mượn/trả & tiền phạt; `ON DELETE CASCADE` cho các bảng trung gian.

---

## 2. Database Design

*(Adapted from ISO/IEC 19505 / Information Engineering Standards)*

### 2.1 Conceptual Model (EER Diagram)

Mô hình EER của hệ thống sử dụng các kỹ thuật mở rộng:
* **Supertype / Subtype:** `PERSON` làm thực thể cha; `MEMBER` và `AUTHOR` là thực thể con kế thừa theo cơ chế **Overlapping ($O$) & Partial Participation**.
* **1:N & N:M Relationships:** Thiết kế rõ ràng mối quan hệ giữa các phân hệ tài liệu vật lý, tài liệu số, giao dịch và phân loại.

![EER Diagram](https://raw.githubusercontent.com/placeholder/dloar-eer-diagram.png) *(Xem sơ đồ quan hệ đính kèm dưới đây)*

```
                       +--------------------+
                       |       PERSON       |
                       +--------------------+
                       | PK  person_id      |
                       |     first_name     |
                       |     last_name      |
                       | UQ  email          |
                       |     phone_number   |
                       +---------+----------+
                                 | (d, o) Specialization
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
            | 1:1 (0..1)                  |                      |
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

---

### 2.2 Logical Schema Mapping

1. **`PERSON`**: `(person_id [PK], first_name, last_name, email [UQ], phone_number, created_at)`
2. **`MEMBER`**: `(person_id [PK, FK -> PERSON.person_id], member_code [UQ], membership_status, max_borrow_limit, expiry_date)`
3. **`AUTHOR`**: `(person_id [PK, FK -> PERSON.person_id], author_code [UQ], affiliation, orcid [UQ], bio)`
4. **`PHYSICAL_BOOK`**: `(book_id [PK], title, isbn [UQ], publisher, publication_year)`
5. **`BOOK_COPY`**: `(copy_id [PK], book_id [FK -> PHYSICAL_BOOK.book_id], barcode [UQ], copy_status, shelf_location)`
6. **`LICENSE`**: `(license_id [PK], license_name, license_code [UQ], terms_description)`
7. **`DIGITAL_ITEM`**: `(item_id [PK], license_id [FK -> LICENSE.license_id], title, abstract, doi [UQ], file_path, file_format, access_level, embargo_end_date)`
8. **`BORROW_TRANSACTION`**: `(transaction_id [PK], member_id [FK -> MEMBER.person_id], copy_id [FK -> BOOK_COPY.copy_id], borrow_date, due_date, return_date)`
9. **`FINE`**: `(fine_id [PK], transaction_id [FK, UQ -> BORROW_TRANSACTION.transaction_id], fine_amount, fine_reason, fine_status, payment_date)`
10. **`CATEGORY`**: `(category_id [PK], category_name [UQ], description)`
11. **`BOOK_AUTHOR`**: `(book_id [PK, FK -> PHYSICAL_BOOK.book_id], author_id [PK, FK -> AUTHOR.person_id], author_role)`
12. **`ITEM_AUTHOR`**: `(item_id [PK, FK -> DIGITAL_ITEM.item_id], author_id [PK, FK -> AUTHOR.person_id], author_order, author_role)`
13. **`ITEM_CATEGORY`**: `(item_id [PK, FK -> DIGITAL_ITEM.item_id], category_id [PK, FK -> CATEGORY.category_id])`

---

### 2.3 Normalization Verification (1NF $\rightarrow$ BCNF)

#### 2.3.1 Core Functional Dependencies (FDs)
* **PERSON:** $FD_1: person\_id \rightarrow first\_name, last\_name, email, phone\_number, created\_at$; $FD_2: email \rightarrow person\_id, ...$
* **MEMBER:** $FD_1: person\_id \rightarrow member\_code, membership\_status, max\_borrow\_limit, expiry\_date$; $FD_2: member\_code \rightarrow person\_id, ...$
* **AUTHOR:** $FD_1: person\_id \rightarrow author\_code, affiliation, orcid, bio$; $FD_2: orcid \rightarrow person\_id, ...$
* **PHYSICAL_BOOK:** $FD_1: book\_id \rightarrow title, isbn, publisher, publication\_year$; $FD_2: isbn \rightarrow book\_id, ...$
* **BOOK_COPY:** $FD_1: copy\_id \rightarrow barcode, copy\_status, shelf\_location, book\_id$; $FD_2: barcode \rightarrow copy\_id, ...$
* **BORROW_TRANSACTION:** $FD_1: transaction\_id \rightarrow borrow\_date, due\_date, return\_date, member\_id, copy\_id$
* **FINE:** $FD_1: fine\_id \rightarrow fine\_amount, fine\_reason, fine\_status, payment\_date, transaction\_id$; $FD_2: transaction\_id \rightarrow fine\_id, ...$
* **DIGITAL_ITEM:** $FD_1: item\_id \rightarrow title, abstract, doi, file\_path, file\_format, access\_level, embargo\_end\_date, license\_id$; $FD_2: doi \rightarrow item\_id, ...$

#### 2.3.2 Proof of Normal Forms
1. **1NF (First Normal Form):** Tất cả các thuộc tính đều chứa giá trị đơn lẻ (Atomic), không chứa tập thuộc tính lặp hay thuộc tính đa trị.
2. **2NF (Second Normal Form):** 
   * Đối với các bảng có khóa đơn: Nghiễm nhiên đạt 2NF.
   * Đối với các bảng liên kết khóa phức hợp (`BOOK_AUTHOR`, `ITEM_AUTHOR`, `ITEM_CATEGORY`): Không tồn tại phụ thuộc hàm một phần (Partial Dependency), mọi thuộc tính ngoài khóa đều phụ thuộc vào toàn bộ tổ hợp khóa.
3. **3NF (Third Normal Form):** Không tồn tại phụ thuộc bắc cầu (Transitive Dependency). Mọi thông tin tham chiếu như `publisher`, `license_name` đều được phân rã thành các bảng độc lập.
4. **BCNF (Boyce-Codd Normal Form):** Tất cả các vế trái ($X$) của các phụ thuộc hàm $X \rightarrow Y$ đều là Khóa chính (Primary Key) hoặc Khóa ứng viên (Candidate Key - như `email`, `isbn`, `barcode`, `doi`, `orcid`).  
   $$\Rightarrow \text{Toàn bộ hệ thống đạt chuẩn BCNF.}$$

---

## 3. Data Dictionary

*(Adapted from ISO/IEC 11179 Information technology — Metadata registries (MDR))*

### 3.1 Bảng `person`
| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `person_id` | `INT` | PK | No | Auto Inc | Định danh cá nhân duy nhất |
| `first_name` | `VARCHAR(50)` | - | No | None | Tên cá nhân |
| `last_name` | `VARCHAR(50)` | - | No | None | Họ và tên đệm |
| `email` | `VARCHAR(100)`| CK | No | None | Email duy nhất (`UNIQUE`) [BR-01.4] |
| `phone_number` | `VARCHAR(20)` | - | Yes | NULL | Số điện thoại liên hệ |
| `created_at` | `TIMESTAMP` | - | No | `CURRENT_TIMESTAMP` | Thời điểm tạo hồ sơ |

### 3.2 Bảng `member`
| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `person_id` | `INT` | PK, FK | No | None | FK -> `person(person_id) ON DELETE CASCADE` [BR-01.3] |
| `member_code` | `VARCHAR(20)` | CK | No | None | Mã thẻ thành viên (`UNIQUE`) |
| `membership_status`| `VARCHAR(20)` | - | No | `'Active'` | `CHECK (membership_status IN ('Active','Expired','Suspended'))` [BR-02.1] |
| `max_borrow_limit` | `INT` | - | No | `5` | `CHECK (max_borrow_limit > 0)` [BR-02.2] |
| `expiry_date` | `DATE` | - | No | None | Ngày hết hạn thẻ |

### 3.3 Bảng `author`
| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `person_id` | `INT` | PK, FK | No | None | FK -> `person(person_id) ON DELETE CASCADE` [BR-01.3] |
| `author_code` | `VARCHAR(20)` | CK | No | None | Mã số tác giả (`UNIQUE`) |
| `affiliation` | `VARCHAR(100)`| - | Yes | NULL | Đơn vị / Cơ quan công tác |
| `orcid` | `VARCHAR(20)` | CK | Yes | NULL | Mã ORCID iD quốc tế (`UNIQUE`) [BR-01.4] |
| `bio` | `TEXT` | - | Yes | NULL | Tiểu sử tác giả |

### 3.4 Bảng `physical_book`
| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `book_id` | `INT` | PK | No | Auto Inc | Định danh đầu sách |
| `title` | `VARCHAR(255)`| - | No | None | Tiêu đề sách |
| `isbn` | `VARCHAR(20)` | CK | No | None | Mã ISBN (`UNIQUE`) |
| `publisher` | `VARCHAR(100)`| - | Yes | NULL | Nhà xuất bản |
| `publication_year` | `INT` | - | Yes | NULL | `CHECK (publication_year >= 1500)` |

### 3.5 Bảng `book_copy`
| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `copy_id` | `INT` | PK | No | Auto Inc | Định danh bản sao |
| `book_id` | `INT` | FK | No | None | FK -> `physical_book(book_id) ON DELETE RESTRICT` |
| `barcode` | `VARCHAR(50)` | CK | No | None | Mã vạch (`UNIQUE`) [BR-03.1] |
| `copy_status` | `VARCHAR(20)` | - | No | `'Available'` | `CHECK (copy_status IN ('Available','Borrowed','Lost','Damaged','In_Maintenance'))` [BR-03.2] |
| `shelf_location` | `VARCHAR(50)` | - | Yes | NULL | Vị trí thực tế trên kệ |

### 3.6 Bảng `license`
| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `license_id` | `INT` | PK | No | Auto Inc | Định danh giấy phép |
| `license_name` | `VARCHAR(100)`| - | No | None | Tên đầy đủ giấy phép |
| `license_code` | `VARCHAR(50)` | CK | No | None | Ký hiệu viết tắt (`UNIQUE`) |
| `terms_description`| `TEXT` | - | Yes | NULL | Điều khoản sử dụng |

### 3.7 Bảng `digital_item`
| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `item_id` | `INT` | PK | No | Auto Inc | Định danh tài liệu số |
| `license_id` | `INT` | FK | No | None | FK -> `license(license_id) ON DELETE RESTRICT` [BR-06.2] |
| `title` | `VARCHAR(255)`| - | No | None | Tiêu đề tài liệu |
| `abstract` | `TEXT` | - | Yes | NULL | Tóm tắt nội dung |
| `doi` | `VARCHAR(100)`| CK | Yes | NULL | Mã định danh DOI (`UNIQUE`) [BR-06.1] |
| `file_path` | `VARCHAR(500)`| - | No | None | Đường dẫn lưu trữ tệp [BR-06.1] |
| `file_format` | `VARCHAR(10)` | - | Yes | `'PDF'` | Định dạng tệp |
| `access_level` | `VARCHAR(50)` | - | No | `'Public_Open_Access'`| `CHECK (access_level IN ('Public_Open_Access','Restricted_Campus_Only','Embargoed'))` [BR-06.3] |
| `embargo_end_date` | `DATE` | - | Yes | NULL | Ngày hết hạn khóa embargo [BR-06.3] |

### 3.8 Bảng `borrow_transaction`
| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `transaction_id` | `INT` | PK | No | Auto Inc | Định danh giao dịch |
| `member_id` | `INT` | FK | No | None | FK -> `member(person_id) ON DELETE RESTRICT` |
| `copy_id` | `INT` | FK | No | None | FK -> `book_copy(copy_id) ON DELETE RESTRICT` |
| `borrow_date` | `DATE` | - | No | None | Ngày mượn |
| `due_date` | `DATE` | - | No | None | `CHECK (due_date >= borrow_date)` [BR-04.2] |
| `return_date` | `DATE` | - | Yes | NULL | `CHECK (return_date IS NULL OR return_date >= borrow_date)` [BR-04.1, BR-04.2] |

### 3.9 Bảng `fine`
| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `fine_id` | `INT` | PK | No | Auto Inc | Định danh khoản phạt |
| `transaction_id` | `INT` | FK, CK | No | None | FK -> `borrow_transaction(transaction_id) ON DELETE RESTRICT` [BR-05.3] |
| `fine_amount` | `DECIMAL(10,2)`| - | No | `0.00` | `CHECK (fine_amount >= 0.00)` [BR-05.2] |
| `fine_reason` | `VARCHAR(255)`| - | Yes | NULL | Lý do xử phạt |
| `fine_status` | `VARCHAR(20)` | - | No | `'Unpaid'` | `CHECK (fine_status IN ('Unpaid', 'Paid'))` [BR-05.3] |
| `payment_date` | `DATE` | - | Yes | NULL | Ngày thanh toán tiền phạt [BR-05.3] |

### 3.10 Bảng `category`
| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `category_id` | `INT` | PK | No | Auto Inc | Định danh danh mục |
| `category_name` | `VARCHAR(100)`| CK | No | None | Tên danh mục (`UNIQUE`) |
| `description` | `TEXT` | - | Yes | NULL | Mô tả phạm vi |

### 3.11 Bảng `book_author`
| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `book_id` | `INT` | PK, FK | No | None | FK -> `physical_book(book_id) ON DELETE CASCADE` |
| `author_id` | `INT` | PK, FK | No | None | FK -> `author(person_id) ON DELETE CASCADE` |
| `author_role` | `VARCHAR(50)` | - | Yes | `'Main Author'`| `CHECK (author_role IN ('Main Author', 'Co-Author', 'Editor', 'Translator'))` [BR-07.2] |

### 3.12 Bảng `item_author`
| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `item_id` | `INT` | PK, FK | No | None | FK -> `digital_item(item_id) ON DELETE CASCADE` |
| `author_id` | `INT` | PK, FK | No | None | FK -> `author(person_id) ON DELETE CASCADE` |
| `author_order` | `INT` | - | No | `1` | `CHECK (author_order >= 1)` [BR-07.2] |
| `author_role` | `VARCHAR(50)` | - | Yes | `'Principal Investigator'`| Vai trò đối với công trình số |

### 3.13 Bảng `item_category`
| Attribute Name | Data Type | Key | Nullable | Default | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `item_id` | `INT` | PK, FK | No | None | FK -> `digital_item(item_id) ON DELETE CASCADE` [BR-07.3] |
| `category_id` | `INT` | PK, FK | No | None | FK -> `category(category_id) ON DELETE CASCADE` [BR-07.3] |

---

## 4. Database Implementation

### 4.1 DDL Script

#### Database Initialization (`00_init_db.sql`)
```sql
DROP DATABASE IF EXISTS dloar_db;
CREATE DATABASE dloar_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE dloar_db;
```

#### Table Definitions (`01_tables.sql`)
```sql
-- 1. Table PERSON
DROP TABLE IF EXISTS dloar_db.person;
CREATE TABLE dloar_db.person (
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
DROP TABLE IF EXISTS dloar_db.member;
CREATE TABLE dloar_db.member (
    person_id INT NOT NULL,
    member_code VARCHAR(20) NOT NULL,
    membership_status VARCHAR(20) NOT NULL DEFAULT 'Active',
    max_borrow_limit INT NOT NULL DEFAULT 5,
    expiry_date DATE NOT NULL,
    CONSTRAINT pk_member PRIMARY KEY (person_id),
    CONSTRAINT uq_member_code UNIQUE (member_code),
    CONSTRAINT fk_member_person FOREIGN KEY (person_id)
        REFERENCES dloar_db.person (person_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_member_status CHECK (membership_status IN ('Active', 'Expired', 'Suspended')),
    CONSTRAINT chk_member_max_borrow CHECK (max_borrow_limit > 0)
) ENGINE=InnoDB;

-- 3. Table AUTHOR
DROP TABLE IF EXISTS dloar_db.author;
CREATE TABLE dloar_db.author (
    person_id INT NOT NULL,
    author_code VARCHAR(20) NOT NULL,
    affiliation VARCHAR(100) DEFAULT NULL,
    orcid VARCHAR(20) DEFAULT NULL,
    bio TEXT DEFAULT NULL,
    CONSTRAINT pk_author PRIMARY KEY (person_id),
    CONSTRAINT uq_author_code UNIQUE (author_code),
    CONSTRAINT uq_author_orcid UNIQUE (orcid),
    CONSTRAINT fk_author_person FOREIGN KEY (person_id)
        REFERENCES dloar_db.person (person_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 4. Table PHYSICAL_BOOK
DROP TABLE IF EXISTS dloar_db.physical_book;
CREATE TABLE dloar_db.physical_book (
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
DROP TABLE IF EXISTS dloar_db.book_copy;
CREATE TABLE dloar_db.book_copy (
    copy_id INT NOT NULL AUTO_INCREMENT,
    book_id INT NOT NULL,
    barcode VARCHAR(50) NOT NULL,
    copy_status VARCHAR(20) NOT NULL DEFAULT 'Available',
    shelf_location VARCHAR(50) DEFAULT NULL,
    CONSTRAINT pk_book_copy PRIMARY KEY (copy_id),
    CONSTRAINT uq_book_copy_barcode UNIQUE (barcode),
    CONSTRAINT fk_book_copy_book FOREIGN KEY (book_id)
        REFERENCES dloar_db.physical_book (book_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_copy_status CHECK (copy_status IN ('Available', 'Borrowed', 'Lost', 'Damaged', 'In_Maintenance'))
) ENGINE=InnoDB;

-- 6. Table LICENSE
DROP TABLE IF EXISTS dloar_db.license;
CREATE TABLE dloar_db.license (
    license_id INT NOT NULL AUTO_INCREMENT,
    license_name VARCHAR(100) NOT NULL,
    license_code VARCHAR(50) NOT NULL,
    terms_description TEXT DEFAULT NULL,
    CONSTRAINT pk_license PRIMARY KEY (license_id),
    CONSTRAINT uq_license_code UNIQUE (license_code)
) ENGINE=InnoDB;

-- 7. Table DIGITAL_ITEM
DROP TABLE IF EXISTS dloar_db.digital_item;
CREATE TABLE dloar_db.digital_item (
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
        REFERENCES dloar_db.license (license_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_access_level CHECK (access_level IN ('Public_Open_Access', 'Restricted_Campus_Only', 'Embargoed'))
) ENGINE=InnoDB;

-- 8. Table BORROW_TRANSACTION
DROP TABLE IF EXISTS dloar_db.borrow_transaction;
CREATE TABLE dloar_db.borrow_transaction (
    transaction_id INT NOT NULL AUTO_INCREMENT,
    member_id INT NOT NULL,
    copy_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE DEFAULT NULL,
    CONSTRAINT pk_borrow_transaction PRIMARY KEY (transaction_id),
    CONSTRAINT fk_borrow_member FOREIGN KEY (member_id)
        REFERENCES dloar_db.member (person_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_borrow_copy FOREIGN KEY (copy_id)
        REFERENCES dloar_db.book_copy (copy_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_borrow_due_dates CHECK (due_date >= borrow_date),
    CONSTRAINT chk_borrow_return_dates CHECK (return_date IS NULL OR return_date >= borrow_date)
) ENGINE=InnoDB;

-- 9. Table FINE
DROP TABLE IF EXISTS dloar_db.fine;
CREATE TABLE dloar_db.fine (
    fine_id INT NOT NULL AUTO_INCREMENT,
    transaction_id INT NOT NULL,
    fine_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    fine_reason VARCHAR(255) DEFAULT NULL,
    fine_status VARCHAR(20) NOT NULL DEFAULT 'Unpaid',
    payment_date DATE DEFAULT NULL,
    CONSTRAINT pk_fine PRIMARY KEY (fine_id),
    CONSTRAINT uq_fine_transaction UNIQUE (transaction_id),
    CONSTRAINT fk_fine_transaction FOREIGN KEY (transaction_id)
        REFERENCES dloar_db.borrow_transaction (transaction_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_fine_amount CHECK (fine_amount >= 0.00),
    CONSTRAINT chk_fine_status CHECK (fine_status IN ('Unpaid', 'Paid'))
) ENGINE=InnoDB;

-- 10. Table CATEGORY
DROP TABLE IF EXISTS dloar_db.category;
CREATE TABLE dloar_db.category (
    category_id INT NOT NULL AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    description TEXT DEFAULT NULL,
    CONSTRAINT pk_category PRIMARY KEY (category_id),
    CONSTRAINT uq_category_name UNIQUE (category_name)
) ENGINE=InnoDB;

-- 11. Table BOOK_AUTHOR
DROP TABLE IF EXISTS dloar_db.book_author;
CREATE TABLE dloar_db.book_author (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_role VARCHAR(50) DEFAULT 'Main Author',
    CONSTRAINT pk_book_author PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_ba_book FOREIGN KEY (book_id)
        REFERENCES dloar_db.physical_book (book_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ba_author FOREIGN KEY (author_id)
        REFERENCES dloar_db.author (person_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_book_author_role CHECK (author_role IN ('Main Author', 'Co-Author', 'Editor', 'Translator'))
) ENGINE=InnoDB;

-- 12. Table ITEM_AUTHOR
DROP TABLE IF EXISTS dloar_db.item_author;
CREATE TABLE dloar_db.item_author (
    item_id INT NOT NULL,
    author_id INT NOT NULL,
    author_order INT NOT NULL DEFAULT 1,
    author_role VARCHAR(50) DEFAULT 'Principal Investigator',
    CONSTRAINT pk_item_author PRIMARY KEY (item_id, author_id),
    CONSTRAINT fk_ia_item FOREIGN KEY (item_id)
        REFERENCES dloar_db.digital_item (item_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ia_author FOREIGN KEY (author_id)
        REFERENCES dloar_db.author (person_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_item_author_order CHECK (author_order >= 1)
) ENGINE=InnoDB;

-- 13. Table ITEM_CATEGORY
DROP TABLE IF EXISTS dloar_db.item_category;
CREATE TABLE dloar_db.item_category (
    item_id INT NOT NULL,
    category_id INT NOT NULL,
    CONSTRAINT pk_item_category PRIMARY KEY (item_id, category_id),
    CONSTRAINT fk_ic_item FOREIGN KEY (item_id)
        REFERENCES dloar_db.digital_item (item_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ic_category FOREIGN KEY (category_id)
        REFERENCES dloar_db.category (category_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
```

#### Indexing Strategy (`02_indexes.sql`)
```sql
USE dloar_db;

CREATE INDEX idx_person_names ON dloar_db.person (last_name, first_name);
CREATE INDEX idx_borrow_member_status ON dloar_db.borrow_transaction (member_id, return_date);
CREATE INDEX idx_borrow_copy_status ON dloar_db.borrow_transaction (copy_id, return_date);
CREATE INDEX idx_book_copy_status ON dloar_db.book_copy (copy_status);
CREATE INDEX idx_digital_item_access ON dloar_db.digital_item (access_level, embargo_end_date);
CREATE INDEX idx_fine_status ON dloar_db.fine (fine_status);
```

#### Database Views (`03_views.sql`)
```sql
USE dloar_db;

-- View 1: Active Loans Overview
CREATE OR REPLACE VIEW dloar_db.vw_active_loans AS
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
FROM dloar_db.borrow_transaction bt
JOIN dloar_db.member m ON bt.member_id = m.person_id
JOIN dloar_db.person p ON m.person_id = p.person_id
JOIN dloar_db.book_copy bc ON bt.copy_id = bc.copy_id
JOIN dloar_db.physical_book pb ON bc.book_id = pb.book_id
WHERE bt.return_date IS NULL;

-- View 2: Unpaid Fines Summary
CREATE OR REPLACE VIEW dloar_db.vw_unpaid_fines_summary AS
SELECT 
    m.person_id AS member_id,
    m.member_code,
    CONCAT(p.last_name, ' ', p.first_name) AS member_name,
    p.email,
    COUNT(f.fine_id) AS unpaid_fines_count,
    SUM(f.fine_amount) AS total_unpaid_amount
FROM dloar_db.fine f
JOIN dloar_db.borrow_transaction bt ON f.transaction_id = bt.transaction_id
JOIN dloar_db.member m ON bt.member_id = m.person_id
JOIN dloar_db.person p ON m.person_id = p.person_id
WHERE f.fine_status = 'Unpaid'
GROUP BY m.person_id, m.member_code, p.last_name, p.first_name, p.email;

-- View 3: Public Open-Access Catalog
CREATE OR REPLACE VIEW dloar_db.vw_public_repository_catalog AS
SELECT 
    di.item_id,
    di.title,
    di.doi,
    l.license_name,
    l.license_code,
    di.file_path,
    GROUP_CONCAT(c.category_name SEPARATOR ', ') AS categories
FROM dloar_db.digital_item di
JOIN dloar_db.license l ON di.license_id = l.license_id
LEFT JOIN dloar_db.item_category ic ON di.item_id = ic.item_id
LEFT JOIN dloar_db.category c ON ic.category_id = c.category_id
WHERE di.access_level = 'Public_Open_Access'
   OR (di.access_level = 'Embargoed' AND di.embargo_end_date < CURRENT_DATE)
GROUP BY di.item_id, di.title, di.doi, l.license_name, l.license_code, di.file_path;
```

#### Triggers Automation (`04_triggers.sql`)
```sql
USE dloar_db;

DELIMITER //

-- Trigger 1: Auto-update book copy status to 'Borrowed' upon loan insertion
DROP TRIGGER IF EXISTS dloar_db.trg_after_borrow_insert //
CREATE TRIGGER dloar_db.trg_after_borrow_insert
AFTER INSERT ON dloar_db.borrow_transaction
FOR EACH ROW
BEGIN
    UPDATE dloar_db.book_copy 
    SET copy_status = 'Borrowed'
    WHERE copy_id = NEW.copy_id;
END //

-- Trigger 2: Auto-update status to 'Available' & calculate overdue fine upon return
DROP TRIGGER IF EXISTS dloar_db.trg_after_borrow_update_return //
CREATE TRIGGER dloar_db.trg_after_borrow_update_return
AFTER UPDATE ON dloar_db.borrow_transaction
FOR EACH ROW
BEGIN
    DECLARE v_days_overdue INT;
    DECLARE v_penalty_rate DECIMAL(10,2) DEFAULT 5000.00;
    
    IF NEW.return_date IS NOT NULL AND OLD.return_date IS NULL THEN
        -- Set status back to Available if not damaged/lost
        UPDATE dloar_db.book_copy 
        SET copy_status = 'Available'
        WHERE copy_id = NEW.copy_id AND copy_status = 'Borrowed';
        
        -- Auto-generate fine if return is overdue
        IF NEW.return_date > NEW.due_date THEN
            SET v_days_overdue = DATEDIFF(NEW.return_date, NEW.due_date);
            
            INSERT INTO dloar_db.fine (
                transaction_id, 
                fine_amount, 
                fine_reason, 
                fine_status
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

-- Trigger 3: Generate fine compensation if book copy is marked 'Damaged' or 'Lost'
DROP TRIGGER IF EXISTS dloar_db.trg_after_copy_status_update_fine //
CREATE TRIGGER dloar_db.trg_after_copy_status_update_fine
AFTER UPDATE ON dloar_db.book_copy
FOR EACH ROW
BEGIN
    DECLARE v_active_trans_id INT;
    
    IF NEW.copy_status IN ('Damaged', 'Lost') AND OLD.copy_status != NEW.copy_status THEN
        SELECT transaction_id INTO v_active_trans_id
        FROM dloar_db.borrow_transaction
        WHERE copy_id = NEW.copy_id
        ORDER BY borrow_date DESC
        LIMIT 1;
        
        IF v_active_trans_id IS NOT NULL THEN
            INSERT INTO dloar_db.fine (
                transaction_id, 
                fine_amount, 
                fine_reason, 
                fine_status
            )
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
```

---

### 4.2 Advanced Queries & Performance Optimization

#### Queries (`05_queries.sql`)

```sql
USE dloar_db;

-- Query 1: Overlapping Entities Report (Persons who are both Members & Authors)
WITH member_borrow_stats AS (
    SELECT member_id, COUNT(*) AS total_borrows
    FROM dloar_db.borrow_transaction
    GROUP BY member_id
),
author_item_stats AS (
    SELECT author_id, COUNT(*) AS total_digital_publications
    FROM dloar_db.item_author
    GROUP BY author_id
)
SELECT 
    p.person_id,
    CONCAT(p.last_name, ' ', p.first_name) AS full_name,
    p.email,
    m.member_code,
    a.author_code,
    a.affiliation,
    COALESCE(mbs.total_borrows, 0) AS total_borrows,
    COALESCE(ais.total_digital_publications, 0) AS total_digital_publications
FROM dloar_db.person p
JOIN dloar_db.member m ON p.person_id = m.person_id
JOIN dloar_db.author a ON p.person_id = a.person_id
LEFT JOIN member_borrow_stats mbs ON m.person_id = mbs.member_id
LEFT JOIN author_item_stats ais ON a.person_id = ais.author_id
ORDER BY total_digital_publications DESC, total_borrows DESC;

-- Query 2: Dense Ranking of Most Borrowed Physical Books
WITH book_usage AS (
    SELECT 
        pb.book_id,
        pb.title,
        pb.isbn,
        COUNT(bt.transaction_id) AS borrow_count
    FROM dloar_db.physical_book pb
    JOIN dloar_db.book_copy bc ON pb.book_id = bc.book_id
    JOIN dloar_db.borrow_transaction bt ON bc.copy_id = bt.copy_id
    GROUP BY pb.book_id, pb.title, pb.isbn
)
SELECT 
    bu.book_id,
    bu.title,
    bu.isbn,
    bu.borrow_count,
    DENSE_RANK() OVER (ORDER BY bu.borrow_count DESC) AS overall_rank
FROM book_usage bu
LIMIT 10;

-- Query 3: Fine Collection & Overdue Analysis by Membership Status
SELECT 
    m.membership_status,
    COUNT(DISTINCT m.person_id) AS total_members,
    COUNT(f.fine_id) AS total_fine_records,
    SUM(CASE WHEN f.fine_status = 'Unpaid' THEN f.fine_amount ELSE 0 END) AS total_unpaid_amount,
    SUM(CASE WHEN f.fine_status = 'Paid' THEN f.fine_amount ELSE 0 END) AS total_collected_amount
FROM dloar_db.member m
JOIN dloar_db.borrow_transaction bt ON m.person_id = bt.member_id
JOIN dloar_db.fine f ON bt.transaction_id = f.transaction_id
GROUP BY m.membership_status;

-- Query 4: Member Eligibility Validation Engine [BR-02.3]
WITH active_loans AS (
    SELECT member_id, COUNT(*) AS active_loan_count
    FROM dloar_db.borrow_transaction
    WHERE return_date IS NULL
    GROUP BY member_id
),
unpaid_fines AS (
    SELECT bt.member_id, SUM(f.fine_amount) AS total_unpaid_fine
    FROM dloar_db.fine f
    JOIN dloar_db.borrow_transaction bt ON f.transaction_id = bt.transaction_id
    WHERE f.fine_status = 'Unpaid'
    GROUP BY bt.member_id
)
SELECT 
    m.person_id,
    m.member_code,
    CONCAT(p.last_name, ' ', p.first_name) AS member_name,
    m.membership_status,
    m.max_borrow_limit,
    COALESCE(al.active_loan_count, 0) AS current_active_loans,
    COALESCE(uf.total_unpaid_fine, 0) AS total_unpaid_fine,
    CASE 
        WHEN m.membership_status != 'Active' THEN 'BLOCKED: Account Not Active'
        WHEN m.expiry_date < CURRENT_DATE THEN 'BLOCKED: Membership Expired'
        WHEN COALESCE(al.active_loan_count, 0) >= m.max_borrow_limit THEN 'BLOCKED: Max Borrow Limit Reached'
        WHEN COALESCE(uf.total_unpaid_fine, 0) > 0 THEN 'BLOCKED: Unpaid Fine Outstanding'
        ELSE 'ELIGIBLE: Ready to Borrow'
    END AS borrow_eligibility_status
FROM dloar_db.member m
JOIN dloar_db.person p ON m.person_id = p.person_id
LEFT JOIN active_loans al ON m.person_id = al.member_id
LEFT JOIN unpaid_fines uf ON m.person_id = uf.member_id;

-- Query 5: Digital Items Breakdown by Open License and Access Level
SELECT 
    l.license_code,
    l.license_name,
    SUM(CASE WHEN di.access_level = 'Public_Open_Access' THEN 1 ELSE 0 END) AS public_access_count,
    SUM(CASE WHEN di.access_level = 'Restricted_Campus_Only' THEN 1 ELSE 0 END) AS campus_only_count,
    SUM(CASE WHEN di.access_level = 'Embargoed' THEN 1 ELSE 0 END) AS embargoed_count,
    COUNT(di.item_id) AS total_items
FROM dloar_db.license l
LEFT JOIN dloar_db.digital_item di ON l.license_id = di.license_id
GROUP BY l.license_id, l.license_code, l.license_name
ORDER BY total_items DESC;

-- Query 6: Expired Embargoed Items Detection [BR-06.3]
SELECT 
    di.item_id,
    di.title,
    di.doi,
    di.access_level,
    di.embargo_end_date,
    DATEDIFF(CURRENT_DATE, di.embargo_end_date) AS days_since_embargo_expired
FROM dloar_db.digital_item di
WHERE di.access_level = 'Embargoed'
  AND di.embargo_end_date IS NOT NULL
  AND di.embargo_end_date < CURRENT_DATE;

-- Query 7: Top Contributing Authors in Open-Access Repository
SELECT 
    a.person_id AS author_id,
    a.author_code,
    CONCAT(p.last_name, ' ', p.first_name) AS author_name,
    a.affiliation,
    a.orcid,
    COUNT(ia.item_id) AS total_publications,
    MIN(ia.author_order) AS highest_authorship_order
FROM dloar_db.author a
JOIN dloar_db.person p ON a.person_id = p.person_id
JOIN dloar_db.item_author ia ON a.person_id = ia.author_id
GROUP BY a.person_id, a.author_code, p.last_name, p.first_name, a.affiliation, a.orcid
HAVING COUNT(ia.item_id) >= 1
ORDER BY total_publications DESC;

-- Query 8: Physical Book Copies Status Breakdown
SELECT 
    pb.book_id,
    pb.title,
    pb.isbn,
    COUNT(bc.copy_id) AS total_copies,
    SUM(CASE WHEN bc.copy_status = 'Available' THEN 1 ELSE 0 END) AS available_copies,
    SUM(CASE WHEN bc.copy_status = 'Borrowed' THEN 1 ELSE 0 END) AS borrowed_copies,
    SUM(CASE WHEN bc.copy_status = 'Damaged' THEN 1 ELSE 0 END) AS damaged_copies,
    SUM(CASE WHEN bc.copy_status = 'Lost' THEN 1 ELSE 0 END) AS lost_copies,
    SUM(CASE WHEN bc.copy_status = 'In_Maintenance' THEN 1 ELSE 0 END) AS maintenance_copies
FROM dloar_db.physical_book pb
LEFT JOIN dloar_db.book_copy bc ON pb.book_id = bc.book_id
GROUP BY pb.book_id, pb.title, pb.isbn;

-- Query 9: Monthly Fine Revenue Report
SELECT 
    DATE_FORMAT(f.payment_date, '%Y-%m') AS payment_month,
    COUNT(f.fine_id) AS total_fines_paid,
    SUM(f.fine_amount) AS total_revenue
FROM dloar_db.fine f
WHERE f.fine_status = 'Paid' AND f.payment_date IS NOT NULL
GROUP BY DATE_FORMAT(f.payment_date, '%Y-%m')
ORDER BY payment_month DESC;

-- Query 10: Multi-Categorized Digital Resources
SELECT 
    di.item_id,
    di.title,
    di.doi,
    COUNT(ic.category_id) AS category_count,
    GROUP_CONCAT(c.category_name ORDER BY c.category_name SEPARATOR ' | ') AS categories_list
FROM dloar_db.digital_item di
JOIN dloar_db.item_category ic ON di.item_id = ic.item_id
JOIN dloar_db.category c ON ic.category_id = c.category_id
GROUP BY di.item_id, di.title, di.doi
HAVING COUNT(ic.category_id) > 1
ORDER BY category_count DESC;
```

#### Performance Test Case & Optimization Strategy
* **Kịch bản:** Thực thi tra cứu lịch sử mượn sách chưa trả của độc giả theo `member_id` ($return\_date \text{ IS NULL}$).
* **Trước tối ưu:** Thực hiện Full Table Scan trên bảng `borrow_transaction` khi đạt quy mô hàng triệu bản ghi, dẫn đến latency cao.
* **Sau tối ưu:** Bổ sung Composite Index `idx_borrow_member_status(member_id, return_date)`. Chuyển truy vấn thành Index Range Scan với thời gian phản hồi $<10\text{ms}$, tuân thủ chuẩn ISO/IEC 25010 về hiệu năng.

---

## 5. Verification & Security

### 5.1 Constraint Verification Test Cases

```sql
-- ============================================================
-- 5.1 CONSTRAINT TEST CASES
-- ============================================================

-- Test Case 1: Insert Duplicate Email in PERSON
-- Constraint: uq_person_email
-- Expected Result: FAIL (ERROR 1062: Duplicate entry)
INSERT INTO person (first_name, last_name, email) 
VALUES ('An', 'Nguyễn', 'n25dcat107@gmail.student.ptithcm.edu.vn');

-- Test Case 2: Insert MEMBER with invalid max_borrow_limit <= 0
-- Constraint: chk_member_max_borrow
-- Expected Result: FAIL (ERROR 3819: Check constraint violated)
INSERT INTO member (person_id, member_code, membership_status, max_borrow_limit, expiry_date) 
VALUES (1, 'MEM999', 'Active', 0, '2026-12-31');

-- Test Case 3: Insert Borrow Transaction with due_date < borrow_date
-- Constraint: chk_borrow_due_dates
-- Expected Result: FAIL (ERROR 3819: Check constraint violated)
INSERT INTO borrow_transaction (member_id, copy_id, borrow_date, due_date) 
VALUES (1, 1, '2026-08-20', '2026-08-10');

-- Test Case 4: Delete MEMBER while having Active Loans
-- Constraint: ON DELETE RESTRICT (fk_borrow_member)
-- Expected Result: FAIL (ERROR 1451: Cannot delete parent row)
DELETE FROM member WHERE person_id = 1;
```

---

### 5.2 Role-Based Access Control (RBAC)

```sql
-- ============================================================
-- 5.2 ROLE-BASED ACCESS CONTROL (RBAC) DEFINITION
-- ============================================================

-- 1. Create Roles
CREATE ROLE IF NOT EXISTS 'role_admin';
CREATE ROLE IF NOT EXISTS 'role_librarian';
CREATE ROLE IF NOT EXISTS 'role_reader';

-- 2. Admin Privileges (Full Access)
GRANT ALL PRIVILEGES ON dloar_db.* TO 'role_admin';

-- 3. Librarian Privileges
GRANT SELECT, INSERT, UPDATE ON dloar_db.physical_book TO 'role_librarian';
GRANT SELECT, INSERT, UPDATE ON dloar_db.book_copy TO 'role_librarian';
GRANT SELECT, INSERT, UPDATE ON dloar_db.member TO 'role_librarian';
GRANT SELECT, INSERT, UPDATE ON dloar_db.borrow_transaction TO 'role_librarian';
GRANT SELECT, INSERT, UPDATE ON dloar_db.fine TO 'role_librarian';
GRANT SELECT ON dloar_db.vw_active_loans TO 'role_librarian';
GRANT SELECT ON dloar_db.vw_unpaid_fines_summary TO 'role_librarian';

-- 4. Reader/Student Privileges
GRANT SELECT ON dloar_db.vw_public_repository_catalog TO 'role_reader';
GRANT SELECT (book_id, title, isbn, publisher, publication_year) ON dloar_db.physical_book TO 'role_reader';
GRANT SELECT (copy_id, book_id, copy_status, shelf_location) ON dloar_db.book_copy TO 'role_reader';

-- 5. Assign Role to User
CREATE USER IF NOT EXISTS 'librarian_user'@'localhost' IDENTIFIED BY 'LibPass123!';
GRANT 'role_librarian' TO 'librarian_user'@'localhost';
SET DEFAULT ROLE 'role_librarian' TO 'librarian_user'@'localhost';

FLUSH PRIVILEGES;