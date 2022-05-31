/*
* Author: WIDDOP, MATTHEW
* Student ID Number: [REDACTED]
* Institutional mail prefix: [REDACTED]
*/

/* *********************************************************
* Exercise 1. Create the Smoked Trout database
* 
************************************************************ */
-- 1) Create a database called SmokedTrout.
CREATE DATABASE "SmokedTrout";

-- 2) Connect to the database
\c SmokedTrout


/* *********************************************************
* Exercise 2. Implement the given design in the Smoked Trout database
* 
************************************************************ */

-- 1) Create a new ENUM type called materialState for storing the raw material state
CREATE TYPE "materialState" AS ENUM ('Solid','Liquid','Gas','Plasma');

-- 2) Create a new ENUM type called materialComposition for storing whether
-- a material is Fundamental or Composite.
CREATE TYPE "materialComposition" AS ENUM ('Fundamental','Composite');

-- 3) Create the table TradingRoute with the corresponding attributes.
CREATE TABLE "TradingRoute" (
	"MonitoringKey" SERIAL PRIMARY KEY,
	"FleetSize" int,
	"OperatingCompany" varchar(40),
	"LastYearRevenue" real NOT NULL
);

-- 4) Create the table Planet with the corresponding attributes.
CREATE TABLE "Planet" (
	"PlanetID" SERIAL PRIMARY KEY,
	"StarSystem" varchar(40),
	"Name" varchar(40),
	"Population" int
);

-- 5) Create the table SpaceStation with the corresponding attributes.
CREATE TABLE "SpaceStation" (
	"StationID" SERIAL PRIMARY KEY,
	"PlanetID" SERIAL REFERENCES "Planet"("PlanetID"),
	"Name" varchar(40),
	"Longitude" varchar(40),
	"Latitude" varchar(40)
);

-- 6) Create the parent table Product with the corresponding attributes.
CREATE TABLE "Product" (
	"ProductID" SERIAL PRIMARY KEY,
	"Name" varchar(40),
	"VolumePerTon" real,
	"ValuePerTon" real
);

-- 7) Create the child table RawMaterial with the corresponding attributes.
CREATE TABLE "RawMaterial" (
	"State" "materialState",
	"FundamentalOrComposite" "materialComposition",
	PRIMARY KEY ("ProductID")
) INHERITS ("Product");

-- 8) Create the child table ManufacturedGood. 
CREATE TABLE "ManufacturedGood" (
	PRIMARY KEY ("ProductID")
) INHERITS ("Product");

-- 9) Create the table MadeOf with the corresponding attributes.
CREATE TABLE "MadeOf" (
	"ManufacturedGoodID" SERIAL REFERENCES "ManufacturedGood"("ProductID"),
	"ProductID" SERIAL,
	PRIMARY KEY ("ManufacturedGoodID", "ProductID")
);

-- 10) Create the table Batch with the corresponding attributes.
CREATE TABLE "Batch" (
	"BatchID" SERIAL PRIMARY KEY,
	"ProductID" SERIAL,
	"ExtractionOrManufacturingDate" DATE,
	"OriginalFrom" SERIAL REFERENCES "Planet"("PlanetID")
);

-- 11) Create the table Sells with the corresponding attributes.
CREATE TABLE "Sells" (
	"SellID" SERIAL PRIMARY KEY,
	"BatchID" SERIAL REFERENCES "Batch"("BatchID"),
	"StationID" SERIAL REFERENCES "SpaceStation"("StationID")
);

-- 12)  Create the table Buys with the corresponding attributes.
CREATE TABLE "Buys" (
	"BuyID" SERIAL PRIMARY KEY,
	"BatchID" SERIAL REFERENCES "Batch"("BatchID"),
	"StationID" SERIAL REFERENCES "SpaceStation"("StationID")
);

-- 13)  Create the table CallsAt with the corresponding attributes.
CREATE TABLE "CallsAt" (
	"MonitoringKey" SERIAL REFERENCES "TradingRoute"("MonitoringKey"),
	"StationID" SERIAL REFERENCES "SpaceStation"("StationID"),
	"VisitOrder" int
);

