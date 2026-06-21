--- migration:up
ALTER TABLE items ADD COLUMN city text;
ALTER TABLE items ADD COLUMN postal_code text;
--- migration:down
ALTER TABLE items DROP COLUMN postal_code;
ALTER TABLE items DROP COLUMN city;
--- migration:end
