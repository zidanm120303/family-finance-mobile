class SqlQueries {
  const SqlQueries._();

  static const loginUser = '''
SELECT users.*, roles.role_name, families.family_name
FROM users
LEFT JOIN roles ON users.role_id = roles.id
LEFT JOIN families ON users.family_id = families.id
WHERE (users.email = :identity OR users.username = :identity)
  AND users.is_active = 1
LIMIT 1
''';

  static const updateLastLogin =
      'UPDATE users SET last_login = NOW() WHERE id = :id';

  static const getRoleId =
      'SELECT id FROM roles WHERE role_name = :role_name LIMIT 1';

  static const insertFamily = '''
INSERT INTO families (family_code, family_name, address, city, province, postal_code, phone, created_at, updated_at)
VALUES (:family_code, :family_name, NULL, :city, :province, NULL, :phone, NOW(), NOW())
''';

  static const insertUser = '''
INSERT INTO users (family_id, role_id, name, email, username, password, phone, is_active, created_at, updated_at)
VALUES (:family_id, :role_id, :name, :email, :username, :password, :phone, 1, NOW(), NOW())
''';

  static const updateFamilyCreator = '''
UPDATE families SET created_by = :user_id WHERE id = :family_id
''';

  static const insertDefaultWallet = '''
INSERT INTO wallets (family_id, wallet_name, balance, type, account_number, created_at, updated_at)
VALUES (:family_id, 'Cash', 0, 'cash', NULL, NOW(), NOW())
''';

  static const insertCategory = '''
INSERT INTO categories (family_id, category_name, type, icon, color, description, is_default, created_at, updated_at)
VALUES (:family_id, :category_name, :type, :icon, :color, :description, 1, NOW(), NOW())
''';

  static const categoriesByType = '''
SELECT *
FROM categories
WHERE family_id = :family_id AND type = :type
ORDER BY is_default DESC, category_name ASC
''';

  static const walletsByFamily = '''
SELECT *
FROM wallets
WHERE family_id = :family_id
ORDER BY type ASC, wallet_name ASC
''';

  static const totalBalance = '''
SELECT COALESCE(SUM(balance), 0) AS total_balance
FROM wallets
WHERE family_id = :family_id
''';

  static const incomeMonth = '''
SELECT COALESCE(SUM(amount), 0) AS total_income
FROM transactions
WHERE family_id = :family_id
  AND type = 'income'
  AND status = 'success'
  AND MONTH(transaction_date) = :month
  AND YEAR(transaction_date) = :year
''';

  static const expenseMonth = '''
SELECT COALESCE(SUM(amount), 0) AS total_expense
FROM transactions
WHERE family_id = :family_id
  AND type = 'expense'
  AND status = 'success'
  AND MONTH(transaction_date) = :month
  AND YEAR(transaction_date) = :year
''';

  static const recentTransactions = '''
SELECT t.*, c.category_name, c.icon, c.color, w.wallet_name, u.name AS user_name
FROM transactions t
LEFT JOIN categories c ON t.category_id = c.id
LEFT JOIN wallets w ON t.wallet_id = w.id
LEFT JOIN users u ON t.user_id = u.id
WHERE t.family_id = :family_id
ORDER BY t.transaction_date DESC, t.id DESC
LIMIT 5
''';

  static const transactionDetail = '''
SELECT t.*, c.category_name, c.icon, c.color, w.wallet_name, u.name AS user_name
FROM transactions t
LEFT JOIN categories c ON t.category_id = c.id
LEFT JOIN wallets w ON t.wallet_id = w.id
LEFT JOIN users u ON t.user_id = u.id
WHERE t.id = :id AND t.family_id = :family_id
LIMIT 1
''';

  static const insertTransaction = '''
INSERT INTO transactions
(family_id, user_id, category_id, wallet_id, transaction_code, type, amount, title, description, transaction_date, attachment, payment_method, status, created_at, updated_at)
VALUES (:family_id, :user_id, :category_id, :wallet_id, :transaction_code, :type, :amount, :title, :description, :transaction_date, NULL, :payment_method, 'success', NOW(), NOW())
''';

  static const walletBalance = '''
SELECT balance FROM wallets WHERE id = :wallet_id AND family_id = :family_id LIMIT 1
''';

  static const updateWalletIncome = '''
UPDATE wallets SET balance = balance + :amount WHERE id = :wallet_id AND family_id = :family_id
''';

  static const updateWalletExpense = '''
UPDATE wallets SET balance = balance - :amount WHERE id = :wallet_id AND family_id = :family_id
''';

  static const insertHistory = '''
INSERT INTO transaction_histories (transaction_id, user_id, action, old_data, new_data, note, created_at)
VALUES (:transaction_id, :user_id, 'create', NULL, NULL, :note, NOW())
''';
}
