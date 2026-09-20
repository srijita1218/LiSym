USE library_management_system;

DELIMITER //

CREATE PROCEDURE return_book(
    IN p_loan_id INT
)
BEGIN

    DECLARE v_copy_id INT;

    SELECT copy_id
    INTO v_copy_id
    FROM loan
    WHERE loan_id = p_loan_id;

    UPDATE loan
    SET return_date = CURDATE()
    WHERE loan_id = p_loan_id;

    UPDATE book_copy
    SET status = 'AVAILABLE'
    WHERE copy_id = v_copy_id;

END //

DELIMITER ;

CALL return_book(1);

SELECT *
FROM loan
WHERE loan_id = 1;

SELECT *
FROM book_copy
WHERE copy_id = 3;

DELIMITER //

CREATE TRIGGER calculate_fine
AFTER UPDATE ON loan
FOR EACH ROW
BEGIN

    DECLARE overdue_days INT;

    IF NEW.return_date IS NOT NULL
       AND NEW.return_date > NEW.due_date THEN

        SET overdue_days =
            DATEDIFF(NEW.return_date, NEW.due_date);

        INSERT INTO fine
        (
            loan_id,
            amount,
            generated_date
        )
        VALUES
        (
            NEW.loan_id,
            overdue_days * 5,
            CURDATE()
        );

    END IF;

END //

DELIMITER ;

SELECT
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
    ON bc.book_id = b.book_id;

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

SELECT COUNT(*) AS total_books
FROM book;

SELECT COUNT(*) AS total_copies
FROM book_copy;

SELECT COUNT(*) AS available_copies
FROM book_copy
WHERE status = 'AVAILABLE';

SELECT COUNT(*) AS issued_copies
FROM book_copy
WHERE status = 'ISSUED';

SELECT COUNT(*) AS total_members
FROM member;

SELECT COUNT(*) AS active_loans
FROM loan
WHERE return_date IS NULL;

SELECT
    COALESCE(SUM(amount), 0) AS unpaid_fines
FROM fine
WHERE paid_status = 'UNPAID';

