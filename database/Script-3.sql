USE library_management_system;

SHOW TABLES;

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

SELECT * FROM issued_books;

SELECT *
FROM book_copy
WHERE status = 'AVAILABLE';

SELECT *
FROM loan
ORDER BY loan_id DESC;

SELECT *
FROM book_copy
WHERE copy_id = 1;

SELECT * FROM loan;

CALL return_book(1);

SELECT * FROM loan
WHERE loan_id = 1;

SELECT * FROM book_copy;

SELECT * FROM book_copy;

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
WHERE r.status = 'WAITING'
ORDER BY r.reservation_date;

CREATE INDEX idx_book_title
ON book(title);

CREATE INDEX idx_member_name
ON member(full_name);

CREATE INDEX idx_loan_due_date
ON loan(due_date);

CREATE INDEX idx_copy_status
ON book_copy(status);

START TRANSACTION;

UPDATE book_copy
SET status = 'ISSUED'
WHERE copy_id = 1;

INSERT INTO loan
(member_id, copy_id, issue_date, due_date)
VALUES
(2, 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY));

COMMIT;

SELECT 
    b.title,
    m.full_name,
    l.due_date
FROM loan l
JOIN member m ON l.member_id = m.member_id
JOIN book_copy bc ON l.copy_id = bc.copy_id
JOIN book b ON bc.book_id = b.book_id
WHERE l.return_date IS NULL
AND l.due_date < CURDATE();

SELECT 
    b.title,
    bc.accession_number,
    bc.status
FROM book b
JOIN book_copy bc ON b.book_id = bc.book_id
ORDER BY b.book_id, bc.copy_id;

SHOW INDEX FROM book;

SHOW INDEX FROM member;

SHOW INDEX FROM loan;

SHOW INDEX FROM book_copy;

SELECT 
    copy_id,
    book_id,
    accession_number,
    status
FROM book_copy
WHERE status = 'AVAILABLE';

SELECT * FROM member;

CALL issue_book(1,1);

CALL issue_book(1,2);

CALL issue_book(2,3);

SELECT *
FROM loan
WHERE return_date IS NULL;

CALL return_book(1);

SELECT *
FROM loan
WHERE loan_id = 1;

SELECT *
FROM book_copy
WHERE copy_id = 3;

SELECT *
FROM book_copy
WHERE status = 'AVAILABLE';

SELECT *
FROM member;

INSERT INTO loan
(
    member_id,
    copy_id,
    issue_date,
    due_date,
    return_date
)
VALUES
(
    1,
    1,
    '2026-09-01',
    '2026-09-05',
    NULL
);

UPDATE book_copy
SET status = 'ISSUED'
WHERE copy_id = 1;

SELECT *
FROM loan
ORDER BY loan_id DESC;

CALL return_book(6);

SELECT * FROM fine;

CALL return_book(1);

SELECT *
FROM loan
WHERE loan_id = 1;

SELECT *
FROM fine;

SELECT
    l.loan_id,
    m.full_name,
    b.title,
    l.due_date,
    l.return_date,
    f.amount,
    f.paid_status
FROM loan l
JOIN member m ON l.member_id = m.member_id
JOIN book_copy bc ON l.copy_id = bc.copy_id
JOIN book b ON bc.book_id = b.book_id
LEFT JOIN fine f ON l.loan_id = f.loan_id
WHERE l.loan_id = 1;

SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'library_management_system'
AND REFERENCED_TABLE_NAME IS NOT NULL;

SHOW CREATE TABLE member;

SHOW CREATE TABLE fine;

SHOW CREATE TABLE reservation;

SELECT
    b.book_id,
    b.title
FROM book b
LEFT JOIN book_copy bc
    ON b.book_id = bc.book_id
LEFT JOIN loan l
    ON bc.copy_id = l.copy_id
WHERE l.loan_id IS NULL;

SELECT
    m.full_name,
    COUNT(l.loan_id) AS total_loans
