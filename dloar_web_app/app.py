from datetime import date, timedelta
import time
from flask import Flask, flash, redirect, render_template, request, session, url_for
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)
app.secret_key = "dloar_g8_secret_key_2026"

# Cấu hình 3 tài khoản phân quyền theo Mục 5.2 (07a_rbac_setup.sql)
DB_ROLES = {
    "reader": {
        "user": "reader_user",
        "password": "ReaderPass123!",
        "label": "Độc giả (reader_user)",
        "badge": "bg-info text-dark",
        "desc": "Chỉ tra cứu tài liệu mở (vw_public_repository_catalog) và các cột công khai của physical_book, book_copy.",
    },
    "librarian": {
        "user": "librarian_user",
        "password": "LibPass123!",
        "label": "Thủ thư (librarian_user)",
        "badge": "bg-warning text-dark",
        "desc": "Quản lý thành viên, sách/bản sao, mượn/trả, thu tiền phạt; bị cấm DELETE và cấm sửa fine_amount.",
    },
    "admin": {
        "user": "admin_user",
        "password": "AdminPass123!",
        "label": "Quản trị hệ thống (admin_user)",
        "badge": "bg-danger",
        "desc": "Toàn quyền trên 13 bảng của dloar_db: EER Person/Member/Author, Kho số, Giấy phép, Danh mục, Liên kết N:M & Báo cáo.",
    },
}

