/* =========================================================
   FINAL SQL PROJECT — PANDEMIC DATABASE
   ========================================================= */

/* -------------------------
   1. Create schema
-------------------------- */
CREATE SCHEMA IF NOT EXISTS pandemic;
USE pandemic;

/* -------------------------
   2. Check imported data
-------------------------- */
SELECT COUNT(*) AS total_rows
FROM infectious_cases;

/* -------------------------
   3. Create entities table
-------------------------- */
DROP TABLE IF EXISTS entities;

CREATE TABLE entities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL
);

/* -------------------------
   4. Fill entities table
-------------------------- */
INSERT INTO entities (entity, code)
SELECT DISTINCT
    Entity,
    Code
FROM infectious_cases
WHERE Entity IS NOT NULL
  AND Code IS NOT NULL;

/* -------------------------
   5. Create normalized table
-------------------------- */
DROP TABLE IF EXISTS infectious_cases_norm;

CREATE TABLE infectious_cases_norm (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_id INT NOT NULL,
    year INT NOT NULL,

    Number_yaws VARCHAR(50),
    polio_cases VARCHAR(50),
    cases_guinea_worm VARCHAR(50),
    Number_rabies VARCHAR(50),
    Number_malaria VARCHAR(50),
    Number_hiv VARCHAR(50),
    Number_tuberculosis VARCHAR(50),
    Number_smallpox VARCHAR(50),
    Number_cholera_cases VARCHAR(50),

    CONSTRAINT fk_entity
        FOREIGN KEY (entity_id) REFERENCES entities(id)
);

/* -------------------------
   6. Fill normalized table
-------------------------- */
INSERT INTO infectious_cases_norm (
    entity_id,
    year,
    Number_yaws,
    polio_cases,
    cases_guinea_worm,
    Number_rabies,
    Number_malaria,
    Number_hiv,
    Number_tuberculosis,
    Number_smallpox,
    Number_cholera_cases
)
SELECT
    e.id,
    ic.Year,
    ic.Number_yaws,
    ic.polio_cases,
    ic.cases_guinea_worm,
    ic.Number_rabies,
    ic.Number_malaria,
    ic.Number_hiv,
    ic.Number_tuberculosis,
    ic.Number_smallpox,
    ic.Number_cholera_cases
FROM infectious_cases ic
JOIN entities e
  ON e.entity = ic.Entity
 AND e.code   = ic.Code;

/* -------------------------
   7. Aggregations (TOP-10 by rabies)
-------------------------- */
SELECT
    e.entity,
    e.code,
    AVG(CAST(NULLIF(icn.Number_rabies, '') AS DECIMAL(10,2))) AS avg_rabies,
    MIN(CAST(NULLIF(icn.Number_rabies, '') AS DECIMAL(10,2))) AS min_rabies,
    MAX(CAST(NULLIF(icn.Number_rabies, '') AS DECIMAL(10,2))) AS max_rabies,
    SUM(CAST(NULLIF(icn.Number_rabies, '') AS DECIMAL(10,2))) AS sum_rabies
FROM infectious_cases_norm icn
JOIN entities e ON e.id = icn.entity_id
WHERE NULLIF(icn.Number_rabies, '') IS NOT NULL
GROUP BY e.entity, e.code
ORDER BY avg_rabies DESC
LIMIT 10;

/* -------------------------
   8. Date calculation from year
-------------------------- */
SELECT
    year,
    MAKEDATE(year, 1) AS year_start_date,
    CURDATE() AS today_date,
    TIMESTAMPDIFF(
        YEAR,
        MAKEDATE(year, 1),
        CURDATE()
    ) AS years_diff
FROM (SELECT DISTINCT year FROM infectious_cases_norm) t
ORDER BY year
LIMIT 20;

/* -------------------------
   9. User Defined Function
-------------------------- */
DROP FUNCTION IF EXISTS year_diff_from_now;

DELIMITER $$

CREATE FUNCTION year_diff_from_now(p_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(
        YEAR,
        MAKEDATE(p_year, 1),
        CURDATE()
    );
END$$

DELIMITER ;

/* -------------------------
   10. Use function
-------------------------- */
SELECT
    year,
    MAKEDATE(year, 1) AS year_start_date,
    CURDATE() AS today_date,
    year_diff_from_now(year) AS years_diff
FROM infectious_cases_norm
ORDER BY year
LIMIT 10;

