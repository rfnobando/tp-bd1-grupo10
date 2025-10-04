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
