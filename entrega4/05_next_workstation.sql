DELIMITER $$

CREATE PROCEDURE next_workstation(
	IN p_license_plate VARCHAR(20),
    OUT n_result INT,
    OUT c_message VARCHAR(255)
)
next_workstation: BEGIN
    DECLARE v_assembly_line_id INT;
    DECLARE v_workstation_id INT;
    DECLARE v_last_workstation_id INT;
    DECLARE v_next_workstation_id INT;
    DECLARE v_chassis_in_use VARCHAR(50);
    DECLARE v_car_id BIGINT(20);

    -- Buscar línea de montaje
    SELECT id_assembly_line INTO v_assembly_line_id
    FROM vehicles
    WHERE license_plate = p_license_plate;

    IF v_assembly_line_id IS NULL THEN
        SET n_result = -1;
        SET c_message = 'No vehicle found with that license plate';
        LEAVE next_workstation;
    END IF;

    -- Buscar la estación que corresponde a esa línea
    SELECT workstation_id INTO v_workstation_id
    FROM workstation_logs wl
    WHERE assembly_line_id = v_assembly_line_id
    AND wl.exit_datetime IS NULL
    ORDER BY wl.entry_datetime DESC
    LIMIT 1;

    -- Verificar si está ocupada
    SELECT car_id INTO v_car_id
    FROM workstation_logs
    WHERE workstation_id = v_workstation_id
    AND exit_datetime IS NULL
    LIMIT 1;
    
    -- Buscar chasis del vehículo
    SELECT chassis_number INTO v_chassis_in_use
    FROM cars
    WHERE license_plate = p_license_plate
    LIMIT 1;
    
	IF v_car_id IS NOT NULL THEN
		-- Estación ocupada
        SET n_result = -2;
		SELECT CONCAT('Station occupied by vehicle with chassis: ', v_chassis_in_use) AS c_message;
        LEAVE next_workstation;
	END IF;
    
    -- Buscar la última estación de esa línea
    SELECT workstation_id INTO v_last_workstation_id
    FROM workstations
    WHERE assembly_line_id = v_assembly_line_id
    ORDER BY station_order DESC
    LIMIT 1;
		
	-- ¿Está en la última?
	IF v_workstation_id = v_last_workstation_id THEN
		-- Marcar vehículo como finalizado
		UPDATE workstation_logs
        SET exit_datetime = NOW()
        WHERE car_id = (SELECT id FROM vehicles WHERE license_plate = p_license_plate)
        AND exit_datetime IS NULL;
        SET n_result = 0;
        SET c_message = 'Vehicle successfully finished.';
	ELSE
        -- Buscar siguiente estación
        SELECT workstation_id INTO v_next_workstation_id
        FROM workstations
        WHERE assembly_line_id = v_assembly_line_id
          AND station_order > (SELECT station_order FROM workstations WHERE workstation_id = v_workstation_id)
        ORDER BY station_order ASC
        LIMIT 1;
        
         -- Verificar si está ocupada
		SELECT car_id INTO v_car_id
		FROM workstation_logs
		WHERE workstation_id = v_next_workstation_id
		AND exit_datetime IS NULL
		LIMIT 1;
    
		IF v_car_id IS NOT NULL THEN
			-- Estación ocupada
            SET n_result = -2;
			SELECT CONCAT('Station occupied by vehicle with chassis: ', v_chassis_in_use) AS c_message;
        LEAVE next_workstation;
		END IF;
        
        -- Registrar entrada
        INSERT INTO workstation_logs (workstation_id, chassis_number, entry_datetime)
        SELECT v_next_workstation_id, chassis_number, NOW()
        FROM vehicles
        WHERE license_plate = p_license_plate;
        SET n_result = 0;
        SET c_message = 'Vehicle successfully entered to the next workstation.';
    END IF;
END$$

DELIMITER ;
