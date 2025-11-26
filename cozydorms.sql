-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Nov 26, 2025 at 12:31 AM
-- Server version: 10.6.23-MariaDB-cll-lve
-- PHP Version: 8.3.27

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
(15, 1, 'New Owners', 'For new owners, please make sure that your documents are valid.', 'Pending Owners', 'Send Now', '2025-10-14 06:27:11', 'owners');

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

--
-- Dumping data for table `announcement_reads`
--

INSERT INTO `announcement_reads` (`id`, `announcement_id`, `user_id`, `read_at`) VALUES
(10, 15, 3, '2025-10-19 09:28:26'),
(11, 14, 3, '2025-10-19 09:28:27');

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
(30, 46, 30, 'shared', '2025-10-15', '2026-04-13', 'completed', '2025-10-25 04:20:21', '2025-10-15 02:04:23', '2025-10-15 04:04:23', NULL, NULL, NULL, NULL, NULL, NULL, 'BK00000030'),
(31, 29, 30, 'whole', '2025-10-15', '2026-04-13', 'active', '2025-10-17 10:35:13', '2025-10-15 02:58:05', '2025-10-15 04:58:05', NULL, NULL, NULL, NULL, NULL, NULL, 'BK00000031'),
(32, 28, 52, 'shared', '2025-10-16', '2026-04-16', 'pending', '2025-10-17 10:35:13', '2025-10-16 08:12:13', '2025-10-16 10:12:13', NULL, NULL, NULL, NULL, NULL, NULL, 'BK00000032'),
(33, 18, 30, 'shared', '2025-10-16', '2026-04-14', 'pending', '2025-10-17 10:35:13', '2025-10-16 12:10:34', '2025-10-16 14:10:34', NULL, NULL, NULL, NULL, NULL, NULL, 'BK00000033'),
(34, 49, 30, 'whole', '2025-10-16', '2026-04-14', 'active', '2025-10-17 10:35:13', '2025-10-16 13:01:18', '2025-10-16 15:01:18', NULL, NULL, NULL, NULL, NULL, NULL, 'BK00000034'),
(35, 59, 59, 'shared', '2025-10-19', '2026-04-17', 'approved', '2025-10-19 08:15:54', '2025-10-19 15:14:17', '2025-10-19 17:14:17', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(36, 63, 62, 'shared', '2025-10-20', '2026-04-18', 'approved', '2025-10-19 17:30:39', '2025-10-20 00:30:05', '2025-10-20 02:30:05', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(37, 62, 63, 'shared', '2025-10-20', '2026-04-18', 'approved', '2025-10-19 18:48:59', '2025-10-20 01:46:36', '2025-10-20 03:46:36', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(38, 64, 64, 'shared', '2025-10-20', '2026-04-18', 'approved', '2025-10-19 18:57:06', '2025-10-20 01:56:53', '2025-10-20 03:56:53', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(39, 66, 65, 'whole', '2025-10-20', '2026-04-18', 'approved', '2025-10-19 19:13:15', '2025-10-20 02:12:40', '2025-10-20 04:12:40', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(40, 65, 66, 'whole', '2025-10-20', '2026-04-18', 'approved', '2025-10-19 19:31:35', '2025-10-20 02:31:14', '2025-10-20 04:31:14', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(41, 63, 67, 'shared', '2025-10-20', '2026-04-18', 'approved', '2025-10-19 19:41:32', '2025-10-20 02:40:54', '2025-10-20 04:40:54', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(42, 62, 68, 'shared', '2025-10-20', '2026-04-18', 'approved', '2025-10-19 19:49:14', '2025-10-20 02:49:00', '2025-10-20 04:49:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(43, 64, 69, 'shared', '2025-10-20', '2026-04-18', 'approved', '2025-10-19 19:56:32', '2025-10-20 02:54:11', '2025-10-20 04:54:11', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(44, 67, 70, 'shared', '2025-10-20', '2026-04-18', 'approved', '2025-10-19 20:07:15', '2025-10-20 03:06:57', '2025-10-20 05:06:57', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(45, 65, 73, 'shared', '2025-10-22', '2026-04-18', 'approved', '2025-10-19 20:16:26', '2025-10-20 03:16:09', '2025-10-20 05:16:09', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(46, 66, 74, 'shared', '2025-10-20', '2026-04-21', 'approved', '2025-10-19 20:29:21', '2025-10-20 03:29:09', '2025-10-20 05:29:09', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(47, 68, 75, 'shared', '2025-10-20', '2026-04-18', 'approved', '2025-10-19 21:13:38', '2025-10-20 03:42:34', '2025-10-20 05:42:34', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(48, 67, 76, 'shared', '2025-10-20', '2026-04-18', 'approved', '2025-10-19 20:55:53', '2025-10-20 03:55:27', '2025-10-20 05:55:27', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(49, 64, 78, 'shared', '2025-10-20', '2025-10-20', 'approved', '2025-10-19 21:16:38', '2025-10-20 04:16:26', '2025-10-20 06:16:26', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(50, 47, 76, 'shared', '2025-10-20', '2026-04-18', 'approved', '2025-10-19 21:47:45', '2025-10-20 04:47:14', '2025-10-20 06:47:14', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(51, 68, 83, 'shared', '2025-10-20', '2026-04-18', 'approved', '2025-10-19 23:17:45', '2025-10-20 06:17:30', '2025-10-20 08:17:30', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(52, 46, 85, 'whole', '2025-10-20', '2026-04-18', 'approved', '2025-10-20 00:19:34', '2025-10-20 07:18:26', '2025-10-20 09:18:26', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(53, 28, 86, 'shared', '2025-10-20', '2026-04-18', 'approved', '2025-10-20 00:33:02', '2025-10-20 07:32:38', '2025-10-20 09:32:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(54, 69, 88, 'shared', '2025-10-20', '2026-04-18', 'approved', '2025-10-20 01:21:00', '2025-10-20 08:16:58', '2025-10-20 10:16:58', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(55, 46, 30, 'shared', '2025-10-23', '2026-04-21', 'completed', '2025-10-23 08:55:19', '2025-10-23 15:40:48', '2025-10-23 17:40:48', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(56, 46, 30, 'shared', '2025-10-25', '2026-04-23', 'completed', '2025-10-25 04:56:23', '2025-10-25 11:55:26', '2025-10-25 13:55:26', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(57, 28, 112, 'shared', '2025-11-21', '2026-05-20', 'active', '2025-11-21 06:36:34', '2025-11-21 11:49:32', '2025-11-21 13:49:32', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(58, 28, 113, 'shared', '2025-11-21', '2026-05-21', 'active', '2025-11-21 07:17:54', '2025-11-21 13:42:18', '2025-11-21 15:42:18', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(59, 74, 118, 'shared', '2025-11-22', '2026-05-21', 'approved', '2025-11-21 20:19:43', '2025-11-22 03:19:10', '2025-11-22 05:19:10', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(60, 74, 120, 'shared', '2025-11-22', '2026-05-21', 'approved', '2025-11-21 20:27:26', '2025-11-22 03:27:06', '2025-11-22 05:27:06', NULL, NULL, NULL, NULL, NULL, NULL, NULL);

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
-- Table structure for table `checkout_requests`
--

CREATE TABLE `checkout_requests` (
  `id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `tenant_id` int(11) NOT NULL,
  `owner_id` int(11) NOT NULL,
  `request_reason` text DEFAULT NULL,
  `status` enum('requested','approved','disapproved','completed') NOT NULL DEFAULT 'requested',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `processed_by` int(11) DEFAULT NULL,
  `processed_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

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
  `features` text DEFAULT NULL,
  `deposit_months` int(11) DEFAULT 1 COMMENT 'Number of months required as deposit (1-12)',
  `deposit_required` tinyint(1) DEFAULT 1 COMMENT 'Whether deposit is required (1=yes, 0=no)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dormitories`
--

INSERT INTO `dormitories` (`dorm_id`, `owner_id`, `name`, `address`, `description`, `verified`, `created_at`, `latitude`, `longitude`, `status`, `updated_at`, `cover_image`, `features`, `deposit_months`, `deposit_required`) VALUES
(1, 3, 'Sunshine Dormitory', 'Lacson Street, Bacolod City', 'Affordable dorm with free WiFi and study lounge.', 0, '2025-08-22 02:25:32', 10.67650000, 122.95090000, 'verified', '2025-08-22 04:24:01', NULL, NULL, 1, 1),
(3, 5, 'Blue Haven Dormitory', 'Araneta Avenue, Bacolod City', 'Close to universities, laundry service available, 24/7 security.', 1, '2025-08-22 02:25:32', 10.69170000, 122.97460000, 'pending', '2025-10-16 09:47:11', NULL, NULL, 1, 1),
(4, 4, 'Evergreen Dorms', 'Burgos Avenue, Bacolod City', 'Spacious rooms with air conditioning and shared kitchen.', 0, '2025-08-22 02:30:36', 10.69170000, 122.97460000, 'pending', '2025-10-16 09:47:11', NULL, NULL, 1, 1),
(5, 8, 'Southern Oasis', 'P Hernaez St.', 'A cozy dorm with a cozy atmosphere', 1, '2025-10-07 01:15:32', 10.68530000, 122.95670000, 'pending', '2025-10-16 09:47:11', 'dorm_68e469b41e437.png', 'Free Wifi, Aircon, Meals provided every morning.', 1, 1),
(6, 15, 'Anna\'s Haven Dormitory', '6100 Tops Rd, Bacolod, Negros Occidental, Philippines', 'A cozy and affordable dorm perfect for university students. Located near major schools and transport lines.', 1, '2025-10-10 16:58:30', 10.67523870, 122.95728190, 'pending', '2025-10-16 09:23:38', 'dorm_68e93b36b97a4.png', 'Wi-Fi, Study Lounge, CCTV Security, Air-conditioned Rooms, Laundry Area', 1, 1),
(7, 45, 'lozola', 'Bacolod', 'Secure and awesome', 1, '2025-10-11 07:32:12', 10.69170000, 122.97460000, 'pending', '2025-10-16 09:47:11', 'dorm_68ea07fc77de4.jpg', 'Wifi, Aircon, Study Room, Kitchen,', 1, 1),
(8, 17, 'The Greenfield Residences', 'Burgos Avenue, Brgy. Villamonte, Bacolod City', 'Modern dormitory offering a quiet study-friendly environment with 24/7 access.', 0, '2025-10-14 05:01:20', 10.69170000, 122.97460000, 'pending', '2025-10-16 09:47:11', 'dorm_68edd92060847.jpg', 'Private Bathroom, Common Kitchen, Wi-Fi, Parking Space, Visitor Lobby', 1, 1),
(9, 18, 'Casa de Felisa Dorm', 'Brgy. Mandalagan, Bacolod City', 'Home-like atmosphere with spacious rooms ideal for long-term student boarders.', 0, '2025-10-14 05:57:42', 10.69170000, 122.97460000, 'pending', '2025-10-16 09:47:11', 'dorm_68ede65686ffa.jpg', 'Air Conditioning, Free Water, Shared Kitchen, CCTV, Common Area', 1, 1),
(10, 19, 'DormHub Bacolod', '17th Lacson Street, near Robinsons Place, Bacolod City', 'A digitalized dorm for tech-savvy students with app-based access and smart utilities.', 0, '2025-10-14 06:04:13', 10.69170000, 122.97460000, 'pending', '2025-10-16 09:47:11', 'dorm_68ede7dd98ba7.jpg', 'Smart Lock, Wi-Fi 6, Study Cubicles, Rooftop Area, 24/7 Security', 1, 1),
(11, 20, 'La Salle Courtyard Residence', 'Narra Avenue, near University of St. La Salle, Bacolod City', 'Premium dorm for USLS students offering comfort and convenience within walking distance to campus.', 0, '2025-10-14 06:13:05', 10.69170000, 122.97460000, 'pending', '2025-10-16 09:47:11', 'dorm_68ede9f182e68.jpg', 'Wi-Fi, Study Hall, Air-Conditioned Rooms, Mini Café, Biometric Entry', 1, 1),
(12, 21, 'SunnyStay Dormitory', '8th Street, Brgy. Taculing, Bacolod City', 'Bright and airy dorm designed for female students, close to jeepney routes and eateries.', 0, '2025-10-14 06:18:12', 10.69170000, 122.97460000, 'pending', '2025-10-16 09:47:11', 'dorm_68edeb244bf96.jpg', 'Wi-Fi, Laundry Service, CCTV, Study Desks, Shared Kitchen', 1, 1),
(13, 22, 'St. Claire Student Inn', '15th Street, near USLS Gate 2, Bacolod City', 'Safe and budget-friendly dorm ideal for first-year college students.', 0, '2025-10-14 06:23:43', 10.69170000, 122.97460000, 'pending', '2025-10-16 09:47:11', 'dorm_68edec6f6a5e3.jpg', '24/7 Security, Free Drinking Water, Wi-Fi, Common Lounge, Refrigerator', 1, 1),
(14, 55, 'Good Runners', 'MXG5+V9J, Bacolod, Negros Occidental, Philippines', 'A house of Good people', 1, '2025-10-16 12:55:55', 10.67767337, 122.95872856, 'pending', '2025-10-16 13:00:13', NULL, 'wifi, Shared kitchen, parking, aircon', 1, 1),
(15, 55, 'Bad Runners', 'MXH3+H7W, Bacolod, Negros Occidental, Philippines', 'a house of bad runners', 0, '2025-10-16 12:56:40', 10.67904694, 122.95319986, 'pending', '2025-10-16 13:00:31', NULL, 'wifi, aircon', 1, 1),
(16, 58, 'St. Pete Dorms', 'Rosario st. bacolod', 'Blessed St. Peter dorm a house of resting students.', 1, '2025-10-19 15:02:11', 10.66365140, 122.94653660, 'pending', '2025-10-19 15:03:02', NULL, 'Safe, AC, WiFi, No Paranormal', 1, 1),
(17, 61, 'JazyDorm', 'Unnamed Road, Bago, Negros Occidental, Philippines', 'Cozy and cool', 1, '2025-10-20 00:10:28', 10.46341630, 122.92309910, 'pending', '2025-10-20 00:13:11', NULL, 'Wifi, Aircon, study space,', 2, 1),
(18, 15, 'Anna Second dorm', 'St. John\'s Institute, Bacolod, Negros Occidental, Philippines', '2nd coming of the dorm', -1, '2025-11-21 14:21:45', 10.67509810, 122.95755870, 'pending', '2025-11-26 01:32:50', NULL, 'ac, kitchen, bsthrooms', 2, 1),
(19, 116, 'Cisco', '1700 La Salle', '.', 1, '2025-11-22 03:02:24', NULL, NULL, 'pending', '2025-11-22 03:14:52', 'dorm_69212aac31c91.jpg', '', 3, 1);

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
(15, 30, 15, 6, NULL, 'Hi how much is 1 room', '2025-10-16 05:44:27', '2025-10-16 05:44:30', 'normal', NULL, NULL),
(16, 15, 30, 6, NULL, 'Hello how are you', '2025-10-18 01:40:53', '2025-10-18 02:31:26', 'normal', NULL, NULL),
(17, 15, 30, 6, NULL, 'About the room is everything okay?', '2025-10-18 22:39:05', '2025-10-19 06:11:27', 'normal', NULL, NULL),
(18, 59, 58, 16, NULL, 'Hi how much is your whole room?', '2025-10-19 08:14:55', '2025-10-19 08:16:05', 'normal', NULL, NULL),
(19, 58, 59, 16, NULL, 'It\'s a little be pricey', '2025-10-19 08:16:21', NULL, 'normal', NULL, NULL),
(20, 62, 61, 17, NULL, 'Hello', '2025-10-19 17:23:36', '2025-10-19 17:24:14', 'normal', NULL, NULL),
(21, 61, 62, 17, NULL, 'Wassup', '2025-10-19 17:24:18', '2025-10-19 17:24:21', 'normal', NULL, NULL),
(22, 63, 61, 17, NULL, 'Hello', '2025-10-19 18:47:19', '2025-10-19 18:47:29', 'normal', NULL, NULL),
(23, 61, 63, 17, NULL, 'Hi', '2025-10-19 18:47:32', '2025-10-19 18:47:32', 'normal', NULL, NULL),
(24, 64, 61, 17, NULL, 'Herllo', '2025-10-19 18:56:26', '2025-10-19 18:56:34', 'normal', NULL, NULL),
(25, 61, 64, 17, NULL, 'Hi', '2025-10-19 18:56:37', '2025-10-19 18:56:38', 'normal', NULL, NULL),
(26, 65, 61, 17, NULL, 'Hi', '2025-10-19 19:11:54', '2025-10-19 19:12:05', 'normal', NULL, NULL),
(27, 61, 65, 17, NULL, 'Hello', '2025-10-19 19:12:08', '2025-10-19 19:12:10', 'normal', NULL, NULL),
(28, 66, 61, 17, NULL, 'Hello I want dorm', '2025-10-19 19:30:37', '2025-10-19 19:30:41', 'normal', NULL, NULL),
(29, 61, 66, 17, NULL, 'Cge ah', '2025-10-19 19:30:43', '2025-10-19 19:30:46', 'normal', NULL, NULL),
(30, 67, 61, 17, NULL, 'Nigga', '2025-10-19 19:39:59', '2025-10-19 19:40:04', 'normal', NULL, NULL),
(31, 61, 67, 17, NULL, 'Sup', '2025-10-19 19:40:06', '2025-10-19 19:40:08', 'normal', NULL, NULL),
(32, 62, 61, 17, NULL, 'Yo', '2025-10-19 19:58:21', '2025-10-19 19:58:27', 'normal', NULL, NULL),
(33, 61, 62, 17, NULL, 'Yo', '2025-10-19 19:58:30', NULL, 'normal', NULL, NULL),
(34, 70, 61, 17, NULL, 'Gfy', '2025-10-19 20:06:29', '2025-10-19 20:06:34', 'normal', NULL, NULL),
(35, 61, 70, 17, NULL, 'Figh', '2025-10-19 20:06:36', '2025-10-19 20:06:39', 'normal', NULL, NULL),
(36, 70, 61, 17, NULL, 'Lopir', '2025-10-19 20:06:39', '2025-10-19 20:06:40', 'normal', NULL, NULL),
(37, 73, 61, 17, NULL, 'Hi', '2025-10-19 20:15:36', '2025-10-19 20:15:41', 'normal', NULL, NULL),
(38, 61, 73, 17, NULL, 'Hello', '2025-10-19 20:15:46', '2025-10-19 20:15:49', 'normal', NULL, NULL),
(39, 74, 61, 17, NULL, 'Hello', '2025-10-19 20:28:25', '2025-10-19 20:28:29', 'normal', NULL, NULL),
(40, 61, 74, 17, NULL, 'Hi', '2025-10-19 20:28:31', '2025-10-19 20:28:33', 'normal', NULL, NULL),
(41, 75, 61, 17, NULL, 'Helo', '2025-10-19 20:41:59', '2025-10-19 21:13:47', 'normal', NULL, NULL),
(42, 61, 75, 17, NULL, 'Yo', '2025-10-19 21:13:50', NULL, 'normal', NULL, NULL),
(43, 78, 61, 17, NULL, 'What\'s up my ninja', '2025-10-19 21:18:34', '2025-10-19 21:18:38', 'normal', NULL, NULL),
(44, 61, 78, 17, NULL, 'Type shi', '2025-10-19 21:18:42', '2025-10-19 21:18:44', 'normal', NULL, NULL),
(45, 78, 61, 17, NULL, '<3', '2025-10-19 21:18:50', '2025-10-19 21:18:53', 'normal', NULL, NULL),
(46, 83, 61, 17, NULL, 'Hi', '2025-10-19 23:19:16', '2025-10-19 23:19:21', 'normal', NULL, NULL),
(47, 61, 83, 17, NULL, 'Hello', '2025-10-19 23:19:24', '2025-10-19 23:19:26', 'normal', NULL, NULL),
(48, 85, 15, 6, NULL, 'Bowd', '2025-10-20 00:20:08', '2025-10-20 00:20:12', 'normal', NULL, NULL),
(49, 85, 15, 6, NULL, 'Bows', '2025-10-20 00:20:12', '2025-10-20 00:20:17', 'normal', NULL, NULL),
(50, 85, 15, 6, NULL, 'Vows', '2025-10-20 00:20:16', '2025-10-20 00:20:17', 'normal', NULL, NULL),
(51, 85, 15, 6, NULL, 'Hu', '2025-10-20 00:20:42', '2025-10-20 00:20:47', 'normal', NULL, NULL),
(52, 85, 15, 6, NULL, 'Ha', '2025-10-20 00:20:58', '2025-10-20 00:21:02', 'normal', NULL, NULL),
(53, 15, 85, 6, NULL, 'Hi', '2025-10-20 00:21:35', '2025-10-20 00:21:37', 'normal', NULL, NULL),
(54, 85, 15, 6, NULL, 'Okay pwede e deploy', '2025-10-20 00:21:52', '2025-10-20 00:21:52', 'normal', NULL, NULL),
(55, 88, 61, 17, NULL, 'Hi', '2025-10-20 01:18:24', '2025-10-20 01:18:29', 'normal', NULL, NULL),
(56, 61, 88, 17, NULL, 'Hello', '2025-10-20 01:18:33', '2025-10-20 01:18:36', 'normal', NULL, NULL),
(57, 61, 88, 17, NULL, 'What', '2025-10-20 19:40:21', NULL, 'normal', NULL, NULL);

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
(14, 30, 'monthly', 30, NULL, 1000.00, 'expired', '2025-10-15 02:05:29', '2025-10-15', 'receipt_14_1760495172.jpg', NULL, '2025-10-19 23:54:14', '2025-10-14 19:05:29', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(16, 34, 'monthly', 30, 55, 3000.00, 'paid', '2025-10-16 14:25:24', '2025-10-23', 'receipt_16_1760623714.jpg', NULL, '2025-10-16 07:25:24', '2025-10-16 07:07:19', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(17, 35, 'monthly', 59, 58, 6000.00, 'paid', '2025-10-19 16:20:27', '2025-10-26', 'receipt_17_1760890783.jpg', NULL, '2025-10-19 09:20:27', '2025-10-19 08:15:54', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(18, 36, 'monthly', 62, 61, 500.00, 'paid', '2025-10-20 00:32:49', '2025-10-27', 'receipt_18_1760920347.jpg', NULL, '2025-10-19 17:32:49', '2025-10-19 17:30:39', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(19, 37, 'monthly', 63, 61, 2500.00, 'paid', '2025-10-20 02:00:11', '2025-10-27', NULL, NULL, '2025-10-19 19:00:11', '2025-10-19 18:48:59', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(20, 38, 'monthly', 64, 61, 2500.00, 'paid', '2025-10-20 02:00:14', '2025-10-27', NULL, NULL, '2025-10-19 19:00:14', '2025-10-19 18:57:06', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(21, 39, 'monthly', 65, 61, 10000.00, 'paid', '2025-10-20 02:14:05', '2025-10-27', 'receipt_21_1760926431.jpg', NULL, '2025-10-19 19:14:05', '2025-10-19 19:13:15', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(22, 40, 'monthly', 66, 61, 50000.00, 'paid', '2025-10-20 02:32:12', '2025-10-27', 'receipt_22_1760927523.jpg', NULL, '2025-10-19 19:32:12', '2025-10-19 19:31:35', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(23, 41, 'monthly', 67, 61, 500.00, 'paid', '2025-10-20 02:42:32', '2025-10-27', 'receipt_23_1760928129.jpg', NULL, '2025-10-19 19:42:32', '2025-10-19 19:41:32', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(24, 42, 'monthly', 68, NULL, 5000.00, 'paid', '2025-10-20 02:49:14', '2025-10-20', 'receipt_24_1760928576.jpg', NULL, '2025-10-19 19:50:02', '2025-10-19 19:49:14', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(25, 43, 'monthly', 69, NULL, 10000.00, 'rejected', '2025-10-20 02:56:32', '2025-10-20', 'receipt_25_1760929015.jpg', NULL, '2025-10-19 20:23:15', '2025-10-19 19:56:32', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(26, 43, 'monthly', 69, 61, 100.00, 'paid', '2025-10-20 03:23:11', '2025-10-21', 'receipt_26_1760929546.jpg', NULL, '2025-10-19 20:23:11', '2025-10-19 20:05:35', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(27, 44, 'monthly', 70, 61, 1000.00, 'paid', '2025-10-20 03:07:52', '2025-10-27', 'receipt_27_1760929654.jpg', NULL, '2025-10-19 20:07:52', '2025-10-19 20:07:15', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(28, 45, 'monthly', 73, 61, 5000.00, 'paid', '2025-10-20 03:17:09', '2025-10-27', 'receipt_28_1760930214.jpg', NULL, '2025-10-19 20:17:09', '2025-10-19 20:16:26', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(29, 46, 'monthly', 74, 61, 5000.00, 'paid', '2025-10-20 03:30:03', '2025-10-27', 'receipt_29_1760930985.jpg', NULL, '2025-10-19 20:30:03', '2025-10-19 20:29:21', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(30, 48, 'monthly', 76, NULL, 2000.00, 'paid', '2025-10-20 03:55:53', '2025-10-20', 'receipt_30_1760932634.jpg', NULL, '2025-10-19 20:57:36', '2025-10-19 20:55:53', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(31, 47, 'monthly', 75, 61, 2000.00, 'rejected', '2025-10-20 04:13:38', '2025-10-27', NULL, NULL, '2025-10-19 21:17:39', '2025-10-19 21:13:38', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(32, 49, 'monthly', 78, 61, 2500.00, 'paid', '2025-10-20 04:17:34', '2025-10-27', 'receipt_32_1760933844.jpg', NULL, '2025-10-19 21:17:34', '2025-10-19 21:16:38', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(33, 50, 'monthly', 76, NULL, 200.00, 'paid', '2025-10-20 04:47:45', '2025-10-20', 'receipt_33_1760935713.jpg', NULL, '2025-10-19 21:48:54', '2025-10-19 21:47:45', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(34, 51, 'monthly', 83, 61, 2000.00, 'paid', '2025-10-20 06:18:34', '2025-10-27', 'receipt_34_1760941090.jpg', NULL, '2025-10-19 23:18:34', '2025-10-19 23:17:45', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(35, 52, 'monthly', 85, NULL, 1000.00, 'paid', '2025-10-20 07:53:30', '2025-10-20', 'receipt_35_1760944991.jpg', NULL, '2025-10-20 00:53:30', '2025-10-20 00:19:34', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(36, 53, 'monthly', 86, NULL, 4000.00, 'paid', '2025-10-20 07:33:02', '2025-10-20', 'receipt_36_1760945627.jpg', NULL, '2025-10-20 00:34:09', '2025-10-20 00:33:02', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(37, 54, 'monthly', 88, 61, 2000.00, 'paid', '2025-10-20 08:22:03', '2025-10-27', 'receipt_37_1760948511.jpg', NULL, '2025-10-20 01:22:03', '2025-10-20 01:21:00', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(38, 55, 'monthly', 30, NULL, 1000.00, 'paid', '2025-10-23 15:43:12', '2025-10-23', 'receipt_38_1761234216.jpg', NULL, '2025-10-23 08:55:19', '2025-10-23 08:43:12', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(39, 30, 'monthly', 30, 15, 1.00, 'paid', '2025-10-25 11:19:31', '2025-10-25', 'receipt_39_1761391191.jpg', NULL, '2025-10-25 04:20:21', '2025-10-25 04:19:31', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(40, 56, 'monthly', 30, NULL, 1000.00, 'paid', '2025-10-25 11:55:52', '2025-10-25', 'receipt_40_1761393371.jpg', NULL, '2025-10-25 04:56:23', '2025-10-25 04:55:52', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(41, 57, 'monthly', 112, NULL, 4000.00, 'paid', '2025-11-21 12:10:03', '2025-11-21', 'receipt_41_1763731921.jpg', NULL, '2025-11-21 06:36:51', '2025-11-21 05:10:03', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(42, 58, 'monthly', 113, 15, 666.67, 'paid', '2025-11-21 14:17:54', '2025-11-28', NULL, NULL, '2025-11-21 07:17:54', '2025-11-21 06:43:16', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(43, 59, 'monthly', 118, NULL, 1500.00, '', '2025-11-22 03:19:43', '2025-11-22', 'receipt_43_1763782098.jpg', NULL, '2025-11-24 00:00:03', '2025-11-21 20:19:43', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(44, 60, 'monthly', 120, NULL, 1500.00, '', '2025-11-22 03:27:26', '2025-11-22', NULL, NULL, '2025-11-24 00:00:03', '2025-11-21 20:27:26', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(45, 35, 'monthly', 59, 58, 6000.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(46, 36, 'monthly', 62, 61, 500.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(47, 37, 'monthly', 63, 61, 2500.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(48, 38, 'monthly', 64, 61, 2500.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(49, 39, 'monthly', 65, 61, 10000.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(50, 40, 'monthly', 66, 61, 50000.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(51, 41, 'monthly', 67, 61, 500.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(52, 42, 'monthly', 68, 61, 2500.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(53, 43, 'monthly', 69, 61, 2500.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(54, 44, 'monthly', 70, 61, 1000.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(55, 45, 'monthly', 73, 61, 5000.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(56, 46, 'monthly', 74, 61, 5000.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(57, 47, 'monthly', 75, 61, 2000.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(58, 48, 'monthly', 76, 61, 1000.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(59, 49, 'monthly', 78, 61, 2500.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(60, 50, 'monthly', 76, 15, 200.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(61, 51, 'monthly', 83, 61, 2000.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(62, 52, 'monthly', 85, 15, 1000.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(63, 53, 'monthly', 86, 15, 666.67, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL),
(64, 54, 'monthly', 88, 61, 2000.00, 'pending', '2025-11-25 07:00:04', '2025-11-30', NULL, NULL, '2025-11-25 00:00:04', '2025-11-25 00:00:04', 0, NULL, NULL, NULL, 'bank_transfer', NULL);

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

--
-- Dumping data for table `reviews`
--

INSERT INTO `reviews` (`review_id`, `booking_id`, `student_id`, `dorm_id`, `rating`, `comment`, `created_at`, `status`) VALUES
(1, 56, 30, 6, 5, 'qweasd', '2025-10-25 10:14:16', 'rejected'),
(2, 56, 30, 6, 5, 'good dorm', '2025-10-25 11:52:56', 'rejected');

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
(28, 6, 'Single', 6, NULL, 4000.00, 'occupied', '2025-10-12 15:14:11', NULL, NULL),
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
(46, 6, 'Double', 2, NULL, 1000.00, 'occupied', '2025-10-14 21:57:13', NULL, NULL),
(47, 6, 'Single', 1, NULL, 200.00, 'occupied', '2025-10-16 09:04:30', NULL, NULL),
(49, 14, 'Single', 1, NULL, 3000.00, 'occupied', '2025-10-16 12:57:04', NULL, NULL),
(50, 14, 'Double', 2, NULL, 6000.00, 'vacant', '2025-10-16 12:57:17', NULL, NULL),
(51, 14, 'Twin', 4, NULL, 7000.00, 'vacant', '2025-10-16 12:57:31', NULL, NULL),
(52, 14, 'Suite', 6, NULL, 20000.00, 'vacant', '2025-10-16 12:57:48', NULL, NULL),
(53, 15, 'Suite', 10, NULL, 30000.00, 'vacant', '2025-10-16 12:58:12', NULL, NULL),
(54, 15, 'Single', 1, NULL, 1000.00, 'vacant', '2025-10-16 12:58:31', NULL, NULL),
(55, 15, 'Double', 2, NULL, 2000.00, 'vacant', '2025-10-16 12:58:43', NULL, NULL),
(58, 16, 'Single', 1, NULL, 7000.00, 'vacant', '2025-10-19 15:03:58', NULL, NULL),
(59, 16, 'Double', 2, NULL, 12000.00, 'occupied', '2025-10-19 15:05:53', NULL, NULL),
(60, 16, 'Twin', 2, NULL, 25000.00, 'vacant', '2025-10-19 15:11:37', NULL, NULL),
(61, 16, 'Suite', 4, NULL, 35000.00, 'vacant', '2025-10-19 15:12:00', NULL, NULL),
(62, 17, 'Double', 2, NULL, 5000.00, 'occupied', '2025-10-20 00:10:50', NULL, NULL),
(63, 17, 'Twin', 2, NULL, 1000.00, 'occupied', '2025-10-20 00:11:14', NULL, NULL),
(64, 17, 'Suite', 4, NULL, 10000.00, 'occupied', '2025-10-20 00:11:37', NULL, NULL),
(65, 17, 'Suite', 10, NULL, 50000.00, 'occupied', '2025-10-20 02:02:23', NULL, NULL),
(66, 17, 'Twin', 2, NULL, 10000.00, 'occupied', '2025-10-20 02:02:49', NULL, NULL),
(67, 17, 'Twin', 2, NULL, 2000.00, 'occupied', '2025-10-20 02:59:52', NULL, NULL),
(68, 17, 'Suite', 2, NULL, 4000.00, 'occupied', '2025-10-20 03:00:51', NULL, NULL),
(69, 17, 'Twin', 2, NULL, 4000.00, 'occupied', '2025-10-20 04:59:25', NULL, NULL),
(70, 6, 'Single', 1, NULL, 5000.00, 'vacant', '2025-11-21 14:20:33', NULL, NULL),
(71, 18, 'Single', 1, NULL, 5000.00, 'vacant', '2025-11-21 14:22:45', NULL, NULL),
(72, 18, 'Double', 2, NULL, 10000.00, 'vacant', '2025-11-21 14:23:09', NULL, NULL),
(73, 18, 'Twin', 4, NULL, 30000.00, 'vacant', '2025-11-21 14:23:26', NULL, NULL),
(74, 19, 'Single', 2, '15.5', 3000.00, 'occupied', '2025-11-22 03:09:28', NULL, NULL);

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
(16, 45, 'room_68eded084a3ea.jpg', '2025-10-13 23:26:16'),
(17, 46, 'room_69202d38e4da0_Sample_double_Room.jpg', '0000-00-00 00:00:00'),
(18, 46, 'room_69202dfa5497a_Sample_double_Room.jpg', '0000-00-00 00:00:00'),
(22, 74, 'room_692129afb50cd_premium_photo-1676823547752-1d24e8597047.jpg', '0000-00-00 00:00:00');

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
(3, 30, 30, 6, 46, 'completed', '2025-10-15 12:00:00', '2025-10-25 04:20:21', '2026-04-13', 1.00, 0.00, NULL, '2025-10-17 17:35:13', '2025-10-25 11:20:21'),
(4, 31, 30, 5, 29, 'active', '2025-10-15 12:00:00', NULL, '2026-04-13', 0.00, 0.00, NULL, '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(5, 34, 30, 14, 49, 'active', '2025-10-16 12:00:00', NULL, '2026-04-14', 3000.00, 0.00, NULL, '2025-10-17 17:35:13', '2025-10-17 17:35:13'),
(8, 35, 59, 16, 59, 'active', '2025-10-19 00:00:00', NULL, '2026-04-17', 6000.00, 0.00, NULL, '2025-10-19 15:15:54', '2025-10-19 16:20:27'),
(9, 36, 62, 17, 63, 'active', '2025-10-20 00:00:00', NULL, '2026-04-18', 500.00, 0.00, NULL, '2025-10-20 00:30:39', '2025-10-20 00:32:49'),
(10, 37, 63, 17, 62, 'active', '2025-10-20 00:00:00', NULL, '2026-04-18', 2500.00, 0.00, NULL, '2025-10-20 01:48:59', '2025-10-20 02:00:11'),
(11, 38, 64, 17, 64, 'active', '2025-10-20 00:00:00', NULL, '2026-04-18', 2500.00, 0.00, NULL, '2025-10-20 01:57:06', '2025-10-20 02:00:14'),
(12, 39, 65, 17, 66, 'active', '2025-10-20 00:00:00', NULL, '2026-04-18', 10000.00, 0.00, NULL, '2025-10-20 02:13:15', '2025-10-20 02:14:05'),
(13, 40, 66, 17, 65, 'active', '2025-10-20 00:00:00', NULL, '2026-04-18', 50000.00, 0.00, NULL, '2025-10-20 02:31:35', '2025-10-20 02:32:12'),
(14, 41, 67, 17, 63, 'active', '2025-10-20 00:00:00', NULL, '2026-04-18', 500.00, 0.00, NULL, '2025-10-20 02:41:32', '2025-10-20 02:42:32'),
(15, 42, 68, 17, 62, 'active', '2025-10-20 00:00:00', NULL, '2026-04-18', 5000.00, 0.00, NULL, '2025-10-20 02:49:14', '2025-10-20 02:50:02'),
(16, 43, 69, 17, 64, 'active', '2025-10-20 00:00:00', NULL, '2026-04-18', 100.00, 0.00, NULL, '2025-10-20 02:56:32', '2025-10-20 03:23:11'),
(17, 44, 70, 17, 67, 'active', '2025-10-20 00:00:00', NULL, '2026-04-18', 1000.00, 0.00, NULL, '2025-10-20 03:07:15', '2025-10-20 03:07:52'),
(18, 45, 73, 17, 65, 'active', '2025-10-22 00:00:00', NULL, '2026-04-18', 5000.00, 0.00, NULL, '2025-10-20 03:16:26', '2025-10-20 03:17:09'),
(19, 46, 74, 17, 66, 'active', '2025-10-20 00:00:00', NULL, '2026-04-21', 5000.00, 0.00, NULL, '2025-10-20 03:29:21', '2025-10-20 03:30:03'),
(20, 48, 76, 17, 67, 'active', '2025-10-20 00:00:00', NULL, '2026-04-18', 2000.00, 0.00, NULL, '2025-10-20 03:55:53', '2025-10-20 03:57:36'),
(21, 47, 75, 17, 68, 'active', '2025-10-20 00:00:00', NULL, '2026-04-18', 0.00, 0.00, NULL, '2025-10-20 04:13:38', '2025-10-20 04:13:38'),
(22, 49, 78, 17, 64, 'active', '2025-10-20 00:00:00', NULL, '2025-10-20', 2500.00, 0.00, NULL, '2025-10-20 04:16:38', '2025-10-20 04:17:34'),
(23, 50, 76, 6, 47, 'active', '2025-10-20 00:00:00', NULL, '2026-04-18', 200.00, 0.00, NULL, '2025-10-20 04:47:45', '2025-10-20 04:48:54'),
(24, 51, 83, 17, 68, 'active', '2025-10-20 00:00:00', NULL, '2026-04-18', 2000.00, 0.00, NULL, '2025-10-20 06:17:45', '2025-10-20 06:18:34'),
(25, 52, 85, 6, 46, 'active', '2025-10-20 00:00:00', NULL, '2026-04-18', 1000.00, 0.00, NULL, '2025-10-20 07:19:34', '2025-10-20 07:53:30'),
(26, 53, 86, 6, 28, 'active', '2025-10-20 00:00:00', NULL, '2026-04-18', 4000.00, 0.00, NULL, '2025-10-20 07:33:02', '2025-10-20 07:34:09'),
(27, 54, 88, 17, 69, 'active', '2025-10-20 00:00:00', NULL, '2026-04-18', 2000.00, 0.00, NULL, '2025-10-20 08:21:00', '2025-10-20 08:22:03'),
(28, 55, 30, 6, 46, 'completed', '2025-10-23 00:00:00', '2025-10-23 08:55:19', '2026-04-21', 1000.00, 0.00, NULL, '2025-10-23 15:43:12', '2025-10-23 15:55:19'),
(29, 56, 30, 6, 46, 'completed', '2025-10-25 00:00:00', '2025-10-25 04:56:23', '2026-04-23', 1000.00, 0.00, NULL, '2025-10-25 11:55:52', '2025-10-25 11:56:23'),
(30, 57, 112, 6, 28, 'active', '2025-11-21 00:00:00', NULL, '2026-05-20', 4000.00, 0.00, NULL, '2025-11-21 12:10:03', '2025-11-21 13:36:34'),
(31, 58, 113, 6, 28, 'active', '2025-11-21 00:00:00', NULL, '2026-05-21', 666.67, 0.00, NULL, '2025-11-21 13:43:16', '2025-11-21 14:17:54'),
(32, 59, 118, 19, 74, 'active', '2025-11-22 00:00:00', NULL, '2026-05-21', 0.00, 0.00, NULL, '2025-11-22 03:19:43', '2025-11-22 03:19:43'),
(33, 60, 120, 19, 74, 'active', '2025-11-22 00:00:00', NULL, '2026-05-21', 0.00, 0.00, NULL, '2025-11-22 03:27:26', '2025-11-22 03:27:26');

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
(1, 'Angelo', NULL, 'angelo@gmail.com', '$2y$10$lmeeDUafjSWU9pZZd.sIz.0U7AG2GXt5yTOblJBhx0HRLQVP65vNa', 'admin', '2025-08-20 14:23:12', 1, NULL, NULL, NULL, NULL),
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
(30, 'Ethan Castillo', NULL, 'ethan.castillo@email.com', '$2y$10$JAERYBGf7naHaqTRbNibr.eOxUHaEUWXpcJ764P58iJDf.zeCQXgG', 'student', '2025-10-09 05:43:34', 1, '09178881234', NULL, NULL, NULL),
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
(41, 'Alexa Cruz', NULL, 'alexa.cruz@email.org', '$2y$10$wujbhtrucaToLd0Ah3Bc.OwH8NrEF1ntwusp2s/TRhzchPKKZNA/K', 'student', '2025-10-09 05:46:17', 1, '09275554567', NULL, NULL, NULL),
(42, 'Noah Enriquez', NULL, 'noah.enriquez@email.com', '$2y$10$9faaKs6k8o8CRsXMXIfXQ.mhyMCQFcEVC8BVhZ3Trj1Yl4PaO4GNe', 'student', '2025-10-09 05:46:29', 0, '09364445678', NULL, NULL, NULL),
(43, 'Kylie Delos Reyes', NULL, 'kylie.dr@email.net', '$2y$10$3V/hQoA5bynyYG2Clw3C9OFvdN7g2ZrMkSel3.WfFjch/waJ96HIy', 'student', '2025-10-09 05:46:40', 0, '09453336789', NULL, NULL, NULL),
(44, 'Nathaniel Reyes', NULL, 'nathaniel.r@email.org', '$2y$10$ulSD9yuBVnVqUuhyKaHqs.Rg/B0GfhK2RVNkWOHZS2Y7SbmnxHMNC', 'student', '2025-10-09 05:46:56', 0, '09542227890', NULL, NULL, NULL),
(45, 'Fall Gomes', NULL, 'jpsgomes0212@gmail.com', '$2y$10$GULRRafuNafHQb0JFZmFAucbpqolQI0Xnl6Tcc8SxaHL/HLvccyJC', 'owner', '2025-10-11 07:22:53', 0, '09453196127', NULL, NULL, NULL),
(46, 'Jan Pol Gomes', NULL, 'janpolgomes@gmal.com', '$2y$10$xiaLSF0v9z3UGK5d7eS1A.SXWfHtie6PaM/r1jm.uT2NUCE5rQLpS', 'student', '2025-10-11 10:05:13', 0, '09453196129', NULL, NULL, NULL),
(47, 'Jan Pol Gomes', NULL, 'janpol@gmail.com', '$2y$10$OZp52j10PNJnJFs.yZGlYua5JWxTES1BJmrG.k/yrNz1S6xBrcqPC', 'student', '2025-10-11 10:06:43', 0, '09453196127', NULL, NULL, NULL),
(48, 'Jhanna Gracey Villan', NULL, 'jhanna@gmail.com', '$2y$10$55XADUHThWKpFwwYe09bReyYZKmiJY65e4XxNS4o4u1G1E7Ir8cv6', 'student', '2025-10-13 23:48:11', 0, '09019203817', NULL, NULL, NULL),
(49, 'James Ham', NULL, 'jamesham@email.com', '$2y$10$ti5K7WBkOm6MdSmIRgsZe.bR0FiMeBK3c4rpo6ZsZpXkYp.HYYyoy', 'student', '2025-10-14 00:05:07', 0, '09764537234', NULL, NULL, NULL),
(50, 'John Garcia', NULL, 'garcia@email.com', '$2y$10$G7Xl.SKODvwTi4VkbLyCDebskx2gPw8vQNOFYgrcN63VtrGN.Fw/y', 'student', '2025-10-14 04:41:58', 0, '09874356273', NULL, NULL, NULL),
(51, 'Azer Jan', NULL, 's2201387@usls.edu.ph', '$2y$10$SiBkIaJFN47lVorRVgcuieCWEvqIWRxsleYfijCAgM7zmEjNAvXgW', 'student', '2025-10-16 08:07:35', 1, '09100010101', NULL, NULL, NULL),
(52, 'Leanne Gumban', NULL, 's2016022@usls.edu.ph', '$2y$10$647ogLFwqRcFXj.CW5bamOPe532Fyf..acMIFee0pfTvqFrh7QbtG', 'student', '2025-10-16 08:10:21', 0, '09062643027', NULL, NULL, NULL),
(53, 'Kirby Calampinay', NULL, 's24321', '$2y$10$RSd/YTyn4SR4qQX415iaGe/0Vsx03p7ZTXxyScPJONm4LetMKWbw6', 'student', '2025-10-16 11:10:10', 0, NULL, NULL, NULL, NULL),
(54, 'Sam Smith', NULL, 'jr74084@gmail.com', '$2y$10$ozLCeg6b8ydv0g7Ucqi8Ne8f1pAoN3pRAviaHDXqDTWE8pA14yU9S', 'student', '2025-10-16 11:12:48', 0, NULL, NULL, NULL, NULL),
(55, 'Joshua Campo', NULL, 'campo.j@email.com', '$2y$10$5uGpdOBtHGvrguJIAaTF7.3qQji78PxXRI1L0YRg5LebEj0XbYvtS', 'owner', '2025-10-16 12:53:18', 0, NULL, NULL, NULL, NULL),
(56, 'Mikey Segovia', NULL, 'anonsfwend19@gmail.com', '$2y$10$34qAUcRgeCD8Y.3hhCV8buRCCmkj18v35duoCQaoVM0uJYXmY7MQy', 'student', '2025-10-16 15:53:48', 0, NULL, NULL, NULL, NULL),
(57, 'Brad Ed Sale', NULL, 'brod@gmail.com', '$2y$10$2Y868faqd.GMPl9pFNr3ZOnEyOzmExmHkvaLjuNV4/wJKjJXcrNfC', 'student', '2025-10-16 15:58:36', 0, NULL, NULL, NULL, NULL),
(58, 'Justin Cantilero', NULL, 'j.cantilero@email.com', '$2y$10$mEpFSZxaeznO5BwOCYTAOOpbb2iMnmetnoKRkcoQBKIh.jXbPSiNq', 'owner', '2025-10-19 14:42:02', 0, NULL, NULL, NULL, NULL),
(59, 'Kevin Figueroa', NULL, 'k.figueroa@email.com', '$2y$10$koyV8AiUxK9yCkKDCw0OqeEDHnNtb6/YcvXRvMwhnSBL.vVIXb5F.', 'student', '2025-10-19 14:45:52', 0, NULL, NULL, NULL, NULL),
(60, 'Dray Young', 'Hilado St, Bacolod City', 'young@gmail.com', '$2y$10$XlVANn.R0lZmk1hB3lMXhuZZh6zzp2lpTKBhTzBl/hN9WQ9CuX6YC', 'student', '2025-10-19 17:38:07', 0, '09457654536', 'N/A', NULL, NULL),
(61, 'Jay Ramos', NULL, 'jay@gmail.com', '$2y$10$A6B.Zee5z28Qa4.WjyliEOYwZp5nOdCzQiuQCK0vRKeEgf7.UBlA.', 'owner', '2025-10-20 00:02:54', 1, NULL, NULL, NULL, NULL),
(62, 'Brad Ed Sale', NULL, 'brad12345@gmail.com', '$2y$10$mxSk/6nNqS6vbGoXhc5gG.AlSFcgSp4O0MK6HxT7Wfs2FtJTRXgmu', 'student', '2025-10-20 00:03:10', 0, NULL, NULL, NULL, NULL),
(63, 'Elaiza Francisco', NULL, 's2500728@usls.edu.ph', '$2y$10$x.m.XlsWchHJwalt7y7/auTuC7VVMfHSkwDplpJzdyVxu4Y6ijdmC', 'student', '2025-10-20 01:45:34', 0, NULL, NULL, NULL, NULL),
(64, 'w', NULL, 'w@s.com', '$2y$10$WTrLzNpSYgcmTyJlxQXVyu9I2d/WfMv1c5D8117T2mHmySiJ0fdJ.', 'student', '2025-10-20 01:55:28', 0, NULL, NULL, NULL, NULL),
(65, 'Raymund Alfaro', NULL, 'raymund@gmail.com', '$2y$10$vGEyD9OHiK/d68dufGTRKupOL/gPO7GPqwna62GUfQ8LkaJdE43Ym', 'student', '2025-10-20 02:11:04', 0, NULL, NULL, NULL, NULL),
(66, 'Razianth Oanes', NULL, 'raz123@gmail.com', '$2y$10$l7NwycPRf6f10Y9rAzU15.COeFLT92SCxFjWJ8yL2BT3wt2izy5Z2', 'student', '2025-10-20 02:29:46', 0, NULL, NULL, NULL, NULL),
(67, 'Gorge Batumbakal', NULL, 'ilovelolis67@yahoo.cum', '$2y$10$ab04ZgSs21o.zYB2bwL7aOZp29jzqVbsvLvjvitiJPjMnOSijUTg.', 'student', '2025-10-20 02:38:38', 0, NULL, NULL, NULL, NULL),
(68, 'Jeremy Isaac B. Martirez', NULL, 's2120515@usls.edu.ph', '$2y$10$..XvX/Bgqh9y2ap9.syOK.tcgDf6NY.2zsLSdW/KlFMDuuItYAU0u', 'student', '2025-10-20 02:47:40', 0, NULL, NULL, NULL, NULL),
(69, 'Kevin M. Figueroa', NULL, 'zemaster18@gmail.com', '$2y$10$PY7z4hLd3wzTXdBjvg/2I.IIRKhOz2ZI..AIKKdNM1Zk3RpDO0BV6', 'student', '2025-10-20 02:52:23', 0, NULL, NULL, NULL, NULL),
(70, 'Brad ed', NULL, 'doe@gmail.com', '$2y$10$zdQswIpwIBGIWXZtMugwVuwzvrui36zPAQT0VZ9ElbuntC1HEI92a', 'student', '2025-10-20 03:06:01', 0, NULL, NULL, NULL, NULL),
(71, 'Fall asleep', NULL, 'whizy212@gmail.com', '$2y$10$Ka.SsmjXW3q/LzI/2bQV5uSo6Mct06sDqRXl4r6eYq.ptWn1Gjlx2', 'student', '2025-10-20 03:13:20', 0, NULL, NULL, NULL, NULL),
(72, 'Fall Asleep', NULL, 'salebraded@gmail.com', '$2y$10$BtvRbO/j2HOYAB3IvMXXL.CFrCUZuebvu3KPp5oOc8X.j8Cm/Xt1K', 'student', '2025-10-20 03:13:56', 0, NULL, NULL, NULL, NULL),
(73, 'Fall Asleep', NULL, 'test@email.com', '$2y$10$C9V9BDDhDTvHCvYUgbg7peQAKZBNe/cWdYwKgU6zEvm4d0b6tSMSG', 'student', '2025-10-20 03:14:29', 0, NULL, NULL, NULL, NULL),
(74, 'Charles', NULL, 'dcharlesmarce@gmail.com', '$2y$10$EbkmLzNenWIiqd7xlieuKewHwk1SXsANnttvuohAxN5ORA58RQ0.2', 'student', '2025-10-20 03:27:44', 0, NULL, NULL, NULL, NULL),
(75, 'pauly', NULL, 'paul@gmail.com', '$2y$10$Mg0VvP6Kh7sQe0LKZGlo2.sKZ.kx6zWigupULTm0B1bQ.Q/KPbxIO', 'student', '2025-10-20 03:41:06', 0, NULL, NULL, NULL, NULL),
(76, 'student 1', NULL, 'student1@email.com', '$2y$10$KFzZ3cdoxjqXJuA1SiVin.ObUeNYIOkMterLdQhKDHqwU9WBuFE4e', 'student', '2025-10-20 03:54:10', 0, NULL, NULL, NULL, NULL),
(77, 'norbert', NULL, 'norbert@gmail.com', '$2y$10$l854QJbxQKQ5d86w37x7z.OzGQGydIuJm7KMTRSpGdIEfe5liFL0C', 'student', '2025-10-20 04:09:22', 0, NULL, NULL, NULL, NULL),
(78, 'Norbert Audines', NULL, 's...2303007@gmail.com', '$2y$10$uHKF4Ipf.jfjjO61N2rKL.GFDQw0ENuVgn0osPbxmP5RWeeaMa4Cy', 'student', '2025-10-20 04:10:33', 0, NULL, NULL, NULL, NULL),
(79, 'Kylin Cabrera', NULL, '.........@gmail.com', '$2y$10$ZJaUIOMLtnNIebjgjWhC2.cmEoXq3XtFh.TeOLJjGtTtL1I4Ay9Xm', 'student', '2025-10-20 04:23:08', 0, NULL, NULL, NULL, NULL),
(80, 'Kylin Cabs', NULL, '..........@gmail.com', '$2y$10$BKB4ddy0h6bIIg652AxHP.MDiLp2h2dnxBXIcfr/TZ33hqa4xzBtq', 'student', '2025-10-20 04:24:36', 0, NULL, NULL, NULL, NULL),
(81, 'julian', NULL, 's2400346@usls.edu.ph', '$2y$10$.k9r9LoEaw7wJMal94imgeMWJhiQ9vB509YI7jI9cJOwLN4DNp/ti', 'student', '2025-10-20 05:30:31', 0, '09691118016', NULL, NULL, NULL),
(82, 'e', NULL, 'ej@example.com', '$2y$10$XC8EpIHWCvJPZqU0p3DCnOtUA6aqxh/MbLFIaBtS36s2mGsIW9bcC', 'student', '2025-10-20 06:05:52', 0, NULL, NULL, NULL, NULL),
(83, 'bry', NULL, 'bry123@gmail.com', '$2y$10$tsYj50U8Ir.mWRU1jYYU6OUIRqyFCl1RDr4RL8M7Y7cB0SAxbNomu', 'student', '2025-10-20 06:15:29', 0, NULL, NULL, NULL, NULL),
(84, 'romeo standards', NULL, 'romeo@exampe.com', '$2y$10$hB/koHVBFY3cAGSlvCpg2u0cnZEp.aGdfVF87cYVjhtXplt29hdj2', 'student', '2025-10-20 07:12:32', 0, NULL, NULL, NULL, NULL),
(85, 'Romeo Seva', NULL, 'romrom@example.com', '$2y$10$K8YfVzvjjrPQpEudmLffiu47lubs5W.GJp4/gaNnWqG5o2hnLW16e', 'student', '2025-10-20 07:15:17', 0, NULL, NULL, NULL, NULL),
(86, 'Kharyl Alejo', NULL, 'alejokharyl1221@gmail.com', '$2y$10$198x0h4vWxRdG8QIGYOHl.1o8edA9.5LUMxd6KjZiiqzAi6.GxZa.', 'student', '2025-10-20 07:30:31', 0, NULL, NULL, NULL, NULL),
(87, 'rojer', NULL, 'rojer@gmail.com', '$2y$10$x.vVvZOWUgHY4APe2b9dbOsqjHSptq9JHfOF5EIunlLWpnwaaSDia', 'student', '2025-10-20 08:05:35', 0, NULL, NULL, NULL, NULL),
(88, 'David M', NULL, 'davidm@any.com', '$2y$10$Zfp4jJg5UoV1F/QskVOZOuVB2dmIaQJz7o/a2iiUBLUvsy.FeWF1y', 'student', '2025-10-20 08:08:20', 0, NULL, NULL, NULL, NULL),
(101, 'Stefan', NULL, 'stefanjhonn123@gmail.com', '$2y$10$rvTVSIR8OncvaEO9dMFcXuzNnyVrNYxlfqt283PLbJCQ13h/.mMoy', 'student', '2025-10-23 13:13:01', 0, '08285779742', NULL, NULL, NULL),
(105, 'stefan', NULL, 'delgado..@gmail.com', '$2y$10$JLkAitV4EourWM9BUYGsSOugW/n.GGKf..Vsd9CD9MYZvb.636Uuy', 'student', '2025-10-23 14:56:41', 0, NULL, NULL, NULL, NULL),
(110, 'stefan', NULL, 'delgado@gmail.com', '$2y$10$V89dE6lppR/fL8JKDO76juIn2V.2w1LV7JAR/JrIMVXnBhTRq4hii', 'student', '2025-10-23 15:03:01', 1, NULL, NULL, NULL, NULL),
(111, 'stefan', NULL, 'delgado@email.com', '$2y$10$W5T.vN0ZNAOBxPuvN.AQSu5rcXUfkIhYO7m.M4iO/4iJ1sMx7IfS2', 'student', '2025-10-23 15:04:07', -1, NULL, NULL, NULL, NULL),
(112, 'Stefan Jhonn Delgado', NULL, 'stefan123@gmail.com', '$2y$10$42cwjS3VuYdk9n/ROM/ppezgz.HTPygTaN8uY66gsGKXpVepG62FC', 'student', '2025-11-21 07:32:04', 1, NULL, NULL, NULL, NULL),
(113, 'Sid Delgado', NULL, 'sid123@gmail.com', '$2y$10$bJj0JtE1.vJ6OSfdqrlssu9.LOmmWBzC2gcaOa.e01mMx0t8QxT.m', 'student', '2025-11-21 13:41:25', 1, '0909090909', NULL, NULL, NULL),
(114, 'Brad ed Sale', NULL, 'salebred@gmail.com', '$2y$10$gZycN7dNwWJd.qTgLosy8OugIEuhiLFFJULJFIdJ4ZqJM10NLZyo.', 'student', '2025-11-22 01:33:48', 1, NULL, NULL, NULL, NULL),
(115, 'Noel Lacson', '', 'n.lacson@gmail.com', '$2y$10$r759pRJKuLtCv38N2kzHX.KjPTWLYidSg4ifyUI.hEVttRoNavhMe', 'admin', '2025-11-22 02:46:54', 1, '', 'N/A', NULL, NULL),
(116, 'Roger Intong', NULL, 'r.intong@gmail.com', '$2y$10$YXCsRSsgMFqxKhhJwQ.ZZuAdoGhbkZoWDENRrz4ZPayOuR7Gj8EVm', 'owner', '2025-11-22 02:55:16', 1, '09123456789', NULL, NULL, NULL),
(117, 'braded', NULL, 'salebrod@gmail.com', '$2y$10$fwCjV269FSV7hS3QHDY/UukjBNMH2dgExKhk/E6cgo1vwyegKCWee', 'student', '2025-11-22 03:13:41', 1, NULL, NULL, NULL, NULL),
(118, 'Niel Bunda', NULL, 'n.bunda@gmail.com', '$2y$10$IITbJeYCikzOJDT4jauC6.a9qRUqf9MjKTP.dEuJl2gxEF3l8zLCq', 'student', '2025-11-22 03:14:21', 1, NULL, NULL, NULL, NULL),
(119, 'bradsale', NULL, 'sale@gmail.com', '$2y$10$o4tvFFP9JRlY3R9PIticiOn2/GE9whwDef30dud0A4.31PQGM9SK.', 'owner', '2025-11-22 03:15:06', 1, NULL, NULL, NULL, NULL),
(120, 'rad', NULL, 'salbrad@gmail.com', '$2y$10$VnBmpUU8gej64u1sq5XKI.nCYJyvSkjmBTKH/V.GJF9oEB/HooB7S', 'student', '2025-11-22 03:22:41', 1, NULL, NULL, NULL, NULL),
(121, 'John Paul Gones', NULL, 'john@gmail.com', '$2y$10$c.du2/EgyuGdiv7joovUf.42P7VGe2jGwbKifBqxTBwtqCOAjgHOO', 'student', '2025-11-22 03:23:09', 1, NULL, NULL, NULL, NULL),
(122, 'John Denver', NULL, 'denver@gmail.com', '$2y$10$sO2yWDfLaKOmG5NPAJujnufh3HSGCEgJFiRJWHQ5nbQ/kvz0JRO92', 'owner', '2025-11-24 23:45:22', 1, '09867342564', NULL, NULL, NULL),
(123, 'Hi hello', NULL, 'hello@gmail.com', '$2y$10$Ct15sIzxTNedz0r3A8OGYuVwKjeMdXJSJD7nJXrd1uc/9eBfCJa1i', 'student', '2025-11-26 07:18:13', 1, NULL, NULL, NULL, NULL);

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
-- Table structure for table `user_verifications`
--

CREATE TABLE `user_verifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `token` varchar(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_verifications`
--

INSERT INTO `user_verifications` (`id`, `user_id`, `token`, `expires_at`, `created_at`) VALUES
(1, 89, '83eac12bd4cc9af6096a69afbddf87b5', '2025-10-24 10:35:20', '2025-10-23 10:35:20'),
(2, 90, 'b68128e8bcd9f9d896fe8200104a6a51', '2025-10-24 10:47:01', '2025-10-23 10:47:01'),
(3, 91, 'a8e42d74def3ca134a58177c3dc1e82d', '2025-10-24 10:57:06', '2025-10-23 10:57:06'),
(4, 92, 'fadb6000d8eafd1d69b97fec263cd133', '2025-10-24 11:09:31', '2025-10-23 11:09:31'),
(5, 93, '42596efb0afb325243698c2ede53a52a', '2025-10-24 11:51:44', '2025-10-23 11:51:44'),
(6, 94, 'c4c5b94492a5cbca088a50d71e687cb9', '2025-10-24 12:01:44', '2025-10-23 12:01:44'),
(7, 95, 'bfbf6142180a5e370d480c6244d55eeb', '2025-10-24 12:09:41', '2025-10-23 12:09:41'),
(8, 96, 'd80850b08e51e53e740911e8bfe51302', '2025-10-24 12:12:37', '2025-10-23 12:12:37'),
(9, 97, '07948dd7f7c248a3a74e6852f75f73d4', '2025-10-24 12:19:35', '2025-10-23 12:19:35'),
(10, 98, '6bb479aaba67b9ddfed8cb51b28bafa9', '2025-10-24 12:23:23', '2025-10-23 12:23:23'),
(11, 99, 'ed3fd1f8889ca5002d5bdb89304cca39', '2025-10-24 12:37:05', '2025-10-23 12:37:05'),
(12, 100, 'a8e4640eb9eea875af1fa813e11528d4', '2025-10-24 13:01:55', '2025-10-23 13:01:55'),
(13, 101, 'e778dccd57e83c919ef22f04ff51d817', '2025-10-24 13:13:01', '2025-10-23 13:13:01'),
(14, 102, '4bb34438936dd4e73bce373c9c98a482', '2025-10-24 14:36:16', '2025-10-23 14:36:16'),
(15, 103, '550762992896c4e1d7ea5bea6c4194f0', '2025-10-24 14:37:02', '2025-10-23 14:37:02'),
(16, 104, '8384b5959c2e925d3e873bcc435384ba', '2025-10-24 14:37:30', '2025-10-23 14:37:30'),
(17, 113, 'c8c811d5a5ddc13c664948d9b54b7548', '2025-11-22 13:41:25', '2025-11-21 13:41:25'),
(18, 116, '7b839e8c5eefed6ec76475078bebe6d0', '2025-11-23 02:55:16', '2025-11-22 02:55:16'),
(19, 122, '8325227dae37c241c729c9a42039548f', '2025-11-25 23:45:22', '2025-11-24 23:45:22');

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
-- Indexes for table `checkout_requests`
--
ALTER TABLE `checkout_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `booking_id` (`booking_id`);

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
-- Indexes for table `user_verifications`
--
ALTER TABLE `user_verifications`
  ADD PRIMARY KEY (`id`);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `booking_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT for table `checkout_requests`
--
ALTER TABLE `checkout_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dormitories`
--
ALTER TABLE `dormitories`
  MODIFY `dorm_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `dorm_images`
--
ALTER TABLE `dorm_images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `payment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=76;

--
-- AUTO_INCREMENT for table `payment_schedules`
--
ALTER TABLE `payment_schedules`
  MODIFY `schedule_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `review_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `rooms`
--
ALTER TABLE `rooms`
  MODIFY `room_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=75;

--
-- AUTO_INCREMENT for table `room_images`
--
ALTER TABLE `room_images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `tenants`
--
ALTER TABLE `tenants`
  MODIFY `tenant_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=124;

--
-- AUTO_INCREMENT for table `user_preferences`
--
ALTER TABLE `user_preferences`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

--
-- AUTO_INCREMENT for table `user_verifications`
--
ALTER TABLE `user_verifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

-- --------------------------------------------------------

--
-- Structure for view `view_active_tenants`
--
DROP TABLE IF EXISTS `view_active_tenants`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_active_tenants`  AS SELECT `t`.`tenant_id` AS `tenant_id`, `t`.`booking_id` AS `booking_id`, `t`.`student_id` AS `student_id`, `u`.`name` AS `student_name`, `u`.`email` AS `student_email`, `u`.`phone` AS `student_phone`, `t`.`dorm_id` AS `dorm_id`, `d`.`name` AS `dorm_name`, `d`.`address` AS `dorm_address`, `t`.`room_id` AS `room_id`, `r`.`room_type` AS `room_type`, `r`.`capacity` AS `capacity`, `r`.`price` AS `room_price`, `t`.`check_in_date` AS `check_in_date`, `t`.`expected_checkout` AS `expected_checkout`, to_days(`t`.`expected_checkout`) - to_days(curdate()) AS `days_remaining`, `t`.`total_paid` AS `total_paid`, `t`.`outstanding_balance` AS `outstanding_balance`, `b`.`booking_type` AS `booking_type`, `t`.`created_at` AS `tenancy_start` FROM ((((`tenants` `t` join `users` `u` on(`t`.`student_id` = `u`.`user_id`)) join `dormitories` `d` on(`t`.`dorm_id` = `d`.`dorm_id`)) join `rooms` `r` on(`t`.`room_id` = `r`.`room_id`)) join `bookings` `b` on(`t`.`booking_id` = `b`.`booking_id`)) WHERE `t`.`status` = 'active' ;

-- --------------------------------------------------------

--
-- Structure for view `view_owner_stats`
--
DROP TABLE IF EXISTS `view_owner_stats`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_owner_stats`  AS SELECT `d`.`owner_id` AS `owner_id`, count(distinct `d`.`dorm_id`) AS `total_dorms`, count(distinct `r`.`room_id`) AS `total_rooms`, count(distinct case when `t`.`status` = 'active' then `t`.`tenant_id` end) AS `active_tenants`, count(distinct case when `b`.`status` = 'pending' then `b`.`booking_id` end) AS `pending_bookings`, coalesce(sum(case when `p`.`status` in ('paid','verified') and `p`.`payment_date` >= curdate() - interval 30 day then `p`.`amount` end),0) AS `monthly_revenue`, coalesce(sum(case when `p`.`status` in ('pending','submitted') then `p`.`amount` end),0) AS `pending_payments` FROM ((((`dormitories` `d` left join `rooms` `r` on(`d`.`dorm_id` = `r`.`dorm_id`)) left join `bookings` `b` on(`r`.`room_id` = `b`.`room_id`)) left join `tenants` `t` on(`b`.`booking_id` = `t`.`booking_id`)) left join `payments` `p` on(`b`.`booking_id` = `p`.`booking_id`)) GROUP BY `d`.`owner_id` ;

-- --------------------------------------------------------

--
-- Structure for view `view_tenant_payments`
--
DROP TABLE IF EXISTS `view_tenant_payments`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_tenant_payments`  AS SELECT `t`.`tenant_id` AS `tenant_id`, `t`.`student_id` AS `student_id`, `u`.`name` AS `student_name`, `t`.`dorm_id` AS `dorm_id`, `d`.`name` AS `dorm_name`, `t`.`room_id` AS `room_id`, `r`.`room_type` AS `room_type`, count(`p`.`payment_id`) AS `total_payments`, coalesce(sum(case when `p`.`status` in ('paid','verified') then `p`.`amount` end),0) AS `total_paid`, coalesce(sum(case when `p`.`status` in ('pending','submitted') then `p`.`amount` end),0) AS `pending_amount`, max(`p`.`payment_date`) AS `last_payment_date`, `t`.`outstanding_balance` AS `outstanding_balance` FROM ((((`tenants` `t` join `users` `u` on(`t`.`student_id` = `u`.`user_id`)) join `dormitories` `d` on(`t`.`dorm_id` = `d`.`dorm_id`)) join `rooms` `r` on(`t`.`room_id` = `r`.`room_id`)) left join `payments` `p` on(`t`.`booking_id` = `p`.`booking_id`)) WHERE `t`.`status` = 'active' GROUP BY `t`.`tenant_id`, `t`.`student_id`, `u`.`name`, `t`.`dorm_id`, `d`.`name`, `t`.`room_id`, `r`.`room_type`, `t`.`outstanding_balance` ;

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
-- Constraints for table `checkout_requests`
--
ALTER TABLE `checkout_requests`
  ADD CONSTRAINT `checkout_requests_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE;

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
