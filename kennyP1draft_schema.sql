-- schema.sql
-- PostgreSQL Database Schema for Salero Bundo Restaurant
-- Project: 1

-- ====================================================================
-- DESIGN RATIONALE:
-- 
-- The original CSV files are denormalized. To eliminate redundancy while 
-- accommodating ALL data, this design:
-- 1. Separates lookup data (cuisines, menu, staff, customers) into master tables
-- 2. Creates normalized order structure that preserves all information
-- 3. Enforces constraints using only the 5 allowed constraint types
-- 4. Maintains referential integrity with appropriate cascade behavior
--
-- COLUMNS ADDED/MODIFIED:
-- - Added 'cuisines' table to support business rule about recording cuisines without items
-- - Split staff.csv "Staff,Name,Cuisine" into staff and staff_cuisines tables 
--   to handle many-to-many relationship (staff can cook multiple cuisines)
-- - Normalized orders to separate order header from line items to eliminate 
--   data duplication while preserving all original information
-- - Added sequence numbers to handle multiple instances of same item per order
--
-- CONSTRAINTS ENFORCED (using only allowed constraint types):
-- ✓ PRIMARY KEY, UNIQUE, NOT NULL, FOREIGN KEY, CHECK
-- ✗ Complex business rules requiring triggers (noted in comments)
-- ====================================================================

-- Drop existing tables for clean setup
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS staff_cuisines CASCADE;
DROP TABLE IF EXISTS menu CASCADE;
DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS cuisines CASCADE;

-- ====================================================================
-- CUISINES TABLE
-- Supports business requirement to record cuisines without menu items
-- ====================================================================
CREATE TABLE cuisines (
    cuisine_name VARCHAR(50) PRIMARY KEY,
    description TEXT
);

-- ====================================================================
-- MENU TABLE (from menu.csv: Item, Price, Cuisine)
-- Each item uniquely identified by name, belongs to exactly one cuisine
-- ====================================================================
CREATE TABLE menu (
    item_name VARCHAR(100) PRIMARY KEY,
    price DECIMAL(6,2) NOT NULL CHECK (price > 0),
    cuisine_name VARCHAR(50) NOT NULL,
    
    CONSTRAINT fk_menu_cuisine 
        FOREIGN KEY (cuisine_name) REFERENCES cuisines(cuisine_name)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ====================================================================
-- CUSTOMERS TABLE (from registration.csv: Date, Time, Phone, Firstname, Lastname)
-- Members uniquely identified by phone number
-- ====================================================================
CREATE TABLE customers (
    phone BIGINT PRIMARY KEY CHECK (phone > 0),
    firstname VARCHAR(50) NOT NULL,
    lastname VARCHAR(50) NOT NULL,
    registration_date DATE NOT NULL,
    registration_time TIME NOT NULL
);

-- ====================================================================
-- STAFF TABLE (from staff.csv: Staff, Name, Cuisine)
-- Staff members with unique IDs - cuisine relationship handled separately
-- ====================================================================
CREATE TABLE staff (
    staff_id VARCHAR(20) PRIMARY KEY,
    staff_name VARCHAR(100) NOT NULL
);

-- ====================================================================
-- STAFF_CUISINES TABLE 
-- Handles many-to-many: staff assigned to cook one or more cuisines
-- Supports business rule that not all cuisines need assigned staff
-- ====================================================================
CREATE TABLE staff_cuisines (
    staff_id VARCHAR(20),
    cuisine_name VARCHAR(50),
    
    PRIMARY KEY (staff_id, cuisine_name),
    
    CONSTRAINT fk_staff_cuisines_staff
        FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    
    CONSTRAINT fk_staff_cuisines_cuisine
        FOREIGN KEY (cuisine_name) REFERENCES cuisines(cuisine_name)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ====================================================================
-- ORDERS TABLE
-- Order header information - accommodates both member and non-member orders
-- Derived from order.csv columns: Date, Time, Order, Payment, Card, CardType, 
-- TotalPrice, Phone, Firstname, Lastname
-- ====================================================================
CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    payment_method VARCHAR(4) NOT NULL CHECK (payment_method IN ('card', 'cash')),
    card_number VARCHAR(30), -- Accommodate various card number formats
    card_type VARCHAR(20),
    total_price DECIMAL(8,2) NOT NULL CHECK (total_price > 0),
    
    -- Member information (NULL for non-members as per business rules)
    customer_phone BIGINT,
    customer_firstname VARCHAR(50),
    customer_lastname VARCHAR(50),
    
    -- Referential integrity for members
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_phone) REFERENCES customers(phone)
        ON UPDATE CASCADE ON DELETE SET NULL,
    
    -- Business rule: card payments require card details
    CONSTRAINT chk_card_payment_details
        CHECK (
            (payment_method = 'card' AND card_number IS NOT NULL AND card_type IS NOT NULL) OR
            (payment_method = 'cash' AND card_number IS NULL AND card_type IS NULL)
        ),
    
    -- Business rule: member information consistency
    CONSTRAINT chk_member_info_consistency
        CHECK (
            (customer_phone IS NULL AND customer_firstname IS NULL AND customer_lastname IS NULL) OR
            (customer_phone IS NOT NULL AND customer_firstname IS NOT NULL AND customer_lastname IS NOT NULL)
        ),
    
    -- Valid card types based on data analysis
    CONSTRAINT chk_valid_card_type
        CHECK (card_type IS NULL OR card_type IN ('visa', 'mastercard', 'americanexpress'))
);

