-- Active: 1747414017305@@127.0.0.1@5432@conservation_db
CREATE DATABASE conservation_db;

CREATE TABLE rangers(
    renger_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT null
);
CREATE TABLE species(
    species_id SERIAL PRIMARY KEY,
    common_name VARCHAR(100) NOT NULL,
    scientific_name VARCHAR(100) NOT NULL,
    discovery_date DATE NOT NULL,
    conservation_status VARCHAR(50) NOT NULL
);
CREATE TABLE sightings(
    sightings_id SERIAL PRIMARY KEY,
    species_id INT REFERENCES species(species_id) ON DELETE CASCADE,
    renger_id INT REFERENCES rangers(renger_id) ON DELETE CASCADE,
    location VARCHAR(100) NOT NULL,
    sighting_time TIMESTAMP NOT NULL,
    note TEXT
);

-- DATA FOR RANGERS
INSERT INTO rangers (name, region) VALUES
('Alice Green', 'Northern Hills'),
('Bob White', 'River Delta'),
('Carol King', 'Mountain Range'),
('David Singh', 'Eastern Plains'),
('Emma Brooks', 'Rainforest Edge'),
('Farhan Ali', 'Desert Dunes'),
('Grace Wong', 'Wetlands Reserve'),
('Hassan Yadav', 'Coastal Belt');
-- DATA FOR species
INSERT INTO species (common_name, scientific_name, discovery_date, conservation_status) VALUES
('Snow Leopard', 'Panthera uncia', '1775-01-01', 'Endangered'),
('Bengal Tiger', 'Panthera tigris tigris', '1758-01-01', 'Endangered'),
('Red Panda', 'Ailurus fulgens', '1825-01-01', 'Vulnerable'),
('Asiatic Elephant', 'Elephas maximus indicus', '1758-01-01', 'Endangered'),
('Indian Pangolin', 'Manis crassicaudata', '1822-01-01', 'Vulnerable'),
('Blackbuck', 'Antilope cervicapra', '1827-01-01', 'Least Concern'),
('Sloth Bear', 'Melursus ursinus', '1791-01-01', 'Vulnerable'),
('Great Indian Bustard', 'Ardeotis nigriceps', '1864-01-01', 'Critically Endangered');
-- DATA FOR sightings
INSERT INTO sightings (species_id, renger_id, location, sighting_time, note) VALUES
(1, 1, 'Peak Ridge', '2024-05-10 07:45:00', 'Camera trap image captured'),
(2, 2, 'Bankwood Area', '2024-05-12 16:20:00', 'Juvenile seen'),
(3, 3, 'Bamboo Grove East', '2024-05-15 09:10:00', 'Feeding observed'),
(1, 2, 'Snowfall Pass', '2024-05-18 18:30:00', NULL),
(5, 6, 'River Bend', '2024-05-19 06:30:00', 'Tracks found'),
(2, 5, 'Open Grasslands', '2024-05-20 08:00:00', 'Herd grazing'),
(7, 6, 'Rocky Hills', '2024-05-21 17:00:00', 'Roaring heard'),
(8, 7, 'Dry Scrub Area', '2024-05-22 06:10:00', 'Rare sighting'),
(4, 1, 'Forest Trail', '2024-05-23 09:45:00', 'Mother with calf seen'),
(2, 3, 'Delta Edge', '2024-05-24 11:15:00', 'Territorial markings'),
(3, 8, 'Eastern Bamboo Zone', '2024-05-25 10:00:00', NULL),
(5, 5, 'Wetland Border', '2024-05-25 12:30:00', 'Burrow entrance spotted');



-- Problem Solving 1 
INSERT INTO rangers(name,region) VALUES
('Derek Fox','Coastal Plains');


-- Problem Solving 2            Count unique species ever sighted.
SELECT count(DISTINCT species_id) FROM sightings ;


-- Problem Solving 3    Find all sightings where the location includes "Pass".
SELECT * FROM  sightings WHERE location ILIKE ('%%Pass%%');

-- Problem Solving 4    List each ranger's name and their total number of sightings.
SELECT rangers.name, count(sightings.sightings_id)AS total_sightings FROM rangers  
 JOIN sightings ON rangers.renger_id = sightings.renger_id 
GROUP BY rangers.renger_id  ORDER BY rangers.renger_id ; 

-- Problem solving 5     List species that have never been sighted.
SELECT common_name FROM species 
LEFT JOIN sightings ON species.species_id = sightings.species_id  WHERE sightings.species_id IS NULL;


-- Problem Solving 6     Show the most recent 2 sightings.
SELECT common_name,sighting_time,name FROM  sightings 
JOIN species ON sightings.species_id = species.species_id 
JOIN rangers ON sightings.renger_id = rangers.renger_id 
ORDER BY sightings.sighting_time DESC LIMIT 2 ;

-- Prolbem solving 7     Update all species discovered before year 1800 to have status 'Historic'.
UPDATE species SET conservation_status ='Historic' WHERE extract(YEAR FROM discovery_date) < '1800' ;

-- Problem Solving 8      Label each sighting's time of day as 'Morning', 'Afternoon', or 'Evening'.
CREATE OR REPLACE FUNCTION setLabel(ts TIMESTAMP)
RETURNS TEXT 
LANGUAGE plpgsql
AS
$$
DECLARE 
    hr INTEGER;
    result TEXT;
        BEGIN 
            hr :=  EXTRACT(HOUR FROM ts);
            IF hr < 12 THEN  result  := 'Morning';
            ELSEIF hr < 12 AND hr < 17 THEN result  := 'Afternoon';
            ELSE  result := 'Evening'; 
            END IF ;
         RETURN result ;
        END;
$$;
SELECT sightings_id, setLabel(sighting_time) AS  time_of_day
  FROM sightings;


-- Problem Solving 9     Delete rangers who have never sighted any species
DELETE FROM rangers 
WHERE NOT EXISTS(
    SELECT 1 FROM sightings WHERE sightings.renger_id = rangers.renger_id
);


SELECT * FROM  rangers ;
SELECT * FROM  species ;
SELECT * FROM  sightings;
