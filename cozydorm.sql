-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Oct 12, 2025 at 01:26 PM
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
  `status` enum('pending','approved','rejected','cancelled') NOT NULL DEFAULT 'pending',
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` datetime DEFAULT NULL,
  `selfie` varchar(255) DEFAULT NULL,
  `id_document` varchar(255) DEFAULT NULL,
  `display_picture` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`booking_id`, `room_id`, `student_id`, `booking_type`, `start_date`, `end_date`, `status`, `updated_at`, `created_at`, `expires_at`, `selfie`, `id_document`, `display_picture`, `notes`) VALUES
(7, 18, 9, 'shared', '2025-10-07', '2026-04-07', 'cancelled', '2025-10-12 11:00:18', '2025-10-07 02:43:54', '2025-10-07 06:43:54', NULL, NULL, NULL, NULL),
(8, 23, 30, 'shared', '2025-10-10', '2026-04-10', 'cancelled', '2025-10-12 11:00:18', '2025-10-10 17:16:37', '2025-10-10 19:16:37', NULL, NULL, NULL, NULL),
(10, 26, 11, 'shared', '2025-10-11', '2026-04-11', 'cancelled', '2025-10-12 11:00:18', '2025-10-11 09:43:38', '2025-10-11 11:43:38', NULL, NULL, NULL, NULL),
(11, 22, 11, 'shared', '2025-10-11', '2026-04-11', 'pending', '2025-10-12 11:00:18', '2025-10-11 22:39:05', '2025-10-12 00:39:05', NULL, NULL, NULL, NULL),
(12, 22, 47, 'shared', '2025-10-12', '2026-04-12', 'cancelled', '2025-10-12 11:00:18', '2025-10-12 13:45:18', '2025-10-12 15:45:18', NULL, NULL, NULL, NULL),
(13, 23, 47, 'shared', '2025-10-12', '2026-04-12', 'cancelled', '2025-10-12 11:00:18', '2025-10-12 13:49:02', '2025-10-12 15:49:02', NULL, NULL, NULL, NULL),
(26, 28, 31, 'whole', '2025-10-12', '2026-04-12', 'approved', '2025-10-12 12:26:56', '2025-10-12 19:26:47', '2025-10-12 21:26:47', NULL, NULL, NULL, NULL);

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
(3, 5, 'Blue Haven Dormitory', 'Araneta Avenue, Bacolod City', 'Close to universities, laundry service available, 24/7 security.', 1, '2025-08-22 02:25:32', NULL, NULL, 'pending', '2025-10-11 06:08:50', NULL, NULL),
(4, 4, 'Evergreen Dorms', 'Burgos Avenue, Bacolod City', 'Spacious rooms with air conditioning and shared kitchen.', 0, '2025-08-22 02:30:36', NULL, NULL, 'pending', '2025-10-07 01:47:34', NULL, NULL),
(5, 8, 'Southern Oasis', 'P Hernaez St.', 'A cozy dorm with a cozy atmosphere', 1, '2025-10-07 01:15:32', NULL, NULL, 'pending', '2025-10-07 01:47:24', 'dorm_68e469b41e437.png', 'Free Wifi, Aircon, Meals provided every morning.'),
(6, 15, 'Anna\'s Haven Dormitory', '12th Street, Lacson Extension, Bacolod City', 'A cozy and affordable dorm perfect for university students. Located near major schools and transport lines.', 0, '2025-10-10 16:58:30', NULL, NULL, 'pending', '2025-10-11 06:08:31', 'dorm_68e93b36b97a4.png', 'Wi-Fi, Study Lounge, CCTV Security, Air-conditioned Rooms, Laundry Area'),
(7, 45, 'lozola', 'Bacolod', 'Secure and awesome', 1, '2025-10-11 07:32:12', NULL, NULL, 'pending', '2025-10-11 07:33:36', 'dorm_68ea07fc77de4.jpg', 'Wifi, Aircon, Study Room, Kitchen,');

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
(6, 15, 30, 6, NULL, 'Hi your downpayment is due', '2025-10-10 10:24:03', NULL, 'normal', NULL, NULL),
(7, 45, 11, 7, NULL, 'hi', '2025-10-11 02:45:07', '2025-10-11 02:46:01', 'normal', NULL, NULL),
(8, 45, 11, 7, NULL, 'hi', '2025-10-11 02:46:05', '2025-10-11 02:46:07', 'normal', NULL, NULL),
(9, 45, 11, 7, NULL, 'hi', '2025-10-11 02:46:38', '2025-10-11 02:46:40', 'normal', NULL, NULL),
(10, 11, 45, 7, NULL, 'hello sir', '2025-10-11 02:46:48', '2025-10-11 02:46:51', 'normal', NULL, NULL),
(11, 45, 11, 7, NULL, 'yo', '2025-10-11 02:47:06', '2025-10-11 02:47:06', 'normal', NULL, NULL),
(12, 11, 45, 7, NULL, 'hello sir', '2025-10-11 02:47:31', NULL, 'normal', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `payment_id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `student_id` int(11) DEFAULT NULL,
  `owner_id` int(11) DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `status` enum('pending','paid','expired','rejected','submitted') DEFAULT 'pending',
  `payment_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `due_date` date DEFAULT NULL,
  `receipt_image` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` datetime DEFAULT current_timestamp(),
  `reminder_sent` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`payment_id`, `booking_id`, `student_id`, `owner_id`, `amount`, `status`, `payment_date`, `due_date`, `receipt_image`, `notes`, `updated_at`, `created_at`, `reminder_sent`) VALUES
