USE car_factory;

ALTER TABLE workstation_logs
MODIFY COLUMN exit_datetime datetime NULL DEFAULT NULL;