# 10 Truy vấn phức tạp chuẩn theo Mục 4.2 của báo cáo (Không giới hạn LIMIT, trừ Q2 là TOP 10)
ADVANCED_QUERIES = {
    "q1": {
        "title": "Truy vấn 1: Thực thể chồng chéo (Cá nhân vừa là Độc giả vừa là Tác giả - CTEs)",
        "sql": """
            WITH member_borrow_stats AS (
                SELECT member_id, COUNT(*) AS total_borrows
                FROM borrow_transaction
                GROUP BY member_id
            ),
            author_item_stats AS (
                SELECT author_id, COUNT(*) AS total_digital_publications
                FROM item_author
                GROUP BY author_id
            )
            SELECT p.person_id,
                   CONCAT(p.last_name, ' ', p.first_name) AS full_name,
                   p.email,
                   m.member_code,
                   a.author_code,
                   a.affiliation,
                   COALESCE(mbs.total_borrows, 0) AS total_borrows,
                   COALESCE(ais.total_digital_publications, 0) AS total_digital_publications
            FROM person p
            JOIN member m ON p.person_id = m.person_id
            JOIN author a ON p.person_id = a.person_id
            LEFT JOIN member_borrow_stats mbs ON m.person_id = mbs.member_id
            LEFT JOIN author_item_stats ais ON a.person_id = ais.author_id
            ORDER BY total_digital_publications DESC, total_borrows DESC;
        """,
    },
    "q2": {
        "title": "Truy vấn 2: TOP 10 đầu sách vật lý được mượn nhiều nhất (DENSE_RANK)",
        "sql": """
            WITH book_usage AS (
                SELECT pb.book_id, pb.title, pb.isbn,
                       COUNT(bt.transaction_id) AS borrow_count
                FROM physical_book pb
                JOIN book_copy bc ON pb.book_id = bc.book_id
                JOIN borrow_transaction bt ON bc.copy_id = bt.copy_id
                GROUP BY pb.book_id, pb.title, pb.isbn
            )
            SELECT bu.book_id, bu.title, bu.isbn, bu.borrow_count,
                   DENSE_RANK() OVER (ORDER BY bu.borrow_count DESC) AS overall_rank
            FROM book_usage bu
            LIMIT 10;
        """,
    },
    "q3": {
        "title": "Truy vấn 3: Phân tích tình trạng vi phạm & tổng tiền phạt theo từng loại thẻ",
        "sql": """
            SELECT m.membership_status,
                   COUNT(DISTINCT m.person_id) AS total_members,
                   COUNT(f.fine_id) AS total_fine_records,
                   SUM(CASE WHEN f.fine_status = 'Unpaid' THEN f.fine_amount ELSE 0 END) AS total_unpaid_amount,
                   SUM(CASE WHEN f.fine_status = 'Paid' THEN f.fine_amount ELSE 0 END) AS total_collected_amount
            FROM member m
            JOIN borrow_transaction bt ON m.person_id = bt.member_id
            JOIN fine f ON bt.transaction_id = f.transaction_id
            GROUP BY m.membership_status;
        """,
    },
    "q4": {
        "title": "Truy vấn 4: Kiểm tra điều kiện mượn sách mới của toàn bộ độc giả (ELIGIBLE / BLOCKED)",
        "sql": """
            WITH unpaid_fines AS (
                SELECT bt.member_id, SUM(f.fine_amount) AS total_unpaid_fines
                FROM borrow_transaction bt
                JOIN fine f ON bt.transaction_id = f.transaction_id
                WHERE f.fine_status = 'Unpaid'
                GROUP BY bt.member_id
            )
            SELECT m.person_id, m.member_code,
                   CONCAT(p.last_name, ' ', p.first_name) AS member_name,
                   m.membership_status, m.max_borrow_limit,
                   COUNT(bt.transaction_id) AS current_active_loans,
                   COALESCE(uf.total_unpaid_fines, 0.00) AS total_unpaid_fines,
                   CASE
                       WHEN m.membership_status != 'Active' THEN 'BLOCKED: Tài khoản không hoạt động'
                       WHEN m.expiry_date < CURRENT_DATE THEN 'BLOCKED: Thẻ đã hết hạn'
                       WHEN COUNT(bt.transaction_id) >= m.max_borrow_limit THEN 'BLOCKED: Đạt giới hạn mượn tối đa'
                       WHEN COALESCE(uf.total_unpaid_fines, 0.00) > 100000.00 THEN 'BLOCKED: Nợ phạt > 100.000 VNĐ'
                       ELSE 'ELIGIBLE: Đủ điều kiện mượn'
                   END AS borrow_eligibility_status
            FROM member m
            JOIN person p ON m.person_id = p.person_id
            LEFT JOIN borrow_transaction bt ON m.person_id = bt.member_id AND bt.return_date IS NULL
            LEFT JOIN unpaid_fines uf ON m.person_id = uf.member_id
            GROUP BY m.person_id, m.member_code, p.last_name, p.first_name,
                     m.membership_status, m.max_borrow_limit, m.expiry_date, uf.total_unpaid_fines
            ORDER BY m.person_id ASC;
        """,
    },
    "q5": {
        "title": "Truy vấn 5: Phân bổ tài liệu số theo Giấy phép (LICENSE) & Mức truy cập",
        "sql": """
            SELECT l.license_code, l.license_name,
                   SUM(CASE WHEN di.access_level = 'Public_Open_Access' THEN 1 ELSE 0 END) AS public_access_count,
                   SUM(CASE WHEN di.access_level = 'Restricted_Campus_Only' THEN 1 ELSE 0 END) AS campus_only_count,
                   SUM(CASE WHEN di.access_level = 'Embargoed' THEN 1 ELSE 0 END) AS embargoed_count,
                   COUNT(di.item_id) AS total_items
            FROM license l
            LEFT JOIN digital_item di ON l.license_id = di.license_id
            GROUP BY l.license_id, l.license_code, l.license_name
            ORDER BY total_items DESC;
        """,
    },
    "q6": {
        "title": "Truy vấn 6: Toàn bộ tài liệu số Embargoed đã hết hạn khóa cần mở công khai",
        "sql": """
            SELECT di.item_id, di.title, di.doi, di.access_level, di.embargo_end_date,
                   DATEDIFF(CURRENT_DATE, di.embargo_end_date) AS days_since_embargo_expired
            FROM digital_item di
            WHERE di.access_level = 'Embargoed'
              AND di.embargo_end_date IS NOT NULL
              AND di.embargo_end_date < CURRENT_DATE;
        """,
    },
    "q7": {
        "title": "Truy vấn 7: Tác giả có đóng góp cho Kho lưu trữ mở (item_author)",
        "sql": """
            SELECT a.person_id AS author_id, a.author_code,
                   CONCAT(p.last_name, ' ', p.first_name) AS author_name,
                   a.affiliation, a.orcid,
                   COUNT(ia.item_id) AS total_publications,
                   MIN(ia.author_order) AS highest_authorship_order
            FROM author a
            JOIN person p ON a.person_id = p.person_id
            JOIN item_author ia ON a.person_id = ia.author_id
            GROUP BY a.person_id, a.author_code, p.last_name, p.first_name, a.affiliation, a.orcid
            HAVING COUNT(ia.item_id) >= 1
            ORDER BY total_publications DESC;
        """,
    },
    "q8": {
        "title": "Truy vấn 8: Kiểm kê toàn bộ đầu sách & bản sao (book_copy) theo từng trạng thái",
        "sql": """
            SELECT pb.book_id, pb.title, pb.isbn,
                   COUNT(bc.copy_id) AS total_copies,
                   SUM(CASE WHEN bc.copy_status = 'Available' THEN 1 ELSE 0 END) AS available_copies,
                   SUM(CASE WHEN bc.copy_status = 'Borrowed' THEN 1 ELSE 0 END) AS borrowed_copies,
                   SUM(CASE WHEN bc.copy_status = 'Damaged' THEN 1 ELSE 0 END) AS damaged_copies,
                   SUM(CASE WHEN bc.copy_status = 'Lost' THEN 1 ELSE 0 END) AS lost_copies,
                   SUM(CASE WHEN bc.copy_status = 'In_Maintenance' THEN 1 ELSE 0 END) AS maintenance_copies
            FROM physical_book pb
            LEFT JOIN book_copy bc ON pb.book_id = bc.book_id
            GROUP BY pb.book_id, pb.title, pb.isbn;
        """,
    },
    "q9": {
        "title": "Truy vấn 9: Tổng hợp doanh thu tiền phạt đã thu được theo từng tháng",
        "sql": """
            SELECT DATE_FORMAT(f.payment_date, '%Y-%m') AS payment_month,
                   COUNT(f.fine_id) AS total_fines_paid,
                   SUM(f.fine_amount) AS total_revenue
            FROM fine f
            WHERE f.fine_status = 'Paid' AND f.payment_date IS NOT NULL
            GROUP BY DATE_FORMAT(f.payment_date, '%Y-%m')
            ORDER BY payment_month DESC;
        """,
    },
    "q10": {
        "title": "Truy vấn 10: Toàn bộ tài liệu số đa ngành / liên ngành (>= 2 danh mục)",
        "sql": """
            SELECT di.item_id, di.title, di.doi,
                   COUNT(ic.category_id) AS category_count,
                   GROUP_CONCAT(c.category_name ORDER BY c.category_name SEPARATOR ' | ') AS categories_list
            FROM digital_item di
            JOIN item_category ic ON di.item_id = ic.item_id
            JOIN category c ON ic.category_id = c.category_id
            GROUP BY di.item_id, di.title, di.doi
            HAVING COUNT(ic.category_id) >= 2
            ORDER BY category_count DESC;
        """,
    },
}


