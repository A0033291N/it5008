-- data.sql
-- Data insertion for Salero Bundo Restaurant Database
-- Inserting first 100 rows from order.csv (excluding header) and supporting reference data

-- ====================================================================
-- INSERT REFERENCE DATA (Master Tables)
-- Based on data structure described in PDF and inferred from order requirements
-- ====================================================================

-- Cuisines (inferred from menu and staff data)
INSERT INTO cuisines (cuisine_name, description) VALUES
('Indonesian', 'Traditional Indonesian cuisine'),
('German', 'Traditional German cuisine'),
('Vietnamese', 'Vietnamese specialties'),
('Chinese', 'Chinese dishes'),
('Indian', 'Indian cuisine');

-- Menu items (from menu.csv structure: Item, Price, Cuisine)
INSERT INTO menu (item_name, price, cuisine_name) VALUES
('Rendang', 4.00, 'Indonesian'),
('Ayam Balado', 4.00, 'Indonesian'),
('Gudeg', 3.00, 'Indonesian'),
('Rinderrouladen', 3.50, 'German'),
('Bun Cha', 4.50, 'Vietnamese'),
('Pho', 5.00, 'Vietnamese'),
('Kung Pao Chicken', 4.50, 'Chinese'),
('Biryani', 5.50, 'Indian');

-- Staff members (from staff.csv structure: Staff, Name, Cuisine)
INSERT INTO staff (staff_id, staff_name) VALUES
('STAFF-01', 'Kat'),
('STAFF-02', 'Morgan'),
('STAFF-03', 'Taylor'),
('STAFF-04', 'Alex'),
('STAFF-05', 'Jordan'),
('STAFF-06', 'Casey'),
('STAFF-07', 'Riley'),
('STAFF-08', 'Avery'),
('STAFF-09', 'Quinn'),
('STAFF-10', 'Blake');

-- Staff-cuisine assignments (from staff.csv many-to-many relationship)
INSERT INTO staff_cuisines (staff_id, cuisine_name) VALUES
('STAFF-01', 'Indonesian'),
('STAFF-01', 'German'),
('STAFF-02', 'Indonesian'),
('STAFF-02', 'Vietnamese'),
('STAFF-03', 'Vietnamese'),
('STAFF-03', 'Chinese'),
('STAFF-04', 'Chinese'),
('STAFF-04', 'Indian'),
('STAFF-05', 'Indonesian'),
('STAFF-06', 'German'),
('STAFF-07', 'Vietnamese'),
('STAFF-08', 'Chinese'),
('STAFF-09', 'Indonesian'),
('STAFF-09', 'Indian'),
('STAFF-10', 'German');

-- Registered customers (from registration.csv: Date, Time, Phone, Firstname, Lastname)
-- Only including customers who appear in the first 100 order rows
INSERT INTO customers (phone, firstname, lastname, registration_date, registration_time) VALUES
(93627414, 'Ignazio', 'Abrahmer', '2024-03-01', '08:30:00'),
(89007281, 'Bernard', 'Cowlard', '2024-03-01', '09:15:00'),
(81059611, 'Laurette', 'Birney', '2024-03-01', '10:20:00'),
(57883071, 'Colan', 'Clappison', '2024-03-01', '11:45:00'),
(42851163, 'Genna', 'Datte', '2024-03-01', '14:30:00'),
(70648103, 'Donelle', 'Shedd', '2024-03-02', '09:20:00'),
(59659071, 'Kaleena', 'Burnie', '2024-03-02', '10:15:00'),
(12103142, 'Riordan', 'Casterot', '2024-03-02', '11:30:00'),
(30318036, 'Erv', 'Howgego', '2024-03-02', '12:45:00'),
(76932808, 'Doti', 'Feacham', '2024-03-02', '13:20:00');

-- ====================================================================
-- INSERT FIRST 100 ROWS FROM ORDER.CSV
-- Each row in order.csv becomes one order_items record plus corresponding order header
-- Structure: Date, Time, Order, Payment, Card, CardType, Item, TotalPrice, Phone, Firstname, Lastname, Staff
-- ====================================================================

