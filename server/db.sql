CREATE database if not EXISTS delivery;
use delivery;
-- Table to store users
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    phone VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL
);

-- Table to store service requests
CREATE TABLE IF NOT EXISTS service_requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    request_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    service_type VARCHAR(100) NOT NULL,
    details TEXT,
    status VARCHAR(20) DEFAULT 'Pending',
    estimated_arrival_time varchar(20),
    employee_id INT
);

-- Table to store transactions
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    request_id INT,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50),
    transaction_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table to store ratings and feedback
CREATE TABLE IF NOT EXISTS ratings_feedback (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    request_id INT,
    rating INT NOT NULL,
    feedback TEXT,
    rating_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table to store assistance and resources
CREATE TABLE IF NOT EXISTS assistance_resources (
    resource_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    content TEXT,
    category VARCHAR(50)
);

-- Table to store service providers
CREATE TABLE IF NOT EXISTS service_providers (
    provider_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role INT NOT NULL
);

-- Table to store admin data
CREATE TABLE IF NOT EXISTS admins (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL
);

-- Table to store user and employee locations
CREATE TABLE IF NOT EXISTS locations_user (
    location_id int(255) AUTO_INCREMENT PRIMARY KEY,
    user_id int(6),
    longitude VARCHAR(50) NOT NULL,
    latitude VARCHAR(50) NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS locations_employe (
    location_id int(255) AUTO_INCREMENT PRIMARY KEY,
    employee_id int(6),
    longitude VARCHAR(50) NOT NULL,
    latitude VARCHAR(50) NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
