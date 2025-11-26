-- Create dorm_certifications table
CREATE TABLE IF NOT EXISTS `dorm_certifications` (
  `certification_id` int(11) NOT NULL AUTO_INCREMENT,
  `dorm_id` int(11) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `certification_type` varchar(100) DEFAULT NULL COMMENT 'e.g., Business Permit, Fire Safety, Sanitary Permit, etc.',
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`certification_id`),
  KEY `dorm_id` (`dorm_id`),
  CONSTRAINT `dorm_certifications_ibfk_1` FOREIGN KEY (`dorm_id`) REFERENCES `dormitories` (`dorm_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Create uploads directory path for certifications
-- Note: Actual directory should be created at: Main/uploads/certifications/