-- ====================================================================
-- ORDER_ITEMS TABLE
-- Individual line items from order.csv: Item, Staff columns
-- Handles multiple instances of same item per order via sequence numbers
-- ====================================================================
CREATE TABLE order_items (
    order_id BIGINT,
    item_sequence INTEGER,
    item_name VARCHAR(100) NOT NULL,
    staff_id VARCHAR(20) NOT NULL,
    
    PRIMARY KEY (order_id, item_sequence),
    
    -- Order must exist
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    
    -- Item must be on menu
    CONSTRAINT fk_order_items_menu
        FOREIGN KEY (item_name) REFERENCES menu(item_name)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    
    -- Staff member must exist
    CONSTRAINT fk_order_items_staff
        FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    
    -- Sequence numbers start from 1
    CHECK (item_sequence > 0)
);

-- ====================================================================
-- PERFORMANCE INDEXES
-- Optimize common query patterns
-- ====================================================================
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_customer ON orders(customer_phone);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_menu_cuisine ON menu(cuisine_name);
CREATE INDEX idx_customers_registration ON customers(registration_date);

-- ====================================================================
-- UPDATE/DELETE PROPAGATION RATIONALE:
-- - CASCADE updates: Allows changing primary keys while maintaining integrity
-- - CASCADE deletes: Only where child records have no independent meaning
--   (staff_cuisines, order_items depend entirely on their parents)
-- - RESTRICT deletes: Where deletion would cause data loss
--   (menu items referenced in orders, staff assigned to orders)
-- - SET NULL: For optional relationships (customer info when customer deleted)
-- ====================================================================

-- ====================================================================
-- CONSTRAINTS NOT ENFORCEABLE WITH STANDARD DDL:
-- (Would require triggers in future phases - NOT implemented here per requirements)
--
-- 1. Staff must be assigned to cuisine matching the item they prepare
--    (Requires join between staff_cuisines, menu, and order_items)
-- 2. Member discount validation ($2 off for members with ≥4 items)
--    (Requires counting items and calculating expected total)
-- 3. Total price must equal sum of menu prices minus applicable discounts
--    (Requires complex calculation across multiple tables)
-- 4. Member registration date/time must be ≤ order date/time
--    (Requires temporal comparison across tables)
-- 5. Single order consistency (same date/time/payment/customer for all items)
--    (Enforced by normalized design but calculation validation needs triggers)
--
-- These constraints are documented for implementation in later project phases.
-- ====================================================================

-- ====================================================================
-- TABLE DOCUMENTATION
-- ====================================================================
COMMENT ON TABLE cuisines IS 'Master list of cuisine types, supports future menu expansion';
COMMENT ON TABLE menu IS 'Restaurant menu items with pricing (from menu.csv)';
COMMENT ON TABLE customers IS 'Registered restaurant members (from registration.csv)';
COMMENT ON TABLE staff IS 'Restaurant staff members (from staff.csv)';
COMMENT ON TABLE staff_cuisines IS 'Staff assignments to cuisines they can prepare';
COMMENT ON TABLE orders IS 'Order headers with payment and customer info (from order.csv)';
COMMENT ON TABLE order_items IS 'Individual items within orders (from order.csv)';

COMMENT ON COLUMN orders.total_price IS 'Final amount including member discounts';
COMMENT ON COLUMN orders.customer_phone IS 'NULL for non-member orders';
COMMENT ON COLUMN order_items.item_sequence IS 'Allows multiple instances of same item per order';
