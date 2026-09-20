CREATE DATABASE library_management_system;
SHOW DATABASES;
USE library_management_system;
SELECT DATABASE();

CREATE TABLE category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
);

CREATE TABLE publisher (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(150) NOT NULL,
    contact_email VARCHAR(150),
    phone VARCHAR(20),
    address VARCHAR(255)
);

CREATE TABLE author (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    author_name VARCHAR(150) NOT NULL,
    biography TEXT
);

CREATE TABLE book (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    publication_year YEAR,
    category_id INT NOT NULL,
    publisher_id INT,

    FOREIGN KEY (category_id)
        REFERENCES category(category_id),

    FOREIGN KEY (publisher_id)
        REFERENCES publisher(publisher_id)
);

DROP TABLE IF EXISTS book;

CREATE TABLE book (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    publication_year INT,
    category_id INT NOT NULL,
    publisher_id INT,
    CONSTRAINT fk_book_category
        FOREIGN KEY (category_id)
        REFERENCES category(category_id),
    CONSTRAINT fk_book_publisher
        FOREIGN KEY (publisher_id)
        REFERENCES publisher(publisher_id)
);

SHOW TABLES;

CREATE TABLE book_author (
    book_id INT NOT NULL,
    author_id INT NOT NULL,

    PRIMARY KEY (book_id, author_id),

    FOREIGN KEY (book_id)
        REFERENCES book(book_id)
        ON DELETE CASCADE,

    FOREIGN KEY (author_id)
        REFERENCES author(author_id)
        ON DELETE CASCADE
);

DROP TABLE IF EXISTS book_author;

CREATE TABLE book_author (
    book_id INT NOT NULL,
    author_id INT NOT NULL,

    PRIMARY KEY (book_id, author_id),

    CONSTRAINT fk_book_author_book
        FOREIGN KEY (book_id)
        REFERENCES book(book_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_book_author_author
        FOREIGN KEY (author_id)
        REFERENCES author(author_id)
        ON DELETE CASCADE
);
DROP TABLE IF EXISTS book_author;

CREATE TABLE book_author (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id)
);

ALTER TABLE book_author
ADD CONSTRAINT fk_book_author_book
FOREIGN KEY (book_id)
REFERENCES book(book_id)
ON DELETE CASCADE;

ALTER TABLE book_author
ADD CONSTRAINT fk_book_author_author
FOREIGN KEY (author_id)
REFERENCES author(author_id)
ON DELETE CASCADE;

SHOW CREATE TABLE book_author;

CREATE TABLE book_copy (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    accession_number VARCHAR(50) NOT NULL UNIQUE,

    status ENUM(
        'AVAILABLE',
        'ISSUED',
        'LOST',
        'DAMAGED'
    ) NOT NULL DEFAULT 'AVAILABLE',

    acquisition_date DATE,

    FOREIGN KEY (book_id)
        REFERENCES book(book_id)
);

DROP TABLE IF EXISTS book_copy;

CREATE TABLE book_copy (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    accession_number VARCHAR(50) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',
    acquisition_date DATE
);

ALTER TABLE book_copy
ADD CONSTRAINT fk_book_copy_book
FOREIGN KEY (book_id)
REFERENCES book(book_id);

DESCRIBE book_copy;

SELECT VERSION();

SELECT DATABASE();

SELECT @@sql_mode;

CREATE TABLE test_parent (
    id INT PRIMARY KEY
);

CREATE TABLE test_child (
    id INT PRIMARY KEY,
    parent_id INT
);

ALTER TABLE test_child
ADD CONSTRAINT fk_test
FOREIGN KEY (parent_id)
REFERENCES test_parent(id);

DROP TABLE test_child;

DROP TABLE test_parent;

DESCRIBE book_copy;

CREATE TABLE member (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    membership_date DATE NOT NULL,

    membership_status ENUM(
        'ACTIVE',
        'SUSPENDED',
        'EXPIRED'
    ) NOT NULL DEFAULT 'ACTIVE'
);