def get_current_role():
    role = session.get("role", "reader")
    return role if role in DB_ROLES else "reader"


def get_db_connection(role=None):
    role = role or get_current_role()
    cfg = DB_ROLES[role]
    return mysql.connector.connect(
        host="localhost",
        port=3306,
        user=cfg["user"],
        password=cfg["password"],
        database="dloar_db",
        autocommit=False,
    )


def format_mysql_error(err: Error) -> str:
    return f"MySQL Error {err.errno} ({err.sqlstate}): {err.msg}"


@app.route("/switch_role", methods=["POST"])
def switch_role():
    new_role = request.form.get("role", "reader")
    if new_role in DB_ROLES:
        session["role"] = new_role
        flash(f"Đã chuyển kết nối MySQL sang tài khoản: {DB_ROLES[new_role]['label']}", "info")
    return redirect(url_for("index"))


@app.route("/", methods=["GET"])
def index():
    role = get_current_role()
    keyword = request.args.get("q", "").strip()
    selected_q = request.args.get("query_key", "q1")
    if selected_q not in ADVANCED_QUERIES:
        selected_q = "q1"

    data = {
        "kpi": {},
        "digital_catalog": [],
        "physical_books": [],
        "book_copies": [],
        "active_loans": [],
        "all_transactions": [],
        "fines": [],
        "unpaid_summary": [],
        "members": [],
        "persons_eer": [],
        "authors": [],
        "licenses": [],
        "categories": [],
        "digital_items_all": [],
        "book_authors": [],
        "item_authors": [],
        "item_categories": [],
        "query_result": [],
        "query_columns": [],
        "query_exec_ms": 0.0,
        "explain_rows": [],
    }

    conn = None
    try:
        conn = get_db_connection(role)
        cur = conn.cursor(dictionary=True)

        # =================================================================
        # 1. VAI TRÒ ĐỘC GIẢ (reader_user) - KHÔNG GIỚI HẠN LIMIT
        # =================================================================
        if role == "reader":
            if keyword:
                like_kw = f"%{keyword}%"
                cur.execute(
                    """
                    SELECT item_id, title, doi, license_name, license_code, file_path, categories
                    FROM vw_public_repository_catalog
                    WHERE title LIKE %s OR COALESCE(doi, '') LIKE %s OR COALESCE(categories, '') LIKE %s
                    ORDER BY item_id ASC
                    """,
                    (like_kw, like_kw, like_kw),
                )
                data["digital_catalog"] = cur.fetchall()

                cur.execute(
                    """
                    SELECT book_id, title, isbn, publisher, publication_year
                    FROM physical_book
                    WHERE title LIKE %s OR isbn LIKE %s OR COALESCE(publisher, '') LIKE %s
                    ORDER BY book_id ASC
                    """,
                    (like_kw, like_kw, like_kw),
                )
                data["physical_books"] = cur.fetchall()
            else:
                cur.execute("SELECT * FROM vw_public_repository_catalog ORDER BY item_id ASC")
                data["digital_catalog"] = cur.fetchall()

                cur.execute(
                    "SELECT book_id, title, isbn, publisher, publication_year FROM physical_book ORDER BY book_id ASC"
                )
                data["physical_books"] = cur.fetchall()

            # Chỉ lấy các cột công khai của book_copy (không lấy barcode do RBAC cột)
            cur.execute(
                "SELECT copy_id, book_id, copy_status, shelf_location FROM book_copy ORDER BY copy_id ASC"
            )
            data["book_copies"] = cur.fetchall()

            data["kpi"] = {
                "public_digital": len(data["digital_catalog"]),
                "physical_books": len(data["physical_books"]),
                "total_copies": len(data["book_copies"]),
                "available_copies": sum(1 for c in data["book_copies"] if c["copy_status"] == "Available"),
            }

        # =================================================================
        # 2. VAI TRÒ THỦ THƯ (librarian_user) - KHÔNG GIỚI HẠN LIMIT
        # =================================================================
        elif role == "librarian":
            cur.execute("SELECT * FROM vw_active_loans ORDER BY transaction_id DESC")
            data["active_loans"] = cur.fetchall()

            cur.execute(
                """
                SELECT bt.transaction_id, bt.member_id, m.member_code,
                       CONCAT(p.last_name, ' ', p.first_name) AS member_name,
                       bt.copy_id, bc.barcode, pb.title AS book_title,
                       bt.borrow_date, bt.due_date, bt.return_date
                FROM borrow_transaction bt
                JOIN member m ON bt.member_id = m.person_id
                JOIN person p ON m.person_id = p.person_id
                JOIN book_copy bc ON bt.copy_id = bc.copy_id
                JOIN physical_book pb ON bc.book_id = pb.book_id
                ORDER BY bt.transaction_id DESC
                """
            )
            data["all_transactions"] = cur.fetchall()

            cur.execute(
                """
                SELECT f.fine_id, f.transaction_id, f.fine_amount, f.fine_reason, f.fine_status, f.payment_date,
                       m.member_code, CONCAT(p.last_name, ' ', p.first_name) AS member_name
                FROM fine f
                JOIN borrow_transaction bt ON f.transaction_id = bt.transaction_id
                JOIN member m ON bt.member_id = m.person_id
                JOIN person p ON m.person_id = p.person_id
                ORDER BY (f.fine_status = 'Unpaid') DESC, f.fine_id DESC
                """
            )
            data["fines"] = cur.fetchall()

            cur.execute("SELECT * FROM vw_unpaid_fines_summary ORDER BY total_unpaid_amount DESC")
            data["unpaid_summary"] = cur.fetchall()

            cur.execute(
                """
                SELECT bc.copy_id, bc.book_id, pb.title, bc.barcode, bc.copy_status, bc.shelf_location
                FROM book_copy bc
                JOIN physical_book pb ON bc.book_id = pb.book_id
                ORDER BY bc.copy_id ASC
                """
            )
            data["book_copies"] = cur.fetchall()

            cur.execute(
                "SELECT book_id, title, isbn, publisher, publication_year FROM physical_book ORDER BY book_id ASC"
            )
            data["physical_books"] = cur.fetchall()

            cur.execute(
                """
                SELECT m.person_id, m.member_code, m.membership_status, m.max_borrow_limit, m.expiry_date,
                       p.first_name, p.last_name, p.email, p.phone_number, p.created_at
                FROM member m
                JOIN person p ON m.person_id = p.person_id
                ORDER BY m.person_id ASC
                """
            )
            data["members"] = cur.fetchall()

            data["kpi"] = {
                "total_members": len(data["members"]),
                "active_loans": len(data["active_loans"]),
                "total_transactions": len(data["all_transactions"]),
                "total_copies": len(data["book_copies"]),
                "available_copies": sum(1 for c in data["book_copies"] if c["copy_status"] == "Available"),
                "unpaid_fines_count": sum(1 for f in data["fines"] if f["fine_status"] == "Unpaid"),
                "unpaid_fines_sum": sum(float(f["fine_amount"]) for f in data["fines"] if f["fine_status"] == "Unpaid"),
            }

        # =================================================================
        # 3. VAI TRÒ QUẢN TRỊ VIÊN (admin_user) - TOÀN BỘ 13 BẢNG & KPI
        # =================================================================
        elif role == "admin":
            # Bảng 1, 2, 3: PERSON, MEMBER, AUTHOR (Full columns incl. created_at, bio, orcid)
            cur.execute(
                """
                SELECT p.person_id, p.first_name, p.last_name, p.email, p.phone_number, p.created_at,
                       m.member_code, m.membership_status, m.max_borrow_limit, m.expiry_date,
                       a.author_code, a.affiliation, a.orcid, a.bio
                FROM person p
                LEFT JOIN member m ON p.person_id = m.person_id
                LEFT JOIN author a ON p.person_id = a.person_id
                ORDER BY p.person_id ASC
                """
            )
            data["persons_eer"] = cur.fetchall()

            # Bảng 4 & 5: PHYSICAL_BOOK & BOOK_COPY
            cur.execute("SELECT * FROM physical_book ORDER BY book_id ASC")
            data["physical_books"] = cur.fetchall()

            cur.execute(
                """
                SELECT bc.*, pb.title
                FROM book_copy bc
                JOIN physical_book pb ON bc.book_id = pb.book_id
                ORDER BY bc.copy_id ASC
                """
            )
            data["book_copies"] = cur.fetchall()

            # Bảng 6 & 10: LICENSE & CATEGORY (Full columns incl. terms_description, description)
            cur.execute("SELECT * FROM license ORDER BY license_id ASC")
            data["licenses"] = cur.fetchall()

            cur.execute("SELECT * FROM category ORDER BY category_id ASC")
            data["categories"] = cur.fetchall()

            # Bảng 7: DIGITAL_ITEM (Full columns incl. abstract, embargo_end_date)
            cur.execute(
                """
                SELECT di.item_id, di.license_id, di.title, di.abstract, di.doi,
                       di.file_path, di.file_format, di.access_level, di.embargo_end_date,
                       l.license_code, l.license_name,
                       GROUP_CONCAT(DISTINCT c.category_name SEPARATOR ', ') AS categories
                FROM digital_item di
                JOIN license l ON di.license_id = l.license_id
                LEFT JOIN item_category ic ON di.item_id = ic.item_id
                LEFT JOIN category c ON ic.category_id = c.category_id
                GROUP BY di.item_id, di.license_id, di.title, di.abstract, di.doi,
                         di.file_path, di.file_format, di.access_level, di.embargo_end_date,
                         l.license_code, l.license_name
                ORDER BY di.item_id ASC
                """
            )
            data["digital_items_all"] = cur.fetchall()

            # Bảng 11, 12, 13: BOOK_AUTHOR, ITEM_AUTHOR, ITEM_CATEGORY
            cur.execute(
                """
                SELECT ba.book_id, pb.title AS book_title, ba.author_id,
                       a.author_code, CONCAT(p.last_name, ' ', p.first_name) AS author_name, ba.author_role
                FROM book_author ba
                JOIN physical_book pb ON ba.book_id = pb.book_id
                JOIN author a ON ba.author_id = a.person_id
                JOIN person p ON a.person_id = p.person_id
                ORDER BY ba.book_id ASC, ba.author_id ASC
                """
            )
            data["book_authors"] = cur.fetchall()

            cur.execute(
                """
                SELECT ia.item_id, di.title AS item_title, ia.author_id,
                       a.author_code, CONCAT(p.last_name, ' ', p.first_name) AS author_name,
                       ia.author_order, ia.author_role
                FROM item_author ia
                JOIN digital_item di ON ia.item_id = di.item_id
                JOIN author a ON ia.author_id = a.person_id
                JOIN person p ON a.person_id = p.person_id
                ORDER BY ia.item_id ASC, ia.author_order ASC
                """
            )
            data["item_authors"] = cur.fetchall()

            cur.execute(
                """
                SELECT ic.item_id, di.title AS item_title, ic.category_id, c.category_name
                FROM item_category ic
                JOIN digital_item di ON ic.item_id = di.item_id
                JOIN category c ON ic.category_id = c.category_id
                ORDER BY ic.item_id ASC, ic.category_id ASC
                """
            )
            data["item_categories"] = cur.fetchall()

            # Bảng 8 & 9: Tổng hợp số liệu giao dịch & tiền phạt cho KPI
            cur.execute("SELECT COUNT(*) AS cnt, SUM(return_date IS NULL) AS active_cnt FROM borrow_transaction")
            tx_stat = cur.fetchone()

            cur.execute(
                """
                SELECT COUNT(*) AS cnt,
                       COALESCE(SUM(CASE WHEN fine_status = 'Unpaid' THEN fine_amount ELSE 0 END), 0) AS unpaid_amt,
                       COALESCE(SUM(CASE WHEN fine_status = 'Paid' THEN fine_amount ELSE 0 END), 0) AS paid_amt
                FROM fine
                """
            )
            fine_stat = cur.fetchone()

            data["kpi"] = {
                "persons": len(data["persons_eer"]),
                "members": sum(1 for p in data["persons_eer"] if p["member_code"]),
                "authors": sum(1 for p in data["persons_eer"] if p["author_code"]),
                "overlap": sum(1 for p in data["persons_eer"] if p["member_code"] and p["author_code"]),
                "books": len(data["physical_books"]),
                "copies": len(data["book_copies"]),
                "digital_items": len(data["digital_items_all"]),
                "licenses": len(data["licenses"]),
                "categories": len(data["categories"]),
                "transactions": tx_stat["cnt"] or 0,
                "active_loans": int(tx_stat["active_cnt"] or 0),
                "fines_count": fine_stat["cnt"] or 0,
                "unpaid_amt": float(fine_stat["unpaid_amt"] or 0),
                "paid_amt": float(fine_stat["paid_amt"] or 0),
            }

            # Thực thi 1 trong 10 truy vấn nâng cao (Mục 4.2) + đo thời gian thực thi (ms)
            q_sql = ADVANCED_QUERIES[selected_q]["sql"]
            t0 = time.perf_counter()
            cur.execute(q_sql)
            rows = cur.fetchall()
            data["query_exec_ms"] = round((time.perf_counter() - t0) * 1000, 2)
            data["query_result"] = rows
            if rows:
                data["query_columns"] = list(rows[0].keys())

            # EXPLAIN kiểm chứng chỉ mục idx_borrow_member_status
            cur.execute(
                "EXPLAIN SELECT * FROM borrow_transaction WHERE member_id = 1 AND return_date IS NULL"
            )
            data["explain_rows"] = cur.fetchall()

        cur.close()
    except Error as err:
        flash(f"Lỗi kết nối/truy vấn CSDL: {format_mysql_error(err)}", "danger")
    finally:
        if conn and conn.is_connected():
            conn.close()

    return render_template(
        "index.html",
        role=role,
        role_info=DB_ROLES[role],
        roles=DB_ROLES,
        keyword=keyword,
        today=date.today().isoformat(),
        default_due=(date.today() + timedelta(days=14)).isoformat(),
        advanced_queries=ADVANCED_QUERIES,
        selected_q=selected_q,
        data=data,
    )


