-- Missing Tables (to be added):
CREATE TABLE `a_footer` (
  `ida_footer` int NOT NULL AUTO_INCREMENT,
  `a_footercol` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`ida_footer`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `a_header` (
  `ida_header` int NOT NULL AUTO_INCREMENT,
  `a_header` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`ida_header`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `a_side` (
  `ida_side` int NOT NULL AUTO_INCREMENT,
  `a_sideNOVO` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`ida_side`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='test side';

-- Alterations for existing tables:
-- Missing columns in table a_nome
ALTER TABLE `a_nome` ADD COLUMN   `a_new` varchar(45) DEFAULT NULL;