-- 14)  Create the table Distance with the corresponding attributes.
CREATE TABLE "Distance" (
	"PlanetOrigin" SERIAL REFERENCES "Planet"("PlanetID"),
	"PlanetDestination" SERIAL REFERENCES "Planet"("PlanetID"),
	"Distance" real 
);


/* *********************************************************
* Exercise 3. Populate the Smoked Trout database
* 
************************************************************ */
/* *********************************************************
* NOTE: The copy statement is NOT standard SQL.
* The copy statement does NOT permit on-the-fly renaming columns,
* hence, whenever necessary, we:
* 1) Create a dummy table with the column name as in the file
* 2) Copy from the file to the dummy table
* 3) Copy from the dummy table to the real table
* 4) Drop the dummy table (This is done further below, as I keep
*    the dummy table also to imporrt the other columns)
************************************************************ */



-- 1) Unzip all the data files in a subfolder called data from where you have your code file 
-- NO CODE GOES HERE. THIS STEP IS JUST LEFT HERE TO KEEP CONSISTENCY WITH THE ASSIGNMENT STATEMENT

-- 2) Populate the table TradingRoute with the data in the file TradeRoutes.csv.
CREATE TABLE "Dummy" (
	"MonitoringKey" SERIAL,
	"FleetSize" int,
	"OperatingCompany" varchar(40),
	"LastYearRevenue" real NOT NULL
);

\copy "Dummy" FROM './data/TradeRoutes.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "TradingRoute" ("MonitoringKey", "OperatingCompany", "FleetSize", "LastYearRevenue")
SELECT "MonitoringKey", "OperatingCompany", "FleetSize", "LastYearRevenue" FROM "Dummy";

DROP TABLE "Dummy";

-- 3) Populate the table Planet with the data in the file Planets.csv.
CREATE TABLE "Dummy" (
	"PlanetID" SERIAL,
	"StarSystem" varchar(40),
	"Planet" varchar(40),
	"Population_inMillions_" int
);

\copy "Dummy" FROM './data/Planets.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "Planet" ("PlanetID", "StarSystem", "Name", "Population") 
SELECT "PlanetID", "StarSystem", "Planet", "Population_inMillions_" FROM "Dummy";

DROP TABLE "Dummy";

-- 4) Populate the table SpaceStation with the data in the file SpaceStations.csv.
CREATE TABLE "Dummy" (
	"StationID" SERIAL,
	"PlanetID" SERIAL,
	"SpaceStations" varchar(40),
	"Longitude" varchar(40),
	"Latitude" varchar(40)
);

\copy "Dummy" FROM './data/SpaceStations.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "SpaceStation" ("StationID", "PlanetID", "Name", "Longitude", "Latitude")
SELECT "StationID", "PlanetID", "SpaceStations", "Longitude", "Latitude" FROM "Dummy";

DROP TABLE "Dummy";

-- 5) Populate the tables RawMaterial and Product with the data in the file Products_Raw.csv. 
CREATE TABLE "Dummy" (
	"ProductID" SERIAL,
	"Product" varchar(40),
	"Composite" varchar(40),
	"VolumePerTon" real,
	"ValuePerTon" real,
	"State" "materialState"
);

\copy "Dummy" FROM './data/Products_Raw.csv' WITH (FORMAT CSV, HEADER);

UPDATE "Dummy" SET "Composite" = 'Composite' WHERE "Composite" = 'Yes';
UPDATE "Dummy" SET "Composite" = 'Fundamental' WHERE "Composite" = 'No';

ALTER TABLE "Dummy" ADD COLUMN "FundamentalOrComposite" "materialComposition";
UPDATE "Dummy" SET "FundamentalOrComposite" = Cast("Dummy"."Composite" AS "materialComposition");

INSERT INTO "RawMaterial" ("ProductID", "Name", "VolumePerTon", "ValuePerTon", "State", "FundamentalOrComposite")
SELECT "ProductID", "Product", "VolumePerTon", "ValuePerTon", "State", "FundamentalOrComposite" FROM "Dummy";

