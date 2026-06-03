select
  items.id,
  items.title,
  items.description,
  profiles.name as author_name,
  items.score,
  items.city,
  items.postal_code,
  items.created_at::text as created_at,
  items.author_id
from items, profiles
where items.id = $1 and items.author_id = profiles.id