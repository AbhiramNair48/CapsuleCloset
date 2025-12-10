-- Create the users table

CREATE DATABASE capsule_closet;
USE capsule_closet;
CREATE TABLE users(
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    friends TEXT,
    pending_friend_requests TEXT
    );


-- Create the closet table
CREATE TABLE closet(
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    clothing_type VARCHAR(100),
    color VARCHAR(100),
    material VARCHAR(100),
    style VARCHAR(100),
    description TEXT,
    img_filename VARCHAR(255) NOT NULL,
    public BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);