DROP TABLE IF EXISTS member;

CREATE TABLE member (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    membership_date DATE NOT NULL,
    membership_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
);

ALTER TABLE member
ADD CONSTRAINT chk_member_status
CHECK (membership_status IN ('ACTIVE', 'SUSPENDED', 'EXPIRED'));

CREATE TABLE loan (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    copy_id INT NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE
);

ALTER TABLE loan
ADD CONSTRAINT fk_loan_member
FOREIGN KEY (member_id)
REFERENCES member(member_id);

ALTER TABLE loan
ADD CONSTRAINT fk_loan_copy
FOREIGN KEY (copy_id)
REFERENCES book_copy(copy_id);

CREATE TABLE fine (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL UNIQUE,
    amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    paid_status VARCHAR(10) NOT NULL DEFAULT 'UNPAID',
    generated_date DATE
);

ALTER TABLE fine
ADD CONSTRAINT fk_fine_loan
FOREIGN KEY (loan_id)
REFERENCES loan(loan_id);

ALTER TABLE fine
ADD CONSTRAINT chk_fine_status
CHECK (paid_status IN ('PAID', 'UNPAID'));

CREATE TABLE reservation (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    reservation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'WAITING'
);

ALTER TABLE reservation
ADD CONSTRAINT fk_reservation_member
FOREIGN KEY (member_id)
REFERENCES member(member_id);

ALTER TABLE reservation
ADD CONSTRAINT fk_reservation_book
FOREIGN KEY (book_id)
REFERENCES book(book_id);

ALTER TABLE reservation
ADD CONSTRAINT chk_reservation_status
CHECK (status IN ('WAITING', 'FULFILLED', 'CANCELLED'));

SHOW TABLES;

DESCRIBE book;

DESCRIBE loan;

INSERT INTO category
(category_name, description)
VALUES
('Computer Science',
 'Books related to computing and information technology'),
('Fiction',
 'Novels and fictional literature'),
('Mathematics',
 'Mathematics and mathematical sciences'),
('History',
 'Historical books and references'),
('Science',
 'General science and scientific subjects');

INSERT INTO publisher
(publisher_name, contact_email, phone, address)
VALUES
('Pearson',
 'contact@pearson.com',
 '9876543210',
 'New Delhi'),
('McGraw Hill',
 'contact@mcgrawhill.com',
 '9876543211',
 'Mumbai'),
('Penguin Random House',
 'contact@penguin.com',
 '9876543212',
 'Bangalore'),
('Oxford University Press',
 'contact@oup.com',
 '9876543213',
 'Chennai');

INSERT INTO author
(author_name, biography)
VALUES
('Abraham Silberschatz',
 'Computer science author and database researcher.'),
('Henry F. Korth',
 'Author and researcher in database systems.'),
('S. Sudarshan',
 'Computer science professor and database researcher.'),
('J.K. Rowling',
 'Author of the Harry Potter series.'),
('George Orwell',
 'English novelist and essayist.');

INSERT INTO book
(isbn, title, publication_year, category_id, publisher_id)
VALUES
('9780078022159',
 'Database System Concepts',
 2019,
 1,
 2),
('9780133970777',
 'Operating System Concepts',
 2018,
 1,
 1),
('9780747532743',
 'Harry Potter and the Philosopher''s Stone',
 1997,
 2,
 3),
('9780451524935',
 '1984',
 1949,
 2,
 3),
('9780199535721',
 'Mathematics: A Very Short Introduction',
 2008,
 3,
 4);

INSERT INTO book_author
(book_id, author_id)
VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 1),
(2, 2),
(3, 4),
(4, 5);

