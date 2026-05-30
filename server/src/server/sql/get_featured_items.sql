select
  id,
  title,
  description,
  author_name,
  score,
  city,
  postal_code,
  coalesce(
    st_distance(location, st_setsrid(st_makepoint($2, $1), 4326)::geography) / 1000,
    0.0
  ) as distance_km
from
  items
order by
  score desc