(10, 26, 31, NULL, 4000.00, 'submitted', '2025-10-12 19:26:56', '2025-10-12', 'receipt_10_1760300247.png', NULL, '2025-10-12 13:17:27', '2025-10-12 12:26:56', 0);

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
(23, 6, 'SIngle', 4, NULL, 100.00, 'vacant', '2025-10-10 17:04:02', NULL, NULL),
(26, 7, 'twin', 2, NULL, 2000.00, 'vacant', '2025-10-11 09:42:05', NULL, NULL),
(27, 7, 'twin', 2, '', 3000.00, 'vacant', '2025-10-12 13:42:13', NULL, NULL),
(28, 6, 'Single', 6, NULL, 4000.00, 'vacant', '2025-10-12 15:14:11', NULL, NULL);

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
(18, 'Leo Gutierrez', NULL, 'leo.g@email.com', '$2y$10$FIMS9XX/o8/o30PF8KuiUOB9Lp2JE06cNR9BcPowbp9z22dtuXvk6', 'student', '2025-10-09 05:28:40', 0, '09456789012', NULL, NULL, NULL),
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
(47, 'Jan Pol Gomes', NULL, 'janpol@gmail.com', '$2y$10$OZp52j10PNJnJFs.yZGlYua5JWxTES1BJmrG.k/yrNz1S6xBrcqPC', 'student', '2025-10-11 10:06:43', 0, '09453196127', NULL, NULL, NULL);

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
  ADD KEY `student_id` (`student_id`);

--
-- Indexes for table `dormitories`
--
ALTER TABLE `dormitories`
  ADD PRIMARY KEY (`dorm_id`),
  ADD KEY `owner_id` (`owner_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `idx_thread` (`sender_id`,`receiver_id`,`dorm_id`),
  ADD KEY `idx_inbox` (`receiver_id`,`read_at`),
  ADD KEY `fk_msg_dorm` (`dorm_id`),
  ADD KEY `fk_msg_booking` (`booking_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `fk_payment_booking` (`booking_id`),
  ADD KEY `fk_payment_student` (`student_id`),
  ADD KEY `fk_payment_owner` (`owner_id`);

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
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `announcements`
--
ALTER TABLE `announcements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `announcement_reads`
--
ALTER TABLE `announcement_reads`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `booking_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `dormitories`
--
ALTER TABLE `dormitories`
  MODIFY `dorm_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `payment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `review_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rooms`
--
ALTER TABLE `rooms`
  MODIFY `room_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `room_images`
--
ALTER TABLE `room_images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

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
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE;

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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
