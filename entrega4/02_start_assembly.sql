DELIMITER $$

CREATE PROCEDURE start_assembly(
	IN p_license_plate VARCHAR(20),
	OUT n_result INT,
    OUT c_message VARCHAR(255))
BEGIN
	DECLARE v_car_model_id INT;
    DECLARE v_car_id INT;
    DECLARE v_assembly_line_id INT;
    DECLARE v_workstation_id INT;
    DECLARE v_first_workstation_id INT;
    DECLARE v_chassis_number VARCHAR(50);

    -- Seleccionar ID del auto que corresponde a la patente
    SELECT id INTO v_car_id
    FROM cars
    WHERE license_plate = p_license_plate;

    IF v_car_id IS NULL THEN
        SET n_result = '-1';
        SET c_message = 'No vehicle found with that license plate';
    END IF;

    -- Seleccionar su número de chasis
    SELECT chassis_number INTO v_chassis_number
    FROM cars
    WHERE id = v_car_id
    ORDER BY id ASC
    LIMIT 1;
    
    -- Seleccionar el ID del modelo de ese auto
    SELECT car_model_id INTO v_car_model_id
    FROM cars
    WHERE id = v_car_id
    ORDER BY id ASC
    LIMIT 1;
    
    -- Seleccionar línea de montaje que corresponde al modelo
    SELECT assembly_line_id INTO v_assembly_line_id
    FROM car_models
    WHERE id = v_car_model_id
    ORDER BY id ASC
    LIMIT 1;

    -- Verificar si está ocupada
    SELECT workstation_id INTO v_workstation_id
    FROM workstation_logs
    WHERE car_id = v_car_id
    AND exit_datetime IS NULL
    LIMIT 1;
    
    IF v_workstation_id IS NOT NULL THEN
        -- Estación ocupada
        SET n_result = '-1';
        SET c_message = CONCAT('Station occupied by car with chassis: ', v_chassis_number);
    ELSE
		-- Obtener la primera estación de la línea de montaje
        SELECT id INTO v_first_workstation_id
        FROM workstations 
        WHERE assembly_line_id = v_assembly_line_id 
        ORDER BY assembly_line_id ASC 
        LIMIT 1;
        
        -- Insertar o posicionar el auto en la primera estación
        INSERT INTO workstation_logs(workstation_id, car_id, entry_datetime, exit_datetime)
        SELECT v_first_workstation_id, v_car_id, NOW(), NULL;
        SET n_result = '0';
        SET c_message = 'Car successfully positioned in the first station of its assembly line.';
    END IF;
END$$

DELIMITER ;