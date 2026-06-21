--- migration:up
ALTER TABLE items ADD COLUMN category TEXT NOT NULL DEFAULT 'Sonstiges';
--- migration:down
ALTER TABLE items DROP COLUMN category;
--- migration:end