# =========================================================
# FR-01: QUẢN LÝ PERSON / MEMBER / AUTHOR (EER OVERLAPPING)
# =========================================================
@app.route("/eer/create_person", methods=["POST"])
def create_person_eer():
    first_name = request.form.get("first_name", "").strip()
    last_name = request.form.get("last_name", "").strip()
    email = request.form.get("email", "").strip()
    phone_number = request.form.get("phone_number", "").strip() or None

    is_member = request.form.get("is_member") == "1"
    member_code = request.form.get("member_code", "").strip()
    max_borrow_limit = int(request.form.get("max_borrow_limit") or 5)
    expiry_date = request.form.get("expiry_date") or "2028-12-31"

    is_author = request.form.get("is_author") == "1"
    author_code = request.form.get("author_code", "").strip()
    affiliation = request.form.get("affiliation", "").strip() or None
    orcid = request.form.get("orcid", "").strip() or None
    bio = request.form.get("bio", "").strip() or None

    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO person (first_name, last_name, email, phone_number) VALUES (%s, %s, %s, %s)",
            (first_name, last_name, email, phone_number),
        )
        person_id = cur.lastrowid

        roles_created = ["PERSON"]
        if is_member:
            cur.execute(
                """
                INSERT INTO member (person_id, member_code, membership_status, max_borrow_limit, expiry_date)
                VALUES (%s, %s, 'Active', %s, %s)
                """,
                (person_id, member_code, max_borrow_limit, expiry_date),
            )
            roles_created.append("MEMBER")

        if is_author:
            cur.execute(
                """
                INSERT INTO author (person_id, author_code, affiliation, orcid, bio)
                VALUES (%s, %s, %s, %s, %s)
                """,
                (person_id, author_code, affiliation, orcid, bio),
            )
            roles_created.append("AUTHOR")

        conn.commit()
        flash(
            f"[FR-01 / BR-01] Tạo thành công Person ID #{person_id} ({last_name} {first_name}) "
            f"với các vai trò: {' + '.join(roles_created)}.",
            "success",
        )
    except Error as err:
        if conn:
            conn.rollback()
        flash(f"[Từ chối tại CSDL] {format_mysql_error(err)}", "danger")
    finally:
        if conn and conn.is_connected():
            conn.close()
    return redirect(url_for("index"))


