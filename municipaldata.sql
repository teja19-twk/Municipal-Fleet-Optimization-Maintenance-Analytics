CREATE DATABASE municipal_fleet;
USE municipal_fleet;
CREATE TABLE vehicles (
    vehicle_id VARCHAR(20) PRIMARY KEY,
    vehicle_type VARCHAR(50),
    make VARCHAR(50),
    model_name VARCHAR(100),
    model_year INT,
    department VARCHAR(100),
    fuel_type VARCHAR(50),
    purchase_price_inr INT,
    odometer_km INT,
    vehicle_age_yrs INT,
    status_now VARCHAR(50),
    status_future VARCHAR(50),
    fleet_degradation_now DOUBLE,
    fleet_degradation_future DOUBLE
);
CREATE TABLE fuel_logs (
    vehicle_id VARCHAR(20),

    now_avg_kmpl DOUBLE,
    now_avg_kmpl_inv DOUBLE,
    now_total_fuel_cost_inr DOUBLE,
    now_avg_co2_kg DOUBLE,

    future_avg_kmpl DOUBLE,
    future_avg_kmpl_inv DOUBLE,
    future_total_fuel_cost_inr DOUBLE,
    future_avg_co2_kg DOUBLE,

    FOREIGN KEY (vehicle_id)
    REFERENCES vehicles(vehicle_id)
);

CREATE TABLE maintenance_records (

    maintenance_id VARCHAR(20) PRIMARY KEY,
    vehicle_id VARCHAR(20),

    maintenance_date DATE,
    maintenance_type VARCHAR(100),
    maintenance_code VARCHAR(50),

    cost_inr DOUBLE,
    downtime_days DOUBLE,
    description TEXT,

    now_maint_count INT,
    now_total_maint_cost DOUBLE,
    now_avg_parts_cost DOUBLE,
    now_avg_labor_cost DOUBLE,
    now_total_downtime_days DOUBLE,

    future_maint_count INT,
    future_total_maint_cost DOUBLE,
    future_avg_parts_cost DOUBLE,
    future_avg_labor_cost DOUBLE,
    future_total_downtime_days DOUBLE,

    FOREIGN KEY (vehicle_id)
    REFERENCES vehicles(vehicle_id)
);
-- 4. INSPECTIONS TABLE
CREATE TABLE inspections (
    InspectionID VARCHAR(20) PRIMARY KEY,
    VehicleID VARCHAR(20),
    InspectionDate DATE,
    InspectorID VARCHAR(30),
    InspectionType VARCHAR(50),
    OverallScore INT,
    EngineScore INT,
    BrakeScore INT,
    TireScore INT,
    BodyScore INT,
    SafetyEquipScore INT,
    Result VARCHAR(30),
    DeficienciesFound INT,
    EstRepairCost DECIMAL(12,2),
    NextInspectionDue DATE,
    CertificateNumber VARCHAR(50)
);

-- 5. INCIDENT REPORTS TABLE
CREATE TABLE incident_reports (
    IncidentID VARCHAR(20) PRIMARY KEY,
    VehicleID VARCHAR(20),
    IncidentDate DATE,
    IncidentType VARCHAR(50),
    Severity VARCHAR(50),
    Location VARCHAR(100),
    DriverID VARCHAR(30),
    InjuriesReported INT,
    PropertyDamage DECIMAL(12,2),
    InsuranceClaim BOOLEAN,
    ClaimAmount DECIMAL(12,2),
    DowntimeDays DECIMAL(10,2),
    RepairCost DECIMAL(12,2),
    ReportedBy VARCHAR(30),
    CaseStatus VARCHAR(50)
);

SELECT COUNT(*) AS Total_Vehicles
FROM vehicles;

SELECT COUNT(*) AS Total_Repairs
FROM maintenance_records;

SELECT COUNT(*) AS Total_Telemetry
FROM fuel_logs;
-- View Table Structure
DESCRIBE vehicles;

DESCRIBE maintenance_records;

DESCRIBE fuel_logs;

SELECT
    now_avg_parts_cost,
    now_avg_labor_cost,
    now_total_maint_cost
FROM maintenance_records
LIMIT 10;


