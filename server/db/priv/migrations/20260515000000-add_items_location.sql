--- migration:up
ALTER TABLE items ADD COLUMN location geography(Point, 4326);
--- migration:down
ALTER TABLE items DROP COLUMN location;
--- migration:end
