DELIMITER $$

CREATE PROCEDURE create_order(
    IN p_dealership_id bigint unsigned,
    IN p_code varchar(100),
    OUT n_result int,
    OUT c_message varchar(100)
)
BEGIN
	IF (SELECT COUNT(id) FROM orders WHERE `code` = p_code) = 0 THEN
  	    INSERT INTO orders (dealership_id, sale_datetime, `code`, expected_delivery_date, total_amount)
	    VALUES (p_dealership_id, NOW(), p_code, DATE_ADD(NOW(), INTERVAL 1 WEEK), 0);

        SET n_result = 0;
        SET c_message = '';
    ELSE
        SET n_result = -1;
        SET c_message = CONCAT('Order with code ', p_code, ' already exists.');
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_order(
    IN p_id bigint unsigned,
    IN p_dealership_id bigint unsigned,
    IN p_sale_datetime datetime,
    IN p_code varchar(100),
    IN p_expected_delivery_date date,
    IN p_total_amount decimal(10,2),
    OUT n_result int,
    OUT c_message varchar(100)
)
BEGIN
    DECLARE v_count int;
    
    SELECT COUNT(id) INTO v_count FROM orders WHERE id = p_id;

	IF v_count = 1 THEN
    	IF (SELECT COUNT(id) FROM orders WHERE `code` = p_code) = 0 THEN
			UPDATE orders
			SET
				dealership_id = COALESCE(p_dealership_id, dealership_id),
                sale_datetime = COALESCE(p_sale_datetime, sale_datetime),
                `code` = COALESCE(p_code, `code`),
                expected_delivery_date = COALESCE(p_expected_delivery_date, expected_delivery_date),
                total_amount = COALESCE(p_total_amount, total_amount)
			WHERE id = p_id;

			SET n_result = 0;
			SET c_message = '';
		ELSE
			SET n_result = -1;
			SET c_message = CONCAT('Order with code ', p_code, ' already exists.');
		END IF;
	ELSE
        SET n_result = -2;
        SET c_message = 'Order not found.';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_order(
    IN p_id bigint unsigned,
    OUT n_result int,
    OUT c_message varchar(100)
)
BEGIN
    DECLARE v_count int;
    SELECT COUNT(id) INTO v_count FROM orders WHERE id = p_id;

    IF v_count = 1 THEN
        IF (SELECT COUNT(id) FROM order_items WHERE order_id = p_id) = 0 THEN
			DELETE FROM orders WHERE id = p_id;
			
			SET n_result = 0;
			SET c_message = '';
        ELSE
            SET n_result = -2;
            SET c_message = 'The order still has items.';
        END IF;
	ELSE
        SET n_result = -1;
        SET c_message = 'Order not found.';
	END IF;
END$$

DELIMITER ;
