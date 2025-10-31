DELIMITER $$

CREATE PROCEDURE finish_assembly(
	IN p_license_plate VARCHAR(20),
	OUT n_result INT,
    OUT c_message VARCHAR(255))
BEGIN
    DECLARE v_car_id INT;
    DECLARE v_car_model_id INT;
    DECLARE v_assembly_line_id INT;
    DECLARE v_actual_workstation_id INT;
    DECLARE v_cant_workstations INT;
    
    -- Seleccionar ID del auto que corresponde a la patente
    SELECT id INTO v_car_id
    FROM cars
    WHERE license_plate = p_license_plate;

    IF v_car_id IS NULL THEN
        SET n_result = '-1';
        SET c_message = 'No vehicle found with that license plate';
    END IF;
    
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
    
    -- Seleccionar la estación actual del auto
    SELECT workstation_id INTO v_actual_workstation_id
    FROM workstation_logs
    WHERE car_id = v_car_id
    ORDER BY workstation_id DESC
    LIMIT 1;

	-- Obtener cantidad de estaciones de trabajo
    SELECT COUNT(*) INTO v_cant_workstations
    FROM workstations
    WHERE assembly_line_id = v_assembly_line_id;
    
    -- Verificamos si es la última
    IF v_cant_workstations = v_actual_workstation_id THEN
		-- Es la última
		UPDATE workstation_logs
        SET exit_datetime = NOW()
        WHERE workstation_id = v_actual_workstation_id;
        SET n_result = '0';
        SET c_message = 'Car successfully finished.';
	ELSE
		-- Insertar o posicionar el auto en la siguiente estación
        UPDATE workstation_logs
        SET exit_datetime = NOW()
        WHERE workstation_id = v_actual_workstation_id;
        INSERT INTO workstation_logs(workstation_id, car_id, entry_datetime)
        SELECT v_actual_workstation_id + 1, v_car_id, NOW();
        SET n_result = '0';
        SET c_message = 'Car successfully positioned in the next station of its assembly line.';
	END IF;
END$$

DELIMITER ;