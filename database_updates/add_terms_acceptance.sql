-- Add terms and conditions acceptance tracking
-- Run this migration to add terms acceptance fields

ALTER TABLE `users` 
ADD COLUMN `terms_accepted` TINYINT(1) DEFAULT 0 COMMENT 'Whether user accepted terms and conditions' AFTER `created_at`,
ADD COLUMN `terms_accepted_at` DATETIME DEFAULT NULL COMMENT 'When user accepted terms' AFTER `terms_accepted`,
ADD COLUMN `terms_version` VARCHAR(20) DEFAULT NULL COMMENT 'Version of terms accepted (e.g., v1.0)' AFTER `terms_accepted_at`;

-- Optional: Create a terms_and_conditions table to store different versions
CREATE TABLE IF NOT EXISTS `terms_and_conditions` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `version` VARCHAR(20) NOT NULL COMMENT 'Version identifier (e.g., v1.0, v1.1)',
  `user_type` ENUM('student', 'owner', 'both') DEFAULT 'both' COMMENT 'Which user type this applies to',
  `title` VARCHAR(255) NOT NULL,
  `content` TEXT NOT NULL COMMENT 'HTML content of terms and conditions',
  `effective_date` DATE NOT NULL COMMENT 'When this version becomes effective',
  `is_active` TINYINT(1) DEFAULT 1 COMMENT 'Whether this version is currently active',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `version` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Insert default terms and conditions
INSERT INTO `terms_and_conditions` (`version`, `user_type`, `title`, `content`, `effective_date`, `is_active`) VALUES
('v1.0', 'both', 'LCozy Dormitory Management System - Terms and Conditions', 
'<h3>1. Acceptance of Terms</h3>
<p>By registering and using the LCozy Dormitory Management System, you agree to be bound by these Terms and Conditions.</p>

<h3>2. User Responsibilities</h3>
<p><strong>For Students:</strong></p>
<ul>
<li>Provide accurate and truthful information during registration</li>
<li>Pay rent and other fees on time as agreed</li>
<li>Respect dorm rules and regulations</li>
<li>Report any issues or damages promptly</li>
<li>Maintain cleanliness and order in shared spaces</li>
</ul>

<p><strong>For Dorm Owners:</strong></p>
<ul>
<li>Provide accurate information about dormitory facilities</li>
<li>Maintain safe and habitable living conditions</li>
<li>Address tenant concerns promptly</li>
<li>Comply with local housing regulations</li>
<li>Process payments and refunds fairly</li>
</ul>

<h3>3. Privacy and Data Protection</h3>
<p>We collect and store personal information necessary for dormitory management. Your data will be protected and not shared with third parties without consent, except as required by law.</p>

<h3>4. Payment Terms</h3>
<p>All payments must be made through the system. Late payments may result in penalties. Refunds are subject to the cancellation policy.</p>

<h3>5. Cancellation Policy</h3>
<p>Students may cancel bookings before payment without penalty. After payment, cancellations are subject to owner approval and may incur fees.</p>

<h3>6. Liability</h3>
<p>LCozy acts as a platform connecting students and dorm owners. We are not responsible for disputes between parties, property damage, or personal injuries.</p>

<h3>7. Termination</h3>
<p>We reserve the right to terminate accounts that violate these terms or engage in fraudulent activities.</p>

<h3>8. Changes to Terms</h3>
<p>We may update these terms periodically. Continued use of the system constitutes acceptance of updated terms.</p>

<h3>9. Contact</h3>
<p>For questions about these terms, please contact support through the app.</p>',
NOW(), 1);
