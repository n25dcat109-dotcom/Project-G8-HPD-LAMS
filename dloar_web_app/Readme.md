# Hướng Dẫn Sử Dụng Chi Tiết Hệ Thống Quản Lý Thư Viện & Kho Tài Liệu Mở (DLOAR Management System)

Giao diện web **DLOAR Management System** được thiết kế gồm **3 phân hệ chức năng** tương ứng với 3 tài khoản phân quyền trên MySQL (`reader_user`, `librarian_user`, `admin_user`), cho phép thao tác toàn bộ 13 bảng, 3 view, 4 trigger và 10 truy vấn thống kê trong cơ sở dữ liệu `dloar_db`.

## 1. Hướng dẫn cài đặt & cách chạy hệ thống

### 1.1. Yêu cầu môi trường & Cài đặt thư viện Python

* **Hệ quản trị CSDL:** MySQL Server 8.0 trở lên đang hoạt động tại `localhost` cổng `3306`.
* **Môi trường Python:** Python 3.8+ đã cài đặt 2 thư viện `flask` và `mysql-connector-python`. Mở Terminal (PowerShell / CMD) và chạy lệnh sau để cài đặt:

```bash
pip install flask mysql-connector-python
```

*(Trường hợp máy cài nhiều phiên bản Python, gọi trực tiếp đường dẫn trình thông dịch, ví dụ: `& 'D:\Programs\Python\python.exe' -m pip install flask mysql-connector-python`)*

### 1.2. Khởi tạo Cơ sở dữ liệu `dloar_db` trên MySQL

Mở **MySQL Workbench** (hoặc MySQL Command Line) bằng tài khoản `root` và thực thi lần lượt các tệp SQL theo đúng thứ tự phụ thuộc:

1. **`01_schema_ddl.sql`**: Tạo cơ sở dữ liệu `dloar_db` và cấu trúc 13 bảng cùng các khóa chính, khóa ngoại, ràng buộc `UNIQUE`, `CHECK`.
2. **Các tệp ràng buộc, View, Trigger & Chỉ mục** (bao gồm **`04b_extra_constraints.sql`**): Khởi tạo 3 View (`vw_public_repository_catalog`, `vw_active_loans`, `vw_unpaid_fines_summary`), 4 Trigger kiểm soát mượn/trả/phạt tự động và chỉ mục `idx_borrow_member_status`.
3. **`06_seed_data.sql`**: Nạp toàn bộ dữ liệu mẫu (~16.000 bản ghi) cho 13 bảng để phục vụ kiểm thử và thống kê.
4. **`07a_rbac_setup.sql`**: Tạo 3 tài khoản phân quyền cục bộ trên MySQL (`reader_user`, `librarian_user`, `admin_user`) và cấp phát quyền bảng/cột tương ứng.

### 1.3. Cấu trúc thư mục ứng dụng Web

Đảm bảo mã nguồn ứng dụng được tổ chức đúng cấu trúc thư mục chuẩn của Flask:

```text
dloar_web_app/
├── app.py                  # Mã nguồn Backend Flask, định tuyến & kết nối MySQL RBAC
└── templates/
    └── index.html          # Giao diện Frontend Bootstrap 5 + DataTables
```

### 1.4. Khởi chạy máy chủ Web & Truy cập trình duyệt

1. Mở Terminal trong VS Code (hoặc PowerShell), di chuyển vào thư mục `dloar_web_app`:

```bash
cd dloar_web_app
```

2. Chạy tệp `app.py` để khởi động máy chủ Flask:

```bash
python app.py
```

*(Hoặc chỉ định rõ đường dẫn Python trên máy: `& 'D:\Programs\Python\python.exe' app.py`)*

3. Khi Terminal hiển thị thông báo `* Running on http://127.0.0.1:5000`, mở trình duyệt web (Chrome / Edge) và truy cập đúng địa chỉ:
   **`http://127.0.0.1:5000`**