FROM member m
LEFT JOIN loan l
    ON m.member_id = l.member_id
GROUP BY m.member_id, m.full_name
ORDER BY total_loans DESC;

SELECT
    b.title,
    COUNT(bc.copy_id) AS total_copies
FROM book b
LEFT JOIN book_copy bc
    ON b.book_id = bc.book_id
GROUP BY b.book_id, b.title;

CALL return_book(5);

SELECT *
FROM loan
WHERE loan_id = 5;

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
WHERE r.status = 'WAITING'
ORDER BY r.reservation_date;

SELECT
    b.title,
    m.full_name,
    l.due_date,
    DATEDIFF(CURDATE(), l.due_date) AS days_overdue
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
    c.category_name,
    COUNT(b.book_id) AS number_of_books
FROM category c
LEFT JOIN book b
    ON c.category_id = b.category_id
GROUP BY c.category_id, c.category_name;

START TRANSACTION;

SELECT *
FROM book
WHERE book_id = 1;

ROLLBACK;

SHOW PROCEDURE STATUS
WHERE Db = 'library_management_system';

SHOW CREATE PROCEDURE issue_book;

SHOW TRIGGERS
FROM library_management_system;

SELECT
    TRIGGER_SCHEMA,
    TRIGGER_NAME,
    EVENT_MANIPULATION,
    EVENT_OBJECT_TABLE,
    ACTION_TIMING
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'library_management_system';

ALTER TABLE MEMBER
MODIFY COLUMN phone VARCHAR(10);

ALTER TABLE LIBRARIAN
MODIFY COLUMN phone VARCHAR(10);


ALTER TABLE PUBLISHER
MODIFY COLUMN phone VARCHAR(10);

USE library_management;

DESCRIBE MEMBER;
DESCRIBE LIBRARIAN;
DESCRIBE PUBLISHER;

show tables;

select * from reservation;
desc author;


USE library_management_system;

SHOW TABLES;

select * from book; 

select * from book_author;

select * from book_copy;

desc loan;

desc member;



SELECT COUNT(*) AS total_books
FROM book;

SELECT COUNT(*) AS total_copies
FROM book_copy;

SELECT AVG(amount) AS average_fine
FROM fine;

SELECT
    MIN(amount) AS minimum_fine,
    MAX(amount) AS maximum_fine
FROM fine;


SELECT
    category_id,
    COUNT(*) AS book_count
FROM book
GROUP BY category_id;

SELECT
    category_id,
    COUNT(*) AS book_count
FROM book
GROUP BY category_id
HAVING COUNT(*) > 2;


SELECT
    category_id,
    COUNT(*) AS book_count
FROM book
WHERE category_id IS NOT NULL
GROUP BY category_id
HAVING COUNT(*) >= 2;




SELECT
    b.book_id,
    b.title,
    bc.copy_id,
    bc.accession_number,
    bc.status
FROM book b
LEFT JOIN book_copy bc
    ON b.book_id = bc.book_id;



SELECT
    b.book_id,
    b.title,
    bc.copy_id,
    bc.accession_number,
    bc.status
FROM book b
RIGHT JOIN book_copy bc
    ON b.book_id = bc.book_id;




SELECT
    b.book_id,
    b.title,
    bc.copy_id,
    bc.accession_number,
    bc.status
FROM book b
LEFT JOIN book_copy bc
    ON b.book_id = bc.book_id;




SELECT
    b1.title AS first_book,
    b2.title AS second_book,
    b1.category_id
FROM book b1
INNER JOIN book b2
    ON b1.category_id = b2.category_id
WHERE b1.book_id < b2.book_id;



SELECT
    b.title,
    bc.copy_id,
    bc.accession_number
FROM book b
CROSS JOIN book_copy bc;


DESCRIBE reservation;

SELECT title, category_id
FROM book
WHERE category_id = (
    SELECT category_id
    FROM book
    GROUP BY category_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
);