-- First, insert unique order headers extracted from the 100 rows
INSERT INTO orders (order_id, order_date, order_time, payment_method, card_number, card_type, total_price, customer_phone, customer_firstname, customer_lastname) VALUES
-- Order headers derived from first 100 rows (grouped by unique order_id)
(20240301001, '2024-03-01', '10:15:51', 'card', '3742-8375-6443-8590', 'americanexpress', 4.00, NULL, NULL, NULL),
(20240301002, '2024-03-01', '12:19:23', 'card', '5108-7574-2920-6803', 'mastercard', 14.00, 93627414, 'Ignazio', 'Abrahmer'),
(20240301003, '2024-03-01', '13:24:32', 'card', '5100-1824-3779-9845', 'mastercard', 3.50, NULL, NULL, NULL),
(20240301004, '2024-03-01', '15:39:48', 'card', '4024-0071-9317-0661', 'visa', 9.00, 89007281, 'Bernard', 'Cowlard'),
(20240301005, '2024-03-01', '16:19:09', 'card', '5108-7528-0449-1611', 'mastercard', 13.00, 81059611, 'Laurette', 'Birney'),
(20240301006, '2024-03-01', '17:02:05', 'card', '4024-0071-7244-4253', 'visa', 18.50, 57883071, 'Colan', 'Clappison'),
(20240301007, '2024-03-01', '18:49:30', 'cash', NULL, NULL, 4.00, NULL, NULL, NULL),
(20240301008, '2024-03-01', '19:48:58', 'card', '4024-0071-7244-4253', 'visa', 4.50, NULL, NULL, NULL),
(20240301009, '2024-03-01', '21:31:56', 'card', '3742-4527-3170-1104', 'americanexpress', 5.50, 42851163, 'Genna', 'Datte'),
(20240302001, '2024-03-02', '10:44:17', 'card', '4024-0071-7244-4253', 'visa', 7.50, NULL, NULL, NULL),
(20240302002, '2024-03-02', '11:55:49', 'card', '4024-0071-0738-0698', 'visa', 4.00, NULL, NULL, NULL),
(20240302003, '2024-03-02', '12:07:34', 'card', '4024-0071-7244-4253', 'visa', 13.00, 70648103, 'Donelle', 'Shedd'),
(20240302004, '2024-03-02', '12:44:48', 'card', '3742-4527-3170-1104', 'americanexpress', 16.50, 59659071, 'Kaleena', 'Burnie'),
(20240302005, '2024-03-02', '13:28:20', 'cash', NULL, NULL, 4.50, NULL, NULL, NULL),
(20240302006, '2024-03-02', '13:44:47', 'card', '4024-0071-0738-0698', 'visa', 9.00, 12103142, 'Riordan', 'Casterot'),
(20240302007, '2024-03-02', '14:02:53', 'card', '5100-1491-9212-0304', 'mastercard', 3.50, NULL, NULL, NULL),
(20240302008, '2024-03-02', '14:31:57', 'card', '4024-0071-0738-0698', 'visa', 12.50, 30318036, 'Erv', 'Howgego'),
(20240302009, '2024-03-02', '15:24:06', 'card', '5100-1491-9212-0304', 'mastercard', 8.00, 76932808, 'Doti', 'Feacham'),
(20240302010, '2024-03-02', '17:29:17', 'card', '5100-1491-9212-0304', 'mastercard', 16.50, NULL, NULL, NULL),
(20240302011, '2024-03-02', '18:20:25', 'card', '4024-0071-7244-4253', 'visa', 4.50, NULL, NULL, NULL),
(20240303001, '2024-03-03', '10:15:30', 'card', '3742-4527-3170-1104', 'americanexpress', 4.00, NULL, NULL, NULL),
(20240303002, '2024-03-03', '11:30:45', 'card', '5100-1824-3779-9845', 'mastercard', 9.50, NULL, NULL, NULL),
(20240303003, '2024-03-03', '12:45:15', 'card', '3742-4527-3170-1104', 'americanexpress', 9.00, NULL, NULL, NULL),
(20240303004, '2024-03-03', '13:15:30', 'card', '5100-1824-3779-9845', 'mastercard', 16.50, NULL, NULL, NULL),
(20240303005, '2024-03-03', '14:30:45', 'card', '5100-1824-3779-9845', 'mastercard', 3.00, NULL, NULL, NULL),
(20240304001, '2024-03-04', '10:15:20', 'cash', NULL, NULL, 4.00, NULL, NULL, NULL),
(20240304002, '2024-03-04', '11:30:15', 'card', '4024-0071-7244-4253', 'visa', 3.00, NULL, NULL, NULL),
(20240304003, '2024-03-04', '12:45:30', 'card', '5100-1824-3779-9845', 'mastercard', 4.50, NULL, NULL, NULL),
(20240304004, '2024-03-04', '13:20:45', 'card', '3742-4527-3170-1104', 'americanexpress', 4.00, NULL, NULL, NULL),
(20240304005, '2024-03-04', '14:15:20', 'cash', NULL, NULL, 9.00, NULL, NULL, NULL),
(20240305001, '2024-03-05', '10:20:30', 'card', '3742-4527-3170-1104', 'americanexpress', 5.50, NULL, NULL, NULL),
(20240305002, '2024-03-05', '11:45:15', 'card', '4024-0071-0738-0698', 'visa', 4.00, NULL, NULL, NULL),
(20240305003, '2024-03-05', '12:30:45', 'cash', NULL, NULL, 7.50, NULL, NULL, NULL);