4. **Lưu ý vận hành:**
   * **Không** mở trực tiếp tệp `templates/index.html` bằng cách nhấp đúp từ File Explorer (sẽ làm hiện mã mẫu `{{ ... }}` và không kết nối được MySQL).
   * Luôn giữ cửa sổ Terminal chạy `app.py` trong suốt quá trình sử dụng; nhấn tổ hợp phím **`Ctrl + C`** tại Terminal khi muốn dừng máy chủ.

## 2. Điều khiển chung trên toàn trang

* **Đổi vai trò kết nối MySQL (góc trên bên phải):** Chọn giữa **Độc giả (`reader_user`)**, **Thủ thư (`librarian_user`)** và **Quản trị hệ thống (`admin_user`)**. Ngay khi chuyển đổi, ứng dụng sẽ ngắt kết nối cũ và mở phiên MySQL mới bằng đúng tài khoản tương ứng để thực thi phân quyền RBAC trực tiếp tại tầng cơ sở dữ liệu.

* **Thanh thống kê KPI (dưới thanh điều hướng):** Tự động đếm và tổng hợp số liệu thực tế từ `dloar_db` (tổng số cá nhân, độc giả, tác giả, thực thể chồng chéo Overlap, đầu sách, bản sao, tài liệu số, giao dịch đang mượn và tổng tiền phạt).

* **Khung thông báo hệ thống:** Mọi thao tác thành công hoặc bị MySQL từ chối đều hiển thị ngay phía trên nội dung chính, kèm mã lỗi SQL gốc (`Error 1644` từ trigger, `1142`/`1143` từ RBAC, `3819` từ `CHECK`, `1062` từ `UNIQUE`, `1451` từ khóa ngoại `RESTRICT`).

* **Thao tác trên bảng dữ liệu (DataTables):** Tất cả bảng đều tích hợp ô **Tìm nhanh trong bảng** (lọc tức thì theo mọi cột), nút sắp xếp tăng/giảm tại tiêu đề cột, phân trang và ô **Hiển thị số dòng** (`10`, `20`, `50`, `100` hoặc `Tất cả`).

## 3. Phân hệ 1: Độc giả (`reader_user`) — Tra cứu & Kiểm thử giới hạn quyền

Phân hệ này mô phỏng người dùng phổ thông tra cứu kho tài liệu số mở và danh mục sách giấy với quyền hạn tối thiểu.

### 3.1. Tra cứu dữ liệu công khai

* **Lọc trực tiếp trên CSDL:** Nhập từ khóa (tiêu đề, mã `DOI`, `ISBN`, nhà xuất bản hoặc tên danh mục) vào ô tìm kiếm phía trên và bấm **Lọc trên MySQL**; để trống và bấm lọc để hiển thị lại toàn bộ danh mục.

* **Xem 3 bảng dữ liệu công khai:**

  1. **Kho Tài liệu số Mở (`vw_public_repository_catalog`):** Chỉ hiển thị tài liệu có trạng thái `Public_Open_Access` hoặc tài liệu `Embargoed` đã qua ngày hết hạn khóa.

  2. **Danh mục Đầu sách Vật lý (`physical_book`):** Hiển thị thông tin xuất bản cơ bản (`book_id`, `title`, `isbn`, `publisher`, `publication_year`).

  3. **Tình trạng Bản sao (`book_copy`):** Chỉ hiển thị `copy_id`, `book_id`, `copy_status`, `shelf_location` — cột nhạy cảm `barcode` bị ẩn hoàn toàn do không được cấp quyền `SELECT`.

### 3.2. Kiểm thử phân quyền RBAC (3 nút viền đỏ ở góc phải thẻ tiêu đề)

* **Test R-03b:** Thử đọc trực tiếp cột `barcode` trong `book_copy` $\rightarrow$ MySQL chặn với **`Error 1143`** (từ chối truy cập mức cột).

* **Test R-04:** Thử đọc cột `email` trong bảng `person` $\rightarrow$ MySQL chặn với **`Error 1142`** (từ chối truy cập mức bảng).

* **Test R-05:** Thử thêm bản sao mới vào `book_copy` $\rightarrow$ MySQL chặn với **`Error 1142`**.

