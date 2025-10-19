USE `car_factory`;

ALTER TABLE `cars`
ADD COLUMN `license_plate` VARCHAR(20) NULL DEFAULT NULL AFTER `chassis_number`,
ADD CONSTRAINT `uq_cars_license_plate` UNIQUE (`license_plate`);