SELECT title, category_id
FROM book
WHERE category_id = (
    SELECT category_id
    FROM book
    WHERE book_id = 1
);

SELECT title, category_id
FROM book
WHERE category_id IN (
    SELECT category_id
    FROM book
    GROUP BY category_id
    HAVING COUNT(*) > 1
);

SELECT title, category_id
FROM book
WHERE category_id >= ALL (
    SELECT category_id
    FROM book
    WHERE category_id IS NOT NULL
);



SELECT b1.title, b1.category_id
FROM book b1
WHERE (
    SELECT COUNT(*)
    FROM book b2
    WHERE b2.category_id = b1.category_id
) > (
    SELECT AVG(category_count)
    FROM (
        SELECT COUNT(*) AS category_count
        FROM book
        WHERE category_id IS NOT NULL
        GROUP BY category_id
    ) AS category_totals
);


SELECT c.category_id, c.category_name
FROM category c
WHERE EXISTS (
    SELECT 1
    FROM book b
    WHERE b.category_id = c.category_id
);

SELECT title AS item_name
FROM book

UNION

SELECT author_name AS item_name
FROM author;



SELECT full_name AS person_name
FROM member

UNION ALL

SELECT author_name AS person_name
FROM author;

SELECT book_id, title
FROM book
WHERE book_id IN (
    SELECT book_id
    FROM reservation
);


SELECT book_id, title
FROM book
WHERE book_id NOT IN (
    SELECT book_id
    FROM reservation
    WHERE book_id IS NOT NULL
);

SELECT
    copy_id,
    accession_number,
    status,
    CASE
        WHEN status = 'AVAILABLE' THEN 'Ready to Issue'
        WHEN status = 'ISSUED' THEN 'Currently Borrowed'
        ELSE 'Other Status'
    END AS availability_category
FROM book_copy;

SELECT
    member_id,
    full_name,
    COALESCE(phone, 'Not Provided') AS contact_number
FROM member;


SELECT
    fine_id,
    amount,
    NULLIF(amount, 0) AS nonzero_fine_amount
FROM fine;

SELECT
    loan_id,
    issue_date,
    due_date,
    DATEDIFF(due_date, issue_date) AS allowed_loan_days
FROM loan;

SELECT
    member_id,
    UPPER(full_name) AS uppercase_name,
    LENGTH(full_name) AS name_length
FROM member;

SELECT
    category_id,
    COUNT(*) AS total_books,
    RANK() OVER (
        ORDER BY COUNT(*) DESC
    ) AS category_rank
FROM book
GROUP BY category_id;


SELECT
    book_id,
    title,
    category_id,
    ROW_NUMBER() OVER (
        PARTITION BY category_id
        ORDER BY title
    ) AS book_number
FROM book;

SELECT
    fine_id,
    generated_date,
    amount,
    LAG(amount) OVER (
        ORDER BY fine_id
    ) AS previous_fine_amount
FROM fine;

SELECT
    b.book_id,
    b.title,
    c.category_name,
    p.publisher_name,
    COUNT(bc.copy_id) AS total_copies
FROM book b
LEFT JOIN category c
    ON b.category_id = c.category_id
LEFT JOIN publisher p
    ON b.publisher_id = p.publisher_id
LEFT JOIN book_copy bc
    ON b.book_id = bc.book_id
GROUP BY
    b.book_id,
    b.title,
    c.category_name,
    p.publisher_name
ORDER BY b.title;

SELECT
    m.member_id,
    m.full_name,
    b.title,
    bc.accession_number,
    l.issue_date,
    l.due_date,
    l.return_date
FROM member m
INNER JOIN loan l
    ON m.member_id = l.member_id
INNER JOIN book_copy bc
    ON l.copy_id = bc.copy_id
INNER JOIN book b
    ON bc.book_id = b.book_id
ORDER BY m.full_name, l.issue_date DESC;


