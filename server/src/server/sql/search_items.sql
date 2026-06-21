select
  items.id,
  items.title,
  items.description,
  profiles.name as author_name,
  items.author_id,
  items.score,
  items.city,
  items.postal_code,
  items.category,
  coalesce(
    st_distance(location, st_setsrid(st_makepoint($2, $1), 4326)::geography) / 1000,
    0.0
  ) as distance_km,
  first_img.id as first_image_uuid
from items, profiles
left join lateral (
  select id
  from item_images
  where item_images.item_id = items.id
  order by sort_order, created_at
  limit 1
) as first_img on true
where items.author_id = profiles.id
  and ($3 = '' or items.title ilike '%' || $3 || '%' or items.description ilike '%' || $3 || '%')
  and ($4 = '' or items.category = any(string_to_array($4, ',')))
  and ($5 = 0.0 or items.score >= $5)
  and ($6 = 0.0 or coalesce(st_distance(location, st_setsrid(st_makepoint($2, $1), 4326)::geography) / 1000, 0.0) <= $6)
order by
  case $7
    when 'distance' then coalesce(st_distance(location, st_setsrid(st_makepoint($2, $1), 4326)::geography) / 1000, 0.0)
    when 'score' then items.score
    when 'newest' then extract(epoch from items.created_at)
    else items.score
  end desc