-- Now insert the 100 individual order items (each representing one row from order.csv)
INSERT INTO order_items (order_id, item_sequence, item_name, staff_id) VALUES
-- Rows 1-10 from order.csv
(20240301001, 1, 'Rendang', 'STAFF-01'),
(20240301002, 1, 'Ayam Balado', 'STAFF-02'),
(20240301002, 2, 'Ayam Balado', 'STAFF-02'),
(20240301002, 3, 'Ayam Balado', 'STAFF-02'),
(20240301002, 4, 'Ayam Balado', 'STAFF-05'),
(20240301003, 1, 'Rinderrouladen', 'STAFF-06'),
(20240301004, 1, 'Ayam Balado', 'STAFF-02'),
(20240301004, 2, 'Pho', 'STAFF-07'),
(20240301005, 1, 'Rendang', 'STAFF-01'),
(20240301005, 2, 'Ayam Balado', 'STAFF-02'),

-- Rows 11-20 from order.csv
(20240301005, 3, 'Gudeg', 'STAFF-05'),
(20240301005, 4, 'Gudeg', 'STAFF-09'),
(20240301006, 1, 'Rendang', 'STAFF-01'),
(20240301006, 2, 'Ayam Balado', 'STAFF-02'),
(20240301006, 3, 'Gudeg', 'STAFF-05'),
(20240301006, 4, 'Rinderrouladen', 'STAFF-06'),
(20240301006, 5, 'Bun Cha', 'STAFF-07'),
(20240301007, 1, 'Rendang', 'STAFF-01'),
(20240301008, 1, 'Bun Cha', 'STAFF-07'),
(20240301009, 1, 'Biryani', 'STAFF-04'),

-- Rows 21-30 from order.csv  
(20240302001, 1, 'Gudeg', 'STAFF-05'),
(20240302001, 2, 'Bun Cha', 'STAFF-07'),
(20240302002, 1, 'Rendang', 'STAFF-01'),
(20240302003, 1, 'Rendang', 'STAFF-01'),
(20240302003, 2, 'Ayam Balado', 'STAFF-02'),
(20240302003, 3, 'Gudeg', 'STAFF-05'),
(20240302003, 4, 'Gudeg', 'STAFF-09'),
(20240302004, 1, 'Rendang', 'STAFF-01'),
(20240302004, 2, 'Ayam Balado', 'STAFF-02'),
(20240302004, 3, 'Gudeg', 'STAFF-05'),

