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
