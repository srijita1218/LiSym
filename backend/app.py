
import os
from functools import wraps

from dotenv import load_dotenv
from flask import (
    Flask,
    render_template,
    request,
    redirect,
    url_for,
    flash,
    session,
    abort,
)

from flask_wtf.csrf import CSRFProtect
from flask_wtf import FlaskForm
from werkzeug.security import (
    generate_password_hash,
    check_password_hash,
)
from wtforms import StringField, PasswordField
from wtforms.validators import DataRequired, Length, EqualTo

from database import get_db_connection


# ============================================================
# APPLICATION CONFIGURATION
# ============================================================

load_dotenv()

app = Flask(
    __name__,
    template_folder="../templates",
    static_folder="../static",
)
app = Flask(__name__, template_folder="../templates", static_folder="../static")

app.config["SECRET_KEY"] = os.getenv("SECRET_KEY")

csrf = CSRFProtect(app)

if not app.config["SECRET_KEY"]:
    raise RuntimeError(
        "SECRET_KEY is missing from your .env file."
    )

app.config["SESSION_COOKIE_HTTPONLY"] = True
app.config["SESSION_COOKIE_SAMESITE"] = "Lax"


# ============================================================
# AUTHENTICATION FORMS
# ============================================================

class LoginForm(FlaskForm):
    username = StringField(
        "Username",
        validators=[
            DataRequired(),
            Length(max=100),
        ],
    )

    password = PasswordField(
        "Password",
        validators=[
            DataRequired(),
            Length(max=256),
        ],
    )


class RegisterForm(FlaskForm):
    email = StringField(
        "Library email",
        validators=[
            DataRequired(),
            Length(max=254),
        ],
    )

    username = StringField(
        "Username",
        validators=[
            DataRequired(),
            Length(min=3, max=100),
        ],
    )

    password = PasswordField(
        "Password",
        validators=[
            DataRequired(),
            Length(min=8, max=256),
        ],
    )

    confirm_password = PasswordField(
        "Confirm password",
        validators=[
            DataRequired(),
            EqualTo(
                "password",
                message="Passwords must match.",
            ),
        ],
    )


# ============================================================
# AUTHENTICATION DECORATORS
# ============================================================

def login_required(view):
    @wraps(view)
    def wrapped_view(*args, **kwargs):
        if not session.get("user_id"):
            flash("Please log in first.", "error")
            return redirect(url_for("login"))

        return view(*args, **kwargs)

    return wrapped_view


def role_required(*allowed_roles):
    def decorator(view):
        @wraps(view)
        def wrapped_view(*args, **kwargs):
            if not session.get("user_id"):
                flash("Please log in first.", "error")
                return redirect(url_for("login"))

            if session.get("role") not in allowed_roles:
                abort(403)

            return view(*args, **kwargs)

        return wrapped_view

    return decorator


# ============================================================
# REGISTER
# ============================================================

@app.route("/register", methods=["GET", "POST"])
def register():
    if session.get("user_id"):
        return redirect(url_for("dashboard"))

    form = RegisterForm()

    if form.validate_on_submit():
        email = form.email.data.strip()
        username = form.username.data.strip()
        password = form.password.data

        connection = None
        cursor = None

        try:
            connection = get_db_connection()
            cursor = connection.cursor(dictionary=True)

            # Find an existing active library member.
            cursor.execute(
                """
                SELECT member_id
                FROM member
                WHERE email = %s
                  AND membership_status = 'ACTIVE'
                """,
                (email,),
            )

            member = cursor.fetchone()

            if not member:
                flash(
                    "No active membership matches that email.",
                    "error",
                )
                return render_template(
                    "register.html",
                    form=form,
                )

            # Each member can have one account, and each
            # username must be unique.
            cursor.execute(
                """
                SELECT user_id
                FROM user_account
                WHERE member_id = %s
                   OR username = %s
                """,
                (member["member_id"], username),
            )

            if cursor.fetchone():
                flash(
                    "This membership already has an account, "
                    "or that username is taken.",
                    "error",
                )
                return render_template(
                    "register.html",
                    form=form,
                )

            # Never store the original password.
            password_hash = generate_password_hash(password)

            cursor.execute(
                """
                INSERT INTO user_account
                    (
                        member_id,
                        username,
                        password_hash,
                        role
                    )
                VALUES (%s, %s, %s, 'MEMBER')
                """,
                (
                    member["member_id"],
                    username,
                    password_hash,
                ),
            )

            connection.commit()

            flash(
                "Account created successfully. You can now log in.",
                "success",
            )

            return redirect(url_for("login"))

        except Exception:
            if connection is not None:
                connection.rollback()

            app.logger.exception("Registration failed")

            flash(
                "Registration could not be completed. "
                "Please check the server log.",
                "error",
            )

        finally:
            if cursor is not None:
                cursor.close()

            if connection is not None:
                connection.close()

    return render_template(
        "register.html",
        form=form,
    )