SELECT
    SUM(CASE WHEN now_avg_parts_cost IS NULL THEN 1 ELSE 0 END) AS Missing_now_avg_parts_cost,
    SUM(CASE WHEN now_avg_labor_cost IS NULL THEN 1 ELSE 0 END) AS Missing_now_avg_labor_cost,
    SUM(CASE WHEN now_total_maint_cost IS NULL THEN 1 ELSE 0 END) AS Missing_now_total_maint_cost,
    SUM(CASE WHEN future_avg_parts_cost IS NULL THEN 1 ELSE 0 END) AS Missing_future_avg_parts_cost,
    SUM(CASE WHEN future_avg_labor_cost IS NULL THEN 1 ELSE 0 END) AS Missing_future_avg_labor_cost,
    SUM(CASE WHEN future_total_maint_cost IS NULL THEN 1 ELSE 0 END) AS Missing_future_total_maint_cost
FROM maintenance_records;

##fuel log table
SELECT
    SUM(CASE WHEN now_avg_kmpl IS NULL THEN 1 ELSE 0 END) AS Missing_now_avg_kmpl,
    SUM(CASE WHEN now_avg_kmpl_inv IS NULL THEN 1 ELSE 0 END) AS Missing_now_avg_kmpl_inv,
    SUM(CASE WHEN now_total_fuel_cost_inr IS NULL THEN 1 ELSE 0 END) AS Missing_now_total_fuel_cost_inr,
    SUM(CASE WHEN now_avg_co2_kg IS NULL THEN 1 ELSE 0 END) AS Missing_now_avg_co2_kg
FROM fuel_logs;

##column statistic cost
SELECT
    MIN(now_total_maint_cost) AS Min_Cost,
    MAX(now_total_maint_cost) AS Max_Cost,
    AVG(now_total_maint_cost) AS Avg_Cost,
    SUM(now_total_maint_cost) AS Total_Maintenance_Cost
FROM maintenance_records;

##Mileage Statistics
SELECT
    MIN(odometer_km) AS Min_Mileage,
    MAX(odometer_km) AS Max_Mileage,
    AVG(odometer_km) AS Avg_Mileage
FROM vehicles;
##Duplicate Vehicle IDs
SELECT
    vehicle_id,
    COUNT(*) AS Duplicate_Count
FROM vehicles
GROUP BY vehicle_id
HAVING COUNT(*) > 1;

##Data Quality Summary Report
SELECT
    COUNT(*) AS Total_Records,
    SUM(CASE WHEN now_total_maint_cost IS NULL THEN 1 ELSE 0 END) AS Missing_Cost,
    SUM(CASE WHEN vehicle_id IS NULL THEN 1 ELSE 0 END) AS Missing_VehicleID
FROM maintenance_records;
##Verify Relationship Between Vehicles and Repairs
SELECT COUNT(*) AS Matching_Records
FROM vehicles v
INNER JOIN maintenance_records m
ON v.vehicle_id = m.vehicle_id;
##Verify Relationship Between Vehicles and Telemetry
SELECT COUNT(*) AS Matching_Records
FROM vehicles v
INNER JOIN fuel_logs f
ON v.vehicle_id = f.vehicle_id;

-- 1. Verify row counts
SELECT 'vehicles' AS Table_Name, COUNT(*) AS Row_Count
FROM vehicles
UNION ALL
SELECT 'maintenance_records' AS Table_Name, COUNT(*) AS Row_Count
FROM maintenance_records;


-- 2. Check primary key uniqueness in Vehicles
SELECT vehicle_id, COUNT(*) AS Count_ID
FROM vehicles
GROUP BY vehicle_id
HAVING COUNT(*) > 1;


-- 3. Check primary key uniqueness in Repairs
SELECT vehicle_id, COUNT(*) AS Count_ID
FROM maintenance_records
GROUP BY vehicle_id
HAVING COUNT(*) > 1;


-- 4. Check NULL primary keys
SELECT
    SUM(CASE WHEN vehicle_id IS NULL OR TRIM(vehicle_id) = '' THEN 1 ELSE 0 END) AS Null_vehicle_id
FROM vehicles;
SELECT
    SUM(CASE WHEN vehicle_id IS NULL OR TRIM(vehicle_id) = '' THEN 1 ELSE 0 END) AS Null_vehicle_id
FROM maintenance_records;

-- 5. Check foreign key integrity
-- Repairs without matching vehicle
SELECT m.*
FROM maintenance_records m
LEFT JOIN vehicles v
ON m.vehicle_id = v.vehicle_id
WHERE v.vehicle_id IS NULL;


