-- Database cho do an website ban hang PHP + MySQL (Shop Giày Dép)
-- Import file nay bang phpMyAdmin hoac chay trong MySQL.

CREATE DATABASE IF NOT EXISTS website_ban_hang
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE website_ban_hang;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  phone VARCHAR(20) NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('customer', 'admin') NOT NULL DEFAULT 'customer',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS categories (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(120) NOT NULL UNIQUE,
  description TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS products (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  category_id BIGINT UNSIGNED NULL,
  name VARCHAR(180) NOT NULL,
  slug VARCHAR(200) NOT NULL UNIQUE,
  description TEXT NULL,
  price DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  stock INT UNSIGNED NOT NULL DEFAULT 0,
  image VARCHAR(255) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_products_category FOREIGN KEY (category_id)
    REFERENCES categories(id) ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX idx_products_category (category_id),
  INDEX idx_products_active (is_active)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS cart_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  quantity INT UNSIGNED NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_cart_user FOREIGN KEY (user_id)
    REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_cart_product FOREIGN KEY (product_id)
    REFERENCES products(id) ON UPDATE CASCADE ON DELETE CASCADE,
  UNIQUE KEY uq_cart_user_product (user_id, product_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS orders (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  order_code VARCHAR(30) NOT NULL UNIQUE,
  recipient_name VARCHAR(100) NOT NULL,
  recipient_phone VARCHAR(20) NOT NULL,
  shipping_address VARCHAR(255) NOT NULL,
  note TEXT NULL,
  subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  shipping_fee DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  status ENUM('pending','confirmed','shipping','completed','cancelled') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_orders_user FOREIGN KEY (user_id)
    REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_orders_user (user_id),
  INDEX idx_orders_status (status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS order_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NULL,
  product_name VARCHAR(180) NOT NULL,
  unit_price DECIMAL(12,2) NOT NULL,
  quantity INT UNSIGNED NOT NULL,
  line_total DECIMAL(12,2) NOT NULL,
  CONSTRAINT fk_order_items_order FOREIGN KEY (order_id)
    REFERENCES orders(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_order_items_product FOREIGN KEY (product_id)
    REFERENCES products(id) ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX idx_order_items_order (order_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS payments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  method ENUM('cash_on_delivery','bank_transfer','online') NOT NULL DEFAULT 'cash_on_delivery',
  amount DECIMAL(12,2) NOT NULL,
  status ENUM('pending','paid','failed','refunded') NOT NULL DEFAULT 'pending',
  transaction_code VARCHAR(100) NULL,
  paid_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_payments_order FOREIGN KEY (order_id)
    REFERENCES orders(id) ON UPDATE CASCADE ON DELETE CASCADE,
  INDEX idx_payments_order (order_id),
  INDEX idx_payments_status (status)
) ENGINE=InnoDB;

-- Dữ liệu mẫu danh mục giày dép
INSERT IGNORE INTO categories (name, slug, description) VALUES
('Giày Sneaker', 'giay-sneaker', 'Giày thể thao năng động, trẻ trung cho nam nữ'),
('Giày Tây', 'giay-tay', 'Giày da lịch lãm, công sở, dự tiệc'),
('Dép & Sandal', 'dep-sandal', 'Dép đi chơi, sandal đi học, đi biển thoải mái');

-- Dữ liệu mẫu sản phẩm giày dép
INSERT IGNORE INTO products (category_id, name, slug, description, price, stock, image, is_active)
SELECT id, 'Giày Sneaker White Classic', 'giay-sneaker-white-classic', 'Giày thể thao trắng phong cách tối giản, dễ phối đồ', 650000.00, 25, NULL, 1
FROM categories WHERE slug = 'giay-sneaker';

INSERT IGNORE INTO products (category_id, name, slug, description, price, stock, image, is_active)
SELECT id, 'Giày Tây Oxford Nam', 'giay-tay-oxford-nam', 'Giày da bò nguyên tấm sang trọng lịch sự', 1250000.00, 15, NULL, 1
FROM categories WHERE slug = 'giay-tay';

INSERT IGNORE INTO products (category_id, name, slug, description, price, stock, image, is_active)
SELECT id, 'Sandal Quai Chéo Unisex', 'sandal-quai-cheo-unisex', 'Sandal quai chéo êm chân, chống trượt tốt', 280000.00, 40, NULL, 1
FROM categories WHERE slug = 'dep-sandal';


-- =====================================================================
-- PHẦN BỔ SUNG THEO MÔ HÌNH ERD (các bảng/cột còn thiếu)
-- Lưu ý: chạy 1 lần sau khi import phần trên (các lệnh ALTER không chạy lại được).
-- =====================================================================

-- 3. Brands (thương hiệu)
CREATE TABLE IF NOT EXISTS brands (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  brand_name VARCHAR(100) NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 4. Products: thêm brand_id (FK)
ALTER TABLE products
  ADD COLUMN brand_id BIGINT UNSIGNED NULL AFTER category_id,
  ADD INDEX idx_products_brand (brand_id),
  ADD CONSTRAINT fk_products_brand FOREIGN KEY (brand_id)
    REFERENCES brands(id) ON UPDATE CASCADE ON DELETE SET NULL;

-- 5. Product_Sizes (kích cỡ + tồn kho theo size)
CREATE TABLE IF NOT EXISTS product_sizes (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id BIGINT UNSIGNED NOT NULL,
  size VARCHAR(10) NOT NULL,
  stock INT UNSIGNED NOT NULL DEFAULT 0,
  CONSTRAINT fk_product_sizes_product FOREIGN KEY (product_id)
    REFERENCES products(id) ON UPDATE CASCADE ON DELETE CASCADE,
  UNIQUE KEY uq_product_size (product_id, size)
) ENGINE=InnoDB;

-- 6. Product_Images (nhiều hình ảnh cho 1 sản phẩm)
CREATE TABLE IF NOT EXISTS product_images (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id BIGINT UNSIGNED NOT NULL,
  image_url VARCHAR(255) NOT NULL,
  CONSTRAINT fk_product_images_product FOREIGN KEY (product_id)
    REFERENCES products(id) ON UPDATE CASCADE ON DELETE CASCADE,
  INDEX idx_product_images_product (product_id)
) ENGINE=InnoDB;

-- 7. Addresses (một người dùng lưu nhiều địa chỉ)
CREATE TABLE IF NOT EXISTS addresses (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  address VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_addresses_user FOREIGN KEY (user_id)
    REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
  INDEX idx_addresses_user (user_id)
) ENGINE=InnoDB;

-- 8. Carts (giỏ hàng của người dùng)
CREATE TABLE IF NOT EXISTS carts (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_carts_user FOREIGN KEY (user_id)
    REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
  INDEX idx_carts_user (user_id)
) ENGINE=InnoDB;

-- 9. Cart_Details (sản phẩm + size trong giỏ hàng)
CREATE TABLE IF NOT EXISTS cart_details (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  cart_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  size_id BIGINT UNSIGNED NOT NULL,
  quantity INT UNSIGNED NOT NULL DEFAULT 1,
  CONSTRAINT fk_cart_details_cart FOREIGN KEY (cart_id)
    REFERENCES carts(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_cart_details_product FOREIGN KEY (product_id)
    REFERENCES products(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_cart_details_size FOREIGN KEY (size_id)
    REFERENCES product_sizes(id) ON UPDATE CASCADE ON DELETE CASCADE,
  UNIQUE KEY uq_cart_product_size (cart_id, product_id, size_id)
) ENGINE=InnoDB;

-- 10. Orders: thêm address_id (FK). Ngày đặt hàng = created_at, tổng tiền = total_amount (đã có)
ALTER TABLE orders
  ADD COLUMN address_id BIGINT UNSIGNED NULL AFTER user_id,
  ADD INDEX idx_orders_address (address_id),
  ADD CONSTRAINT fk_orders_address FOREIGN KEY (address_id)
    REFERENCES addresses(id) ON UPDATE CASCADE ON DELETE SET NULL;

-- 11. Order_Details (order_items): thêm size_id (FK)
ALTER TABLE order_items
  ADD COLUMN size_id BIGINT UNSIGNED NULL AFTER product_id,
  ADD CONSTRAINT fk_order_items_size FOREIGN KEY (size_id)
    REFERENCES product_sizes(id) ON UPDATE CASCADE ON DELETE SET NULL;

-- 12. Reviews (đánh giá sản phẩm)
CREATE TABLE IF NOT EXISTS reviews (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  rating TINYINT UNSIGNED NOT NULL,
  comment TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 5),
  CONSTRAINT fk_reviews_user FOREIGN KEY (user_id)
    REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_reviews_product FOREIGN KEY (product_id)
    REFERENCES products(id) ON UPDATE CASCADE ON DELETE CASCADE,
  INDEX idx_reviews_product (product_id)
) ENGINE=InnoDB;

-- Dữ liệu mẫu thương hiệu
INSERT IGNORE INTO brands (brand_name) VALUES
('Nike'),
('Adidas'),
('Biti''s');

-- Gán thương hiệu mẫu cho sản phẩm
UPDATE products SET brand_id = (SELECT id FROM brands WHERE brand_name = 'Nike')
WHERE slug = 'giay-sneaker-white-classic';
UPDATE products SET brand_id = (SELECT id FROM brands WHERE brand_name = 'Adidas')
WHERE slug = 'giay-tay-oxford-nam';
UPDATE products SET brand_id = (SELECT id FROM brands WHERE brand_name = 'Biti''s')
WHERE slug = 'sandal-quai-cheo-unisex';

-- Dữ liệu mẫu kích cỡ cho từng sản phẩm
INSERT IGNORE INTO product_sizes (product_id, size, stock)
SELECT id, s.size, s.stock FROM products
JOIN (SELECT '39' AS size, 8 AS stock UNION ALL SELECT '40', 10 UNION ALL SELECT '41', 7) s
WHERE slug = 'giay-sneaker-white-classic';

INSERT IGNORE INTO product_sizes (product_id, size, stock)
SELECT id, s.size, s.stock FROM products
JOIN (SELECT '40' AS size, 5 AS stock UNION ALL SELECT '41', 6 UNION ALL SELECT '42', 4) s
WHERE slug = 'giay-tay-oxford-nam';

INSERT IGNORE INTO product_sizes (product_id, size, stock)
SELECT id, s.size, s.stock FROM products
JOIN (SELECT '38' AS size, 12 AS stock UNION ALL SELECT '39', 14 UNION ALL SELECT '40', 14) s
WHERE slug = 'sandal-quai-cheo-unisex';