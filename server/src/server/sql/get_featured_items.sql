select
  items.id,
  items.title,
  items.description,
  profiles.name as author_name,
  items.score,
  items.city,
  items.postal_code,
  coalesce(
    st_distance(location, st_setsrid(st_makepoint($2, $1), 4326)::geography) / 1000,
    0.0
  ) as distance_km
from items, profiles
where items.author_id = profiles.id
order by score desc
