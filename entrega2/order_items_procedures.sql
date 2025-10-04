DELIMITER $$
CREATE PROCEDURE create_order_item(
	IN p_car_model_id BIGINT,
    IN p_order_id BIGINT,
    IN p_quantity int,
    OUT n_result int,
    OUT c_message VARCHAR(100)
)
BEGIN
	DECLARE v_unit_price DECIMAL(10,2);
	IF (SELECT COUNT(*) FROM car_models WHERE id = p_car_model_id) > 0 AND (SELECT COUNT(*) FROM orders WHERE id = p_order_id) > 0 THEN
		
        SELECT current_price INTO v_unit_price FROM car_models WHERE id = p_car_model_id; -- trae el unit price
        
        -- insertar
        INSERT INTO order_items(order_id, car_model_id, unit_price, quantity)
        VALUES (p_order_id, p_car_model_id, v_unit_price, p_quantity);
        
        SET n_result = 0;
        SET c_message = '';
		
    ELSE
		SET n_result = -1;
        SET c_message = 'Order or Car Model dont exist';
    END IF;

END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE update_order_item(
	IN p_id BIGINT,
    IN p_quantity int,
    OUT n_result int,
    OUT c_message VARCHAR(100)
)
BEGIN
	DECLARE v_count int;
    DECLARE v_car_model_id BIGINT;
	DECLARE v_new_price DECIMAL(10,2);
    SELECT COUNT(id) INTO v_count FROM order_items WHERE id = p_id;
    
	IF v_count = 1 THEN 
		SELECT car_model_id INTO v_car_model_id FROM order_items WHERE id = p_id;
		SELECT current_price INTO v_new_price FROM car_models WHERE id = v_car_model_id;
        
        UPDATE order_items
        SET
			unit_price = v_new_price,
            quantity = p_quantity
		WHERE
			id = p_id;
		
		SET n_result = 0;
		SET c_message = '';
    ELSE
		SET n_result = -2;
        SET c_message = 'Order Item not found.';
    END IF;

END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE delete_order_item(
	IN p_id BIGINT,
    OUT n_result int,
    OUT c_message VARCHAR(100)
)
BEGIN
	DECLARE v_result INT;
    SELECT COUNT(id) INTO v_result FROM order_items WHERE id = p_id;
    
    IF v_result = 1 THEN
		DELETE FROM order_items WHERE id = p_id;
        
        SET n_result = 0;
		SET c_message = '';
    ELSE
		SET n_result = -1;
        SET c_message = 'Order Item not found.';
    END IF;
    

END$$
DELIMITER ;
