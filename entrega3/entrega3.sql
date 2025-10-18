DELIMITER $$



CREATE PROCEDURE generate_cars_for_order_improved(

    IN p_order_id BIGINT,

    OUT n_result INT,

    OUT c_message VARCHAR(255)

)

BEGIN

    DECLARE v_done INT DEFAULT FALSE;

    DECLARE v_car_model_id BIGINT;

    DECLARE v_quantity INT;

    DECLARE v_counter INT;

    DECLARE v_license_plate VARCHAR(20);

    DECLARE v_chassis_number VARCHAR(100);

    DECLARE v_exists INT;

    DECLARE v_attempts INT;

    DECLARE v_max_attempts INT DEFAULT 100;



    DECLARE cur_order_items CURSOR FOR 

        SELECT car_model_id, quantity 

        FROM order_items 

        WHERE order_id = p_order_id;

        

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION

    BEGIN

        ROLLBACK;

        SET n_result = -100;

        SET c_message = 'SQL Error: Transaction rolled back';

    END;



    -- Validar pedido existe

    IF (SELECT COUNT(*) FROM orders WHERE id = p_order_id) = 0 THEN

        SET n_result = -1;

        SET c_message = 'Error: Order does not exist';

    ELSE

        START TRANSACTION;

        OPEN cur_order_items;



        read_loop: LOOP

            FETCH cur_order_items INTO v_car_model_id, v_quantity;

            IF v_done THEN LEAVE read_loop; END IF;



            SET v_counter = 0;

            WHILE v_counter < v_quantity DO

                

                -- Generar número de chasis único (mejorado)

                SET v_attempts = 0;

                SET v_chassis_number = NULL;

                REPEAT

                    SET v_chassis_number = SUBSTRING(REPLACE(UUID(), '-', '') FROM 1 FOR 17);

                    SELECT COUNT(*) INTO v_exists FROM cars WHERE chassis_number = v_chassis_number;

                    SET v_attempts = v_attempts + 1;

                    IF v_attempts >= v_max_attempts THEN

                        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot generate unique chassis number';

                    END IF;

                UNTIL v_exists = 0 END REPEAT;



                -- Generar patente única (mejorado)

                SET v_attempts = 0;

                SET v_license_plate = NULL;

                REPEAT

                    -- Formato más flexible: letras y números mezclados

                    SET v_license_plate = CONCAT(

                        CHAR(65 + FLOOR(RAND() * 26)),

                        CHAR(65 + FLOOR(RAND() * 26)),

                        FLOOR(RAND() * 10),

                        CHAR(65 + FLOOR(RAND() * 26)),

                        FLOOR(RAND() * 10),

                        FLOOR(RAND() * 10),

                        CHAR(65 + FLOOR(RAND() * 26))

                    );

                    SELECT COUNT(*) INTO v_exists FROM cars WHERE license_plate = v_license_plate;

                    SET v_attempts = v_attempts + 1;

                    IF v_attempts >= v_max_attempts THEN

                        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot generate unique license plate';

                    END IF;

                UNTIL v_exists = 0 END REPEAT;



                -- Insertar automóvil

                INSERT INTO cars (car_model_id, chassis_number, license_plate, year, transmission)

                VALUES (v_car_model_id, v_chassis_number, v_license_plate, YEAR(CURDATE()), 'Manual');



                SET v_counter = v_counter + 1;

            END WHILE;

        END LOOP;



        CLOSE cur_order_items;

        COMMIT;

        

        SET n_result = 0;

        SET c_message = 'Cars generated successfully';

    END IF;

END$$



DELIMITER ;