## 4. Phân hệ 2: Thủ thư (`librarian_user`) — Nghiệp vụ Mượn/Trả, Bản sao & Tiền phạt

Phân hệ này vận hành toàn bộ nghiệp vụ lưu thông sách giấy và thu tiền phạt hằng ngày.

### 4.1. Cột bên trái (Biểu mẫu thao tác & Kiểm thử)

1. **FR-03: Lập Phiếu Mượn Sách (`borrow_transaction`):**

   * Nhập `member_id`, `copy_id`, chọn `Ngày mượn`, `Hạn trả` rồi bấm **Xác nhận cho mượn**.

   * Nếu hợp lệ, trigger `trg_after_borrow_insert` tự động đổi trạng thái bản sao sang `Borrowed`. Nếu vi phạm điều kiện thẻ, hạn mức mượn, nợ phạt trên 100.000 VNĐ hoặc sách không sẵn sàng, trigger `trg_before_borrow_insert` chặn lại và báo **`Error 1644`**.

   * **6 nút điền nhanh kịch bản kiểm thử:** Bấm `TC-31` (hợp lệ), `TC-38` (thẻ `Suspended`), `TC-39` (thẻ `Expired`), `TC-41` (bản sao `Lost`), `TC-42` (bản sao `Borrowed`), hoặc `TC-43` (bản sao đang có giao dịch chưa trả) để tự động điền thông số vào form phía trên rồi bấm **Xác nhận cho mượn**.

2. **Kiểm thử giới hạn quyền Thủ thư (5 nút viền đỏ R-10 đến R-14):**

   * **Test R-10:** Thử sửa số tiền phạt `fine_amount = 0` $\rightarrow$ MySQL chặn với **`Error 1143`**.

   * **Test R-11:** Thử xóa bản ghi tiền phạt (`DELETE FROM fine`) $\rightarrow$ MySQL chặn với **`Error 1142`**.

   * **Test R-12:** Thử xóa lịch sử mượn trả (`DELETE FROM borrow_transaction`) $\rightarrow$ MySQL chặn với **`Error 1142`**.

   * **Test R-13:** Thử thêm tài liệu số vào `digital_item` $\rightarrow$ MySQL chặn với **`Error 1142`**.

   * **Test R-14:** Thử đọc bảng giấy phép `license` $\rightarrow$ MySQL chặn với **`Error 1142`**.

3. **FR-02: Cập nhật Trạng thái Bản sao (`book_copy`):**

   * Nhập `Copy ID`, chọn trạng thái mới (`Available`, `Damaged`, `Lost`, `In_Maintenance`) và bấm **Cập nhật trạng thái**.

   * Khi chuyển một bản sao đang ở trạng thái `Borrowed` sang `Damaged` hoặc `Lost`, trigger `trg_after_copy_status_update` tự động tạo phiếu phạt đền bù **`50.000 VNĐ`** (hư hỏng) hoặc **`200.000 VNĐ`** (mất sách) gắn với giao dịch mượn đang mở của bản sao đó.

4. **BR-02: Cập nhật Thẻ Thành viên (`member`):**

   * Nhập `Member ID`, chọn trạng thái thẻ (`Active`, `Expired`, `Suspended`), điều chỉnh hạn mức mượn tối đa (`max_borrow_limit`) và ngày hết hạn thẻ (`expiry_date`) rồi bấm **Lưu thẻ**.

### 4.2. Cột bên phải (5 Tab theo dõi dữ liệu)

* **Tab Đang mượn (`vw_active_loans`):** Liệt kê mọi phiếu mượn chưa trả (`return_date IS NULL`). Chọn ngày trả thực tế ở cột cuối và bấm **Trả** — nếu ngày trả lớn hơn `Hạn trả`, trigger `trg_after_borrow_update_return` tự động trả bản sao về `Available` và sinh khoản phạt quá hạn với mức **`5.000 VNĐ/ngày trễ`**.

