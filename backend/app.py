from flask import Flask, render_template, request, redirect, url_for, flash
from database import get_db_connection


app = Flask(
    __name__,
    template_folder="../templates",
    static_folder="../static"
)

app.secret_key = "lisym-library-secret-key"


# ============================================================
# DASHBOARD
# ============================================================

@app.route("/")
def dashboard():

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT COUNT(*) AS total_books
        FROM book
    """)
    total_books = cursor.fetchone()["total_books"]

    cursor.execute("""
        SELECT COUNT(*) AS total_copies
        FROM book_copy
    """)
    total_copies = cursor.fetchone()["total_copies"]

    cursor.execute("""
        SELECT COUNT(*) AS available_copies
        FROM book_copy
        WHERE status = 'AVAILABLE'
    """)
    available_copies = cursor.fetchone()["available_copies"]

    cursor.execute("""
        SELECT COUNT(*) AS issued_copies
        FROM book_copy
        WHERE status = 'ISSUED'
    """)
    issued_copies = cursor.fetchone()["issued_copies"]

    cursor.execute("""
        SELECT COUNT(*) AS total_members
        FROM member
    """)
    total_members = cursor.fetchone()["total_members"]

    cursor.execute("""
        SELECT COUNT(*) AS active_loans
        FROM loan
        WHERE return_date IS NULL
    """)
    active_loans = cursor.fetchone()["active_loans"]

    cursor.execute("""
        SELECT COALESCE(SUM(amount), 0) AS unpaid_fines
        FROM fine
        WHERE paid_status = 'UNPAID'
    """)
    unpaid_fines = cursor.fetchone()["unpaid_fines"]

    cursor.close()
    connection.close()

    return render_template(
        "dashboard.html",
        total_books=total_books,
        total_copies=total_copies,
        available_copies=available_copies,
        issued_copies=issued_copies,
        total_members=total_members,
        active_loans=active_loans,
        unpaid_fines=unpaid_fines
    )


# ============================================================
# BOOKS
# ============================================================

@app.route("/books")
def books():

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    search = request.args.get("search", "")

    query = """
        SELECT
            b.book_id,
            b.isbn,
            b.title,
            b.publication_year,
            c.category_name,
            p.publisher_name,

            GROUP_CONCAT(
                DISTINCT a.author_name
                ORDER BY a.author_name
                SEPARATOR ', '
            ) AS authors,

            COUNT(DISTINCT bc.copy_id) AS total_copies,

            SUM(
                CASE
                    WHEN bc.status = 'AVAILABLE'
                    THEN 1
                    ELSE 0
                END
            ) AS available_copies

        FROM book b

        LEFT JOIN category c
            ON b.category_id = c.category_id

        LEFT JOIN publisher p
            ON b.publisher_id = p.publisher_id

        LEFT JOIN book_author ba
            ON b.book_id = ba.book_id

        LEFT JOIN author a
            ON ba.author_id = a.author_id

        LEFT JOIN book_copy bc
            ON b.book_id = bc.book_id

        WHERE
            b.title LIKE %s
            OR b.isbn LIKE %s
            OR c.category_name LIKE %s
            OR a.author_name LIKE %s

        GROUP BY
            b.book_id,
            b.isbn,
            b.title,
            b.publication_year,
            c.category_name,
            p.publisher_name

        ORDER BY b.title
    """

    search_value = f"%{search}%"

    cursor.execute(
        query,
        (
            search_value,
            search_value,
            search_value,
            search_value
        )
    )

    books = cursor.fetchall()

    cursor.close()
    connection.close()

    return render_template(
        "pages/books.html",
        books=books,
        search=search
    )


# ============================================================
# MEMBERS
# ============================================================

@app.route("/members")
def members():

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            m.member_id,
            m.full_name,
            m.email,
            m.phone,
            m.membership_date,
            m.membership_status,
            COUNT(l.loan_id) AS total_loans

        FROM member m

        LEFT JOIN loan l
            ON m.member_id = l.member_id

        GROUP BY
            m.member_id,
            m.full_name,
            m.email,
            m.phone,
            m.membership_date,
            m.membership_status

        ORDER BY m.full_name
    """)

    members = cursor.fetchall()

    cursor.close()
    connection.close()

    return render_template(
        "pages/members.html",
        members=members
    )


