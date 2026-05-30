select
  items.id,
  items.title,
  items.description,
  profiles.name as author_name,
  items.score,
  items.city,
  items.postal_code
from items, profiles
where items.author_id = profiles.id
order by score desc