# ============================================================
# LOGIN
# ============================================================

@app.route("/login", methods=["GET", "POST"])
def login():
    if session.get("user_id"):
        return redirect(url_for("dashboard"))

    form = LoginForm()

    if form.validate_on_submit():
        username = form.username.data.strip()
        password = form.password.data

        connection = None
        cursor = None

        try:
            connection = get_db_connection()
            cursor = connection.cursor(dictionary=True)

            cursor.execute(
                """
                SELECT
                    ua.user_id,
                    ua.member_id,
                    ua.username,
                    ua.password_hash,
                    ua.role,
                    ua.account_status,
                    m.membership_status
                FROM user_account ua
                JOIN member m
                    ON ua.member_id = m.member_id
                WHERE ua.username = %s
                """,
                (username,),
            )

            account = cursor.fetchone()

            if (
                account
                and account["account_status"] == "ACTIVE"
                and account["membership_status"] == "ACTIVE"
                and check_password_hash(
                    account["password_hash"],
                    password,
                )
            ):
                # Remove old session data before creating
                # the authenticated session.
                session.clear()

                session["user_id"] = account["user_id"]
                session["member_id"] = account["member_id"]
                session["username"] = account["username"]
                session["role"] = account["role"]

                return redirect(url_for("dashboard"))

            flash(
                "Invalid username or password.",
                "error",
            )

        except Exception:
            app.logger.exception("Login failed")

            flash(
                "Login could not be completed. "
                "Please try again.",
                "error",
            )

        finally:
            if cursor is not None:
                cursor.close()

            if connection is not None:
                connection.close()

    return render_template(
        "login.html",
        form=form,
    )


# ============================================================
# LOGOUT
# ============================================================

@app.route("/logout", methods=["POST"])
def logout():
    session.clear()

    flash(
        "You have been logged out.",
        "success",
    )

    return redirect(url_for("login"))


# ============================================================
# DASHBOARD
# ============================================================

@app.route("/")
@login_required
def dashboard():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
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

        return render_template(
            "dashboard.html",
            total_books=total_books,
            total_copies=total_copies,
            available_copies=available_copies,
            issued_copies=issued_copies,
            total_members=total_members,
            active_loans=active_loans,
            unpaid_fines=unpaid_fines,
        )

    finally:
        cursor.close()
        connection.close()


# ============================================================
# BOOKS
# ============================================================

@app.route("/books")
@login_required
def books():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        search = request.args.get("search", "").strip()

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
                search_value,
            ),
        )

        books_list = cursor.fetchall()

        return render_template(
            "pages/books.html",
            books=books_list,
            search=search,
        )

    finally:
        cursor.close()
        connection.close()


# ============================================================
# MEMBERS — STAFF ONLY
# ============================================================

@app.route("/members")
@role_required("LIBRARIAN", "ADMIN")
def members():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
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

        members_list = cursor.fetchall()

        return render_template(
            "pages/members.html",
            members=members_list,
        )

    finally:
        cursor.close()
        connection.close()


# ============================================================
# ISSUE BOOK — STAFF ONLY
# ============================================================

@app.route("/issue", methods=["GET", "POST"])
@role_required("LIBRARIAN", "ADMIN")
def issue_book():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    if request.method == "POST":
        member_id = request.form.get("member_id")
        copy_id = request.form.get("copy_id")

        try:
            if not member_id or not copy_id:
                flash(
                    "Please select a member and a book copy.",
                    "error",
                )
            else:
                cursor.execute(
                    "CALL issue_book(%s, %s)",
                    (member_id, copy_id),
                )

                # Consume stored-procedure result sets.
                while cursor.nextset():
                    pass

                connection.commit()

                flash(
                    "Book issued successfully.",
                    "success",
                )

        except Exception:
            connection.rollback()
            app.logger.exception("Book issue failed")

            flash(
                "The book could not be issued. "
                "Check the server log for details.",
                "error",
            )

        finally:
            cursor.close()
            connection.close()

        return redirect(url_for("issue_book"))

    try:
        cursor.execute("""
            SELECT
                member_id,
                full_name,
                email
            FROM member
            WHERE membership_status = 'ACTIVE'
            ORDER BY full_name
        """)
        members_list = cursor.fetchall()

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

        return render_template(
            "pages/issue.html",
            members=members_list,
            available_copies=available_copies,
        )

    finally:
        cursor.close()
        connection.close()