@app.route("/members/update", methods=["POST"])
def update_member():
    person_id = request.form.get("person_id")
    membership_status = request.form.get("membership_status")
    max_borrow_limit = int(request.form.get("max_borrow_limit") or 5)
    expiry_date = request.form.get("expiry_date")

    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            """
            UPDATE member
            SET membership_status = %s, max_borrow_limit = %s, expiry_date = %s
            WHERE person_id = %s
            """,
            (membership_status, max_borrow_limit, expiry_date, person_id),
        )
        conn.commit()
        flash(f"[BR-02] Đã cập nhật thẻ thành viên #{person_id} ({membership_status}, hạn mức {max_borrow_limit}).", "success")
    except Error as err:
        if conn:
            conn.rollback()
        flash(f"[Từ chối tại CSDL] {format_mysql_error(err)}", "danger")
    finally:
        if conn and conn.is_connected():
            conn.close()
    return redirect(url_for("index"))


# =========================================================
# FR-02: QUẢN LÝ ĐẦU SÁCH & BẢN SAO
# =========================================================
@app.route("/books/add", methods=["POST"])
def add_book():
    title = request.form.get("title", "").strip()
    isbn = request.form.get("isbn", "").strip()
    publisher = request.form.get("publisher", "").strip() or None
    pub_year = request.form.get("publication_year", "").strip()
    pub_year_val = int(pub_year) if pub_year else None

    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO physical_book (title, isbn, publisher, publication_year) VALUES (%s, %s, %s, %s)",
            (title, isbn, publisher, pub_year_val),
        )
        conn.commit()
        flash(f"[FR-02] Đã thêm đầu sách mới '{title}' (ISBN: {isbn}).", "success")
    except Error as err:
        if conn:
            conn.rollback()
        flash(f"[Từ chối tại CSDL] {format_mysql_error(err)}", "danger")
    finally:
        if conn and conn.is_connected():
            conn.close()
    return redirect(url_for("index"))


