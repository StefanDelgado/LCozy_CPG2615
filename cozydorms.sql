-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Oct 17, 2025 at 11:04 AM
-- Server version: 10.6.22-MariaDB-cll-lve
-- PHP Version: 8.3.22

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `cozydorms`
--

-- --------------------------------------------------------

--
-- Table structure for table `announcements`
--

CREATE TABLE `announcements` (
  `id` int(11) NOT NULL,
  `sender_id` int(11) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `audience` enum('All Hosts','Verified Owners','Pending Owners') DEFAULT 'All Hosts',
  `send_option` enum('Send Now','Schedule') DEFAULT 'Send Now',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `recipient_type` enum('all','owners','students','custom') DEFAULT 'all'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `announcements`
--

INSERT INTO `announcements` (`id`, `sender_id`, `title`, `message`, `audience`, `send_option`, `created_at`, `recipient_type`) VALUES
(14, 1, 'Verify', 'Submit all required documents.', 'All Hosts', '', '2025-10-14 00:00:17', 'all'),
(15, 1, 'New Owners', 'For new owners, please make sure that your documents are valid.', 'All Hosts', '', '2025-10-14 06:27:11', 'owners');

-- --------------------------------------------------------

--
-- Table structure for table `announcement_reads`
--

CREATE TABLE `announcement_reads` (
  `id` int(11) NOT NULL,
  `announcement_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `read_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `booking_id` int(11) NOT NULL,
  `room_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `booking_type` enum('whole','shared') DEFAULT 'shared',
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` enum('pending','approved','rejected','cancelled','completed','active') NOT NULL DEFAULT 'pending' COMMENT 'pending=awaiting approval, approved=owner approved, active=currently occupying, completed=tenancy ended, rejected=owner declined, cancelled=student cancelled',
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` datetime DEFAULT NULL,
  `selfie` varchar(255) DEFAULT NULL,
  `id_document` varchar(255) DEFAULT NULL,
  `display_picture` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `check_in_date` datetime DEFAULT NULL COMMENT 'Actual check-in date/time',
  `check_out_date` datetime DEFAULT NULL COMMENT 'Actual check-out date/time',
  `booking_reference` varchar(50) DEFAULT NULL COMMENT 'Unique booking reference code'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`booking_id`, `room_id`, `student_id`, `booking_type`, `start_date`, `end_date`, `status`, `updated_at`, `created_at`, `expires_at`, `selfie`, `id_document`, `display_picture`, `notes`, `check_in_date`, `check_out_date`, `booking_reference`) VALUES
(7, 18, 9, 'shared', '2025-10-07', '2026-04-07', 'cancelled', '2025-10-17 10:35:13', '2025-10-07 02:43:54', '2025-10-07 06:43:54', NULL, NULL, NULL, NULL, NULL, NULL, 'BK00000007'),
(10, 26, 11, 'shared', '2025-10-11', '2026-04-11', 'cancelled', '2025-10-17 10:35:13', '2025-10-11 09:43:38', '2025-10-11 11:43:38', NULL, NULL, NULL, NULL, NULL, NULL, 'BK00000010'),
(11, 22, 11, 'shared', '2025-10-11', '2026-04-11', 'active', '2025-10-17 10:35:13', '2025-10-11 22:39:05', '2025-10-12 00:39:05', NULL, NULL, NULL, NULL, NULL, NULL, 'BK00000011'),
(12, 22, 47, 'shared', '2025-10-12', '2026-04-12', 'cancelled', '2025-10-17 10:35:13', '2025-10-12 13:45:18', '2025-10-12 15:45:18', NULL, NULL, NULL, NULL, NULL, NULL, 'BK00000012'),
(26, 28, 31, 'whole', '2025-10-12', '2026-04-12', 'active', '2025-10-17 10:35:13', '2025-10-12 19:26:47', '2025-10-12 21:26:47', NULL, NULL, NULL, NULL, NULL, NULL, 'BK00000026'),
(27, 26, 48, 'whole', '2025-10-13', '2026-04-13', 'pending', '2025-10-17 10:35:13', '2025-10-13 23:49:07', '2025-10-14 01:49:07', NULL, NULL, NULL, NULL, NULL, NULL, 'BK00000027'),
(28, 27, 50, 'shared', '2025-10-14', '2026-04-14', 'cancelled', '2025-10-17 10:35:13', '2025-10-14 04:42:43', '2025-10-14 06:42:43', NULL, NULL, NULL, NULL, NULL, NULL, 'BK00000028'),
(29, 22, 50, 'shared', '2025-10-14', '2026-04-14', 'pending', '2025-10-17 10:35:13', '2025-10-14 04:43:12', '2025-10-14 06:43:12', NULL, NULL, NULL, NULL, NULL, NULL, 'BK00000029'),
(30, 46, 30, 'shared', '2025-10-15', '2026-04-13', 'active', '2025-10-17 10:35:13', '2025-10-15 02:04:23', '2025-10-15 04:04:23', NULL, NULL, NULL, NULL, NULL, NULL, 'BK00000030'),
(31, 29, 30, 'whole', '2025-10-15', '2026-04-13', 'active', '2025-10-17 10:35:13', '2025-10-15 02:58:05', '2025-10-15 04:58:05', NULL, NULL, NULL, NULL, NULL, NULL, 'BK00000031'),
(32, 28, 52, 'shared', '2025-10-16', '2026-04-16', 'pending', '2025-10-17 10:35:13', '2025-10-16 08:12:13', '2025-10-16 10:12:13', NULL, NULL, NULL, NULL, NULL, NULL, 'BK00000032'),
(33, 18, 30, 'shared', '2025-10-16', '2026-04-14', 'pending', '2025-10-17 10:35:13', '2025-10-16 12:10:34', '2025-10-16 14:10:34', NULL, NULL, NULL, NULL, NULL, NULL, 'BK00000033'),
(34, 49, 30, 'whole', '2025-10-16', '2026-04-14', 'active', '2025-10-17 10:35:13', '2025-10-16 13:01:18', '2025-10-16 15:01:18', NULL, NULL, NULL, NULL, NULL, NULL, 'BK00000034');

--
-- Triggers `bookings`
--
DELIMITER $$
CREATE TRIGGER `create_tenant_on_booking_approved` AFTER UPDATE ON `bookings` FOR EACH ROW BEGIN
  IF NEW.status = 'approved' AND OLD.status = 'pending' THEN
    INSERT INTO tenants (booking_id, student_id, dorm_id, room_id, status, check_in_date, expected_checkout, notes)
    SELECT 
      NEW.booking_id,
      NEW.student_id,
      r.dorm_id,
      NEW.room_id,
      'active',
      COALESCE(NEW.start_date, CURDATE()),
      NEW.end_date,
      NEW.notes
    FROM rooms r
    WHERE r.room_id = NEW.room_id
      AND NOT EXISTS (
        SELECT 1 FROM tenants t WHERE t.booking_id = NEW.booking_id
      );
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_tenant_on_booking_complete` AFTER UPDATE ON `bookings` FOR EACH ROW BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    UPDATE tenants 
    SET status = 'completed',
        check_out_date = NOW()
    WHERE booking_id = NEW.booking_id
      AND status = 'active';
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `dormitories`
--

CREATE TABLE `dormitories` (
  `dorm_id` int(11) NOT NULL,
  `owner_id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL,
  `address` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `verified` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `status` enum('pending','verified','error') NOT NULL DEFAULT 'pending',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `cover_image` varchar(255) DEFAULT NULL,
  `features` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dormitories`
--

INSERT INTO `dormitories` (`dorm_id`, `owner_id`, `name`, `address`, `description`, `verified`, `created_at`, `latitude`, `longitude`, `status`, `updated_at`, `cover_image`, `features`) VALUES
(1, 3, 'Sunshine Dormitory', 'Lacson Street, Bacolod City', 'Affordable dorm with free WiFi and study lounge.', 0, '2025-08-22 02:25:32', 10.67650000, 122.95090000, 'verified', '2025-08-22 04:24:01', NULL, NULL),
(3, 5, 'Blue Haven Dormitory', 'Araneta Avenue, Bacolod City', 'Close to universities, laundry service available, 24/7 security.', 1, '2025-08-22 02:25:32', 10.69170000, 122.97460000, 'pending', '2025-10-16 09:47:11', NULL, NULL),
(4, 4, 'Evergreen Dorms', 'Burgos Avenue, Bacolod City', 'Spacious rooms with air conditioning and shared kitchen.', 0, '2025-08-22 02:30:36', 10.69170000, 122.97460000, 'pending', '2025-10-16 09:47:11', NULL, NULL),
(5, 8, 'Southern Oasis', 'P Hernaez St.', 'A cozy dorm with a cozy atmosphere', 1, '2025-10-07 01:15:32', 10.68530000, 122.95670000, 'pending', '2025-10-16 09:47:11', 'dorm_68e469b41e437.png', 'Free Wifi, Aircon, Meals provided every morning.'),
(6, 15, 'Anna\'s Haven Dormitory', '6100 Tops Rd, Bacolod, Negros Occidental, Philippines', 'A cozy and affordable dorm perfect for university students. Located near major schools and transport lines.', 1, '2025-10-10 16:58:30', 10.67523870, 122.95728190, 'pending', '2025-10-16 09:23:38', 'dorm_68e93b36b97a4.png', 'Wi-Fi, Study Lounge, CCTV Security, Air-conditioned Rooms, Laundry Area'),
(7, 45, 'lozola', 'Bacolod', 'Secure and awesome', 1, '2025-10-11 07:32:12', 10.69170000, 122.97460000, 'pending', '2025-10-16 09:47:11', 'dorm_68ea07fc77de4.jpg', 'Wifi, Aircon, Study Room, Kitchen,'),
(8, 17, 'The Greenfield Residences', 'Burgos Avenue, Brgy. Villamonte, Bacolod City', 'Modern dormitory offering a quiet study-friendly environment with 24/7 access.', 0, '2025-10-14 05:01:20', 10.69170000, 122.97460000, 'pending', '2025-10-16 09:47:11', 'dorm_68edd92060847.jpg', 'Private Bathroom, Common Kitchen, Wi-Fi, Parking Space, Visitor Lobby'),
(9, 18, 'Casa de Felisa Dorm', 'Brgy. Mandalagan, Bacolod City', 'Home-like atmosphere with spacious rooms ideal for long-term student boarders.', 0, '2025-10-14 05:57:42', 10.69170000, 122.97460000, 'pending', '2025-10-16 09:47:11', 'dorm_68ede65686ffa.jpg', 'Air Conditioning, Free Water, Shared Kitchen, CCTV, Common Area'),
(10, 19, 'DormHub Bacolod', '17th Lacson Street, near Robinsons Place, Bacolod City', 'A digitalized dorm for tech-savvy students with app-based access and smart utilities.', 0, '2025-10-14 06:04:13', 10.69170000, 122.97460000, 'pending', '2025-10-16 09:47:11', 'dorm_68ede7dd98ba7.jpg', 'Smart Lock, Wi-Fi 6, Study Cubicles, Rooftop Area, 24/7 Security'),
(11, 20, 'La Salle Courtyard Residence', 'Narra Avenue, near University of St. La Salle, Bacolod City', 'Premium dorm for USLS students offering comfort and convenience within walking distance to campus.', 0, '2025-10-14 06:13:05', 10.69170000, 122.97460000, 'pending', '2025-10-16 09:47:11', 'dorm_68ede9f182e68.jpg', 'Wi-Fi, Study Hall, Air-Conditioned Rooms, Mini Café, Biometric Entry'),
(12, 21, 'SunnyStay Dormitory', '8th Street, Brgy. Taculing, Bacolod City', 'Bright and airy dorm designed for female students, close to jeepney routes and eateries.', 0, '2025-10-14 06:18:12', 10.69170000, 122.97460000, 'pending', '2025-10-16 09:47:11', 'dorm_68edeb244bf96.jpg', 'Wi-Fi, Laundry Service, CCTV, Study Desks, Shared Kitchen'),
(13, 22, 'St. Claire Student Inn', '15th Street, near USLS Gate 2, Bacolod City', 'Safe and budget-friendly dorm ideal for first-year college students.', 0, '2025-10-14 06:23:43', 10.69170000, 122.97460000, 'pending', '2025-10-16 09:47:11', 'dorm_68edec6f6a5e3.jpg', '24/7 Security, Free Drinking Water, Wi-Fi, Common Lounge, Refrigerator'),
(14, 55, 'Good Runners', 'MXG5+V9J, Bacolod, Negros Occidental, Philippines', 'A house of Good people', 1, '2025-10-16 12:55:55', 10.67767337, 122.95872856, 'pending', '2025-10-16 13:00:13', NULL, 'wifi, Shared kitchen, parking, aircon'),
(15, 55, 'Bad Runners', 'MXH3+H7W, Bacolod, Negros Occidental, Philippines', 'a house of bad runners', 0, '2025-10-16 12:56:40', 10.67904694, 122.95319986, 'pending', '2025-10-16 13:00:31', NULL, 'wifi, aircon');

-- --------------------------------------------------------

--
-- Table structure for table `dorm_images`
--

CREATE TABLE `dorm_images` (
  `id` int(11) NOT NULL,
  `dorm_id` int(11) NOT NULL,
  `image_path` varchar(255) NOT NULL COMMENT 'Path to image file',
  `is_cover` tinyint(1) DEFAULT 0 COMMENT 'Is this the cover/featured image',
  `display_order` int(11) DEFAULT 0 COMMENT 'Order for displaying images',
  `caption` varchar(255) DEFAULT NULL COMMENT 'Optional image caption',
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Multiple images for each dormitory';

--
-- Dumping data for table `dorm_images`
--

INSERT INTO `dorm_images` (`id`, `dorm_id`, `image_path`, `is_cover`, `display_order`, `caption`, `uploaded_at`) VALUES
(1, 5, 'dorm_68e469b41e437.png', 1, 0, NULL, '2025-10-17 17:35:13'),
(2, 6, 'dorm_68e93b36b97a4.png', 1, 0, NULL, '2025-10-17 17:35:13'),
(3, 7, 'dorm_68ea07fc77de4.jpg', 1, 0, NULL, '2025-10-17 17:35:13'),
(4, 8, 'dorm_68edd92060847.jpg', 1, 0, NULL, '2025-10-17 17:35:13'),
(5, 9, 'dorm_68ede65686ffa.jpg', 1, 0, NULL, '2025-10-17 17:35:13'),
(6, 10, 'dorm_68ede7dd98ba7.jpg', 1, 0, NULL, '2025-10-17 17:35:13'),
(7, 11, 'dorm_68ede9f182e68.jpg', 1, 0, NULL, '2025-10-17 17:35:13'),
(8, 12, 'dorm_68edeb244bf96.jpg', 1, 0, NULL, '2025-10-17 17:35:13'),
(9, 13, 'dorm_68edec6f6a5e3.jpg', 1, 0, NULL, '2025-10-17 17:35:13');

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `message_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `dorm_id` int(11) DEFAULT NULL,
  `booking_id` int(11) DEFAULT NULL,
  `body` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `read_at` datetime DEFAULT NULL,
  `urgency` enum('low','normal','high') DEFAULT 'normal',
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`message_id`, `sender_id`, `receiver_id`, `dorm_id`, `booking_id`, `body`, `created_at`, `read_at`, `urgency`, `updated_at`, `deleted_at`) VALUES
(1, 2, 3, 1, NULL, 'Hello, Good Morning!', '2025-09-11 09:33:18', '2025-09-15 00:41:27', 'normal', NULL, NULL),
(2, 3, 2, 1, NULL, 'How may I help you?', '2025-09-15 00:41:42', '2025-09-17 08:06:40', 'normal', NULL, NULL),
(3, 3, 2, 1, NULL, 'Hello!', '2025-09-17 08:06:19', '2025-09-17 08:06:40', 'normal', NULL, NULL),
(4, 3, 2, 1, NULL, ':>', '2025-09-17 10:25:19', '2025-10-04 16:53:26', 'normal', NULL, NULL),
(5, 3, 2, 1, NULL, 'monsieur', '2025-09-20 23:35:18', '2025-10-04 16:53:26', 'normal', NULL, NULL),
(6, 15, 30, 6, NULL, 'Hi your downpayment is due', '2025-10-10 10:24:03', '2025-10-16 05:34:16', 'normal', NULL, NULL),
(7, 45, 11, 7, NULL, 'hi', '2025-10-11 02:45:07', '2025-10-11 02:46:01', 'normal', NULL, NULL),
(8, 45, 11, 7, NULL, 'hi', '2025-10-11 02:46:05', '2025-10-11 02:46:07', 'normal', NULL, NULL),
(9, 45, 11, 7, NULL, 'hi', '2025-10-11 02:46:38', '2025-10-11 02:46:40', 'normal', NULL, NULL),
(10, 11, 45, 7, NULL, 'hello sir', '2025-10-11 02:46:48', '2025-10-11 02:46:51', 'normal', NULL, NULL),
(11, 45, 11, 7, NULL, 'yo', '2025-10-11 02:47:06', '2025-10-11 02:47:06', 'normal', NULL, NULL),
(12, 11, 45, 7, NULL, 'hello sir', '2025-10-11 02:47:31', NULL, 'normal', NULL, NULL),
(13, 30, 15, 6, NULL, 'Tha k you for reminding!', '2025-10-16 05:38:23', '2025-10-16 05:39:23', 'normal', NULL, NULL),
(14, 15, 30, 6, NULL, 'hello :)', '2025-10-16 05:44:06', '2025-10-16 05:44:09', 'normal', NULL, NULL),
(15, 30, 15, 6, NULL, 'Hi how much is 1 room', '2025-10-16 05:44:27', '2025-10-16 05:44:30', 'normal', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `payment_id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `payment_type` enum('downpayment','monthly','utility','deposit','other') DEFAULT 'monthly' COMMENT 'Type of payment: downpayment (initial), monthly (rent), utility (bills), deposit (security), other',
  `student_id` int(11) DEFAULT NULL,
  `owner_id` int(11) DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `status` enum('pending','submitted','processing','paid','verified','expired','rejected') DEFAULT 'pending' COMMENT 'pending=awaiting payment, submitted=receipt uploaded, processing=owner reviewing, paid=owner confirmed, verified=system verified, expired=past due, rejected=invalid receipt',
  `payment_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `due_date` date DEFAULT NULL,
  `receipt_image` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` datetime DEFAULT current_timestamp(),
  `reminder_sent` tinyint(1) DEFAULT 0,
  `verified_by` int(11) DEFAULT NULL COMMENT 'User ID who verified the payment',
  `verified_at` datetime DEFAULT NULL COMMENT 'When payment was verified',
  `rejection_reason` text DEFAULT NULL COMMENT 'Reason for rejection',
  `payment_method` enum('cash','bank_transfer','gcash','paymaya','other') DEFAULT 'bank_transfer' COMMENT 'Method used for payment',
  `reference_number` varchar(100) DEFAULT NULL COMMENT 'Transaction/Reference number'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`payment_id`, `booking_id`, `payment_type`, `student_id`, `owner_id`, `amount`, `status`, `payment_date`, `due_date`, `receipt_image`, `notes`, `updated_at`, `created_at`, `reminder_sent`, `verified_by`, `verified_at`, `rejection_reason`, `payment_method`, `reference_number`) VALUES
(10, 26, 'monthly', 31, NULL, 4000.00, 'paid', '2025-10-12 19:26:56', '2025-10-12', 'receipt_10_1760300247.png', NULL, '2025-10-12 13:36:33', '2025-10-12 12:26:56', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(12, 11, 'monthly', 11, NULL, 4000.00, '', '2025-10-13 17:42:00', '2025-10-11', NULL, NULL, '2025-10-13 16:46:57', '2025-10-13 10:42:00', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(13, 26, 'monthly', 31, 15, 2000.00, '', '2025-10-14 02:03:52', '2025-10-14', NULL, NULL, '2025-10-16 00:00:04', '2025-10-13 19:03:52', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(14, 30, 'monthly', 30, NULL, 1000.00, 'paid', '2025-10-15 02:05:29', '2025-10-15', 'receipt_14_1760495172.jpg', NULL, '2025-10-14 19:27:31', '2025-10-14 19:05:29', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(15, 31, 'monthly', 30, NULL, 1500.00, '', '2025-10-15 02:59:32', '2025-10-15', NULL, NULL, '2025-10-16 06:57:29', '2025-10-14 19:59:32', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(16, 34, 'monthly', 30, 55, 3000.00, 'paid', '2025-10-16 14:25:24', '2025-10-23', 'receipt_16_1760623714.jpg', NULL, '2025-10-16 07:25:24', '2025-10-16 07:07:19', 0, NULL, NULL, NULL, 'bank_transfer', NULL);

--
-- Triggers `payments`
--
DELIMITER $$
CREATE TRIGGER `update_tenant_paid_on_payment` AFTER UPDATE ON `payments` FOR EACH ROW BEGIN
  IF NEW.status IN ('paid', 'verified') AND OLD.status != NEW.status THEN
    UPDATE tenants t
    SET total_paid = (
      SELECT COALESCE(SUM(p.amount), 0)
      FROM payments p
      WHERE p.booking_id = t.booking_id
        AND p.status IN ('paid', 'verified')
    )
    WHERE t.booking_id = NEW.booking_id;
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `payment_schedules`
--

CREATE TABLE `payment_schedules` (
  `schedule_id` int(11) NOT NULL,
  `tenant_id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `payment_type` enum('monthly','utility','other') DEFAULT 'monthly',
  `amount` decimal(10,2) NOT NULL,
  `due_date` date NOT NULL,
  `status` enum('pending','paid','overdue','waived') DEFAULT 'pending',
  `payment_id` int(11) DEFAULT NULL COMMENT 'Link to actual payment when paid',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Scheduled payments for tenants';

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `review_id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `dorm_id` int(11) NOT NULL,
  `rating` tinyint(4) NOT NULL CHECK (`rating` between 1 and 5),
  `comment` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `status` enum('pending','approved','rejected') DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rooms`
--

CREATE TABLE `rooms` (
  `room_id` int(11) NOT NULL,
  `dorm_id` int(11) NOT NULL,
  `room_type` varchar(100) NOT NULL,
  `capacity` int(11) NOT NULL,
  `size` varchar(50) DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `status` enum('vacant','occupied') NOT NULL DEFAULT 'vacant',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `room_number` varchar(50) DEFAULT NULL,
  `features` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `rooms`
--

INSERT INTO `rooms` (`room_id`, `dorm_id`, `room_type`, `capacity`, `size`, `price`, `status`, `created_at`, `room_number`, `features`) VALUES
(12, 4, 'Single', 1, NULL, 1500.00, 'vacant', '2025-10-06 12:22:38', NULL, NULL),
(14, 1, 'Single', 1, NULL, 2000.00, 'vacant', '2025-10-06 12:28:00', NULL, NULL),
(15, 1, 'Double', 2, NULL, 3000.00, 'vacant', '2025-10-06 12:28:12', NULL, NULL),
(17, 4, 'Twin', 2, NULL, 3000.00, 'vacant', '2025-10-06 12:30:42', NULL, NULL),
(18, 3, 'Twin', 2, NULL, 2000.00, 'vacant', '2025-10-06 12:31:08', NULL, NULL),
(19, 3, 'Double', 2, NULL, 3000.00, 'vacant', '2025-10-06 12:31:22', NULL, NULL),
(20, 3, 'Suite', 4, NULL, 8000.00, 'vacant', '2025-10-06 12:31:41', NULL, NULL),
(21, 1, 'Twin', 2, NULL, 4000.00, 'vacant', '2025-10-06 12:32:23', NULL, NULL),
(22, 5, 'Twin', 2, NULL, 4000.00, 'vacant', '2025-10-07 02:10:43', NULL, NULL),
(26, 7, 'twin', 2, NULL, 2000.00, 'vacant', '2025-10-11 09:42:05', NULL, NULL),
(27, 7, 'twin', 2, '', 3000.00, 'vacant', '2025-10-12 13:42:13', NULL, NULL),
(28, 6, 'Single', 6, NULL, 4000.00, 'vacant', '2025-10-12 15:14:11', NULL, NULL),
(29, 5, 'Single', 1, '', 1500.00, 'occupied', '2025-10-12 20:46:23', NULL, NULL),
(30, 5, 'Twin', 2, '27.5', 5000.00, 'vacant', '2025-10-13 02:37:03', NULL, NULL),
(31, 8, 'Suite', 3, '31', 18000.00, 'vacant', '2025-10-14 05:34:08', NULL, NULL),
(32, 8, 'Twin', 2, '23', 21600.00, 'vacant', '2025-10-14 05:41:18', NULL, NULL),
(33, 8, 'Single', 1, '10', 700.00, 'vacant', '2025-10-14 05:44:57', NULL, NULL),
(34, 9, 'Single', 1, '10.2', 6800.00, 'vacant', '2025-10-14 05:59:56', NULL, NULL),
(35, 9, 'Single', 1, '10.2', 6800.00, 'vacant', '2025-10-14 06:01:17', NULL, NULL),
(36, 9, 'Single', 1, '10.2', 6800.00, 'vacant', '2025-10-14 06:01:42', NULL, NULL),
(37, 10, 'Suite', 4, '36', 22000.00, 'vacant', '2025-10-14 06:05:43', NULL, NULL),
(38, 10, 'Group Room', 6, '20', 9500.00, 'vacant', '2025-10-14 06:09:53', NULL, NULL),
(39, 11, 'Single', 1, '11.1', 7000.00, 'vacant', '2025-10-14 06:13:35', NULL, NULL),
(40, 11, 'Single', 1, '11.1', 7000.00, 'vacant', '2025-10-14 06:13:56', NULL, NULL),
(41, 11, 'Single', 1, '11.1', 7000.00, 'vacant', '2025-10-14 06:14:16', NULL, NULL),
(42, 11, 'Suite', 2, '29', 15000.00, 'vacant', '2025-10-14 06:14:52', NULL, NULL),
(43, 12, 'Twin', 2, '23', 10600.00, 'vacant', '2025-10-14 06:21:00', NULL, NULL),
(44, 13, 'Single', 1, '8.7', 5800.00, 'vacant', '2025-10-14 06:25:03', NULL, NULL),
(45, 13, 'Quad Room', 4, '15', 8000.00, 'vacant', '2025-10-14 06:26:16', NULL, NULL),
(46, 6, 'Double', 2, NULL, 1000.00, 'vacant', '2025-10-14 21:57:13', NULL, NULL),
(47, 6, 'Single', 1, NULL, 200.00, 'vacant', '2025-10-16 09:04:30', NULL, NULL),
(49, 14, 'Single', 1, NULL, 3000.00, 'occupied', '2025-10-16 12:57:04', NULL, NULL),
(50, 14, 'Double', 2, NULL, 6000.00, 'vacant', '2025-10-16 12:57:17', NULL, NULL),
(51, 14, 'Twin', 4, NULL, 7000.00, 'vacant', '2025-10-16 12:57:31', NULL, NULL),
(52, 14, 'Suite', 6, NULL, 20000.00, 'vacant', '2025-10-16 12:57:48', NULL, NULL),
(53, 15, 'Suite', 10, NULL, 30000.00, 'vacant', '2025-10-16 12:58:12', NULL, NULL),
(54, 15, 'Single', 1, NULL, 1000.00, 'vacant', '2025-10-16 12:58:31', NULL, NULL),
(55, 15, 'Double', 2, NULL, 2000.00, 'vacant', '2025-10-16 12:58:43', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `room_images`
--

CREATE TABLE `room_images` (
  `id` int(11) NOT NULL,
  `room_id` int(11) NOT NULL,
  `image_path` varchar(255) NOT NULL,
  `uploaded_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `room_images`
--

INSERT INTO `room_images` (`id`, `room_id`, `image_path`, `uploaded_at`) VALUES
(1, 31, 'room_68ede0d0b7610.jpg', '2025-10-13 22:34:08'),
(2, 32, 'room_68ede27ee11bf.jpg', '2025-10-13 22:41:18'),
(3, 33, 'room_68ede35918775.jpg', '2025-10-13 22:44:57'),
(4, 33, 'room_68ede35919600.jpg', '2025-10-13 22:44:57'),
(5, 34, 'room_68ede6dc5d491.jpg', '2025-10-13 22:59:56'),
(6, 35, 'room_68ede72d2d612.jpg', '2025-10-13 23:01:17'),
(7, 36, 'room_68ede746d3af4.jpg', '2025-10-13 23:01:42'),
(8, 37, 'room_68ede837a2447.jpg', '2025-10-13 23:05:43'),
(9, 38, 'room_68ede931f0b77.jpg', '2025-10-13 23:09:53'),
(10, 39, 'room_68edea0fd945d.jpg', '2025-10-13 23:13:35'),
(11, 40, 'room_68edea242178b.jpg', '2025-10-13 23:13:56'),
(12, 41, 'room_68edea386a39b.jpg', '2025-10-13 23:14:16'),
(13, 42, 'room_68edea5c02a21.jpg', '2025-10-13 23:14:52'),
(14, 43, 'room_68edebcc2c04b.jpg', '2025-10-13 23:21:00'),
(15, 44, 'room_68edecbf44883.jpg', '2025-10-13 23:25:03'),
(16, 45, 'room_68eded084a3ea.jpg', '2025-10-13 23:26:16');

-- --------------------------------------------------------

--
-- Table structure for table `tenants`
--

CREATE TABLE `tenants` (
  `tenant_id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `dorm_id` int(11) NOT NULL,
  `room_id` int(11) NOT NULL,
  `status` enum('active','completed','terminated') DEFAULT 'active' COMMENT 'active=currently occupying, completed=tenancy ended normally, terminated=early termination',
  `check_in_date` datetime NOT NULL COMMENT 'Actual check-in date/time',
  `check_out_date` datetime DEFAULT NULL COMMENT 'Actual check-out date/time',
  `expected_checkout` date DEFAULT NULL COMMENT 'Expected end date from booking',
  `total_paid` decimal(10,2) DEFAULT 0.00 COMMENT 'Total amount paid during tenancy',
  `outstanding_balance` decimal(10,2) DEFAULT 0.00 COMMENT 'Remaining balance if any',
  `notes` text DEFAULT NULL COMMENT 'Additional notes about the tenancy',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Tracks current and past tenants for dormitories';

--
-- Dumping data for table `tenants`
--

INSERT INTO `tenants` (`tenant_id`, `booking_id`, `student_id`, `dorm_id`, `room_id`, `status`, `check_in_date`, `check_out_date`, `expected_checkout`, `total_paid`, `outstanding_balance`, `notes`, `created_at`, `updated_at`) VALUES
(1, 11, 11, 5, 22, 'active', '2025-10-11 12:00:00', NULL, '2026-04-11', 0.00, 0.00, NULL, '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(2, 26, 31, 6, 28, 'active', '2025-10-12 12:00:00', NULL, '2026-04-12', 4000.00, 0.00, NULL, '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(3, 30, 30, 6, 46, 'active', '2025-10-15 12:00:00', NULL, '2026-04-13', 1000.00, 0.00, NULL, '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(4, 31, 30, 5, 29, 'active', '2025-10-15 12:00:00', NULL, '2026-04-13', 0.00, 0.00, NULL, '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(5, 34, 30, 14, 49, 'active', '2025-10-16 12:00:00', NULL, '2026-04-14', 3000.00, 0.00, NULL, '2025-10-17 17:35:13', '2025-10-17 17:35:13');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `email` varchar(150) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','owner','student') NOT NULL DEFAULT 'student',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `verified` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0 = Pending, 1 = Verified, -1 = Rejected',
  `phone` varchar(20) DEFAULT NULL,
  `license_no` varchar(100) DEFAULT NULL,
  `profile_pic` varchar(255) DEFAULT NULL,
  `id_document` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `name`, `address`, `email`, `password`, `role`, `created_at`, `verified`, `phone`, `license_no`, `profile_pic`, `id_document`) VALUES
(1, 'Angelo', NULL, 'angelo@gmail.com', '$2y$10$Y00iHBW6kmvSo1UR..5DD.H5N/Ly6tWWfaoUjk60tJTL2.L24331i', 'admin', '2025-08-20 14:23:12', 0, NULL, NULL, NULL, NULL),
(2, 'Sunday', NULL, 'sunday@gmail.com', '$2y$10$tpaHDGCq37RKImP2vRHT..fnYYaZMABCsR/rjxlemydDbVQyDdmm6', 'student', '2025-08-22 02:00:09', 0, NULL, NULL, NULL, NULL),
(3, 'Oswald', NULL, 'oswald@gmail.com', '$2y$10$00XC6x0bMQP4FhEnfzUOyu0TDrph7lT3WNQobhd6snuB4124V8xD6', 'owner', '2025-08-22 02:01:40', 1, NULL, NULL, NULL, NULL),
(4, 'Jake', NULL, 'jake@gmail.com', '$2y$10$cem8jAW8IFcNJB2C6OuO9.svVgFWGjyIW1.2pVVlr3OLk2wN4RwJm', 'owner', '2025-08-22 02:24:47', -1, NULL, NULL, NULL, NULL),
(5, 'Kevin', NULL, 'kevin@gmail.com', '$2y$10$syH7gbYI2bjiUddci.vT5elIRRo6vK4jWxOkrfMmUeXkZ0T6WHY66', 'owner', '2025-08-22 02:25:03', 1, NULL, NULL, NULL, NULL),
(6, 'John', NULL, 'John1@email.com', '$2y$10$3IuLCGJqUHewUzkM9vsooeLfIOixonJMHwp4yaVfZ/Sk54UocxK.e', 'student', '2025-10-06 00:09:18', 0, NULL, NULL, NULL, NULL),
(7, 'Eric Sanchez', NULL, 'eric@gmail.com', '$2y$10$ocy/p71iP5sQs/gu/rLtg.RMbTTqmbPAoqF7QwCEa60TmpcLGRNAS', 'student', '2025-10-07 00:25:42', 0, '09457318765', NULL, NULL, NULL),
(8, 'Bernard Diaz', NULL, 'diaz@gmail.com', '$2y$10$IJBgszxpooObYB00hNYpy.Xqxk9B2izHgtcAq4OdwTXYdPMULg0w6', 'owner', '2025-10-07 01:02:57', 1, '09768523456', NULL, NULL, NULL),
(9, 'john florence', NULL, 'johnflorence@gmail.com', '$2y$10$ccMPd5e/6n..KfWt5bi7O.GnTOcVjcK4vkwhmhQoPMe/auuih5mQW', 'student', '2025-10-07 02:37:48', 0, '09456526238', NULL, NULL, NULL),
(10, 'Stefan Jhonn D Delgado', NULL, 's2120062@gmail.com', '$2y$10$sdMfhva4sWkbVvGxsk3dfe4SLyexM/ywEa4yH1Lz0Is4G17nHeor2', 'student', '2025-10-08 10:57:44', 0, '09391762834', NULL, NULL, NULL),
(11, 'Jamie Fowler', NULL, 'jamie@email.com', '$2y$10$PeR6Bsig96tWdf/tJ423ouak.7COQYuZV20eyHTCVaxvsA60ZrDzK', 'student', '2025-10-08 11:18:56', 0, '09876453254', NULL, NULL, NULL),
(13, 'Juan Dela Cruz', NULL, 'juan.delacruz@example.net', '$2y$10$McI.t4f1cXSlOJTymIGpD.TzUKQyBcfDn.XeAUPsyHfOXBpyPFAnC', 'owner', '2025-10-09 03:46:39', 1, '09175551234', NULL, NULL, NULL),
(14, 'Maria Santos', NULL, 'maria_s@example.com', '$2y$10$MqUwT6gHoIoddSxafaOGMOf1Ayqk87R6BWTS7W4nvSEitqpT.hMpy', 'owner', '2025-10-09 03:47:16', -1, '09205555678', NULL, NULL, NULL),
(15, 'Anna Reyes', NULL, 'anna.reyes@email.com', '$2y$10$GcA1WBqEvjfPSMilhf6JAeayssvMMh2YjkQXs8jLupP2LC2rsToQG', 'owner', '2025-10-09 05:27:48', 1, '09123456789', NULL, NULL, NULL),
(16, 'Mark Dela Cruz', NULL, 'mark.dc@email.net', '$2y$10$/ooC1kx/Kjfu.mxgy.zrTOZEX9GfHlygte8AG.DS5FQWTBO3xtzny', 'student', '2025-10-09 05:28:04', 0, '09234567890', NULL, NULL, NULL),
(17, 'Julia Santos', NULL, 'julia.santos@email.org', '$2y$10$FzPRcx/dy1pX9oYi5iHm1usHELxZ6ENicqrrJ42Q1lS7xIcl73PWu', 'owner', '2025-10-09 05:28:22', -1, '09345678901', NULL, NULL, NULL),
(18, 'Leo Gutierrez', '', 'leo.g@email.com', '$2y$10$FIMS9XX/o8/o30PF8KuiUOB9Lp2JE06cNR9BcPowbp9z22dtuXvk6', 'owner', '2025-10-09 05:28:40', 0, '09456789012', '', NULL, NULL),
(19, 'Mia Navarro', NULL, 'mia.n@email.net', '$2y$10$yk6AyX7psnoKa7hqXoPsseBuXxviTJdRvt7x2UrHPh5MbQBLT6jEO', 'owner', '2025-10-09 05:29:00', 1, '09567890123', NULL, NULL, NULL),
(20, 'Carlo Ramos', NULL, 'carlo.r@email.com', '$2y$10$P9Ee1v7KFY11BhU8PeUcuOpOzzjXHU0dW2Y8KGiQBXrVFpRKjKD4O', 'owner', '2025-10-09 05:32:52', -1, '09678901234', NULL, NULL, NULL),
(21, 'Denise Lopez', NULL, 'denise.lopez@email.org', '$2y$10$gn0Dfqv3gfy6hEywgDYQ0eVaZbqsj3cHWRE6ztc9ljEHupnQh04MO', 'owner', '2025-10-09 05:33:18', 0, '09789012345', NULL, NULL, NULL),
(22, 'Paolo Mendoza', NULL, 'paolo.m@email.com', '$2y$10$d3Kn85uc47zyMhxMHgzjiujAeCc1kfxqL0E3swAfsGgxC6dOKn7bO', 'owner', '2025-10-09 05:33:36', 0, '09890123456', NULL, NULL, NULL),
(23, 'Tricia Lim', NULL, 'tricia.l@email.net', '$2y$10$mI5rc3iaT8vBwKSv2Oervuj/gEB4nJWx4UVrYJk7d70HBWijjXhIu', 'owner', '2025-10-09 05:33:57', 0, '09901234567', NULL, NULL, NULL),
(24, 'Nathan Torres', NULL, 'nathan.t@email.org', '$2y$10$xmxxBLX/z.xld0SqF1hseeL6MSzKd1YfU9G7sTnhdtMSr3JAOa/F6', 'owner', '2025-10-09 05:34:14', 0, '09012345678', NULL, NULL, NULL),
(25, 'Sophia Cruz', NULL, 'sophia.cruz@email.com', '$2y$10$DtX5fhDP11RqbzJ7GHrGWeig1aOa5HiiALzMZo6lyl.6ToAHI9K0W', 'owner', '2025-10-09 05:38:10', 0, '09111222333', NULL, NULL, NULL),
(26, 'Kevin Santos', NULL, 'kevin.s@email.net', '$2y$10$KqkBT93tWbWxJ3flK4WY/ei7bnqi/TJ4DPpC9bvcXixS/RChRZ0Bq', 'owner', '2025-10-09 05:38:29', 0, '09222333444', NULL, NULL, NULL),
(27, 'Bianca Reyes', NULL, 'bianca.r@email.org', '$2y$10$fbJdXt43OrMxBRwgG6x34.zqU7/FGApNsVOVE0obAAxKDdn6Z8DQ.', 'owner', '2025-10-09 05:38:46', 0, '09333444555', NULL, NULL, NULL),
(28, 'Andre Villanueva', NULL, 'andre.v@email.com', '$2y$10$6u7YU5sr2n1EcgLuP/xO0OTDdklR92o360KOPAR6HDzYFML5OCQWm', 'owner', '2025-10-09 05:39:02', 0, '09444555666', NULL, NULL, NULL),
(29, 'Lara Jimenez', NULL, 'lara.j@email.net', '$2y$10$iWOZpw0rmcyjaQda8.xyTe5yCwy75Tjk36jJDR2O8KFborZ.5hV9C', 'owner', '2025-10-09 05:39:18', 0, '09555666777', NULL, NULL, NULL),
(30, 'Ethan Castillo', NULL, 'ethan.castillo@email.com', '$2y$10$JAERYBGf7naHaqTRbNibr.eOxUHaEUWXpcJ764P58iJDf.zeCQXgG', 'student', '2025-10-09 05:43:34', 0, '09178881234', NULL, NULL, NULL),
(31, 'Chloe Manalo', NULL, 'chloe.manalo@email.net', '$2y$10$GXeT6p2ixFMUHuWM61T5ZOKaj5XT766fknFfXz3wMK/eSCftH0is2', 'student', '2025-10-09 05:43:49', 0, '09269992345', NULL, NULL, NULL),
(32, 'Lucas Domingo', NULL, 'lucas.d@email.org', '$2y$10$P//DMtllMV8jiuljyHwX3OWj7Zl79f7mavqMeKH8QCIh.q6d9m5Yu', 'student', '2025-10-09 05:44:05', 0, '09354445678', NULL, NULL, NULL),
(33, 'Isabelle Ramos', NULL, 'isabelle.r@email.com', '$2y$10$J115SGT9HufMWBE1Y3n6e.Dc0i5tMcfbbBzQGl.9G5EUOUNnwMYaO', 'student', '2025-10-09 05:44:19', 0, '09443336789', NULL, NULL, NULL),
(34, 'Elijah Bautista', NULL, 'elijah.b@email.net', '$2y$10$XGvCcUbrjvTFYaiMfBCOyOrPtlQkBH/TQiFtYMBbH5Oygexs6BHTW', 'student', '2025-10-09 05:44:34', 0, '09562227890', NULL, NULL, NULL),
(35, 'Hannah Fajardo', NULL, 'hannah.f@email.org', '$2y$10$udp5FON04E/NLjeQE5IaguUlTf1RD160WmOZG/loW5dt6IBbOtsDq', 'student', '2025-10-09 05:44:47', 0, '09671118901', NULL, NULL, NULL),
(36, 'Aiden Vergara', NULL, 'aiden.v@email.com', '$2y$10$AGSyOxmP1.XfduxwkQEiLOwa2OaGM1WF2jS/vODoU2lMaZJydyLiq', 'student', '2025-10-09 05:45:02', 0, '09780009012', NULL, NULL, NULL),
(37, 'Sofia Alvarez', NULL, 'sofia.alvarez@email.net', '$2y$10$aaxKJkSpku1R./7usnKoXe2GbmYQPu6jEm8aZT647uemplDLlR9ui', 'student', '2025-10-09 05:45:18', 0, '09891110123', NULL, NULL, NULL),
(38, 'Liam Santiago', NULL, 'liam.s@email.org', '$2y$10$jZKIRo1RFDZBLaYpc6rGX./G/wdK98kNRNuzaTqZeoPH9MgL47WhS', 'student', '2025-10-09 05:45:33', 0, '09908881234', NULL, NULL, NULL),
(39, 'Camille De Guzman', NULL, 'camille.dg@email.com', '$2y$10$k9hFiH8MckLgTfdrdd0PR.fcfrSTX8usFkvsaJkhfgbUXSYAsaPlu', 'student', '2025-10-09 05:45:48', 0, '09097772345', NULL, NULL, NULL),
(40, 'Jacob Morales', NULL, 'jacob.m@email.net', '$2y$10$XEXczDpQin44KINOdLusXu./g07ngmQ.2NuP3fkDFO.BSF5nY/I3m', 'student', '2025-10-09 05:46:02', 0, '09186663456', NULL, NULL, NULL),
(41, 'Alexa Cruz', NULL, 'alexa.cruz@email.org', '$2y$10$wujbhtrucaToLd0Ah3Bc.OwH8NrEF1ntwusp2s/TRhzchPKKZNA/K', 'student', '2025-10-09 05:46:17', 0, '09275554567', NULL, NULL, NULL),
(42, 'Noah Enriquez', NULL, 'noah.enriquez@email.com', '$2y$10$9faaKs6k8o8CRsXMXIfXQ.mhyMCQFcEVC8BVhZ3Trj1Yl4PaO4GNe', 'student', '2025-10-09 05:46:29', 0, '09364445678', NULL, NULL, NULL),
(43, 'Kylie Delos Reyes', NULL, 'kylie.dr@email.net', '$2y$10$3V/hQoA5bynyYG2Clw3C9OFvdN7g2ZrMkSel3.WfFjch/waJ96HIy', 'student', '2025-10-09 05:46:40', 0, '09453336789', NULL, NULL, NULL),
(44, 'Nathaniel Reyes', NULL, 'nathaniel.r@email.org', '$2y$10$ulSD9yuBVnVqUuhyKaHqs.Rg/B0GfhK2RVNkWOHZS2Y7SbmnxHMNC', 'student', '2025-10-09 05:46:56', 0, '09542227890', NULL, NULL, NULL),
(45, 'Fall Gomes', NULL, 'jpsgomes0212@gmail.com', '$2y$10$GULRRafuNafHQb0JFZmFAucbpqolQI0Xnl6Tcc8SxaHL/HLvccyJC', 'owner', '2025-10-11 07:22:53', 0, '09453196127', NULL, NULL, NULL),
(46, 'Jan Pol Gomes', NULL, 'janpolgomes@gmal.com', '$2y$10$xiaLSF0v9z3UGK5d7eS1A.SXWfHtie6PaM/r1jm.uT2NUCE5rQLpS', 'student', '2025-10-11 10:05:13', 0, '09453196129', NULL, NULL, NULL),
(47, 'Jan Pol Gomes', NULL, 'janpol@gmail.com', '$2y$10$OZp52j10PNJnJFs.yZGlYua5JWxTES1BJmrG.k/yrNz1S6xBrcqPC', 'student', '2025-10-11 10:06:43', 0, '09453196127', NULL, NULL, NULL),
(48, 'Jhanna Gracey Villan', NULL, 'jhanna@gmail.com', '$2y$10$55XADUHThWKpFwwYe09bReyYZKmiJY65e4XxNS4o4u1G1E7Ir8cv6', 'student', '2025-10-13 23:48:11', 0, '09019203817', NULL, NULL, NULL),
(49, 'James Ham', NULL, 'jamesham@email.com', '$2y$10$ti5K7WBkOm6MdSmIRgsZe.bR0FiMeBK3c4rpo6ZsZpXkYp.HYYyoy', 'student', '2025-10-14 00:05:07', 0, '09764537234', NULL, NULL, NULL),
(50, 'John Garcia', NULL, 'garcia@email.com', '$2y$10$G7Xl.SKODvwTi4VkbLyCDebskx2gPw8vQNOFYgrcN63VtrGN.Fw/y', 'student', '2025-10-14 04:41:58', 0, '09874356273', NULL, NULL, NULL),
(51, 'Azer Jan', NULL, 's2201387@usls.edu.ph', '$2y$10$SiBkIaJFN47lVorRVgcuieCWEvqIWRxsleYfijCAgM7zmEjNAvXgW', 'student', '2025-10-16 08:07:35', 0, '09100010101', NULL, NULL, NULL),
(52, 'Leanne Gumban', NULL, 's2016022@usls.edu.ph', '$2y$10$647ogLFwqRcFXj.CW5bamOPe532Fyf..acMIFee0pfTvqFrh7QbtG', 'student', '2025-10-16 08:10:21', 0, '09062643027', NULL, NULL, NULL),
(53, 'Kirby Calampinay', NULL, 's24321', '$2y$10$RSd/YTyn4SR4qQX415iaGe/0Vsx03p7ZTXxyScPJONm4LetMKWbw6', 'student', '2025-10-16 11:10:10', 0, NULL, NULL, NULL, NULL),
(54, 'Sam Smith', NULL, 'jr74084@gmail.com', '$2y$10$ozLCeg6b8ydv0g7Ucqi8Ne8f1pAoN3pRAviaHDXqDTWE8pA14yU9S', 'student', '2025-10-16 11:12:48', 0, NULL, NULL, NULL, NULL),
(55, 'Joshua Campo', NULL, 'campo.j@email.com', '$2y$10$5uGpdOBtHGvrguJIAaTF7.3qQji78PxXRI1L0YRg5LebEj0XbYvtS', 'owner', '2025-10-16 12:53:18', 0, NULL, NULL, NULL, NULL),
(56, 'Mikey Segovia', NULL, 'anonsfwend19@gmail.com', '$2y$10$34qAUcRgeCD8Y.3hhCV8buRCCmkj18v35duoCQaoVM0uJYXmY7MQy', 'student', '2025-10-16 15:53:48', 0, NULL, NULL, NULL, NULL),
(57, 'Brad Ed Sale', NULL, 'brod@gmail.com', '$2y$10$2Y868faqd.GMPl9pFNr3ZOnEyOzmExmHkvaLjuNV4/wJKjJXcrNfC', 'student', '2025-10-16 15:58:36', 0, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_preferences`
--

CREATE TABLE `user_preferences` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `notification_email` tinyint(1) DEFAULT 1 COMMENT 'Receive email notifications',
  `notification_sms` tinyint(1) DEFAULT 0 COMMENT 'Receive SMS notifications',
  `notification_push` tinyint(1) DEFAULT 1 COMMENT 'Receive push notifications',
  `notification_payment_reminder` tinyint(1) DEFAULT 1 COMMENT 'Payment reminders',
  `notification_booking_updates` tinyint(1) DEFAULT 1 COMMENT 'Booking status updates',
  `notification_messages` tinyint(1) DEFAULT 1 COMMENT 'New message alerts',
  `privacy_profile_visible` tinyint(1) DEFAULT 1 COMMENT 'Profile visible to others',
  `privacy_show_phone` tinyint(1) DEFAULT 1 COMMENT 'Show phone number',
  `language` varchar(10) DEFAULT 'en' COMMENT 'Preferred language',
  `timezone` varchar(50) DEFAULT 'Asia/Manila' COMMENT 'User timezone',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='User preferences and settings';

--
-- Dumping data for table `user_preferences`
--

INSERT INTO `user_preferences` (`id`, `user_id`, `notification_email`, `notification_sms`, `notification_push`, `notification_payment_reminder`, `notification_booking_updates`, `notification_messages`, `privacy_profile_visible`, `privacy_show_phone`, `language`, `timezone`, `created_at`, `updated_at`) VALUES
(1, 36, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(2, 41, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(3, 28, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(4, 1, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(5, 15, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(6, 56, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(7, 27, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(8, 57, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(9, 39, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(10, 55, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(11, 20, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(12, 31, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(13, 21, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(14, 8, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(15, 34, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(16, 7, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(17, 30, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(18, 50, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(19, 35, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(20, 33, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(21, 40, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(22, 4, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(23, 49, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(24, 11, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(25, 47, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(26, 46, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(27, 48, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(28, 6, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(29, 9, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(30, 45, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(31, 54, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(32, 13, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(33, 17, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(34, 26, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(35, 5, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(36, 43, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(37, 29, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(38, 18, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(39, 38, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(40, 32, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(41, 14, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(42, 16, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(43, 19, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(44, 24, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(45, 44, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(46, 42, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(47, 3, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(48, 22, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(49, 52, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(50, 10, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(51, 51, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(52, 53, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(53, 37, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(54, 25, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(55, 2, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(56, 23, 1, 0, 1, 1, 1, 1, 1, 1, 'en', 'Asia/Manila', '2025-10-17 17:35:13', '2025-10-17 17:35:13');

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_active_tenants`
-- (See below for the actual view)
--
CREATE TABLE `view_active_tenants` (
`tenant_id` int(11)
,`booking_id` int(11)
,`student_id` int(11)
,`student_name` varchar(100)
,`student_email` varchar(150)
,`student_phone` varchar(20)
,`dorm_id` int(11)
,`dorm_name` varchar(150)
,`dorm_address` varchar(255)
,`room_id` int(11)
,`room_type` varchar(100)
,`capacity` int(11)
,`room_price` decimal(10,2)
,`check_in_date` datetime
,`expected_checkout` date
,`days_remaining` int(8)
,`total_paid` decimal(10,2)
,`outstanding_balance` decimal(10,2)
,`booking_type` enum('whole','shared')
,`tenancy_start` timestamp
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_owner_stats`
-- (See below for the actual view)
--
CREATE TABLE `view_owner_stats` (
`owner_id` int(11)
,`total_dorms` bigint(21)
,`total_rooms` bigint(21)
,`active_tenants` bigint(21)
,`pending_bookings` bigint(21)
,`monthly_revenue` decimal(32,2)
,`pending_payments` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_tenant_payments`
-- (See below for the actual view)
--
CREATE TABLE `view_tenant_payments` (
`tenant_id` int(11)
,`student_id` int(11)
,`student_name` varchar(100)
,`dorm_id` int(11)
,`dorm_name` varchar(150)
,`room_id` int(11)
,`room_type` varchar(100)
,`total_payments` bigint(21)
,`total_paid` decimal(32,2)
,`pending_amount` decimal(32,2)
,`last_payment_date` timestamp
,`outstanding_balance` decimal(10,2)
);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `announcements`
--
ALTER TABLE `announcements`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `announcement_reads`
--
ALTER TABLE `announcement_reads`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_announcement` (`announcement_id`,`user_id`),
  ADD KEY `fk_user` (`user_id`);

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `room_id` (`room_id`),
  ADD KEY `student_id` (`student_id`),
  ADD KEY `idx_booking_reference` (`booking_reference`),
  ADD KEY `idx_check_in` (`check_in_date`),
  ADD KEY `idx_check_out` (`check_out_date`),
  ADD KEY `idx_status_dates` (`status`,`start_date`,`end_date`),
  ADD KEY `idx_student_status` (`student_id`,`status`),
  ADD KEY `idx_room_status` (`room_id`,`status`);

--
-- Indexes for table `dormitories`
--
ALTER TABLE `dormitories`
  ADD PRIMARY KEY (`dorm_id`),
  ADD KEY `owner_id` (`owner_id`),
  ADD KEY `idx_location` (`latitude`,`longitude`);

--
-- Indexes for table `dorm_images`
--
ALTER TABLE `dorm_images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_dorm` (`dorm_id`),
  ADD KEY `idx_cover` (`is_cover`),
  ADD KEY `idx_order` (`display_order`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `idx_thread` (`sender_id`,`receiver_id`,`dorm_id`),
  ADD KEY `idx_inbox` (`receiver_id`,`read_at`),
  ADD KEY `fk_msg_dorm` (`dorm_id`),
  ADD KEY `fk_msg_booking` (`booking_id`),
  ADD KEY `idx_conversation` (`sender_id`,`receiver_id`),
  ADD KEY `idx_unread` (`receiver_id`,`read_at`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `fk_payment_booking` (`booking_id`),
  ADD KEY `fk_payment_student` (`student_id`),
  ADD KEY `fk_payment_owner` (`owner_id`),
  ADD KEY `idx_payment_type` (`payment_type`),
  ADD KEY `idx_payment_method` (`payment_method`),
  ADD KEY `idx_verified_by` (`verified_by`),
  ADD KEY `idx_booking_status` (`booking_id`,`status`),
  ADD KEY `idx_student_status` (`student_id`,`status`),
  ADD KEY `idx_due_date` (`due_date`),
  ADD KEY `idx_payment_date` (`payment_date`);

--
-- Indexes for table `payment_schedules`
--
ALTER TABLE `payment_schedules`
  ADD PRIMARY KEY (`schedule_id`),
  ADD KEY `payment_id` (`payment_id`),
  ADD KEY `idx_tenant` (`tenant_id`),
  ADD KEY `idx_booking` (`booking_id`),
  ADD KEY `idx_due_date` (`due_date`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_overdue` (`status`,`due_date`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`review_id`),
  ADD KEY `fk_review_booking` (`booking_id`),
  ADD KEY `fk_review_student` (`student_id`),
  ADD KEY `fk_review_dorm` (`dorm_id`);

--
-- Indexes for table `rooms`
--
ALTER TABLE `rooms`
  ADD PRIMARY KEY (`room_id`),
  ADD KEY `dorm_id` (`dorm_id`);

--
-- Indexes for table `room_images`
--
ALTER TABLE `room_images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `room_id` (`room_id`);

--
-- Indexes for table `tenants`
--
ALTER TABLE `tenants`
  ADD PRIMARY KEY (`tenant_id`),
  ADD UNIQUE KEY `unique_active_booking` (`booking_id`,`status`),
  ADD KEY `idx_student` (`student_id`),
  ADD KEY `idx_dorm` (`dorm_id`),
  ADD KEY `idx_room` (`room_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_check_in` (`check_in_date`),
  ADD KEY `idx_check_out` (`check_out_date`),
  ADD KEY `idx_active_tenants` (`status`,`check_out_date`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `user_preferences`
--
ALTER TABLE `user_preferences`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_user` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `announcements`
--
ALTER TABLE `announcements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `announcement_reads`
--
ALTER TABLE `announcement_reads`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `booking_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `dormitories`
--
ALTER TABLE `dormitories`
  MODIFY `dorm_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `dorm_images`
--
ALTER TABLE `dorm_images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `payment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `payment_schedules`
--
ALTER TABLE `payment_schedules`
  MODIFY `schedule_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `review_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rooms`
--
ALTER TABLE `rooms`
  MODIFY `room_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT for table `room_images`
--
ALTER TABLE `room_images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `tenants`
--
ALTER TABLE `tenants`
  MODIFY `tenant_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT for table `user_preferences`
--
ALTER TABLE `user_preferences`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

-- --------------------------------------------------------

--
-- Structure for view `view_active_tenants`
--
DROP TABLE IF EXISTS `view_active_tenants`;

CREATE ALGORITHM=UNDEFINED DEFINER=`cpses_yyyl774o0t`@`localhost` SQL SECURITY DEFINER VIEW `view_active_tenants`  AS SELECT `t`.`tenant_id` AS `tenant_id`, `t`.`booking_id` AS `booking_id`, `t`.`student_id` AS `student_id`, `u`.`name` AS `student_name`, `u`.`email` AS `student_email`, `u`.`phone` AS `student_phone`, `t`.`dorm_id` AS `dorm_id`, `d`.`name` AS `dorm_name`, `d`.`address` AS `dorm_address`, `t`.`room_id` AS `room_id`, `r`.`room_type` AS `room_type`, `r`.`capacity` AS `capacity`, `r`.`price` AS `room_price`, `t`.`check_in_date` AS `check_in_date`, `t`.`expected_checkout` AS `expected_checkout`, to_days(`t`.`expected_checkout`) - to_days(curdate()) AS `days_remaining`, `t`.`total_paid` AS `total_paid`, `t`.`outstanding_balance` AS `outstanding_balance`, `b`.`booking_type` AS `booking_type`, `t`.`created_at` AS `tenancy_start` FROM ((((`tenants` `t` join `users` `u` on(`t`.`student_id` = `u`.`user_id`)) join `dormitories` `d` on(`t`.`dorm_id` = `d`.`dorm_id`)) join `rooms` `r` on(`t`.`room_id` = `r`.`room_id`)) join `bookings` `b` on(`t`.`booking_id` = `b`.`booking_id`)) WHERE `t`.`status` = 'active' ;

-- --------------------------------------------------------

--
-- Structure for view `view_owner_stats`
--
DROP TABLE IF EXISTS `view_owner_stats`;

CREATE ALGORITHM=UNDEFINED DEFINER=`cpses_yyyl774o0t`@`localhost` SQL SECURITY DEFINER VIEW `view_owner_stats`  AS SELECT `d`.`owner_id` AS `owner_id`, count(distinct `d`.`dorm_id`) AS `total_dorms`, count(distinct `r`.`room_id`) AS `total_rooms`, count(distinct case when `t`.`status` = 'active' then `t`.`tenant_id` end) AS `active_tenants`, count(distinct case when `b`.`status` = 'pending' then `b`.`booking_id` end) AS `pending_bookings`, coalesce(sum(case when `p`.`status` in ('paid','verified') and `p`.`payment_date` >= curdate() - interval 30 day then `p`.`amount` end),0) AS `monthly_revenue`, coalesce(sum(case when `p`.`status` in ('pending','submitted') then `p`.`amount` end),0) AS `pending_payments` FROM ((((`dormitories` `d` left join `rooms` `r` on(`d`.`dorm_id` = `r`.`dorm_id`)) left join `bookings` `b` on(`r`.`room_id` = `b`.`room_id`)) left join `tenants` `t` on(`b`.`booking_id` = `t`.`booking_id`)) left join `payments` `p` on(`b`.`booking_id` = `p`.`booking_id`)) GROUP BY `d`.`owner_id` ;

-- --------------------------------------------------------

--
-- Structure for view `view_tenant_payments`
--
DROP TABLE IF EXISTS `view_tenant_payments`;

CREATE ALGORITHM=UNDEFINED DEFINER=`cpses_yyyl774o0t`@`localhost` SQL SECURITY DEFINER VIEW `view_tenant_payments`  AS SELECT `t`.`tenant_id` AS `tenant_id`, `t`.`student_id` AS `student_id`, `u`.`name` AS `student_name`, `t`.`dorm_id` AS `dorm_id`, `d`.`name` AS `dorm_name`, `t`.`room_id` AS `room_id`, `r`.`room_type` AS `room_type`, count(`p`.`payment_id`) AS `total_payments`, coalesce(sum(case when `p`.`status` in ('paid','verified') then `p`.`amount` end),0) AS `total_paid`, coalesce(sum(case when `p`.`status` in ('pending','submitted') then `p`.`amount` end),0) AS `pending_amount`, max(`p`.`payment_date`) AS `last_payment_date`, `t`.`outstanding_balance` AS `outstanding_balance` FROM ((((`tenants` `t` join `users` `u` on(`t`.`student_id` = `u`.`user_id`)) join `dormitories` `d` on(`t`.`dorm_id` = `d`.`dorm_id`)) join `rooms` `r` on(`t`.`room_id` = `r`.`room_id`)) left join `payments` `p` on(`t`.`booking_id` = `p`.`booking_id`)) WHERE `t`.`status` = 'active' GROUP BY `t`.`tenant_id`, `t`.`student_id`, `u`.`name`, `t`.`dorm_id`, `d`.`name`, `t`.`room_id`, `r`.`room_type`, `t`.`outstanding_balance` ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `announcement_reads`
--
ALTER TABLE `announcement_reads`
  ADD CONSTRAINT `fk_announcement` FOREIGN KEY (`announcement_id`) REFERENCES `announcements` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `dormitories`
--
ALTER TABLE `dormitories`
  ADD CONSTRAINT `dormitories_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `dorm_images`
--
ALTER TABLE `dorm_images`
  ADD CONSTRAINT `dorm_images_ibfk_1` FOREIGN KEY (`dorm_id`) REFERENCES `dormitories` (`dorm_id`) ON DELETE CASCADE;

--
-- Constraints for table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `fk_msg_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_msg_dorm` FOREIGN KEY (`dorm_id`) REFERENCES `dormitories` (`dorm_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_msg_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_msg_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `fk_payment_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_payment_owner` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_payment_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_payment_verified_by` FOREIGN KEY (`verified_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE;

--
-- Constraints for table `payment_schedules`
--
ALTER TABLE `payment_schedules`
  ADD CONSTRAINT `payment_schedules_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`tenant_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `payment_schedules_ibfk_2` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `payment_schedules_ibfk_3` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`payment_id`) ON DELETE SET NULL;

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `fk_review_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_review_dorm` FOREIGN KEY (`dorm_id`) REFERENCES `dormitories` (`dorm_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_review_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `rooms`
--
ALTER TABLE `rooms`
  ADD CONSTRAINT `rooms_ibfk_1` FOREIGN KEY (`dorm_id`) REFERENCES `dormitories` (`dorm_id`) ON DELETE CASCADE;

--
-- Constraints for table `room_images`
--
ALTER TABLE `room_images`
  ADD CONSTRAINT `room_images_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE CASCADE;

--
-- Constraints for table `tenants`
--
ALTER TABLE `tenants`
  ADD CONSTRAINT `tenants_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tenants_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tenants_ibfk_3` FOREIGN KEY (`dorm_id`) REFERENCES `dormitories` (`dorm_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tenants_ibfk_4` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE CASCADE;

--
-- Constraints for table `user_preferences`
--
ALTER TABLE `user_preferences`
  ADD CONSTRAINT `user_preferences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
