DELIMITER //

CREATE TRIGGER Prevent_Negative_Stock
BEFORE UPDATE ON Products
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Stock level cannot be negative. Operation aborted.';
    END IF;
END //

CREATE TRIGGER Auto_Archive_Low_Demand_Products
AFTER UPDATE ON Products
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity > 0 AND NOT EXISTS (
        SELECT 1 FROM OrderDetails 
        WHERE prod_id = NEW.prod_id 
        AND created_at > DATE_SUB(NOW(), INTERVAL 12 MONTH)
    ) THEN
        INSERT INTO SystemLogs (event_type, description, severity)
        VALUES ('MARKET_ADVICE', CONCAT('Product ', NEW.prod_name, ' has no sales for 1 year.'), 'LOW');
    END IF;
END //

DELIMITER ;