@app.route("/copies/add", methods=["POST"])
def add_copy():
    book_id = request.form.get("book_id")
    barcode = request.form.get("barcode", "").strip()
    shelf_location = request.form.get("shelf_location", "").strip() or None

    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO book_copy (book_id, barcode, copy_status, shelf_location) VALUES (%s, %s, 'Available', %s)",
            (book_id, barcode, shelf_location),
        )
        conn.commit()
        flash(f"[FR-02 / BR-03] Đã thêm bản sao mã vạch '{barcode}' cho Book ID #{book_id}.", "success")
    except Error as err:
        if conn:
            conn.rollback()
        flash(f"[Từ chối tại CSDL] {format_mysql_error(err)}", "danger")
    finally:
        if conn and conn.is_connected():
            conn.close()
    return redirect(url_for("index"))


@app.route("/copies/status", methods=["POST"])
def update_copy_status():
    copy_id = request.form.get("copy_id")
    new_status = request.form.get("copy_status")

    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "UPDATE book_copy SET copy_status = %s WHERE copy_id = %s",
            (new_status, copy_id),
        )
        conn.commit()
        msg = f"[FR-02 / BR-03.2] Đã cập nhật bản sao #{copy_id} sang trạng thái '{new_status}'."
        if new_status in ("Damaged", "Lost"):
            msg += " Trigger trg_after_copy_status_update đã tự động lập phiếu phạt đền bù nếu sách đang được mượn!"
        flash(msg, "success")
    except Error as err:
        if conn:
            conn.rollback()
        flash(f"[Từ chối tại CSDL] {format_mysql_error(err)}", "danger")
    finally:
        if conn and conn.is_connected():
            conn.close()
    return redirect(url_for("index"))


# =========================================================
# FR-03 & FR-04: MƯỢN & TRẢ SÁCH
# =========================================================
@app.route("/borrow", methods=["POST"])
def borrow_book():
    member_id = request.form.get("member_id")
    copy_id = request.form.get("copy_id")
    borrow_date = request.form.get("borrow_date")
    due_date = request.form.get("due_date")

    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            """
            INSERT INTO borrow_transaction (member_id, copy_id, borrow_date, due_date)
            VALUES (%s, %s, %s, %s)
            """,
            (member_id, copy_id, borrow_date, due_date),
        )
        conn.commit()
        flash(
            f"[FR-03 / BR-04.3] Lập phiếu mượn thành công (Member #{member_id}, Copy #{copy_id}). "
            f"Trigger trg_after_borrow_insert đã chuyển bản sao sang 'Borrowed'.",
            "success",
        )
    except Error as err:
        if conn:
            conn.rollback()
        flash(f"[Trigger/Constraint chặn giao dịch] {format_mysql_error(err)}", "danger")
    finally:
        if conn and conn.is_connected():
            conn.close()
    return redirect(url_for("index"))


@app.route("/return/<int:tx_id>", methods=["POST"])
def return_book(tx_id):
    return_date = request.form.get("return_date") or date.today().isoformat()

    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "UPDATE borrow_transaction SET return_date = %s WHERE transaction_id = %s",
            (return_date, tx_id),
        )
        conn.commit()
        flash(
            f"[FR-04 / BR-05.2] Đã ghi nhận trả sách giao dịch #{tx_id} ngày {return_date}. "
            f"Trigger đã trả bản sao về 'Available' và tự tính phạt nếu quá hạn (5.000 VNĐ/ngày).",
            "success",
        )
    except Error as err:
        if conn:
            conn.rollback()
        flash(f"[Từ chối tại CSDL] {format_mysql_error(err)}", "danger")
    finally:
        if conn and conn.is_connected():
            conn.close()
    return redirect(url_for("index"))


