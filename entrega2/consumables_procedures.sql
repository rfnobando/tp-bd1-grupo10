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