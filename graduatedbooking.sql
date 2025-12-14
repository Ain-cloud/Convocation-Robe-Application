-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 13, 2025 at 09:03 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `graduatedbooking`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `booking_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `robe_id` int(11) NOT NULL,
  `booking_date` date NOT NULL,
  `status` enum('Active','Past') DEFAULT 'Active',
  `collection_status` enum('Ongoing','Collected','Returned') DEFAULT 'Ongoing'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`booking_id`, `user_id`, `robe_id`, `booking_date`, `status`, `collection_status`) VALUES
(1, 14, 17, '2025-01-11', 'Active', 'Collected'),
(2, 16, 16, '2025-01-12', 'Active', 'Collected'),
(6, 17, 3, '2025-01-21', 'Active', 'Collected'),
(17, 21, 1, '2025-01-29', 'Active', 'Ongoing');

-- --------------------------------------------------------

--
-- Table structure for table `rentals`
--

CREATE TABLE `rentals` (
  `rental_id` int(11) NOT NULL,
  `robe_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `rental_date` date NOT NULL,
  `due_date` date NOT NULL,
  `return_date` date DEFAULT NULL,
  `rental_fee` decimal(10,2) DEFAULT NULL,
  `quantity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reports`
--

CREATE TABLE `reports` (
  `id` int(11) NOT NULL,
  `batch` varchar(10) NOT NULL,
  `robe_type` enum('Bachelor Robe','Master Robe','PhD Robe') NOT NULL,
  `size` enum('XS','S','M','L') NOT NULL,
  `stock` int(11) DEFAULT 0,
  `collected` int(11) DEFAULT 0,
  `returned` int(11) DEFAULT 0,
  `flagged` int(11) DEFAULT 0,
  `future_req` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `reports`
--

INSERT INTO `reports` (`id`, `batch`, `robe_type`, `size`, `stock`, `collected`, `returned`, `flagged`, `future_req`) VALUES
(1, '2024', 'Bachelor Robe', 'XS', 1, 0, 0, 0, 0),
(2, '2024', 'Master Robe', 'XS', 1, 0, 0, 0, 0),
(3, '2024', 'PhD Robe', 'XS', 0, 1, 0, 0, 1),
(4, '2024', 'Bachelor Robe', 'S', 1, 0, 0, 0, 0),
(5, '2024', 'Master Robe', 'S', 0, 1, 0, 0, 1),
(6, '2024', 'PhD Robe', 'S', 0, 1, 0, 0, 1),
(7, '2024', 'Bachelor Robe', 'M', 1, 0, 0, 0, 0),
(8, '2024', 'Master Robe', 'M', 1, 0, 0, 0, 0),
(9, '2024', 'PhD Robe', 'M', 1, 0, 0, 0, 0),
(10, '2024', 'Bachelor Robe', 'L', 1, 0, 0, 0, 0),
(11, '2024', 'Master Robe', 'L', 1, 0, 0, 0, 0),
(12, '2024', 'PhD Robe', 'L', 1, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `robes`
--

CREATE TABLE `robes` (
  `robe_id` int(11) NOT NULL,
  `type` enum('Bachelor Robe','Master Robe','PhD Robe') NOT NULL,
  `size` enum('XS','S','M','L') NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `status` enum('Available','Unavailable') NOT NULL DEFAULT 'Available',
  `batch` int(4) DEFAULT NULL,
  `robe_condition` enum('Perfect','Maintenance','Repair') NOT NULL DEFAULT 'Perfect'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `robes`
--

INSERT INTO `robes` (`robe_id`, `type`, `size`, `price`, `image_url`, `status`, `batch`, `robe_condition`) VALUES
(1, 'Bachelor Robe', 'XS', 60.00, 'assets/Bachelor_robe.jpg', 'Available', 2024, 'Perfect'),
(2, 'Master Robe', 'XS', 70.00, 'assets/Master_robe.jpg', 'Available', 2024, 'Perfect'),
(3, 'PhD Robe', 'XS', 80.00, 'assets/PHD_robe.jpg', 'Available', 2024, 'Perfect'),
(5, 'Master Robe', 'M', 70.00, 'assets/Master_robe.jpg', 'Available', 2024, 'Perfect'),
(6, 'PhD Robe', 'M', 80.00, 'assets/PHD_robe.jpg', 'Available', 2024, 'Perfect'),
(7, 'Bachelor Robe', 'L', 60.00, 'assets/Bachelor_robe.jpg', 'Available', 2024, 'Perfect'),
(9, 'PhD Robe', 'L', 80.00, 'assets/PHD_robe.jpg', 'Available', 2024, 'Perfect'),
(10, 'Bachelor Robe', 'S', 60.00, 'assets/Bachelor_robe.jpg', 'Available', 2024, 'Perfect'),
(16, 'Master Robe', 'S', 70.00, 'assets/Master_robe.jpg', 'Available', 2024, 'Perfect'),
(17, 'PhD Robe', 'S', 80.00, 'assets/PHD_robe.jpg', 'Available', 2024, 'Perfect'),
(19, 'Bachelor Robe', 'M', 60.00, 'assets/Bachelor_robe.jpg', 'Available', 2024, 'Perfect'),
(20, 'Master Robe', 'L', 70.00, 'assets/Master_robe.jpg', 'Available', 2024, 'Perfect'),
(21, 'Bachelor Robe', 'XS', 60.00, 'assets/Bachelor_robe.jpg', 'Available', 2024, 'Perfect'),
(22, 'Master Robe', 'M', 70.00, 'assets/Master_robe.jpg', 'Available', 2024, 'Perfect'),
(23, 'PhD Robe', 'L', 80.00, 'assets/PHD_robe.jpg', 'Available', 2024, 'Perfect'),
(24, 'Bachelor Robe', 'XS', 60.00, 'assets/Bachelor_robe.jpg', 'Available', 2024, 'Perfect'),
(35, 'Bachelor Robe', 'S', 60.00, 'assets/Bachelor_robe.jpg', 'Available', 2024, 'Perfect'),
(36, 'Bachelor Robe', 'S', 60.00, 'assets/Bachelor_robe.jpg', 'Available', 2024, 'Perfect'),
(37, 'Bachelor Robe', 'M', 60.00, 'assets/Bachelor_robe.jpg', 'Available', 2024, 'Perfect'),
(38, 'Bachelor Robe', 'M', 60.00, 'assets/Bachelor_robe.jpg', 'Available', 2024, 'Perfect'),
(39, 'Bachelor Robe', 'L', 60.00, 'assets/Bachelor_robe.jpg', 'Available', 2024, 'Perfect'),
(40, 'Bachelor Robe', 'L', 60.00, 'assets/Bachelor_robe.jpg', 'Available', 2024, 'Perfect'),
(41, 'Master Robe', 'XS', 70.00, 'assets/Master_robe.jpg', 'Available', 2024, 'Perfect'),
(42, 'Master Robe', 'XS', 70.00, 'assets/Master_robe.jpg', 'Available', 2024, 'Perfect'),
(43, 'Master Robe', 'S', 70.00, 'assets/Master_robe.jpg', 'Available', 2024, 'Perfect'),
(44, 'Master Robe', 'S', 70.00, 'assets/Master_robe.jpg', 'Available', 2024, 'Perfect'),
(45, 'Master Robe', 'M', 70.00, 'assets/Master_robe.jpg', 'Available', 2024, 'Perfect'),
(46, 'Master Robe', 'L', 70.00, 'assets/Master_robe.jpg', 'Available', 2024, 'Perfect'),
(47, 'Master Robe', 'L', 70.00, 'assets/Master_robe.jpg', 'Available', 2024, 'Perfect'),
(48, 'PhD Robe', 'XS', 80.00, 'assets/PHD_robe.jpg', 'Available', 2024, 'Perfect'),
(49, 'PhD Robe', 'XS', 80.00, 'assets/PHD_robe.jpg', 'Available', 2024, 'Perfect'),
(50, 'PhD Robe', 'S', 80.00, 'assets/PHD_robe.jpg', 'Available', 2024, 'Perfect'),
(51, 'PhD Robe', 'S', 80.00, 'assets/PHD_robe.jpg', 'Available', 2024, 'Perfect'),
(52, 'PhD Robe', 'M', 80.00, 'assets/PHD_robe.jpg', 'Available', 2024, 'Perfect'),
(53, 'PhD Robe', 'M', 80.00, 'assets/PHD_robe.jpg', 'Available', 2024, 'Perfect'),
(54, 'PhD Robe', 'L', 80.00, 'assets/PHD_robe.jpg', 'Available', 2024, 'Perfect');

-- --------------------------------------------------------

--
-- Table structure for table `robes_status`
--

CREATE TABLE `robes_status` (
  `id` int(11) NOT NULL,
  `types` varchar(255) NOT NULL,
  `size` varchar(50) NOT NULL,
  `status` enum('true','false') DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `robes_status`
--

INSERT INTO `robes_status` (`id`, `types`, `size`, `status`, `image_url`) VALUES
(1, 'Bachelor', 'XS', 'true', 'assets/Bachelor_robe.jpg'),
(2, 'Bachelor', 'S', 'true', 'assets/Bachelor_robe.jpg'),
(3, 'Bachelor', 'M', 'true', 'assets/Bachelor_robe.jpg'),
(4, 'Bachelor', 'L', 'true', 'assets/Bachelor_robe.jpg'),
(5, 'Master ', 'XS', 'true', 'assets/Master_robe.jpg'),
(6, 'Master ', 'S', 'true', 'assets/Master_robe.jpg'),
(7, 'Master ', 'M', 'true', 'assets/Master_robe.jpg'),
(8, 'Master ', 'L', 'true', 'assets/Master_robe.jpg'),
(9, 'PhD', 'XS', 'true', 'assets/PHD_robe.jpg'),
(10, 'PhD', 'S', 'true', 'assets/PHD_robe.jpg'),
(11, 'PhD', 'M', 'true', 'assets/PHD_robe.jpg'),
(12, 'PhD', 'L', 'true', 'assets/PHD_robe.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(350) NOT NULL,
  `password` varchar(100) NOT NULL,
  `phone_number` varchar(15) NOT NULL,
  `role` enum('admin','user') NOT NULL DEFAULT 'user',
  `outstanding_payment` double NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `email`, `password`, `phone_number`, `role`, `outstanding_payment`) VALUES
(14, 'arip', 'dummy1@siswa.unimas.my', '$2a$10$bqjr4AeX1UrePxnXFSD6OOGhn4CBn.7XAKd7v2jJSzyN3hNknOlYa', '123456789', 'user', 0),
(15, 'tset', 'dummy2@siswa.unimas.my', '$2a$10$ibzix6q/9eg2Ve0LpvUaReJ6xixWCvMdyo.rJxvAxvWa.5ZGoog9S', '123456789', 'admin', 0),
(16, 'test1', 'dummy3@siswa.unimas.my', '$2a$10$AVXFRb20hBOrtbKjIQ3Yu./woz3aIiV.Jd5ThCGDZUHll3gosd9C2', '123456789', 'user', 0),
(17, 'test2', 'dummy4@siswa.unimas.my', '$2a$10$np/FP0ThamdiytCRg96Mo.YI5QmUfiZQ8u0vdDhSL8JuavbCf2wKy', '123456789', 'user', 0),
(19, 'RequaL', 'abgmizan@siswa.unimas.my', '$2a$10$ii5HF6V5cwLPZPIEKmd4aO5STDtbqyMa9aBiK9H3xBLtPXCwc4tyi', '01125054256', 'user', 0),
(20, 'Rafif', 'Rafif@siswa.unimas.my', '$2a$10$HQGngpY4w70nywhehTIO2eG457bfxT5NdFJd0UoHFprMCN7K/iKuC', '1234567890', 'user', 0),
(21, 'Mizan', 'abgmizan3@siswa.unimas.my', '$2a$10$BGKfkZ..amD58TH8WMdAq.S2rh48XIycS15xiv9/HaOfTtLJXZU4G', '1234567890', 'user', 60);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `robe_id` (`robe_id`);

--
-- Indexes for table `rentals`
--
ALTER TABLE `rentals`
  ADD PRIMARY KEY (`rental_id`),
  ADD KEY `robe_id` (`robe_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `robes`
--
ALTER TABLE `robes`
  ADD PRIMARY KEY (`robe_id`);

--
-- Indexes for table `robes_status`
--
ALTER TABLE `robes_status`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `booking_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `rentals`
--
ALTER TABLE `rentals`
  MODIFY `rental_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `reports`
--
ALTER TABLE `reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `robes`
--
ALTER TABLE `robes`
  MODIFY `robe_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT for table `robes_status`
--
ALTER TABLE `robes_status`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`robe_id`) REFERENCES `robes` (`robe_id`);

--
-- Constraints for table `rentals`
--
ALTER TABLE `rentals`
  ADD CONSTRAINT `rentals_ibfk_1` FOREIGN KEY (`robe_id`) REFERENCES `robes` (`robe_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `rentals_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