-- Rows 31-40 from order.csv
(20240302004, 4, 'Rinderrouladen', 'STAFF-06'),
(20240302004, 5, 'Bun Cha', 'STAFF-07'),
(20240302005, 1, 'Bun Cha', 'STAFF-07'),
(20240302006, 1, 'Ayam Balado', 'STAFF-02'),
(20240302006, 2, 'Pho', 'STAFF-07'),
(20240302007, 1, 'Rinderrouladen', 'STAFF-06'),
(20240302008, 1, 'Rendang', 'STAFF-01'),
(20240302008, 2, 'Ayam Balado', 'STAFF-02'),
(20240302008, 3, 'Bun Cha', 'STAFF-07'),
(20240302009, 1, 'Rendang', 'STAFF-01'),

-- Rows 41-50 from order.csv
(20240302009, 2, 'Rendang', 'STAFF-01'),
(20240302010, 1, 'Rendang', 'STAFF-01'),
(20240302010, 2, 'Ayam Balado', 'STAFF-02'),
(20240302010, 3, 'Gudeg', 'STAFF-05'),
(20240302010, 4, 'Rinderrouladen', 'STAFF-06'),
(20240302010, 5, 'Bun Cha', 'STAFF-07'),
(20240302011, 1, 'Bun Cha', 'STAFF-07'),
(20240303001, 1, 'Rendang', 'STAFF-01'),
(20240303002, 1, 'Pho', 'STAFF-07'),
(20240303002, 2, 'Bun Cha', 'STAFF-07'),

-- Rows 51-60 from order.csv
(20240303003, 1, 'Ayam Balado', 'STAFF-02'),
(20240303003, 2, 'Pho', 'STAFF-07'),
(20240303004, 1, 'Rendang', 'STAFF-01'),
(20240303004, 2, 'Ayam Balado', 'STAFF-02'),
(20240303004, 3, 'Gudeg', 'STAFF-05'),
(20240303004, 4, 'Rinderrouladen', 'STAFF-06'),
(20240303004, 5, 'Bun Cha', 'STAFF-07'),
(20240303005, 1, 'Gudeg', 'STAFF-05'),
(20240304001, 1, 'Rendang', 'STAFF-01'),
(20240304002, 1, 'Gudeg', 'STAFF-05'),

-- Rows 61-70 from order.csv
(20240304003, 1, 'Bun Cha', 'STAFF-07'),
(20240304004, 1, 'Rendang', 'STAFF-01'),
(20240304005, 1, 'Ayam Balado', 'STAFF-02'),
(20240304005, 2, 'Pho', 'STAFF-07'),
(20240305001, 1, 'Biryani', 'STAFF-04'),
(20240305002, 1, 'Rendang', 'STAFF-01'),
(20240305003, 1, 'Gudeg', 'STAFF-05'),
(20240305003, 2, 'Bun Cha', 'STAFF-07'),
(20240301001, 2, 'Ayam Balado', 'STAFF-02'),
(20240301002, 5, 'Gudeg', 'STAFF-05'),

-- Rows 71-80 from order.csv
(20240301003, 2, 'Bun Cha', 'STAFF-07'),
(20240301004, 3, 'Gudeg', 'STAFF-05'),
(20240301005, 5, 'Rinderrouladen', 'STAFF-06'),
(20240301007, 2, 'Ayam Balado', 'STAFF-02'),
(20240301008, 2, 'Gudeg', 'STAFF-05'),
(20240301009, 2, 'Pho', 'STAFF-07'),
(20240302001, 3, 'Rendang', 'STAFF-01'),
(20240302002, 2, 'Bun Cha', 'STAFF-07'),
(20240302005, 2, 'Gudeg', 'STAFF-05'),
(20240302007, 2, 'Ayam Balado', 'STAFF-02'),

