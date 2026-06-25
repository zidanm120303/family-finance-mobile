-- direct_mysql_queries.sql
-- Kumpulan query konsep untuk repository Flutter direct MySQL.

-- Login by email or username
SELECT users.*, roles.role_name, families.family_name
FROM users
LEFT JOIN roles ON users.role_id = roles.id
LEFT JOIN families ON users.family_id = families.id
WHERE (users.email = ? OR users.username = ?)
  AND users.is_active = 1
LIMIT 1;

-- Update last login
UPDATE users SET last_login = NOW() WHERE id = ?;

-- Get role id
SELECT id FROM roles WHERE role_name = ? LIMIT 1;

-- Insert family
INSERT INTO families (family_code, family_name, address, city, province, postal_code, phone, created_at, updated_at)
VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW());

-- Insert user
INSERT INTO users (family_id, role_id, name, email, username, password, phone, is_active, created_at, updated_at)
VALUES (?, ?, ?, ?, ?, ?, ?, 1, NOW(), NOW());

-- Update family creator
UPDATE families SET created_by = ? WHERE id = ?;

-- Insert default wallet
INSERT INTO wallets (family_id, wallet_name, balance, type, account_number, created_at, updated_at)
VALUES (?, 'Cash', 0, 'cash', NULL, NOW(), NOW());

-- Insert category default
INSERT INTO categories (family_id, category_name, type, icon, color, description, is_default, created_at, updated_at)
VALUES (?, ?, ?, ?, ?, ?, 1, NOW(), NOW());

-- Get categories by type
SELECT * FROM categories
WHERE family_id = ? AND type = ?
ORDER BY is_default DESC, category_name ASC;

-- Get wallets
SELECT * FROM wallets
WHERE family_id = ?
ORDER BY type ASC, wallet_name ASC;

-- Insert transaction
INSERT INTO transactions
(family_id, user_id, category_id, wallet_id, transaction_code, type, amount, title, description, transaction_date, attachment, payment_method, status, created_at, updated_at)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW());

-- Update wallet income
UPDATE wallets
SET balance = balance + ?
WHERE id = ? AND family_id = ?;

-- Update wallet expense
UPDATE wallets
SET balance = balance - ?
WHERE id = ? AND family_id = ?;

-- Home total balance
SELECT COALESCE(SUM(balance), 0) AS total_balance
FROM wallets
WHERE family_id = ?;

-- Home income month
SELECT COALESCE(SUM(amount), 0) AS total_income
FROM transactions
WHERE family_id = ?
  AND type = 'income'
  AND status = 'success'
  AND MONTH(transaction_date) = ?
  AND YEAR(transaction_date) = ?;

-- Home expense month
SELECT COALESCE(SUM(amount), 0) AS total_expense
FROM transactions
WHERE family_id = ?
  AND type = 'expense'
  AND status = 'success'
  AND MONTH(transaction_date) = ?
  AND YEAR(transaction_date) = ?;

-- Recent transactions
SELECT t.*, c.category_name, c.icon, c.color, w.wallet_name, u.name AS user_name
FROM transactions t
LEFT JOIN categories c ON t.category_id = c.id
LEFT JOIN wallets w ON t.wallet_id = w.id
LEFT JOIN users u ON t.user_id = u.id
WHERE t.family_id = ?
ORDER BY t.transaction_date DESC, t.id DESC
LIMIT 5;

-- History transactions
SELECT t.*, c.category_name, c.icon, c.color, w.wallet_name, u.name AS user_name
FROM transactions t
LEFT JOIN categories c ON t.category_id = c.id
LEFT JOIN wallets w ON t.wallet_id = w.id
LEFT JOIN users u ON t.user_id = u.id
WHERE t.family_id = ?
ORDER BY t.transaction_date DESC, t.id DESC
LIMIT ? OFFSET ?;