INSERT INTO book_copy
(book_id, accession_number, status, acquisition_date)
VALUES
(1, 'LIB-DB-001', 'AVAILABLE', '2025-01-10'),
(1, 'LIB-DB-002', 'AVAILABLE', '2025-01-10'),
(1, 'LIB-DB-003', 'ISSUED', '2025-01-10'),
(2, 'LIB-OS-001', 'AVAILABLE', '2025-01-15'),
(2, 'LIB-OS-002', 'AVAILABLE', '2025-01-15'),
(3, 'LIB-HP-001', 'AVAILABLE', '2025-02-01'),
(3, 'LIB-HP-002', 'ISSUED', '2025-02-01'),
(4, 'LIB-1984-001', 'AVAILABLE', '2025-02-10'),
(5, 'LIB-MATH-001', 'AVAILABLE', '2025-02-15');

INSERT INTO member
(full_name, email, phone, membership_date)
VALUES
('Aarav Sharma',
 'aarav@gmail.com',
 '9000000001',
 '2025-01-05'),
('Meera Nair',
 'meera@gmail.com',
 '9000000002',
 '2025-01-10'),
('Rohan Gupta',
 'rohan@gmail.com',
 '9000000003',
 '2025-02-15'),
('Ananya Iyer',
 'ananya@gmail.com',
 '9000000004',
 '2025-03-01'),
('Karan Mehta',
 'karan@gmail.com',
 '9000000005',
 '2025-03-15');

INSERT INTO loan
(member_id, copy_id, issue_date, due_date, return_date)
VALUES
(1, 3, '2026-09-10', '2026-09-17', NULL),
(2, 7, '2026-09-05', '2026-09-12', NULL),
(3, 4, '2026-09-01', '2026-09-08', '2026-09-07'),
(4, 6, '2026-08-20', '2026-08-27', '2026-08-26');

INSERT INTO reservation
(member_id, book_id, status)
VALUES
(3, 1, 'WAITING'),
(4, 1, 'WAITING'),
(5, 3, 'WAITING');

SELECT * FROM category;

SELECT * FROM publisher;

SELECT * FROM author;

SELECT * FROM book;

SELECT * FROM book_author;

SELECT * FROM book_copy;

SELECT * FROM member;

SELECT * FROM loan;

SELECT * FROM reservation;

SELECT * FROM book;

SELECT
    b.book_id,
    b.title,
    c.category_name
FROM book b
JOIN category c
    ON b.category_id = c.category_id;

SELECT
    b.title,
    p.publisher_name
FROM book b
JOIN publisher p
    ON b.publisher_id = p.publisher_id;

SELECT
    b.title,
    p.publisher_name
FROM book b
JOIN publisher p
    ON b.publisher_id = p.publisher_id;

SELECT
    b.title,
    a.author_name
FROM book b
JOIN book_author ba
    ON b.book_id = ba.book_id
JOIN author a
    ON ba.author_id = a.author_id
ORDER BY b.title;

SELECT
    b.title,
    bc.accession_number
FROM book b
JOIN book_copy bc
    ON b.book_id = bc.book_id
WHERE bc.status = 'AVAILABLE';

SELECT
    b.title,
    bc.accession_number,
    m.full_name,
    l.issue_date,
    l.due_date
FROM loan l
JOIN member m
    ON l.member_id = m.member_id
JOIN book_copy bc
    ON l.copy_id = bc.copy_id
JOIN book b
    ON bc.book_id = b.book_id
WHERE l.return_date IS NULL;

SELECT
    b.title,
    m.full_name,
    l.due_date
FROM loan l
JOIN member m
    ON l.member_id = m.member_id
JOIN book_copy bc
    ON l.copy_id = bc.copy_id
JOIN book b
    ON bc.book_id = b.book_id
WHERE l.return_date IS NULL
AND l.due_date < CURDATE();

SELECT
    m.full_name,
    b.title,
    l.issue_date,
    l.due_date,
    l.return_date
FROM loan l
JOIN member m
    ON l.member_id = m.member_id
JOIN book_copy bc
    ON l.copy_id = bc.copy_id
JOIN book b
    ON bc.book_id = b.book_id
WHERE m.member_id = 1;

SELECT
    b.title,
    COUNT(l.loan_id) AS times_borrowed
