
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'Tome')
BEGIN
    CREATE DATABASE Tome;
END
GO

USE Tome;
GO


DROP TABLE IF EXISTS reading_logs;
DROP TABLE IF EXISTS reading_goals;
DROP TABLE IF EXISTS user_books;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS CAULACBO, SANVD, QUOCGIA, TINH;
GO


CREATE TABLE users (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
);
GO

-- 2. Books table
CREATE TABLE books (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    genre VARCHAR(100),
    total_pages INT CHECK (total_pages > 0),
    description VARCHAR(MAX),
    created_at DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
);
GO


CREATE TABLE user_books (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    book_id BIGINT NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'WANT_TO_READ'
        CHECK (status IN (
            'WANT_TO_READ',
            'READING',
            'COMPLETED',
            'PAUSED'
        )),
    current_page INT NOT NULL DEFAULT 0 CHECK (current_page >= 0),
    started_at DATE,
    finished_at DATE,
    added_at DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),

    CONSTRAINT uq_user_book UNIQUE (user_id, book_id),
    CONSTRAINT ck_user_book_dates
        CHECK (finished_at IS NULL OR started_at IS NULL OR finished_at >= started_at)
);
GO


CREATE TABLE reading_logs (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_book_id BIGINT NOT NULL REFERENCES user_books(id) ON DELETE CASCADE,
    reading_date DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    pages_read INT NOT NULL CHECK (pages_read > 0),
    note VARCHAR(MAX),
    created_at DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
);
GO


CREATE TABLE reading_goals (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    goal_type VARCHAR(20) NOT NULL CHECK (goal_type IN ('BOOKS', 'PAGES')),
    target_value INT NOT NULL CHECK (target_value > 0),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    created_at DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),

    CONSTRAINT ck_goal_period CHECK (period_end >= period_start)
);
GO


CREATE INDEX idx_user_books_user_id ON user_books(user_id);
CREATE INDEX idx_user_books_book_id ON user_books(book_id);
CREATE INDEX idx_reading_logs_user_book_date ON reading_logs(user_book_id, reading_date);
CREATE INDEX idx_reading_goals_user_period ON reading_goals(user_id, period_start, period_end);
GO


SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'dbo' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
GO

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'user_books'
ORDER BY ordinal_position;