--- migration:up

ALTER TABLE items DROP COLUMN author_name;
ALTER TABLE items ADD COLUMN author_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE;

CREATE INDEX idx_author_id ON items(author_id);

--- migration:down

ALTER TABLE items ADD COLUMN author_name TEXT NOT NULL;
ALTER TABLE items DROP COLUMN author_id;

--- migration:end