-- 6. Count invalid foreign key records
SELECT COUNT(*) AS Repairs_Without_Matching_Vehicle
FROM maintenance_records m
LEFT JOIN vehicles v
ON TRIM(m.vehicle_id) = TRIM(v.vehicle_id)
WHERE v.vehicle_id IS NULL;


-- 7. Count valid matching records
SELECT COUNT(*) AS Valid_Repair_Vehicle_Matches
FROM maintenance_records m
INNER JOIN vehicles v
ON TRIM(m.vehicle_id) = TRIM(v.vehicle_id);

SELECT CONSTRAINT_NAME
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'municipal_fleet'
AND TABLE_NAME = 'maintenance_records'
AND CONSTRAINT_TYPE = 'FOREIGN KEY';

##Fleet Age Profile Calculation per Department, use:

SELECT
    Department,
    ROUND(AVG(YEAR(CURDATE()) - Model_Year), 2) AS Average_Vehicle_Age,
    MIN(YEAR(CURDATE()) - Model_Year) AS Youngest_Vehicle_Age,
    MAX(YEAR(CURDATE()) - Model_Year) AS Oldest_Vehicle_Age,
    COUNT(*) AS Total_Vehicles
FROM vehicles
GROUP BY Department
ORDER BY Average_Vehicle_Age DESC;

##If your column is named Year instead of Model_Year
SELECT
    department,
    ROUND(AVG(YEAR(CURDATE()) - model_year), 2) AS Average_Vehicle_Age,
    MIN(YEAR(CURDATE()) - model_year) AS Youngest_Vehicle_Age,
    MAX(YEAR(CURDATE()) - model_year) AS Oldest_Vehicle_Age,
    COUNT(*) AS Total_Vehicles
FROM vehicles
GROUP BY department
ORDER BY Average_Vehicle_Age DESC;

##r Each Vehicle
SELECT
    vehicle_id,
    department,
    model_year,
    YEAR(CURDATE()) - model_year AS vehicle_age
FROM vehicles;
##Top 10 Vehicles by Total Maintenance Cost (Current Year)
SELECT
    vehicle_id,
    SUM(now_maint_count) AS Repair_Count,
    ROUND(SUM(now_total_maint_cost), 2) AS Total_Maintenance_Cost
FROM maintenance_records
GROUP BY vehicle_id
ORDER BY Total_Maintenance_Cost DESC
LIMIT 10;

##With Vehicle Details
SELECT
    v.vehicle_id,
    v.vehicle_type,
    v.make,
    ROUND(SUM(m.now_total_maint_cost), 2) AS Total_Maintenance_Cost
FROM maintenance_records m
INNER JOIN vehicles v
ON m.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_id, v.vehicle_type, v.make
ORDER BY Total_Maintenance_Cost DESC
LIMIT 10;

USE municipal_fleet;

SELECT DISTINCT vehicle_id
FROM maintenance_records
LIMIT 20;

SELECT
    v.make,
    SUM(m.now_maint_count) AS Failure_Count
FROM maintenance_records m
INNER JOIN vehicles v
ON m.vehicle_id = v.vehicle_id
GROUP BY v.make
ORDER BY Failure_Count DESC;

##Unscheduled Repairs by Vehicle 
SELECT
    v.make,
    SUM(m.now_maint_count) AS Repair_Count,
    SUM(m.now_total_maint_cost) AS Cost
FROM maintenance_records m
INNER JOIN vehicles v
ON m.vehicle_id = v.vehicle_id
GROUP BY v.make
HAVING SUM(m.now_maint_count) > 5
ORDER BY Repair_Count DESC;

## Rank High-Frequency Failure Models

SELECT
    v.make,
    COUNT(m.vehicle_id) AS repair_frequency
FROM maintenance_records m
INNER JOIN vehicles v
ON m.vehicle_id = v.vehicle_id
GROUP BY v.make
ORDER BY repair_frequency DESC
LIMIT 20;

SELECT
    v.make,
    SUM(m.now_maint_count) AS Repair_Count
FROM maintenance_records m
INNER JOIN vehicles v
ON m.vehicle_id = v.vehicle_id
GROUP BY v.make
ORDER BY Repair_Count DESC;



-- 1. Monthly Repair Trends View

CREATE OR REPLACE VIEW vw_maintenance_kpi AS
SELECT
    vehicle_id,

    SUM(now_maint_count) AS total_repairs_now,
    ROUND(SUM(now_total_maint_cost), 2) AS cost_now,

    SUM(future_maint_count) AS predicted_repairs,
    ROUND(SUM(future_total_maint_cost), 2) AS predicted_cost,

    CASE
        WHEN SUM(now_total_maint_cost) > 50000 THEN 'High Risk'
        WHEN SUM(now_total_maint_cost) > 20000 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_category