FROM book b
JOIN book_copy bc
    ON b.book_id = bc.book_id
JOIN loan l
    ON bc.copy_id = l.copy_id
GROUP BY b.book_id, b.title
ORDER BY times_borrowed DESC;

SELECT
    b.title,
    COUNT(bc.copy_id) AS total_copies
FROM book b
LEFT JOIN book_copy bc
    ON b.book_id = bc.book_id
GROUP BY b.book_id, b.title;

SELECT
    c.category_name,
    COUNT(b.book_id) AS number_of_books
FROM category c
LEFT JOIN book b
    ON c.category_id = b.category_id
GROUP BY c.category_id, c.category_name;

SELECT
    m.full_name,
    COUNT(l.loan_id) AS total_loans
FROM member m
LEFT JOIN loan l
    ON m.member_id = l.member_id
GROUP BY m.member_id, m.full_name
ORDER BY total_loans DESC;

CREATE VIEW issued_books AS
SELECT
    l.loan_id,
    m.full_name,
    b.title,
    bc.accession_number,
    l.issue_date,
    l.due_date
FROM loan l
JOIN member m
    ON l.member_id = m.member_id
JOIN book_copy bc
    ON l.copy_id = bc.copy_id
JOIN book b
    ON bc.book_id = b.book_id
WHERE l.return_date IS NULL;

SELECT *
FROM issued_books;

DELIMITER //

CREATE PROCEDURE issue_book(
    IN p_member_id INT,
    IN p_copy_id INT
)
BEGIN

    DECLARE copy_status VARCHAR(20);

    SELECT status
    INTO copy_status
    FROM book_copy
    WHERE copy_id = p_copy_id;

    IF copy_status = 'AVAILABLE' THEN

        INSERT INTO loan
        (
            member_id,
            copy_id,
            issue_date,
            due_date
        )
        VALUES
        (
            p_member_id,
            p_copy_id,
            CURDATE(),
            DATE_ADD(CURDATE(), INTERVAL 14 DAY)
        );

        UPDATE book_copy
        SET status = 'ISSUED'
        WHERE copy_id = p_copy_id;

    ELSE

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Book copy is not available';

    END IF;

END //

DELIMITER ;

CALL issue_book(1, 1);

SHOW PROCEDURE STATUS
WHERE Db = 'library_management_system';

CREATE PROCEDURE issue_book(
    IN p_member_id INT,
    IN p_copy_id INT
)
BEGIN
    DECLARE copy_status VARCHAR(20);

    SELECT status
    INTO copy_status
    FROM book_copy
    WHERE copy_id = p_copy_id;

    IF copy_status = 'AVAILABLE' THEN

        INSERT INTO loan (
            member_id,
            copy_id,
            issue_date,
            due_date
        )
        VALUES (
            p_member_id,
            p_copy_id,
            CURDATE(),
            DATE_ADD(CURDATE(), INTERVAL 14 DAY)
        );

        UPDATE book_copy
        SET status = 'ISSUED'
        WHERE copy_id = p_copy_id;

    ELSE

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Book copy is not available';

    END IF;
END

DROP PROCEDURE IF EXISTS issue_book;

DELIMITER //

CREATE PROCEDURE issue_book(
    IN p_member_id INT,
    IN p_copy_id INT
)
BEGIN
    DECLARE copy_status VARCHAR(20);

    SELECT status
    INTO copy_status
    FROM book_copy
    WHERE copy_id = p_copy_id;

    IF copy_status = 'AVAILABLE' THEN

        INSERT INTO loan (
            member_id,
            copy_id,
            issue_date,
            due_date
        )
        VALUES (
            p_member_id,
            p_copy_id,
            CURDATE(),
            DATE_ADD(CURDATE(), INTERVAL 14 DAY)
        );

        UPDATE book_copy
        SET status = 'ISSUED'
        WHERE copy_id = p_copy_id;

    ELSE

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Book copy is not available';

    END IF;

END //

DELIMITER ;
