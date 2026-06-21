--- migration:up

CREATE TABLE item_images (
  id UUID PRIMARY KEY,
  item_id INTEGER NOT NULL REFERENCES items(id) ON DELETE CASCADE,
  original_name TEXT NOT NULL,
  mime_type TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_item_images_item_id ON item_images(item_id);

--- migration:down

DROP TABLE item_images;

--- migration:end