FROM maintenance_records
GROUP BY vehicle_id;

-- 2. View Output for Power BI
SELECT *
FROM vw_maintenance_kpi
ORDER BY cost_now DESC;

-- 3. Fleet Health Index Proxy View
CREATE OR REPLACE VIEW vw_fleet_health_index AS
SELECT
    COUNT(*) AS Total_Vehicles,

    SUM(CASE WHEN vehicle_age_yrs <= 3 THEN 1 ELSE 0 END) AS New_Vehicles,
    SUM(CASE WHEN vehicle_age_yrs BETWEEN 4 AND 7 THEN 1 ELSE 0 END) AS Mid_Age_Vehicles,
    SUM(CASE WHEN vehicle_age_yrs > 7 THEN 1 ELSE 0 END) AS Old_Vehicles,

    ROUND(
        SUM(CASE WHEN vehicle_age_yrs <= 3 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS Fleet_Health_Index,

    ROUND(
        SUM(CASE WHEN vehicle_age_yrs > 7 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS Risk_Fleet_Rate

FROM vehicles;
-- 4. View Fleet Health Output
SELECT *
FROM vw_fleet_health_index;

USE municipal_fleet;

-- 1. Fuel Efficiency Variance View
CREATE OR REPLACE VIEW vw_fuel_efficiency_variance AS
SELECT
    v.vehicle_id,
    v.vehicle_type,
    v.make,
    v.department,

    ROUND(AVG(f.now_avg_kmpl), 2) AS Avg_Actual_KMPL,
    ROUND(AVG(f.future_avg_kmpl), 2) AS Avg_Future_KMPL,

    ROUND(
        AVG(f.now_avg_kmpl) - AVG(f.future_avg_kmpl),
        2
    ) AS Fuel_Efficiency_Variance,

    ROUND(SUM(f.now_total_fuel_cost_inr), 2) AS Total_Fuel_Cost

FROM fuel_logs f
INNER JOIN vehicles v
ON f.vehicle_id = v.vehicle_id

GROUP BY
    v.vehicle_id,
    v.vehicle_type,
    v.make,
    v.department;
    -- View output
SELECT *
FROM vw_fuel_efficiency_variance
ORDER BY Fuel_Efficiency_Variance DESC;



-- Vehicles table

ALTER TABLE vehicles 
MODIFY vehicle_id VARCHAR(50);

CREATE INDEX idx_vehicles_vehicle_id 
ON vehicles(vehicle_id);

ALTER TABLE maintenance_records 
MODIFY vehicle_id VARCHAR(50);


CREATE INDEX idx_mnt_vehicle_id 
ON maintenance_records(vehicle_id);

CREATE INDEX idx_veh_make 
ON vehicles(make);
ALTER TABLE vehicles
MODIFY COLUMN make VARCHAR(100);
CREATE INDEX idx_veh_make
ON vehicles(make);

ALTER TABLE maintenance_records
MODIFY MaintenanceDate DATE;

ALTER TABLE maintenance_records
MODIFY COLUMN maintenance_date DATE;

-- Maintenance table
CREATE INDEX idx_maintenance_vehicle_id 
ON maintenance_records(vehicle_id);
CREATE INDEX idx_maintenance_cost 
ON maintenance_records(now_total_maint_cost);
CREATE INDEX idx_maintenance_future_cost 
ON maintenance_records(future_total_maint_cost);

-- Fuel logs table
-- Fix data type (only valid column in your schema)
ALTER TABLE fuel_logs
MODIFY vehicle_id VARCHAR(50);

-- Index for JOIN performance
CREATE INDEX idx_fuel_vehicle_id 
ON fuel_logs(vehicle_id);

-- Index for fuel efficiency analytics
CREATE INDEX idx_fuel_avg_kmpl
ON fuel_logs(now_avg_kmpl);

-- Index for fuel cost analysis
CREATE INDEX idx_fuel_total_cost
ON fuel_logs(now_total_fuel_cost_inr);

-- Index for future prediction analysis
CREATE INDEX idx_fuel_future_cost
ON fuel_logs(future_total_fuel_cost_inr);

SELECT DATABASE() AS CurrentDatabase;
SHOW DATABASES;
USE municipal_fleet;
SHOW TABLES;

SELECT USER();