* **Tab Tiền phạt (`fine`):** Hiển thị toàn bộ khoản phạt; bấm nút **Thu phạt (Paid)** ở dòng `Unpaid` để cập nhật trạng thái thành `Paid` và tự động lưu `payment_date` là ngày hiện tại.

* **Tab Lịch sử mượn-trả (`borrow_transaction`):** Xem toàn bộ giao dịch đã hoàn tất lẫn đang mượn.

* **Tab Bản sao sách (`book_copy`):** Xem đầy đủ tất cả bản sao kèm mã vạch `barcode` và vị trí kệ.

* **Tab Thành viên (`member` + `person`):** Tra cứu thông tin liên hệ, hạn mức và trạng thái thẻ của toàn bộ độc giả.

## 5. Phân hệ 3: Quản trị hệ thống (`admin_user`) — Toàn quyền 13 bảng & Báo cáo nâng cao

Phân hệ này mở toàn quyền trên `dloar_db` với **5 Tab chức năng**:

### 5.1. Tab 1 — FR-08: 10 Truy vấn Nâng cao & EXPLAIN

* **Thực thi 10 truy vấn phức tạp:** Chọn từ danh sách (`Q1` thực thể chồng chéo CTEs, `Q2` Top 10 sách mượn nhiều nhất dùng `DENSE_RANK()`, `Q3` phân tích phạt theo loại thẻ, `Q4` xét điều kiện mượn `ELIGIBLE`/`BLOCKED`, `Q5` phân bổ giấy phép Open Access, `Q6` tài liệu hết hạn Embargo, `Q7` tác giả đóng góp nhiều nhất, `Q8` kiểm kê bản sao theo trạng thái, `Q9` doanh thu phạt theo tháng, `Q10` tài liệu đa ngành) và bấm **Chạy truy vấn**.

* **Đo hiệu năng & EXPLAIN:** Góc phải tiêu đề hiển thị **thời gian thực thi tính bằng mili-giây (`ms`)**; bên dưới hiển thị bảng **`EXPLAIN`** chứng minh MySQL sử dụng chỉ mục `idx_borrow_member_status` (`type = ref`) thay vì quét toàn bảng.

* **6 nút kiểm thử ràng buộc toàn vẹn (`TC-01`, `TC-02`, `TC-25`, `TC-27`, `TC-36`, `TC-37`):** Mỗi nút chạy câu lệnh vi phạm trong một giao dịch và tự động `ROLLBACK` để chứng minh CSDL chặn lỗi (`1062`, `3819`, `1451`) mà không làm hỏng dữ liệu mẫu.

### 5.2. Tab 2 — FR-01: Person / Member / Author (Mô hình EER)

* Nhập thông tin cá nhân (`last_name`, `first_name`, `email`, `phone_number`) một lần duy nhất vào bảng cha `person`.

* Tích chọn đồng thời cả **Là Độc giả (`MEMBER`)** và **Đồng thời là Tác giả (`AUTHOR`)** để tạo thực thể chồng chéo (*Overlapping*), hoặc bỏ tích cả hai để tạo thực thể chỉ nằm ở lớp cha (*Partial*).

### 5.3. Tab 3 — FR-06: Kho Tài liệu số, Giấy phép & Danh mục

* **Đăng tải tài liệu số (`digital_item`):** Nhập đầy đủ `title`, `abstract`, `doi`, `file_path`, `license_id`, `access_level` và `embargo_end_date`. Nếu chọn `Embargoed` mà bỏ trống ngày hết hạn, ràng buộc `chk_embargo_end_date` sẽ báo `Error 3819`.

* **Mở công khai tài liệu Embargoed:** Với các tài liệu đang ở trạng thái `Embargoed`, bấm nút **Mở công khai** trong bảng để chuyển sang `Public_Open_Access`.

* **Quản lý danh mục chuẩn:** Bổ sung các loại giấy phép mới vào bảng `license` và chủ đề mới vào bảng `category` ở khung bên trái phía dưới.

### 5.4. Tab 4 — FR-07: Quan hệ Nhiều-Nhiều (`N:M`)