# =========================================================
# FR-05: THU TIỀN PHẠT
# =========================================================
@app.route("/fines/pay/<int:fine_id>", methods=["POST"])
def pay_fine(fine_id):
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "UPDATE fine SET fine_status = 'Paid', payment_date = %s WHERE fine_id = %s",
            (date.today().isoformat(), fine_id),
        )
        conn.commit()
        flash(f"[FR-05 / BR-05.3] Đã thu tiền phạt #{fine_id} và ghi nhận payment_date hôm nay.", "success")
    except Error as err:
        if conn:
            conn.rollback()
        flash(f"[Từ chối tại CSDL] {format_mysql_error(err)}", "danger")
    finally:
        if conn and conn.is_connected():
            conn.close()
    return redirect(url_for("index"))


# =========================================================
# FR-06 & FR-07: KHO TÀI LIỆU SỐ, GIẤY PHÉP, DANH MỤC & N:M
# =========================================================
@app.route("/digital/add", methods=["POST"])
def add_digital_item():
    title = request.form.get("title", "").strip()
    license_id = request.form.get("license_id")
    doi = request.form.get("doi", "").strip() or None
    file_path = request.form.get("file_path", "").strip()
    file_format = request.form.get("file_format", "PDF").strip() or "PDF"
    access_level = request.form.get("access_level")
    embargo_end_date = request.form.get("embargo_end_date") or None
    abstract = request.form.get("abstract", "").strip() or None

    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            """
            INSERT INTO digital_item
                (license_id, title, abstract, doi, file_path, file_format, access_level, embargo_end_date)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """,
            (license_id, title, abstract, doi, file_path, file_format, access_level, embargo_end_date),
        )
        conn.commit()
        flash(f"[FR-06 / BR-06] Đã đăng tải tài liệu số '{title}' ({access_level}).", "success")
    except Error as err:
        if conn:
            conn.rollback()
        flash(f"[Ràng buộc CSDL chặn lưu] {format_mysql_error(err)}", "danger")
    finally:
        if conn and conn.is_connected():
            conn.close()
    return redirect(url_for("index"))


@app.route("/digital/release_embargo/<int:item_id>", methods=["POST"])
def release_embargo(item_id):
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "UPDATE digital_item SET access_level = 'Public_Open_Access' WHERE item_id = %s",
            (item_id,),
        )
        conn.commit()
        flash(f"[BR-06.3] Đã mở công khai (Public_Open_Access) cho tài liệu số #{item_id}.", "success")
    except Error as err:
        if conn:
            conn.rollback()
        flash(f"[Từ chối tại CSDL] {format_mysql_error(err)}", "danger")
    finally:
        if conn and conn.is_connected():
            conn.close()
    return redirect(url_for("index"))


@app.route("/master/add_license", methods=["POST"])
def add_license():
    license_name = request.form.get("license_name", "").strip()
    license_code = request.form.get("license_code", "").strip()
    terms_description = request.form.get("terms_description", "").strip() or None

    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO license (license_name, license_code, terms_description) VALUES (%s, %s, %s)",
            (license_name, license_code, terms_description),
        )
        conn.commit()
        flash(f"[FR-06] Đã thêm giấy phép Open Access '{license_code}'.", "success")
    except Error as err:
        if conn:
            conn.rollback()
        flash(f"[Từ chối tại CSDL] {format_mysql_error(err)}", "danger")
    finally:
        if conn and conn.is_connected():
            conn.close()
    return redirect(url_for("index"))


@app.route("/master/add_category", methods=["POST"])
def add_category():
    category_name = request.form.get("category_name", "").strip()
    description = request.form.get("description", "").strip() or None

    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO category (category_name, description) VALUES (%s, %s)",
            (category_name, description),
        )
        conn.commit()
        flash(f"[FR-07] Đã thêm danh mục '{category_name}'.", "success")
    except Error as err:
        if conn:
            conn.rollback()
        flash(f"[Từ chối tại CSDL] {format_mysql_error(err)}", "danger")
    finally:
        if conn and conn.is_connected():
            conn.close()
    return redirect(url_for("index"))


@app.route("/relations/assign", methods=["POST"])
def assign_relation():
    rel_type = request.form.get("rel_type")
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        if rel_type == "book_author":
            book_id = request.form.get("book_id")
            author_id = request.form.get("author_id")
            author_role = request.form.get("author_role", "Main Author")
            cur.execute(
                "INSERT INTO book_author (book_id, author_id, author_role) VALUES (%s, %s, %s)",
                (book_id, author_id, author_role),
            )
            msg = f"[FR-07 / BR-07.2] Đã gán Author #{author_id} ({author_role}) cho Physical Book #{book_id}."
        elif rel_type == "item_author":
            item_id = request.form.get("item_id")
            author_id = request.form.get("author_id")
            author_order = int(request.form.get("author_order") or 1)
            author_role = request.form.get("author_role", "Principal Investigator")
            cur.execute(
                "INSERT INTO item_author (item_id, author_id, author_order, author_role) VALUES (%s, %s, %s, %s)",
                (item_id, author_id, author_order, author_role),
            )
            msg = f"[FR-07 / BR-07.2] Đã gán Author #{author_id} (thứ tự {author_order}, {author_role}) cho Digital Item #{item_id}."
        elif rel_type == "item_category":
            item_id = request.form.get("item_id")
            category_id = request.form.get("category_id")
            cur.execute(
                "INSERT INTO item_category (item_id, category_id) VALUES (%s, %s)",
                (item_id, category_id),
            )
            msg = f"[FR-07 / BR-07.3] Đã phân loại Digital Item #{item_id} vào Category #{category_id}."
        else:
            msg = "Loại liên kết không hợp lệ."
        conn.commit()
        flash(msg, "success")
    except Error as err:
        if conn:
            conn.rollback()
        flash(f"[Từ chối tại CSDL] {format_mysql_error(err)}", "danger")
    finally:
        if conn and conn.is_connected():
            conn.close()
    return redirect(url_for("index"))