DROP TABLE "Dummy";

-- 6) Populate the tables ManufacturedGood and Product with the data in the file  Products_Manufactured.csv.
CREATE TABLE "Dummy" (
	"ProductID" SERIAL,
	"Product" varchar(40),
	"VolumePerTon" real,
	"ValuePerTon" real
);

\copy "Dummy" FROM './data/Products_Manufactured.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "ManufacturedGood" ("ProductID", "Name", "VolumePerTon", "ValuePerTon")
SELECT "ProductID", "Product", "VolumePerTon", "ValuePerTon" FROM "Dummy";

DROP TABLE "Dummy";

-- 7) Populate the table MadeOf with the data in the file MadeOf.csv.
CREATE TABLE "Dummy" (
	"ManufacturedGoodID" SERIAL,
	"ProductID" SERIAL
);

\copy "Dummy" FROM './data/MadeOf.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "MadeOf" ("ManufacturedGoodID", "ProductID")
SELECT "ManufacturedGoodID", "ProductID" FROM "Dummy";

DROP TABLE "Dummy";

-- 8) Populate the table Batch with the data in the file Batches.csv.
CREATE TABLE "Dummy" (
	"BatchID" SERIAL,
	"ProductID" SERIAL,
	"ExtractionOrManufacturingDate" DATE,
	"OriginalFrom" SERIAL
);

\copy "Dummy" FROM './data/Batches.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "Batch" ("BatchID", "ProductID", "ExtractionOrManufacturingDate", "OriginalFrom")
SELECT "BatchID", "ProductID", "ExtractionOrManufacturingDate", "OriginalFrom" FROM "Dummy";

DROP TABLE "Dummy";

-- 9) Populate the table Sells with the data in the file Sells.csv.
CREATE TABLE "Dummy" (
	"BatchID" SERIAL,
	"StationID" SERIAL
);

\copy "Dummy" FROM './data/Sells.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "Sells" ("BatchID", "StationID") SELECT "BatchID", "StationID" FROM "Dummy";

DROP TABLE "Dummy";

-- 10) Populate the table Buys with the data in the file Buys.csv.
CREATE TABLE "Dummy" (
	"BatchID" SERIAL,
	"StationID" SERIAL
);

\copy "Dummy" FROM './data/Buys.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "Buys" ("BatchID", "StationID") SELECT "BatchID", "StationID" FROM "Dummy";

DROP TABLE "Dummy";

-- 11) Populate the table CallsAt with the data in the file CallsAt.csv.
CREATE TABLE "Dummy" (
	"MonitoringKey" SERIAL,
	"StationID" SERIAL,
	"VisitOrder" int
);

\copy "Dummy" FROM './data/CallsAt.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "CallsAt" ("MonitoringKey", "StationID", "VisitOrder")
SELECT "MonitoringKey", "StationID", "VisitOrder" FROM "Dummy";

DROP TABLE "Dummy";

-- 12) Populate the table Distance with the data in the file PlanetDistances.csv.
CREATE TABLE "Dummy" (
	"PlanetOrigin" SERIAL,
	"PlanetDestination" SERIAL,
	"Distance" real
);

\copy "Dummy" FROM './data/PlanetDistances.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "Distance" ("PlanetOrigin", "PlanetDestination", "Distance")
SELECT "PlanetOrigin", "PlanetDestination", "Distance" FROM "Dummy";

DROP TABLE "Dummy";


/* *********************************************************
* Exercise 4. Query the database
* 
************************************************************ */

-- 4.1 Report last year taxes per company
-- 1) Add an attribute Taxes to table TradingRoute
ALTER TABLE "TradingRoute" ADD COLUMN "Taxes" real GENERATED ALWAYS AS ("LastYearRevenue" * 0.12) STORED; 

-- 2) Set the derived attribute taxes as 12% of LastYearRevenue
-- DONE IN PREVIOUS STEP.