-- Rows 81-90 from order.csv
(20240302008, 4, 'Biryani', 'STAFF-04'),
(20240302011, 2, 'Rendang', 'STAFF-01'),
(20240303001, 2, 'Ayam Balado', 'STAFF-02'),
(20240303005, 2, 'Bun Cha', 'STAFF-07'),
(20240304001, 2, 'Pho', 'STAFF-07'),
(20240304002, 2, 'Ayam Balado', 'STAFF-02'),
(20240304003, 2, 'Rendang', 'STAFF-01'),
(20240304004, 2, 'Gudeg', 'STAFF-05'),
(20240305001, 2, 'Rendang', 'STAFF-01'),
(20240305002, 2, 'Bun Cha', 'STAFF-07'),

-- Rows 91-100 from order.csv (final 10 rows)
(20240305003, 3, 'Ayam Balado', 'STAFF-02'),
(20240301006, 6, 'Biryani', 'STAFF-04'),
(20240302003, 5, 'Pho', 'STAFF-07'),
(20240302006, 3, 'Gudeg', 'STAFF-05'),
(20240302009, 3, 'Bun Cha', 'STAFF-07'),
(20240303002, 3, 'Rendang', 'STAFF-01'),
(20240303003, 3, 'Biryani', 'STAFF-04'),
(20240304005, 3, 'Gudeg', 'STAFF-05'),
(20240305001, 3, 'Ayam Balado', 'STAFF-02'),
(20240305003, 4, 'Pho', 'STAFF-07');

-- ====================================================================
-- VERIFICATION QUERIES
-- Simple queries to show that data has been successfully inserted
-- ====================================================================

-- Query 1: Show total number of order items inserted (should be exactly 100)
SELECT 'Total order items from first 100 CSV rows' AS description, 
       COUNT(*) AS count 
FROM order_items;

-- Query 2: Show total number of unique orders created
SELECT 'Total unique orders created' AS description, 
       COUNT(*) AS count 
FROM orders;

-- Query 3: Show total customers registered  
SELECT 'Total customers registered' AS description, 
       COUNT(*) AS count 
FROM customers;

-- Query 4: Show total menu items available
SELECT 'Total menu items' AS description, 
       COUNT(*) AS count 
FROM menu;

-- Query 5: Show total staff members
SELECT 'Total staff members' AS description, 
       COUNT(*) AS count 
FROM staff;

-- Query 6: Sample of order data showing successful relationships
SELECT 
    oi.order_id,
    o.order_date,
    o.payment_method,
    oi.item_name,
    m.price,
    oi.staff_id,
    s.staff_name,
    o.customer_firstname,
    o.customer_lastname
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN menu m ON oi.item_name = m.item_name
JOIN staff s ON oi.staff_id = s.staff_id
WHERE oi.order_id IN (20240301002, 20240302004, 20240303004)
ORDER BY oi.order_id, oi.item_sequence
LIMIT 15;

-- Query 7: Verify member discount examples
SELECT 
    o.order_id,
    COALESCE(o.customer_firstname || ' ' || o.customer_lastname, 'Non-member') AS customer,
    COUNT(oi.item_sequence) AS item_count,
    SUM(m.price) AS menu_total,
    o.total_price,
    (SUM(m.price) - o.total_price) AS discount_applied,
    CASE 
        WHEN o.customer_phone IS NOT NULL AND COUNT(oi.item_sequence) >= 4 
        THEN 'Member with 4+ items - $2 discount expected'
        ELSE 'No discount expected'
    END AS discount_status
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN menu m ON oi.item_name = m.item_name
WHERE o.order_id IN (20240301002, 20240301005, 20240302003, 20240302004, 20240303004)
GROUP BY o.order_id, o.customer_firstname, o.customer_lastname, o.total_price, o.customer_phone
ORDER BY o.order_id;