# =========================================================
# MỤC 5.1 & 5.2: KIỂM THỬ RÀNG BUỘC & RBAC TRỰC TIẾP
# =========================================================
@app.route("/demo_test/<test_code>", methods=["POST"])
def run_demo_test(test_code):
    tests = {
        "r03b_reader_barcode": (
            "R-03b (RBAC): Độc giả thử đọc cột nhạy cảm barcode trong book_copy (Kỳ vọng ERROR 1143)",
            "SELECT barcode FROM book_copy LIMIT 1",
        ),
        "r04_reader_email": (
            "R-04 (RBAC): Độc giả thử đọc cột email trong bảng person (Kỳ vọng ERROR 1142)",
            "SELECT email FROM person LIMIT 1",
        ),
        "r05_reader_insert": (
            "R-05 (RBAC): Độc giả thử thêm bản sao sách mới (Kỳ vọng ERROR 1142)",
            "INSERT INTO book_copy (book_id, barcode) VALUES (1, 'BC-RBAC-TEST')",
        ),
        "r10_lib_update_amount": (
            "R-10 (RBAC): Thủ thư thử sửa số tiền phạt fine_amount = 0 (Kỳ vọng ERROR 1143)",
            "UPDATE fine SET fine_amount = 0 WHERE fine_id = 1",
        ),
        "r11_lib_delete_fine": (
            "R-11 (RBAC / BR-05.3): Thủ thư thử xóa bản ghi tiền phạt DELETE FROM fine (Kỳ vọng ERROR 1142)",
            "DELETE FROM fine WHERE fine_id = 1",
        ),
        "r12_lib_delete_tx": (
            "R-12 (RBAC / BR-08.2): Thủ thư thử xóa giao dịch mượn trả (Kỳ vọng ERROR 1142)",
            "DELETE FROM borrow_transaction WHERE transaction_id = 1",
        ),
        "r13_lib_insert_digital": (
            "R-13 (RBAC): Thủ thư thử thêm tài liệu số vào digital_item (Kỳ vọng ERROR 1142)",
            "INSERT INTO digital_item (license_id, title, file_path) VALUES (1, 'Test RBAC', '/docs/test.pdf')",
        ),
        "r14_lib_select_license": (
            "R-14 (RBAC): Thủ thư thử truy cập bảng license (Kỳ vọng ERROR 1142)",
            "SELECT * FROM license LIMIT 1",
        ),
        "tc01_dup_email": (
            "TC-01 (BR-01.4): Chèn trùng email đã tồn tại trong person (Kỳ vọng ERROR 1062)",
            "INSERT INTO person (first_name, last_name, email) SELECT 'Test', 'Dup', email FROM person WHERE person_id = 1",
        ),
        "tc02_zero_limit": (
            "TC-02 (BR-02.2): Hạn mức mượn max_borrow_limit = 0 (Kỳ vọng ERROR 3819)",
            "INSERT INTO member (person_id, member_code, membership_status, max_borrow_limit, expiry_date) VALUES (700, 'MEM999', 'Active', 0, '2028-12-31')",
        ),
        "tc25_restrict_member": (
            "TC-25 (BR-08.2): Thử xóa thành viên đang có lịch sử mượn (Kỳ vọng ERROR 1451 RESTRICT)",
            "DELETE FROM member WHERE person_id = 1",
        ),
        "tc27_restrict_fine_tx": (
            "TC-27 (BR-05.3): Thử xóa giao dịch đã phát sinh khoản phạt (Kỳ vọng ERROR 1451 RESTRICT)",
            "DELETE FROM borrow_transaction WHERE transaction_id = 1801",
        ),
        "tc36_paid_no_date": (
            "TC-36 (BR-05.3): Cập nhật fine_status = 'Paid' nhưng payment_date = NULL (Kỳ vọng ERROR 3819)",
            "UPDATE fine SET fine_status = 'Paid', payment_date = NULL WHERE fine_id = 1",
        ),
        "tc37_embargo_no_date": (
            "TC-37 (BR-06.3): Thêm tài liệu Embargoed nhưng để trống embargo_end_date (Kỳ vọng ERROR 3819)",
            "INSERT INTO digital_item (license_id, title, file_path, access_level, embargo_end_date) VALUES (1, 'Embargo Loi', '/docs/e.pdf', 'Embargoed', NULL)",
        ),
    }

    if test_code not in tests:
        flash("Mã kịch bản kiểm thử không tồn tại.", "warning")
        return redirect(url_for("index"))

    desc, sql = tests[test_code]
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(sql)
        if cur.with_rows:
            cur.fetchall()
        conn.rollback()
        flash(f"[CẢNH BÁO - Lệnh không bị chặn] {desc} -> Thực thi thành công ngoài kỳ vọng.", "warning")
    except Error as err:
        if conn:
            conn.rollback()
        flash(f"[PASS - CSDL đã chặn thành công] {desc} => {format_mysql_error(err)}", "success")
    finally:
        if conn and conn.is_connected():
            conn.close()

    return redirect(url_for("index"))


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=True)