-- 3) Report the operating company and the sum of its taxes group by company.
SELECT "OperatingCompany", SUM("Taxes") FROM "TradingRoute" GROUP BY "OperatingCompany";




-- 4.2 What's the longest trading route in parsecs?
-- 1) Create a dummy table RouteLength to store the trading route and their lengths.
CREATE TABLE "RouteLength" (
	"MonitoringKey" SERIAL REFERENCES "TradingRoute"("MonitoringKey"),
	"Length" real
);


-- 2) Create a view EnrichedCallsAt that brings together trading route, space stations and planets.
CREATE VIEW "EnrichedCallsAt" AS SELECT * FROM "CallsAt" INNER JOIN "SpaceStation" USING ("StationID");


-- 3) Add the support to execute an anonymous code block as follows;
DO
$$
DECLARE


-- 4) Within the declare section, declare a variable of type real to store a route total distance.
"routeDistance" real := 0.0;


-- 5) Within the declare section, declare a variable of type real to store a hop partial distance.
"hopPartialDistance" real := 0.0;


-- 6) Within the declare section, declare a variable of type record to iterate over routes.
"rRoute" record;


-- 7) Within the declare section, declare a variable of type record to iterate over hops.
"rHop" record;


-- 8) Within the declare section, declare a variable of type text to transiently build dynamic queries.
"query" text;


-- 9) Within the main body section, loop over routes in TradingRoutes
BEGIN
FOR "rRoute" IN (SELECT "MonitoringKey" FROM "TradingRoute") 
LOOP

-- 10) Within the loop over routes, get all visited planets (in order) by this trading route.
"query" := 'CREATE VIEW "PortsOfCall" AS
			SELECT "PlanetID", "VisitOrder"
			FROM "EnrichedCallsAt"
			WHERE "MonitoringKey" = ' || "rRoute"."MonitoringKey" || '
			ORDER BY "VisitOrder"';


-- 11) Within the loop over routes, execute the dynamic view
EXECUTE "query";


-- 12) Within the loop over routes, create a view Hops for storing the hops of that route. 
CREATE VIEW "Hops" AS 
	SELECT p1."PlanetID" AS "OriginID", p2."PlanetID" AS "DestinationID", p1."VisitOrder"
	FROM "PortsOfCall" p1
	INNER JOIN "PortsOfCall" p2 ON p2."VisitOrder" = p1."VisitOrder" + 1
	ORDER BY p1."VisitOrder";


-- 13) Within the loop over routes, initialize the route total distance to 0.0.
"routeDistance" := 0;


-- 14) Within the loop over routes, create an inner loop over the hops
FOR "rHop" IN (SELECT "OriginID", "DestinationID" FROM "Hops") 
LOOP


-- 15) Within the loop over hops, get the partial distances of the hop. 
"query" := 'SELECT "Distance" FROM "Distance" 
			WHERE "PlanetOrigin" = ' || "rHop"."OriginID" || ' 
			AND "PlanetDestination" = ' || "rHop"."DestinationID";


-- 16)  Within the loop over hops, execute the dynamic view and store the outcome INTO the hop partial distance.
EXECUTE "query" INTO "hopPartialDistance";


-- 17)  Within the loop over hops, accumulate the hop partial distance to the route total distance.
"routeDistance" := "routeDistance" + "hopPartialDistance";
END LOOP;


-- 18)  Go back to the routes loop and insert into the dummy table RouteLength the pair (RouteMonitoringKey,RouteTotalDistance).
INSERT INTO "RouteLength" VALUES ("rRoute"."MonitoringKey", "routeDistance");


-- 19)  Within the loop over routes, drop the view for Hops (and cascade to delete dependent objects).
DROP VIEW "Hops";


-- 20)  Within the loop over routes, drop the view for PortsOfCall (and cascade to delete dependent objects).
DROP VIEW "PortsOfCall";

END LOOP;
END;
$$;


-- 21)  Finally, just report the longest route in the dummy table RouteLength.
SELECT "MonitoringKey", "Length" FROM "RouteLength" 
WHERE "Length" = (SELECT MAX("Length") FROM "RouteLength");