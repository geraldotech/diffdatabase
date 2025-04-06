-- MySQL dump 10.13  Distrib 8.0.38, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: clientes_old
-- ------------------------------------------------------
-- Server version	9.0.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `a_footer`
--

DROP TABLE IF EXISTS `a_footer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `a_footer` (
  `ida_footer` int NOT NULL AUTO_INCREMENT,
  `a_footercol` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`ida_footer`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `a_footer`
--

LOCK TABLES `a_footer` WRITE;
/*!40000 ALTER TABLE `a_footer` DISABLE KEYS */;
/*!40000 ALTER TABLE `a_footer` ENABLE KEYS */;
UNLOCK TABLES;


--
-- Table structure for table `a_header`
--

DROP TABLE IF EXISTS `a_header`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `a_header` (
  `ida_header` int NOT NULL AUTO_INCREMENT,
  `a_header` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`ida_header`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `a_header`
--

LOCK TABLES `a_header` WRITE;
/*!40000 ALTER TABLE `a_header` DISABLE KEYS */;
/*!40000 ALTER TABLE `a_header` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `a_nome`
--

DROP TABLE IF EXISTS `a_nome`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `a_nome` (
  `ida_nome` int NOT NULL AUTO_INCREMENT,
  `a_nome` varchar(45) DEFAULT NULL,
  `a_new` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`ida_nome`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `a_nome`
--

LOCK TABLES `a_nome` WRITE;
/*!40000 ALTER TABLE `a_nome` DISABLE KEYS */;
INSERT INTO `a_nome` VALUES (1,'felipe',NULL),(2,'geraldo',NULL);
/*!40000 ALTER TABLE `a_nome` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `a_side`
--

DROP TABLE IF EXISTS `a_side`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `a_side` (
  `ida_side` int NOT NULL AUTO_INCREMENT,
  `a_sideNOVO` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`ida_side`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='test side';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `a_side`
--

LOCK TABLES `a_side` WRITE;
/*!40000 ALTER TABLE `a_side` DISABLE KEYS */;
/*!40000 ALTER TABLE `a_side` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-06 17:25:04