# ============================================================
# RETURN BOOK — STAFF ONLY
# ============================================================

@app.route("/return", methods=["GET", "POST"])
@role_required("LIBRARIAN", "ADMIN")
def return_book():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    if request.method == "POST":
        loan_id = request.form.get("loan_id")

        try:
            if not loan_id:
                flash("Please select a loan.", "error")
            else:
                cursor.execute(
                    "CALL return_book(%s)",
                    (loan_id,),
                )

                while cursor.nextset():
                    pass

                connection.commit()

                flash(
                    "Book returned successfully. "
                    "Any applicable fine was generated automatically.",
                    "success",
                )

        except Exception:
            connection.rollback()
            app.logger.exception("Book return failed")

            flash(
                "The book could not be returned. "
                "Check the server log for details.",
                "error",
            )

        finally:
            cursor.close()
            connection.close()

        return redirect(url_for("return_book"))

    try:
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

        return render_template(
            "pages/return.html",
            active_loans=active_loans,
        )

    finally:
        cursor.close()
        connection.close()


# ============================================================
# FINES — STAFF ONLY
# ============================================================

@app.route("/fines")
@role_required("LIBRARIAN", "ADMIN")
def fines():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
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

            ORDER BY f.generated_date DESC
        """)

        fines_list = cursor.fetchall()

        return render_template(
            "pages/fines.html",
            fines=fines_list,
        )

    finally:
        cursor.close()
        connection.close()


# ============================================================
# RESERVATIONS — STAFF ONLY
# ============================================================

@app.route("/reservations")
@role_required("LIBRARIAN", "ADMIN")
def reservations():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
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

            ORDER BY r.reservation_date
        """)

        reservations_list = cursor.fetchall()

        return render_template(
            "pages/reservations.html",
            reservations=reservations_list,
        )

    finally:
        cursor.close()
        connection.close()


# ============================================================
# ERROR HANDLERS
# ============================================================

@app.errorhandler(403)
def forbidden(error):
    return (
        "Access denied. Your account does not have permission "
        "to access this page.",
        403,
    )

# ============================================================
# MY BORROWING HISTORY — LOGGED-IN MEMBER
# ============================================================

@app.route("/my-borrowing")
@login_required
def my_borrowing():
    member_id = session.get("member_id")
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT
                l.loan_id,
                b.title,
                bc.accession_number,
                l.issue_date,
                l.due_date,
                l.return_date
            FROM loan l
            JOIN book_copy bc ON l.copy_id = bc.copy_id
            JOIN book b ON bc.book_id = b.book_id
            WHERE l.member_id = %s
            ORDER BY l.issue_date DESC
        """, (member_id,))

        borrowing_history = cursor.fetchall()

        return render_template(
            "pages/my_borrowing.html",
            borrowing_history=borrowing_history
        )

    finally:
        cursor.close()
        connection.close()


# ============================================================
# MY RESERVATIONS — LOGGED-IN MEMBER
# ============================================================

@app.route("/my-reservations")
@login_required
def my_reservations():
    member_id = session.get("member_id")
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT
                r.reservation_id,
                b.title,
                r.reservation_date,
                r.status
            FROM reservation r
            JOIN book b ON r.book_id = b.book_id
            WHERE r.member_id = %s
            ORDER BY r.reservation_date DESC
        """, (member_id,))

        reservations_list = cursor.fetchall()

        return render_template(
            "pages/my_reservations.html",
            reservations=reservations_list
        )

    finally:
        cursor.close()
        connection.close()


# ============================================================
# MY FINES — LOGGED-IN MEMBER
# ============================================================

@app.route("/my-fines")
@login_required
def my_fines():
    member_id = session.get("member_id")
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT
                f.fine_id,
                b.title,
                l.loan_id,
                f.amount,
                f.paid_status,
                f.generated_date
            FROM fine f
            JOIN loan l ON f.loan_id = l.loan_id
            JOIN book_copy bc ON l.copy_id = bc.copy_id
            JOIN book b ON bc.book_id = b.book_id
            WHERE l.member_id = %s
            ORDER BY f.generated_date DESC, f.fine_id DESC
        """, (member_id,))

        fines_list = cursor.fetchall()

        return render_template(
            "pages/my_fines.html",
            fines=fines_list
        )

    finally:
        cursor.close()
        connection.close()


# ============================================================
# RUN APPLICATION
# ============================================================

if __name__ == "__main__":
    app.run(debug=True)