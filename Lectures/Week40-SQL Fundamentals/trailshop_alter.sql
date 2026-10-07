-- Week 40 - Task 1.6: Practice ALTER TABLE

ALTER TABLE customers ADD COLUMN phone VARCHAR(20);
ALTER TABLE products ADD COLUMN weight_grams INTEGER;
ALTER TABLE products
ADD CONSTRAINT chk_products_weight_positive CHECK (weight_grams > 0);
ALTER TABLE products RENAME COLUMN stock TO quantity_in_stock;
\d products
ALTER TABLE products RENAME COLUMN quantity_in_stock TO stock;
\d products
\d customers