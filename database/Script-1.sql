USE library_management_system;

USE library_management_system;

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

SHOW PROCEDURE STATUS
WHERE Db = 'library_management_system';

CALL issue_book(1, 1);

SELECT * 
FROM book_copy
WHERE copy_id = 1;

CALL issue_book(1, 1);

USE library_management_system;

SHOW TABLES;

SELECT *
FROM book_copy
WHERE copy_id = 1;

CALL issue_book(1, 1);

SELECT
    copy_id,
    book_id,
    accession_number,
    status
FROM book_copy
ORDER BY copy_id;

CALL issue_book(1, 2);