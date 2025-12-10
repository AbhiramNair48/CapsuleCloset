-- Create the users table
CREATE DATABASE capsule_closet;
USE capsule_closet;
CREATE TABLE users(
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    );


-- Create the closet table
CREATE TABLE closet(
    user_id INT NOT NULL,
    clothing_type VARCHAR(100),
    color VARCHAR(100),
    material VARCHAR(100),
    style VARCHAR(100),
    description TEXT,
    img_filename VARCHAR(255) NOT NULL,
    public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


-- Friendship system
CREATE TABLE friendships (
    user_id INT NOT NULL,
    friend_id INT NOT NULL,
    status ENUM('pending', 'accepted', 'blocked') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, friend_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (friend_id) REFERENCES users(id) ON DELETE CASCADE
)

