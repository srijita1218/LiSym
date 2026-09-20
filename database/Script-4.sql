USE library_management_system;

SELECT DATABASE();

USE library_management_system;

DROP TRIGGER IF EXISTS calculate_fine;

DELIMITER //

CREATE TRIGGER calculate_fine
AFTER UPDATE ON loan
FOR EACH ROW
BEGIN
    DECLARE overdue_days INT;

    IF OLD.return_date IS NULL
       AND NEW.return_date IS NOT NULL
       AND NEW.return_date > NEW.due_date
       AND NOT EXISTS (
           SELECT 1
           FROM fine
           WHERE loan_id = NEW.loan_id
       ) THEN

        SET overdue_days = DATEDIFF(NEW.return_date, NEW.due_date);

        INSERT INTO fine (
            loan_id,
            amount,
            generated_date
        )
        VALUES (
            NEW.loan_id,
            overdue_days * 5,
            CURDATE()
        );

    END IF;
END //

DELIMITER ;

SHOW TRIGGERS
FROM library_management_system;

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

SELECT
    loan_id,
    member_id,
    copy_id,
    issue_date,
    due_date,
    return_date
FROM loan
ORDER BY loan_id;

SELECT
    loan_id,
    member_id,
    copy_id,
    issue_date,
    due_date,
    return_date,
    DATEDIFF(CURDATE(), due_date) AS days_overdue
FROM loan
WHERE return_date IS NULL
AND due_date < CURDATE();

SELECT
    loan_id,
    member_id,
    copy_id,
    issue_date,
    due_date,
    return_date
FROM loan
ORDER BY loan_id;

SELECT
    loan_id,
    member_id,
    copy_id,
    issue_date,
    due_date,
    return_date,
    DATEDIFF(CURDATE(), due_date) AS days_overdue
FROM loan
WHERE return_date IS NULL
AND due_date < CURDATE();

CREATE INDEX idx_member_name
ON member(full_name);

CREATE INDEX idx_loan_due_date
ON loan(due_date);

CREATE INDEX idx_copy_status
ON book_copy(status);

SHOW INDEX FROM book;

SHOW PROCEDURE STATUS
WHERE Db = 'library_management_system';

SHOW TRIGGERS FROM library_management_system;

SHOW FULL TABLES
WHERE Table_type = 'VIEW';

SELECT
    loan_id,
    member_id,
    copy_id,
    issue_date,
    due_date,
    return_date
FROM loan
ORDER BY loan_id;

SELECT
    loan_id,
    member_id,
    copy_id,
    issue_date,
    due_date,
    return_date,
    DATEDIFF(CURDATE(), due_date) AS days_overdue
FROM loan
WHERE return_date IS NULL
AND due_date < CURDATE();

SELECT *
FROM loan
WHERE loan_id = 9;

SELECT *
FROM fine;

SELECT *
FROM fine
WHERE loan_id = 9;

CALL return_book(9);

SELECT *
FROM loan
WHERE loan_id = 9;

SELECT *
FROM fine
WHERE loan_id = 9;