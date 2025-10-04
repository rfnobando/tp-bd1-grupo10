-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`providers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`providers` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `phone_number` VARCHAR(100) NOT NULL,
  `full_address` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`assembly_lines`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`assembly_lines` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `capacity` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`workstations`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`workstations` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `assembly_line_id` BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_workstations_assembly_lines1_idx` (`assembly_line_id` ASC) VISIBLE,
  CONSTRAINT `fk_workstations_assembly_lines1`
    FOREIGN KEY (`assembly_line_id`)
    REFERENCES `mydb`.`assembly_lines` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`components`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`components` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `code` VARCHAR(100) NOT NULL,
  `expiry_date` DATE NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) VISIBLE,
  UNIQUE INDEX `code_UNIQUE` (`code` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`dealerships`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`dealerships` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `full_address` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`car_models`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`car_models` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `assembly_line_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `current_price` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_models_assembly_lines_idx` (`assembly_line_id` ASC) VISIBLE,
  UNIQUE INDEX `assembly_line_id_UNIQUE` (`assembly_line_id` ASC) VISIBLE,
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) VISIBLE,
  CONSTRAINT `fk_models_assembly_lines`
    FOREIGN KEY (`assembly_line_id`)
    REFERENCES `mydb`.`assembly_lines` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`cars`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`cars` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `car_model_id` BIGINT UNSIGNED NOT NULL,
  `chassis_number` VARCHAR(100) NOT NULL,
  `year` INT NOT NULL,
  `transmission` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_cars_car_models1_idx` (`car_model_id` ASC) VISIBLE,
  UNIQUE INDEX `chassis_number_UNIQUE` (`chassis_number` ASC) VISIBLE,
  CONSTRAINT `fk_cars_car_models1`
    FOREIGN KEY (`car_model_id`)
    REFERENCES `mydb`.`car_models` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`workstation_logs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`workstation_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `workstation_id` BIGINT UNSIGNED NOT NULL,
  `car_id` BIGINT UNSIGNED NOT NULL,
  `entry_datetime` DATETIME NOT NULL,
  `exit_datetime` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_workstation_logs_workstations1_idx` (`workstation_id` ASC) VISIBLE,
  INDEX `fk_workstation_logs_cars1_idx` (`car_id` ASC) VISIBLE,
  CONSTRAINT `fk_workstation_logs_workstations1`
    FOREIGN KEY (`workstation_id`)
    REFERENCES `mydb`.`workstations` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_workstation_logs_cars1`
    FOREIGN KEY (`car_id`)
    REFERENCES `mydb`.`cars` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`orders` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `dealership_id` BIGINT UNSIGNED NOT NULL,
  `sale_datetime` DATETIME NOT NULL,
  `code` VARCHAR(100) NOT NULL,
  `expected_delivery_date` DATE NOT NULL,
  `total_amount` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_orders_dealerships1_idx` (`dealership_id` ASC) VISIBLE,
  UNIQUE INDEX `code_UNIQUE` (`code` ASC) VISIBLE,
  CONSTRAINT `fk_orders_dealerships1`
    FOREIGN KEY (`dealership_id`)
    REFERENCES `mydb`.`dealerships` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`providers_components`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`providers_components` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `provider_id` BIGINT UNSIGNED NOT NULL,
  `component_id` BIGINT UNSIGNED NOT NULL,
  `unit_price` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_providers_consumables_providers1_idx` (`provider_id` ASC) VISIBLE,
  INDEX `fk_providers_consumables_consumables1_idx` (`component_id` ASC) VISIBLE,
  CONSTRAINT `fk_providers_consumables_providers1`
    FOREIGN KEY (`provider_id`)
    REFERENCES `mydb`.`providers` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_providers_consumables_consumables1`
    FOREIGN KEY (`component_id`)
    REFERENCES `mydb`.`components` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`workstations_components`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`workstations_components` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `workstation_id` BIGINT UNSIGNED NOT NULL,
  `component_id` BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_workstations_consumables_workstations1_idx` (`workstation_id` ASC) VISIBLE,
  INDEX `fk_workstations_components_components1_idx` (`component_id` ASC) VISIBLE,
  CONSTRAINT `fk_workstations_consumables_workstations1`
    FOREIGN KEY (`workstation_id`)
    REFERENCES `mydb`.`workstations` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_workstations_components_components1`
    FOREIGN KEY (`component_id`)
    REFERENCES `mydb`.`components` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`order_items`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`order_items` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` BIGINT UNSIGNED NOT NULL,
  `car_model_id` BIGINT UNSIGNED NOT NULL,
  `unit_price` DECIMAL(10,2) NOT NULL,
  `quantity` INT NOT NULL,
  `total_amount` DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
  PRIMARY KEY (`id`),
  INDEX `fk_order_items_orders1_idx` (`order_id` ASC) VISIBLE,
  INDEX `fk_order_items_car_models1_idx` (`car_model_id` ASC) VISIBLE,
  CONSTRAINT `fk_order_items_orders1`
    FOREIGN KEY (`order_id`)
    REFERENCES `mydb`.`orders` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_order_items_car_models1`
    FOREIGN KEY (`car_model_id`)
    REFERENCES `mydb`.`car_models` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`workstation_tasks`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`workstation_tasks` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `workstation_id` BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) VISIBLE,
  INDEX `fk_workstation_tasks_workstations1_idx` (`workstation_id` ASC) VISIBLE,
  CONSTRAINT `fk_workstation_tasks_workstations1`
    FOREIGN KEY (`workstation_id`)
    REFERENCES `mydb`.`workstations` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`consumables`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`consumables` (
  `component_id` BIGINT UNSIGNED NOT NULL,
  `description` VARCHAR(100) NOT NULL,
  INDEX `fk_consumables_components1_idx` (`component_id` ASC) VISIBLE,
  UNIQUE INDEX `component_id_UNIQUE` (`component_id` ASC) VISIBLE,
  PRIMARY KEY (`component_id`),
  CONSTRAINT `fk_consumables_components1`
    FOREIGN KEY (`component_id`)
    REFERENCES `mydb`.`components` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`car_parts`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`car_parts` (
  `component_id` BIGINT UNSIGNED NOT NULL,
  `warranty_end_date` DATE NOT NULL,
  PRIMARY KEY (`component_id`),
  CONSTRAINT `fk_car_parts_components1`
    FOREIGN KEY (`component_id`)
    REFERENCES `mydb`.`components` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`component_stocks`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`component_stocks` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `component_id` BIGINT UNSIGNED NOT NULL,
  `quantity` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_component_stocks_components1_idx` (`component_id` ASC) VISIBLE,
  CONSTRAINT `fk_component_stocks_components1`
    FOREIGN KEY (`component_id`)
    REFERENCES `mydb`.`components` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`workstations_components_logs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`workstations_components_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `workstation_log_id` BIGINT UNSIGNED NOT NULL,
  `component_id` BIGINT UNSIGNED NOT NULL,
  `used_quantity` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_workstations_components_logs_workstation_logs1_idx` (`workstation_log_id` ASC) VISIBLE,
  INDEX `fk_workstations_components_logs_components1_idx` (`component_id` ASC) VISIBLE,
  CONSTRAINT `fk_workstations_components_logs_workstation_logs1`
    FOREIGN KEY (`workstation_log_id`)
    REFERENCES `mydb`.`workstation_logs` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_workstations_components_logs_components1`
    FOREIGN KEY (`component_id`)
    REFERENCES `mydb`.`components` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