SELECT
    m.member_id,
    m.full_name,
    m.phone,
    b.title,
    l.issue_date,
    l.due_date,
    DATEDIFF(CURDATE(), l.due_date) AS days_overdue
FROM member m
INNER JOIN loan l
    ON m.member_id = l.member_id
INNER JOIN book_copy bc
    ON l.copy_id = bc.copy_id
INNER JOIN book b
    ON bc.book_id = b.book_id
WHERE l.return_date IS NULL
  AND l.due_date < CURDATE()
ORDER BY days_overdue DESC;

SELECT
    f.fine_id,
    m.member_id,
    m.full_name,
    b.title,
    f.amount,
    f.paid_status,
    f.generated_date
FROM fine f
INNER JOIN loan l
    ON f.loan_id = l.loan_id
INNER JOIN member m
    ON l.member_id = m.member_id
INNER JOIN book_copy bc
    ON l.copy_id = bc.copy_id
INNER JOIN book b
    ON bc.book_id = b.book_id
WHERE f.paid_status = 'UNPAID'
ORDER BY f.amount DESC;

CREATE OR REPLACE VIEW vw_book_catalogue AS
SELECT
    b.book_id,
    b.isbn,
    b.title,
    b.publication_year,
    c.category_name,
    p.publisher_name,
    bc.copy_id,
    bc.accession_number,
    bc.status AS copy_status
FROM book b
LEFT JOIN category c
    ON b.category_id = c.category_id
LEFT JOIN publisher p
    ON b.publisher_id = p.publisher_id
LEFT JOIN book_copy bc
    ON b.book_id = bc.book_id;

SELECT *
FROM vw_book_catalogue
ORDER BY title;

CREATE OR REPLACE VIEW vw_category_inventory AS
SELECT
    c.category_id,
    c.category_name,
    COUNT(DISTINCT b.book_id) AS total_books,
    COUNT(bc.copy_id) AS total_copies,
    COUNT(
        DISTINCT CASE
            WHEN bc.status = 'AVAILABLE' THEN bc.copy_id
        END
    ) AS available_copies,
    COUNT(
        DISTINCT CASE
            WHEN bc.status = 'ISSUED' THEN bc.copy_id
        END
    ) AS issued_copies
FROM category c
LEFT JOIN book b
    ON c.category_id = b.category_id
LEFT JOIN book_copy bc
    ON b.book_id = bc.book_id
GROUP BY c.category_id, c.category_name;

SELECT *
FROM vw_category_inventory
ORDER BY total_copies DESC;


DELIMITER //

CREATE PROCEDURE sp_search_books(
    IN p_title VARCHAR(200)
)
BEGIN
    SELECT
        b.book_id,
        b.title,
        b.isbn,
        c.category_name,
        p.publisher_name,
        b.publication_year
    FROM book b
    LEFT JOIN category c
        ON b.category_id = c.category_id
    LEFT JOIN publisher p
        ON b.publisher_id = p.publisher_id
    WHERE b.title LIKE CONCAT('%', p_title, '%')
    ORDER BY b.title;
END //

DELIMITER ;

select * from Book;

SHOW PROCEDURE STATUS
WHERE Db = 'library_management_system'
  AND Name = 'sp_search_books';

USE library_management_system;

DROP PROCEDURE IF EXISTS sp_search_books;

USE library_management_system;

DROP PROCEDURE IF EXISTS sp_search_books;

DELIMITER //

CREATE PROCEDURE sp_search_books(
    IN p_title VARCHAR(200)
)
BEGIN
    SELECT
        b.book_id,
        b.title,
        b.isbn,
        c.category_name,
        p.publisher_name,
        b.publication_year
    FROM book b
    LEFT JOIN category c
        ON b.category_id = c.category_id
    LEFT JOIN publisher p
        ON b.publisher_id = p.publisher_id
    WHERE b.title LIKE CONCAT('%', p_title, '%')
    ORDER BY b.title;
END //

DELIMITER ;
