# ============================================================
# ISSUE BOOK
# ============================================================

@app.route("/issue", methods=["GET", "POST"])
def issue_book():

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    if request.method == "POST":

        member_id = request.form["member_id"]
        copy_id = request.form["copy_id"]

        try:

            cursor.execute(
                "CALL issue_book(%s, %s)",
                (member_id, copy_id)
            )

            connection.commit()

            # Consume any remaining result sets
            while cursor.nextset():
                pass

            flash(
                "Book issued successfully.",
                "success"
            )

        except Exception as error:

            connection.rollback()

            flash(
                str(error),
                "error"
            )

        cursor.close()
        connection.close()

        return redirect(url_for("issue_book"))

    cursor.execute("""
        SELECT
            member_id,
            full_name,
            email
        FROM member
        WHERE membership_status = 'ACTIVE'
        ORDER BY full_name
    """)

    members = cursor.fetchall()

    cursor.execute("""
        SELECT
            bc.copy_id,
            bc.accession_number,
            b.title

        FROM book_copy bc

        JOIN book b
            ON bc.book_id = b.book_id

        WHERE bc.status = 'AVAILABLE'

        ORDER BY b.title
    """)

    available_copies = cursor.fetchall()

    cursor.close()
    connection.close()

    return render_template(
        "pages/issue.html",
        members=members,
        available_copies=available_copies
    )


# ============================================================
# RETURN BOOK
# ============================================================

@app.route("/return", methods=["GET", "POST"])
def return_book():

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    if request.method == "POST":

        loan_id = request.form["loan_id"]

        try:

            cursor.execute(
                "CALL return_book(%s)",
                (loan_id,)
            )

            connection.commit()

            while cursor.nextset():
                pass

            flash(
                "Book returned successfully. Any applicable fine was generated automatically.",
                "success"
            )

        except Exception as error:

            connection.rollback()

            flash(
                str(error),
                "error"
            )

        cursor.close()
        connection.close()

        return redirect(url_for("return_book"))

    cursor.execute("""
        SELECT
            l.loan_id,
            m.full_name,
            b.title,
            bc.accession_number,
            l.issue_date,
            l.due_date,

            DATEDIFF(
                CURDATE(),
                l.due_date
            ) AS days_overdue

        FROM loan l

        JOIN member m
            ON l.member_id = m.member_id

        JOIN book_copy bc
            ON l.copy_id = bc.copy_id

        JOIN book b
            ON bc.book_id = b.book_id

        WHERE l.return_date IS NULL

        ORDER BY l.due_date
    """)

    active_loans = cursor.fetchall()

    cursor.close()
    connection.close()

    return render_template(
        "pages/return.html",
        active_loans=active_loans
    )


# ============================================================
# FINES
# ============================================================

@app.route("/fines")
def fines():

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            f.fine_id,
            m.full_name,
            b.title,
            f.amount,
            f.paid_status,
            f.generated_date

        FROM fine f

        JOIN loan l
            ON f.loan_id = l.loan_id

        JOIN member m
            ON l.member_id = m.member_id

        JOIN book_copy bc
            ON l.copy_id = bc.copy_id

        JOIN book b
            ON bc.book_id = b.book_id

        ORDER BY
            f.generated_date DESC
    """)

    fines = cursor.fetchall()

    cursor.close()
    connection.close()

    return render_template(
        "pages/fines.html",
        fines=fines
    )


# ============================================================
# RESERVATIONS
# ============================================================

@app.route("/reservations")
def reservations():

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            r.reservation_id,
            m.full_name,
            b.title,
            r.reservation_date,
            r.status

        FROM reservation r

        JOIN member m
            ON r.member_id = m.member_id

        JOIN book b
            ON r.book_id = b.book_id

        ORDER BY
            r.reservation_date
    """)

    reservations = cursor.fetchall()

    cursor.close()
    connection.close()

    return render_template(
        "pages/reservations.html",
        reservations=reservations
    )


# ============================================================
# RUN APPLICATION
# ============================================================

if __name__ == "__main__":
    app.run(debug=True)