* **Sách giấy — Tác giả (`book_author`):** Gán tác giả và vai trò (`Main Author`, `Co-Author`, `Editor`, `Translator`) cho sách giấy.

* **Tài liệu số — Tác giả (`item_author`):** Gán tác giả kèm thứ tự đóng góp (`author_order >= 1`) và vai trò cho tài liệu số.

* **Tài liệu số — Danh mục (`item_category`):** Gán một hoặc nhiều chủ đề phân loại cho tài liệu số.

### 5.5. Tab 5 — FR-02: Đầu sách & Bản sao

* Thêm mới đầu sách vào `physical_book` (kiểm tra `UNIQUE` trên `isbn` và `publication_year >= 1500`).

* Thêm các bản sao vật lý mới vào `book_copy` (kiểm tra `UNIQUE` trên `barcode`).

## 6. Bảng mã ID dữ liệu mẫu (Seed Data) dùng nhanh khi Demo

| Đối tượng | Mã ID trong `dloar_db` | Đặc điểm dữ liệu & Kịch bản áp dụng | 
| :--- | :--- | :--- | 
| **Thành viên hợp lệ** | `member_id = 1` | Thẻ `MEM000001` trạng thái `Active`, hạn mức `5`, hết hạn `2028-12-31` — dùng để mượn sách thành công (`TC-31`). | 
| **Thành viên vi phạm** | `member_id = 7`, `10` | ID `7` có thẻ `Expired` (`2025-12-31`); ID `10` có trạng thái `Suspended` — dùng để test trigger chặn mượn (`TC-38`, `TC-39`). | 
| **Tác giả đơn vai trò** | `person_id = 601`, `700` | Chỉ nằm trong `author`, chưa có bản ghi trong `member` — dùng để test chuyên môn hóa EER. | 
| **Bản sao sẵn sàng** | `copy_id = 1`, `1001`, `1002` | Trạng thái `Available` — dùng để lập phiếu mượn mới. | 
| **Bản sao đang mượn** | `copy_id = 52`, `1500` | Trạng thái `Borrowed` — dùng để test chặn mượn trùng (`TC-42`, `TC-43`) hoặc chuyển sang `Damaged`/`Lost` để sinh phạt đền bù. | 
| **Bản sao hỏng / mất** | `copy_id = 2000`, `2200` | ID `2000` là `Damaged`, ID `2200` là `Lost` — dùng để test trigger chặn mượn bản sao không sẵn sàng (`TC-41`). | 
| **Giao dịch đang mượn** | `transaction_id = 2551`, `3000` | ID `2551` đã quá hạn (trả sách sẽ tự sinh phạt `5.000 VNĐ/ngày`); ID `3000` còn hạn (trả đúng hạn không phát sinh phạt). | 

## 7. Kịch bản trình diễn (Demo Flow) gợi ý

1. **Bước 1 — Vai trò Độc giả (`reader_user`):** Tra cứu tài liệu số mở và bấm 3 nút kiểm thử `R-03b`, `R-04`, `R-05` để chứng minh bảo mật mức cột và mức bảng.

2. **Bước 2 — Vai trò Thủ thư (`librarian_user`):**

   * Chạy `TC-31` để mượn sách thành công, sau đó chạy `TC-38` hoặc `TC-41` để chứng minh trigger chặn vi phạm nghiệp vụ.

   * Thực hiện trả sách quá hạn (`transaction_id = 2551`) và thu tiền phạt (`Paid`).

   * Bấm `R-10` và `R-11` để chứng minh thủ thư không thể sửa số tiền phạt hay xóa lịch sử giao dịch.

3. **Bước 3 — Vai trò Quản trị hệ thống (`admin_user`):**

   * Tạo một thực thể chồng chéo (*Overlapping*) vừa là Độc giả vừa là Tác giả tại Tab `FR-01`.

   * Chạy các truy vấn nâng cao (`Q1`, `Q2`, `Q4`) tại Tab `FR-08` và kiểm chứng kế hoạch thực thi chỉ mục qua bảng `EXPLAIN`.