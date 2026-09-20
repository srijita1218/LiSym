-- MySQL dump 10.13  Distrib 8.0.19, for Win64 (x86_64)
--
-- Host: localhost    Database: library_management_system
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `author`
--

DROP TABLE IF EXISTS `author`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `author` (
  `author_id` int NOT NULL AUTO_INCREMENT,
  `author_name` varchar(150) NOT NULL,
  `biography` text,
  PRIMARY KEY (`author_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `author`
--

LOCK TABLES `author` WRITE;
/*!40000 ALTER TABLE `author` DISABLE KEYS */;
INSERT INTO `author` VALUES (1,'Abraham Silberschatz','Computer science author and database researcher.'),(2,'Henry F. Korth','Author and researcher in database systems.'),(3,'S. Sudarshan','Computer science professor and database researcher.'),(4,'J.K. Rowling','Author of the Harry Potter series.'),(5,'George Orwell','English novelist and essayist.');
/*!40000 ALTER TABLE `author` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `book`
--

DROP TABLE IF EXISTS `book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `book` (
  `book_id` int NOT NULL AUTO_INCREMENT,
  `isbn` varchar(20) NOT NULL,
  `title` varchar(200) NOT NULL,
  `publication_year` int DEFAULT NULL,
  `category_id` int NOT NULL,
  `publisher_id` int DEFAULT NULL,
  PRIMARY KEY (`book_id`),
  UNIQUE KEY `isbn` (`isbn`),
  KEY `fk_book_category` (`category_id`),
  KEY `fk_book_publisher` (`publisher_id`),
  KEY `idx_book_title` (`title`),
  CONSTRAINT `fk_book_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`),
  CONSTRAINT `fk_book_publisher` FOREIGN KEY (`publisher_id`) REFERENCES `publisher` (`publisher_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `book`
--

LOCK TABLES `book` WRITE;
/*!40000 ALTER TABLE `book` DISABLE KEYS */;
INSERT INTO `book` VALUES (1,'9780078022159','Database System Concepts',2019,1,2),(2,'9780133970777','Operating System Concepts',2018,1,1),(3,'9780747532743','Harry Potter and the Philosopher\'s Stone',1997,2,3),(4,'9780451524935','1984',1949,2,3),(5,'9780199535721','Mathematics: A Very Short Introduction',2008,3,4);
/*!40000 ALTER TABLE `book` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `book_author`
--

DROP TABLE IF EXISTS `book_author`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `book_author` (
  `book_id` int NOT NULL,
  `author_id` int NOT NULL,
  PRIMARY KEY (`book_id`,`author_id`),
  KEY `fk_book_author_author` (`author_id`),
  CONSTRAINT `fk_book_author_author` FOREIGN KEY (`author_id`) REFERENCES `author` (`author_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_book_author_book` FOREIGN KEY (`book_id`) REFERENCES `book` (`book_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `book_author`
--

LOCK TABLES `book_author` WRITE;
/*!40000 ALTER TABLE `book_author` DISABLE KEYS */;
INSERT INTO `book_author` VALUES (1,1),(2,1),(1,2),(2,2),(1,3),(3,4),(4,5);
/*!40000 ALTER TABLE `book_author` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `book_copy`
--

DROP TABLE IF EXISTS `book_copy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `book_copy` (
  `copy_id` int NOT NULL AUTO_INCREMENT,
  `book_id` int NOT NULL,
  `accession_number` varchar(50) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'AVAILABLE',
  `acquisition_date` date DEFAULT NULL,
  PRIMARY KEY (`copy_id`),
  UNIQUE KEY `accession_number` (`accession_number`),
  KEY `fk_book_copy_book` (`book_id`),
  KEY `idx_copy_status` (`status`),
  CONSTRAINT `fk_book_copy_book` FOREIGN KEY (`book_id`) REFERENCES `book` (`book_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `book_copy`
--

LOCK TABLES `book_copy` WRITE;
/*!40000 ALTER TABLE `book_copy` DISABLE KEYS */;
INSERT INTO `book_copy` VALUES (1,1,'LIB-DB-001','ISSUED','2025-01-10'),(2,1,'LIB-DB-002','AVAILABLE','2025-01-10'),(3,1,'LIB-DB-003','AVAILABLE','2025-01-10'),(4,2,'LIB-OS-001','AVAILABLE','2025-01-15'),(5,2,'LIB-OS-002','AVAILABLE','2025-01-15'),(6,3,'LIB-HP-001','AVAILABLE','2025-02-01'),(7,3,'LIB-HP-002','AVAILABLE','2025-02-01'),(8,4,'LIB-1984-001','ISSUED','2025-02-10'),(9,5,'LIB-MATH-001','AVAILABLE','2025-02-15');
/*!40000 ALTER TABLE `book_copy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `category_name` (`category_name`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (1,'Computer Science','Books related to computing and information technology'),(2,'Fiction','Novels and fictional literature'),(3,'Mathematics','Mathematics and mathematical sciences'),(4,'History','Historical books and references'),(5,'Science','General science and scientific subjects');
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fine`
--

DROP TABLE IF EXISTS `fine`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fine` (
  `fine_id` int NOT NULL AUTO_INCREMENT,
  `loan_id` int NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `paid_status` varchar(10) NOT NULL DEFAULT 'UNPAID',
  `generated_date` date DEFAULT NULL,
  PRIMARY KEY (`fine_id`),
  UNIQUE KEY `loan_id` (`loan_id`),
  CONSTRAINT `fk_fine_loan` FOREIGN KEY (`loan_id`) REFERENCES `loan` (`loan_id`),
  CONSTRAINT `chk_fine_status` CHECK ((`paid_status` in (_utf8mb4'PAID',_utf8mb4'UNPAID')))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fine`
--

LOCK TABLES `fine` WRITE;
/*!40000 ALTER TABLE `fine` DISABLE KEYS */;
INSERT INTO `fine` VALUES (1,9,80.00,'UNPAID','2026-09-21'),(2,2,45.00,'UNPAID','2026-09-21');
/*!40000 ALTER TABLE `fine` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `issued_books`
--

DROP TABLE IF EXISTS `issued_books`;
/*!50001 DROP VIEW IF EXISTS `issued_books`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `issued_books` AS SELECT 
 1 AS `loan_id`,
 1 AS `full_name`,
 1 AS `title`,
 1 AS `accession_number`,
 1 AS `issue_date`,
 1 AS `due_date`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `loan`
--

DROP TABLE IF EXISTS `loan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loan` (
  `loan_id` int NOT NULL AUTO_INCREMENT,
  `member_id` int NOT NULL,
  `copy_id` int NOT NULL,
  `issue_date` date NOT NULL,
  `due_date` date NOT NULL,
  `return_date` date DEFAULT NULL,
  PRIMARY KEY (`loan_id`),
  KEY `fk_loan_member` (`member_id`),
  KEY `fk_loan_copy` (`copy_id`),
  KEY `idx_loan_due_date` (`due_date`),
  CONSTRAINT `fk_loan_copy` FOREIGN KEY (`copy_id`) REFERENCES `book_copy` (`copy_id`),
  CONSTRAINT `fk_loan_member` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loan`
--

LOCK TABLES `loan` WRITE;
/*!40000 ALTER TABLE `loan` DISABLE KEYS */;
INSERT INTO `loan` VALUES (1,1,3,'2026-09-10','2026-09-17','2026-09-21'),(2,2,7,'2026-09-05','2026-09-12','2026-09-21'),(3,3,4,'2026-09-01','2026-09-08','2026-09-07'),(4,4,6,'2026-08-20','2026-08-27','2026-08-26'),(5,1,1,'2026-09-21','2026-10-05','2026-09-21'),(6,1,2,'2026-09-21','2026-10-05','2026-09-21'),(7,2,1,'2026-09-21','2026-10-05',NULL),(8,2,3,'2026-09-21','2026-10-05',NULL),(9,1,1,'2026-09-01','2026-09-05','2026-09-21'),(10,2,1,'2026-09-21','2026-10-05',NULL),(11,1,8,'2026-09-21','2026-10-05',NULL);
/*!40000 ALTER TABLE `loan` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `calculate_fine` AFTER UPDATE ON `loan` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `member`
--

DROP TABLE IF EXISTS `member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `member` (
  `member_id` int NOT NULL AUTO_INCREMENT,
  `full_name` varchar(150) NOT NULL,
  `email` varchar(150) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `membership_date` date NOT NULL,
  `membership_status` varchar(20) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (`member_id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_member_name` (`full_name`),
  CONSTRAINT `chk_member_status` CHECK ((`membership_status` in (_utf8mb4'ACTIVE',_utf8mb4'SUSPENDED',_utf8mb4'EXPIRED')))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `member`
--

LOCK TABLES `member` WRITE;
/*!40000 ALTER TABLE `member` DISABLE KEYS */;
INSERT INTO `member` VALUES (1,'Aarav Sharma','aarav@gmail.com','9000000001','2025-01-05','ACTIVE'),(2,'Meera Nair','meera@gmail.com','9000000002','2025-01-10','ACTIVE'),(3,'Rohan Gupta','rohan@gmail.com','9000000003','2025-02-15','ACTIVE'),(4,'Ananya Iyer','ananya@gmail.com','9000000004','2025-03-01','ACTIVE'),(5,'Karan Mehta','karan@gmail.com','9000000005','2025-03-15','ACTIVE');
/*!40000 ALTER TABLE `member` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `publisher`
--

DROP TABLE IF EXISTS `publisher`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `publisher` (
  `publisher_id` int NOT NULL AUTO_INCREMENT,
  `publisher_name` varchar(150) NOT NULL,
  `contact_email` varchar(150) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`publisher_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `publisher`
--

LOCK TABLES `publisher` WRITE;
/*!40000 ALTER TABLE `publisher` DISABLE KEYS */;
INSERT INTO `publisher` VALUES (1,'Pearson','contact@pearson.com','9876543210','New Delhi'),(2,'McGraw Hill','contact@mcgrawhill.com','9876543211','Mumbai'),(3,'Penguin Random House','contact@penguin.com','9876543212','Bangalore'),(4,'Oxford University Press','contact@oup.com','9876543213','Chennai');
/*!40000 ALTER TABLE `publisher` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reservation`
--

DROP TABLE IF EXISTS `reservation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reservation` (
  `reservation_id` int NOT NULL AUTO_INCREMENT,
  `member_id` int NOT NULL,
  `book_id` int NOT NULL,
  `reservation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(20) NOT NULL DEFAULT 'WAITING',
  PRIMARY KEY (`reservation_id`),
  KEY `fk_reservation_member` (`member_id`),
  KEY `fk_reservation_book` (`book_id`),
  CONSTRAINT `fk_reservation_book` FOREIGN KEY (`book_id`) REFERENCES `book` (`book_id`),
  CONSTRAINT `fk_reservation_member` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`),
  CONSTRAINT `chk_reservation_status` CHECK ((`status` in (_utf8mb4'WAITING',_utf8mb4'FULFILLED',_utf8mb4'CANCELLED')))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reservation`
--

LOCK TABLES `reservation` WRITE;
/*!40000 ALTER TABLE `reservation` DISABLE KEYS */;
INSERT INTO `reservation` VALUES (1,3,1,'2026-09-21 01:09:54','WAITING'),(2,4,1,'2026-09-21 01:09:54','WAITING'),(3,5,3,'2026-09-21 01:09:54','WAITING');
/*!40000 ALTER TABLE `reservation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'library_management_system'
--
/*!50003 DROP PROCEDURE IF EXISTS `issue_book` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `issue_book`(
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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `return_book` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `return_book`(
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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `issued_books`
--

/*!50001 DROP VIEW IF EXISTS `issued_books`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `issued_books` AS select `l`.`loan_id` AS `loan_id`,`m`.`full_name` AS `full_name`,`b`.`title` AS `title`,`bc`.`accession_number` AS `accession_number`,`l`.`issue_date` AS `issue_date`,`l`.`due_date` AS `due_date` from (((`loan` `l` join `member` `m` on((`l`.`member_id` = `m`.`member_id`))) join `book_copy` `bc` on((`l`.`copy_id` = `bc`.`copy_id`))) join `book` `b` on((`bc`.`book_id` = `b`.`book_id`))) where (`l`.`return_date` is null) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-21  3:55:57
