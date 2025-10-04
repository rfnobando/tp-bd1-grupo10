-- Dealerships

DELIMITER $$

CREATE PROCEDURE create_dealership(
    IN p_name varchar(100),
    IN p_full_address varchar(100),
    OUT n_result int,
    OUT c_message varchar(100)
)
BEGIN
    SET n_result = 0;
    SET c_message = '';

	INSERT INTO dealerships (`name`, full_address)
	VALUES (p_name, p_full_address);
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_dealership(
    IN p_id bigint unsigned,
    IN p_name varchar(100),
    IN p_full_address varchar(100),
    OUT n_result int,
    OUT c_message varchar(100)
)
BEGIN
    DECLARE v_count int;
    SELECT COUNT(id) INTO v_count FROM dealerships WHERE id = p_id;

    IF v_count = 1 THEN     
        UPDATE dealerships
        SET
            `name` = COALESCE(p_name, `name`),
            full_address = COALESCE(p_full_address, full_address)
		WHERE id = p_id;
        
        SET n_result = 0;
        SET c_message = '';
	ELSE
        SET n_result = -1;
        SET c_message = 'Dealership not found.';
	END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_dealership(
    IN p_id bigint unsigned,
    OUT n_result int,
    OUT c_message varchar(100)
)
BEGIN
    DECLARE v_count int;
    SELECT COUNT(id) INTO v_count FROM dealerships WHERE id = p_id;

    IF v_count = 1 THEN
        DELETE FROM dealerships WHERE id = p_id;
        
        SET n_result = 0;
        SET c_message = '';
	ELSE
        SET n_result = -1;
        SET c_message = 'Dealership not found.';
	END IF;
END$$

DELIMITER ;



-- Providers

DELIMITER $$

CREATE PROCEDURE create_provider(
    IN p_name varchar(100),
    IN p_phone_number varchar(100),
    IN p_full_address varchar(100),
    OUT n_result int,
    OUT c_message varchar(100)
)
BEGIN
    SET n_result = 0;
    SET c_message = '';

	INSERT INTO providers (`name`, phone_number, full_address)
	VALUES (p_name, p_phone_number, p_full_address);
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_provider(
    IN p_id bigint unsigned,
    IN p_name varchar(100),
    IN p_phone_number varchar(100),
    IN p_full_address varchar(100),
    OUT n_result int,
    OUT c_message varchar(100)
)
BEGIN
    DECLARE v_count int;
    SELECT COUNT(id) INTO v_count FROM providers WHERE id = p_id;

    IF v_count = 1 THEN     
        UPDATE providers
        SET
            `name` = COALESCE(p_name, `name`),
            phone_number = COALESCE(p_phone_number, phone_number),
            full_address = COALESCE(p_full_address, full_address)
		WHERE id = p_id;
        
        SET n_result = 0;
        SET c_message = '';
	ELSE
        SET n_result = -1;
        SET c_message = 'Provider not found.';
	END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_provider(
    IN p_id bigint unsigned,
    OUT n_result int,
    OUT c_message varchar(100)
)
BEGIN
    DECLARE v_count int;
    SELECT COUNT(id) INTO v_count FROM providers WHERE id = p_id;

    IF v_count = 1 THEN
        DELETE FROM providers WHERE id = p_id;
        
        SET n_result = 0;
        SET c_message = '';
	ELSE
        SET n_result = -1;
        SET c_message = 'Provider not found.';
	END IF;
END$$

DELIMITER ;


-- Orders

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


-- Order Items

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


-- Consumables

DELIMITER $$

CREATE PROCEDURE create_consumable (
    IN p_name VARCHAR(100),
    IN p_code VARCHAR(100),
    IN p_expiry_date DATE,
    IN p_description VARCHAR(100)
)
proc:BEGIN
    DECLARE v_count_name INT;
    DECLARE v_count_code INT;
    DECLARE v_component_id BIGINT unsigned;

    -- verificar duplicado por name
    SELECT COUNT(*) INTO v_count_name
    FROM components
    WHERE name = p_name;

    IF v_count_name > 0 THEN
        SELECT -1 AS nResultado, 'Ya existe un componente con ese nombre' AS cMensaje;
        LEAVE proc;
    END IF;

    -- verificar duplicado por code
    SELECT COUNT(*) INTO v_count_code
    FROM components
    WHERE code = p_code;

    IF v_count_code > 0 THEN
        SELECT -2 AS nResultado, 'Ya existe un componente con ese código' AS cMensaje;
        LEAVE proc;
    END IF;

    -- insertar primero en components
    INSERT INTO components (name, code, expiry_date)
    VALUES (p_name, p_code, p_expiry_date);
	
	-- obtener id generado
    SET v_component_id = LAST_INSERT_ID();
    
    -- luego en consumables
    INSERT INTO consumables (component_id, description)
    VALUES (v_component_id, p_description);

    SELECT 0 AS nResultado, '' AS cMensaje;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_consumable (
    IN p_component_id BIGINT unsigned,
    IN p_name VARCHAR(100),
    IN p_code VARCHAR(100),
    IN p_expiry_date DATE,
    IN p_description VARCHAR(100)
)
proc: BEGIN
    DECLARE v_count INT;
    DECLARE v_count_name INT;
    DECLARE v_count_code INT;

    -- verificar existencia
    SELECT COUNT(*) INTO v_count
    FROM consumables
    WHERE component_id = p_component_id;

    IF v_count = 0 THEN
        SELECT -1 AS nResultado, 'El insumo no existe' AS cMensaje;
        LEAVE proc;
    END IF;

    -- verificar duplicado de name (excluyendo el propio registro)
    SELECT COUNT(*) INTO v_count_name
    FROM components
    WHERE name = p_name
      AND id <> p_component_id;

    IF v_count_name > 0 THEN
        SELECT -2 AS nResultado, 'Ya existe un componente con ese nombre' AS cMensaje;
        LEAVE proc;
    END IF;

    -- verificar duplicado de code (excluyendo el propio registro)
    SELECT COUNT(*) INTO v_count_code
    FROM components
    WHERE code = p_code
      AND id <> p_component_id;

    IF v_count_code > 0 THEN
        SELECT -3 AS nResultado, 'Ya existe un componente con ese código' AS cMensaje;
        LEAVE proc;
    END IF;

    -- actualizar en components
    UPDATE components
    SET name = COALESCE(p_name, name),
        code = COALESCE(p_code, code),
        expiry_date = COALESCE(p_expiry_date, expiry_date)
    WHERE id = p_component_id;

    -- actualizar en consumables
    UPDATE consumables
    SET description = COALESCE(p_description, description)
    WHERE component_id = p_component_id;

    SELECT 0 AS nResultado, '' AS cMensaje;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_consumable (
    IN p_component_id BIGINT unsigned
)
proc: BEGIN
    DECLARE v_count INT;
    DECLARE v_referenced INT;

    -- verificar existencia en consumables
    SELECT COUNT(*) INTO v_count
    FROM consumables
    WHERE component_id = p_component_id;

    IF v_count = 0 THEN
        SELECT -1 AS nResultado, 'El insumo no existe' AS cMensaje;
        LEAVE proc;
    END IF;

    -- verificar si está referenciado en stocks
    SELECT COUNT(*) INTO v_referenced
    FROM component_stocks
    WHERE component_id = p_component_id;

    IF v_referenced > 0 THEN
        SELECT -2 AS nResultado, 'El insumo no se puede eliminar porque tiene stock asociado' AS cMensaje;
        LEAVE proc;
    END IF;

    -- verificar si está referenciado en workstations
    SELECT COUNT(*) INTO v_referenced
    FROM workstations_components
    WHERE component_id = p_component_id;

    IF v_referenced > 0 THEN
        SELECT -3 AS nResultado, 'El insumo no se puede eliminar porque está asignado a un puesto de trabajo' AS cMensaje;
        LEAVE proc;
    END IF;

    -- si pasa los controles -> eliminar
    DELETE FROM consumables
    WHERE component_id = p_component_id;

    DELETE FROM components
    WHERE id = p_component_id;

    SELECT 0 AS nResultado, '' AS cMensaje;
END$$

DELIMITER ;

